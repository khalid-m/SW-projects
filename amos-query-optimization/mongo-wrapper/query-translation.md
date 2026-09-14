# How an AmosQL query becomes a MongoDB query

A walkthrough of the two files that do the query processing:
`mongo_query_processor.amosql` and `mongo_optimizer.lsp`. Together they are
the **translator** half of the wrapper — the part that decides which
predicates MongoDB can evaluate and turns them into a BSON filter document.

Companion to [`README.md`](README.md), which surveys the whole directory.
This page goes function by function.

> **Unverified.** The wrapper cannot be loaded on the tested build (no
> compiled DLL — see [`README.md`](README.md#status-unverified-and-blocked)),
> so everything below is read from source. Claims about *what the code does*
> are traceable to the listings; claims about *what AMOS II does with it* rest
> on the registration API, which is undocumented in `rewrite.txt`.

## The idea: mediators and wrappers

Worth reading before the code, because both files make far more sense once
the problem they solve is clear.

### The problem

You have a query engine that knows nothing about MongoDB, and a MongoDB
server that knows nothing about AmosQL. A user wants to write:

```sql
select p from Person p where age(p) > 30 and age(p) <= 50;
```

where `Person` lives in a MongoDB collection. What MongoDB itself needs is:

```javascript
db.person.find({ age: { $gt: 30, $lte: 50 } })
```

and the same thing through AMOS II's foreign functions, with no wrapper
involved, is:

```sql
mongo_query(:c, "tutorial", "person", {"age": {"$gt": 30, "$lte": 50}});
```

Two obvious approaches, both bad:

| Approach | Problem |
|---|---|
| Pull the whole collection into AMOS II, filter locally | Correct, but transfers every document to discard most of them |
| Make the user hand-write MongoDB filters | Fast, but the query is no longer declarative, cannot span sources, and the optimizer cannot reason about it |

The second is what `examples/test.osql` does — every call there names a
database, a collection and an explicit filter record. Useful for testing the
interface, useless as a query language.

### What you get to write

The point of the whole exercise, stated as a before and after.

**Without the wrapper** — what `examples/test.osql` does. Every call names a
connection, a database, a collection, and a filter record by hand:

```sql
mongo_get(:c, "tutorial", "person", {"age": 27});
```

**With the wrapper**, after importing the collection once:

```sql
import_mongo_collection(:ds, "tutorial", "person", "Person");

select p["_id"] from Person p where p["age"] > 10 and p["age"] < 20;
```

Nothing in that query mentions MongoDB, a connection, a collection, or a
filter document. `Person` is a type, `p["age"]` is an attribute, `>` is a
comparison — and the wrapper turns the two bounds into
`{"$and": [{"age":{"$gt":10}}, {"age":{"$lt":20}}]}` and sends it.

Three points of syntax, since the query is not quite SQL:

**The type name is chosen at import**, independently of the collection name —
`"Person"` is the fourth argument above, `"person"` the third.

**AmosQL is functional, so there is no implicit row scope.** A bare `age`
has nothing to attach to; attributes are functions applied to an object.

**`p["age"]` rather than `age(p)`**, because the wrapper generates a single
*generic* accessor rather than one function per field:

```sql
create function vref(Person r, Charstring a) -> Object as value(r)[a];
```

`p["age"]` is sugar for `vref(p, "age")`. Nothing generates an `age`
function, and nothing can — MongoDB documents are schemaless, so the fields
are not known at import time.

If you want the `age(p)` form, define it yourself in one line:

```sql
create function age(Person p) -> Integer as p["age"];
```

It pushes down identically, and the reason is worth knowing early.

#### Why every form pushes down equally

The extractor matches exactly one thing:

```lisp
(defglobal _record-vref_ (theresolvent 'record.charstring.vref->object))
```

`vref` on a **`Record`** — not on `Person`, and not on your `age` function.
Yet all three spellings work, because of `rewrite.txt` §3:

> all views are expanded when the TBR-rules are applied

By the time the extractor runs, `age(p)` has expanded to `p["age"]`, which
expanded to `value(p)["age"]`, which is a `record.charstring.vref` predicate
on the record variable the source predicate produced. One matcher covers
every layer of sugar above it — which is why the wrapper needs no knowledge
of how users choose to name their accessors.

*(Predicted from the code. The wrapper does not load here, so no transcript
backs this.)*

### The mediator idea

A **mediator** sits between users and data sources and presents the sources
*as if they were local*. The user writes one declarative query; the system
works out which parts can be answered where, sends those parts, and combines
the results. AMOS II is a **functional mediator** — sources appear as
ordinary AmosQL functions and types.

The goal is stated most simply by what the user gets to write. Nothing in the
query above mentions MongoDB, a connection, a collection, or a filter
document. `Person` is a type, `age` is a function, `>` is a comparison. All
the MongoDB-specific knowledge lives in the wrapper.

*(Background: `../../Amos-II-docs/FuncMedPaper.pdf`, "Functional Data
Integration in a Distributed Mediator System", is the architecture paper.
The 1992 paper summarised in
[`../litwin-risch-1992-objectlog.md`](../litwin-risch-1992-objectlog.md)
predates this layer — it has foreign predicates but no mediator.)*

### What a wrapper is

`rewrite.txt` §1 defines it as two subsystems:

> 1) An **INTERFACE** that accesses the external data source through a set of
>    foreign functions … Typically the query interface accepts parameters as
>    an input and delivers the result as a bag (or stream) of vectors
>    representing tuples.
>
> 2) A **TRANSLATOR** that translates the internal S-expression-based
>    predicate TBR representation in Amos II to calls to the interface
>    functions. Often query strings in the query language of the data source
>    are generated as arguments of the interface functions.

For this wrapper:

| | Role | Files |
|---|---|---|
| **Interface** | *can* we talk to MongoDB at all? | `MongoForeign.c`, `mongo_interface.amosql` |
| **Translator** | *what* should we ask it, for this query? | `mongo_query_processor.amosql`, `mongo_optimizer.lsp` |

The interface is the easy half — connect, send a filter, get documents back.
This page is about the other half.

### Why translation is an optimization problem

It would be natural to expect a translator to be a compiler: walk the query,
emit MongoDB. It cannot be, for three reasons.

**What can be sent depends on what is already known.** A comparison can go
into a MongoDB filter only if one side is a constant or an already-bound
variable — and whether a variable is bound depends on the execution order,
which the optimizer has not decided yet. Translation and ordering cannot be
separated.

Three cases make the point, assuming two imported collections:

```sql
import_mongo_collection(:ds, "tutorial", "person",   "Person");
import_mongo_collection(:ds, "tutorial", "employee", "Employee");
```

**(a) Constant — always extractable.**

```sql
select p from Person p
 where p["age"] > 30;
```

`30` is a literal, so `{"age": {"$gt": 30}}` can be built at compile time.

**(b) Correlated — extractable only in one ordering.**

```sql
select p, q from Person p, Employee q
 where q["dept"] = "sales"
   and p["age"] > q["salary"];
```

| Ordering | Is `q["salary"]` bound when `Person` is accessed? | Result |
|---|---|---|
| `Employee` first | yes | comparison **is** extracted → `{"age": {"$gt": S}}` |
| `Person` first | no | comparison stays behind as a post-filter |

Note what the filter contains in the first case: a **variable**, not a
constant. That is what the `substv` branch of the finalizer exists for —

```lisp
(setq rvars (variables-in-record compl))
```

is non-empty, so the value is substituted into the record at run time before
`mongo_query` is called. Were only constants ever pushable, that branch would
be dead code.

`q["dept"] = "sales"` earns its place in the example: it makes `Employee`
look selective, which is what would lead the cost model to schedule it first
— and that ordering is what makes the correlated comparison pushable.

#### Which comes first, cost or ordering?

Neither. It looks circular — ordering decides what is extractable, extraction
decides the cost, cost decides the ordering — but the loop is resolved
**incrementally**, one predicate at a time. What comes first is the *prefix*
of the ordering already fixed:

```
fixed prefix so far
      ↓ determines
bound variables (bnd)
      ↓ extractor: what can MongoDB take, given these bindings?
extractable subset
      ↓ cost model: what does that subset cost?
(cost fanout)
      ↓ optimizer compares this candidate against the alternatives
next predicate chosen  →  prefix grows, bnd grows
```

At the start the prefix is empty and only the query's literals are bound.
Each step adds bindings, which can make extractable what was not before —
case (b) above is exactly that: `q["salary"]` becomes pushable the moment
`Employee` joins the prefix.

The circularity also dissolves once two different things stop sharing the
name *translation*:

| | When | How often | Purpose |
|---|---|---|---|
| **Provisional extraction** | during the search | once per candidate, many times | to obtain a price |
| **Final translation** | after the search | once | to build the actual `mongo_query` |

Only the first feeds back into cost. The finalizer runs on the ordering that
already won and influences nothing.

That is why these are three registered functions rather than one, and why the
cost model is as coarse as it is: `mongo-extractor` and `mongo-costmodel` sit
in the optimizer's inner loop, while `mongo-finalizer` does the expensive BSON
assembly exactly once.

*(The per-candidate call protocol is inferred from the hook signatures —
`mongo-costmodel` takes `bnd`, and inspects a filter that extraction must
already have determined. It is not documented in `rewrite.txt`.)*

**(c) Two fields of one document — never expressible.**

```sql
select p from Person p
 where p["age"] > p["children"];
```

MongoDB's plain filter syntax compares a field to a *value*, not to another
field; this needs `$expr` or `$where`, neither of which the wrapper emits.

The code handles it, but by luck rather than design. The **extractor** claims
this predicate, because `known-vars` includes the attribute variables:

```lisp
(known-vars (adjoin rvar (union attr-vars bnd)))
```

so both fields' variables count as known. But `generate-mongo-query` runs
against the *true* bound set `bnd`, where neither is bound, so no clause
matches and the predicate falls through into `remaining` — a post-filter.
The answer is correct; the cost model was simply told this access was better
than it is.

*(That asymmetry — extractor widened, filter generator not — is a reading of
the source, not a run.)*

**Sending more is usually better, but not always possible.** A source may
support each condition individually and not their combination — the exact
complaint `rewrite.txt` §1 raises against capability lists. So the translator
must be able to send *part* of a conjunction and leave the rest behind.

**The result has to be comparable with local alternatives.** The optimizer is
choosing between plans. A MongoDB access must be priced in the same currency
as an in-memory hash lookup, or it cannot be weighed against one.

So translation runs **inside** the optimizer, and must answer the optimizer's
questions in the optimizer's terms.

### The three hooks

Which gives exactly the three functions this wrapper registers:

| Question the optimizer asks | Hook | Answers with |
|---|---|---|
| *Which of these predicates could you handle?* | **extractor** | a split: taken / remaining |
| *What would that cost me?* | **cost model** | a `(cost fanout)` pair, or `nil` for impossible |
| *Fine — build it.* | **finalizer** | the predicates replaced by a `mongo_query` call |

They are called at different moments. The extractor and cost model run
**during** the search, possibly many times, as the optimizer tries orderings.
The finalizer runs **once**, on the ordering that won.

That timing explains a design detail: the cost model is deliberately
coarse — four tiers, no selectivity estimation — because it runs in the
optimizer's inner loop, while the finalizer does the real work of assembling
a BSON document exactly once.

### Why two languages

The split between the `.amosql` and `.lsp` files is not stylistic.

**AmosQL** can declare functions, types and stored metadata. That is what
schema-level work needs: a `Mongo` type, a connection, a generated function
per collection, annotations recording which collection a function stands for.

**Lisp** is where the optimizer's internal representation lives. ObjectLog
predicates are S-expressions — `(#[OID …] X 1)` — and AmosQL has no way to
take one apart. Anything that inspects a conjunction, tests a binding
pattern, or builds a replacement predicate must be Lisp.

So: **AmosQL declares and registers; Lisp inspects and rewrites.** The same
division as in [`../query-rewrite/`](../query-rewrite/), where the rewrite
rule had to be Lisp for exactly the same reason.

### What to look for while reading

Three threads run through both files, and following them makes the rest
straightforward:

1. **The record variable.** Everything the translator does is anchored on the
   variable holding a MongoDB document. Which predicates touch it? Which of
   those can MongoDB evaluate?
2. **What counts as "known".** The extractor widens the usual notion of bound
   to include *fields MongoDB will produce* — the move that makes field
   comparisons extractable at all.
3. **The function object as a key.** A predicate carries the function object,
   and that object is what the annotations `mongo_database` and
   `mongo_collection` hang on. It is the thread connecting a predicate in
   some conjunction back to a specific collection on a specific server.

## Division of labour

The two files are two halves of one mechanism:

| | `mongo_query_processor.amosql` | `mongo_optimizer.lsp` |
|---|---|---|
| Language | AmosQL | ALisp |
| Runs | once, at load and at import time | every time a query is optimized |
| Job | declare the wrapper, generate per-collection functions, **register the hooks** | **implement the hooks** |
| Knows about | data sources, types, connections | ObjectLog predicates, binding patterns, BSON |

The join between them is three lines at the bottom of the AmosQL file:

```sql
load_lisp("mongo_optimizer.lsp");

set_extractor('Mongo', 'mongo-extractor');
set_finalizer('Mongo', 'mongo-finalizer');
set_costmodel('Mongo', 'mongo-costmodel');
```

Same shape as `ADD-REWRITER` in
[`../query-rewrite/building-a-rewrite-rule.md`](../query-rewrite/building-a-rewrite-rule.md):
name a Lisp function to the optimizer. The difference is granularity — a
rewriter is registered per (predicate function, binding pattern), these are
registered **per data source**, and they see the whole conjunction.

---

# Part 1 — `mongo_query_processor.amosql`

## Declaring the wrapper

```sql
new_wrapper("Mongo");
```

One call, and a lot follows from it. It creates a `Mongo` type whose
instances are data sources, and it is what makes `set_extractor('Mongo', …)`
meaningful later.

## Connections

```sql
create function mongo_connid(Datasource c) -> Integer as stored;

create function connect(Mongo m, Charstring host) -> Integer
    as begin set mongo_connid(m) = mongo_connect(host);
             return mongo_connid(m);
       end;

create function mongo_connid_named(Charstring ds) -> Number
  as mongo_connid(datasource_named("Mongo",ds));
```

`connect` is an **overload on the generic `connect`** — AMOS II presumably
calls it when a `Mongo` data source is connected, which is why the signature
leads with `Mongo m` rather than being named `mongo_connect_ds`. The integer
it stores is the C-level connection slot from `MongoForeign.c`.

`mongo_connid_named` matters more than it looks: the generated functions
below are **text**, and text can only refer to a data source by name. This is
the lookup that turns a name back into a live connection at run time.

## Per-source-predicate metadata

```sql
create function mongo_database(Function sp) -> Charstring as stored;
create function mongo_collection(Function sp) -> Charstring as stored;
```

Note the argument type: **`Function`**. These attach a database and
collection name *to a function object*. That is how the Lisp finalizer, which
sees only ObjectLog predicates, recovers which MongoDB collection a predicate
refers to:

```lisp
(defun mongo-database (sp)
  (caar (getfunction 'mongo_database (list sp))))
```

A stored function used as an annotation on another function — worth noticing
as a technique, and the reason the two halves can stay so loosely coupled.

## Generating a source predicate per collection

> **What a source predicate is.** The ObjectLog predicate standing for *the
> contents of the external source* — the generator in a conjunction, as
> opposed to the predicates that filter what it produces.
>
> You have met the idea already. For a local stored function AMOS II
> generates a **predicate function**, `P_INTEGER.BAR->INTEGER` for `bar`, and
> that is what appears in a conjunction and what rewrite rules attach to. A
> source predicate is the same role for a wrapped external source, except the
> wrapper has to generate it.
>
> In a query over an imported type the conjunction looks like
>
> ```
> person_sourcepred(id, r)   ← generator: produces documents
> vref(r, "age", A)          ← accessor
> (> A 30)                   ← filter
> ```
>
> Only the first is tied to a data source, so only it can tell the finalizer
> *which* database and collection to query — through the
> `mongo_database(Function sp)` annotation set at import time. The rest are
> candidates to fold into the filter.
>
> As a predicate it is a list — function object, then arguments — so the
> optimizer picks it apart positionally:
>
> ```lisp
> (rvar (third sp))    ; the record variable: the document
> (kval (second sp))   ; the key, when bound
> ```
>
> Everything the extractor does is anchored on `rvar`, which is why
> `mongo-finalizer` opens by locating it with `(get-sourcepred predl)`.

The core of the file. `create_mongo_sourcepred` builds AmosQL **source text**
and runs it through `eval`:

```sql
create function <coll>_sourcepred () -> Bag of (Object id key, Record v key)
  as multidirectional
     ('fb' key select r['_id'] from Record r
            where r in mongo_query(mongo_connid_named('<ds>'),
                                   '<db>', '<coll>', v))
     ('bf' key select mongo_get(mongo_connid_named('<ds>'),
                                '<db>', '<coll>', id))
     ('ff' select mongo_kvp(mongo_connid_named('<ds>'), '<db>', '<coll>'));
```

One function per imported collection, with the data source, database and
collection names **baked into the generated text** as literals. That is why
`eval` is needed at all: AmosQL has no way to parameterise a
`multidirectional` declaration.

Three binding patterns, three physical access paths:

| Pattern | Bound | Strategy | Cost implication |
|---|---|---|---|
| `bf` | the id | `mongo_get` — fetch one document by `_id` | cheapest |
| `fb` | the record | `mongo_query` with the record as filter | selective |
| `ff` | nothing | `mongo_kvp` — read the whole collection | a scan |

`key` on the first two declares them as key lookups, so the optimizer knows
the fanout is one.

The `ff` helper is where the scan lives:

```sql
create function mongo_kvp (Number conn, Charstring db, Charstring coll)
                         -> Bag of (Literal id key, Record value key)
  as select r['_id'], r from Record r
     where r in mongo_query(conn, db, coll, empty_record());
```

An empty filter record — MongoDB's "match everything".

This is the multi-directional foreign function of Litwin & Risch 1992 §5
([notes](../litwin-risch-1992-objectlog.md)), applied to a document store:
one logical relation, three implementations, the optimizer choosing by cost.

### Worked: what gets generated for one collection

Take the collection used throughout `examples/test.osql`:

```sql
import_mongo_collection(:ds, "tutorial", "person", "Person");
```

`create_mongo_sourcepred("MyMongo", "tutorial", "person")` substitutes those
strings into the template and evaluates the result:

```sql
create function person_sourcepred () -> Bag of (Object id key, Record v key)
  as multidirectional
     ('fb' key select r['_id'] from Record r
            where r in mongo_query(mongo_connid_named('MyMongo'),
                                   'tutorial', 'person', v))
     ('bf' key select mongo_get(mongo_connid_named('MyMongo'),
                                'tutorial', 'person', id))
     ('ff' select mongo_kvp(mongo_connid_named('MyMongo'),
                            'tutorial', 'person'));
```

Note that `'MyMongo'`, `'tutorial'` and `'person'` are now **literals in the
function body**. Nothing is passed in at query time; each imported collection
gets its own function with its own coordinates hard-coded.

#### The function object

`eval` returns the new function, which `import_mongo_collection` binds to
`extfn` and annotates:

```sql
set extfn = create_mongo_sourcepred(name(ds), db, mongocoll);
…
set datasource(extfn) = ds;
set mongo_database(extfn) = "tutorial";
set mongo_collection(extfn) = "person";
```

So `extfn` is the `person_sourcepred` function object, carrying three stored
annotations.

#### The predicate in a conjunction

The function takes **no arguments and returns two results**, so as a relation
it has two positions, and the predicate is three elements long:

```lisp
(#[OID nnnn "PERSON_SOURCEPRED->OBJECT.RECORD"]   ID   R)
;     └── (car sp): the function object     (second sp)┘ └(third sp)
```

which is precisely what the optimizer assumes:

```lisp
(kval (second sp))   ; the id
(rvar (third sp))    ; the record
```

Compare a function *with* arguments — `bar_range(Integer,Integer) ->
<Integer,Integer>` resolved as
`INTEGER.INTEGER.BAR_RANGE->INTEGER.INTEGER`. With no arguments the type
prefix is empty, hence the bare `PERSON_SOURCEPRED->…` form.

*(Arity and positions follow from the code. The exact printed resolvent name
is reconstructed from AMOS II's naming convention — unverified, since the
wrapper does not load here.)*

#### Why `(car sp)` must be that same object

Not a guess. The Lisp side recovers the collection like this:

```lisp
(defun mongo-database (sp)
  (caar (getfunction 'mongo_database (list sp))))
```

and the finalizer calls it as `(mongo-database (car sp))`. For that lookup to
return `"tutorial"`, `(car sp)` has to be **the identical object** that
`import_mongo_collection` annotated. So the head of the source predicate is
the `person_sourcepred` function object itself — not a `P_…` predicate
function of the kind AMOS II generates for stored functions.

That closes the loop on why a predicate carries a function object rather than
a name: it is the lookup key joining a predicate in some conjunction back to
*this is the `tutorial.person` collection, reached over connection `MyMongo`*.

#### The whole chain, for one query

```sql
select p from Person p where age(p) > 30;
```

| Step | Value |
|---|---|
| Type `Person` | mapped type, extent defined by `person_sourcepred` |
| Source predicate | `(#[… PERSON_SOURCEPRED …] ID R)` |
| `(car sp)` | the function object → `mongo_database` → `"tutorial"` |
| `(third sp)` | `R`, the document variable |
| `age(p)` | `(vref R "age" A)` — a record access on `R` |
| `age(p) > 30` | `(> A 30)` — extractable once `A` counts as known |
| Emitted | `mongo_query(ci, "tutorial", "person", {"age":{"$gt":30}}, R)` |

#### A consequence of the naming

The generated name is built from the **collection alone**:

```sql
create function "+collection+"_sourcepred () -> …
```

So `tutorial.person` and `other.person` would both generate
`person_sourcepred`, with identical signatures — a redefinition rather than
an overload. Importing two same-named collections from different databases
looks like it would clobber the first, and with it the `mongo_database`
annotation that tells the finalizer which database to query. *(Follows from
the string concatenation; not tested.)*

## The other generated functions

Four more `eval`-generated definitions, one per capability a mapped type
needs:

| Generator | Produces | Purpose |
|---|---|---|
| `create_mongo_accessor` | `vref(<T> r, Charstring a) -> Object` | attribute access — `value(r)[a]` |
| `create_mongo_replacer` | `replace_value(<T> m, Record r)` | write a whole document back |
| `create_mongo_setter` | `set_property(<T> p, Charstring prop, Object val)` | change one field, via `put_record` then replace |
| `create_mongo_destructor` | `mongo_destructor(<T> m)` | delete the document when the proxy object is deleted |

`vref` is the one the optimizer cares about. Every `p.age` in an AmosQL query
becomes a `vref` predicate, and the extractor recognises exactly those — see
[`is-record-access`](#recognising-what-mongodb-can-do) below.

`set_property` is a nice illustration of building on what is already there:

```sql
as replace_value(p, put_record(value(p), prop, val));
```

Read the record, put one field, write the whole thing back. MongoDB has
`$set` for this; the wrapper does not use it.

## Tying it together

```sql
create function import_mongo_collection(Mongo ds, Charstring db,
                                        Charstring mongocoll,
                                        Charstring typename) -> Type
  as begin declare Function extfn;
           set extfn = create_mongo_sourcepred(name(ds), db, mongocoll);
           create_mapped_type(typename, {"rkey"}, {"rkey", "value"},
                              name(extfn));
           create_mongo_accessor(typename);
           create_mongo_replacer(name(ds), db, mongocoll, typename);
           create_mongo_setter(typename);
           set_destructor(typenamed(typename),
                          create_mongo_destructor(…));
           set datasource(extfn) = ds;
           set mongo_database(extfn) = db;
           set mongo_collection(extfn) = mongocoll;
     end;
```

One call and a MongoDB collection becomes an AMOS II type whose instances
behave like ordinary objects. The last three lines are the annotations the
Lisp side will read back.

`create_mapped_type` is doing the heavy lifting — declaring that objects of
this type are *proxies* keyed by `rkey`, materialised through the source
predicate. That machinery is AMOS II mediator infrastructure, not part of
this wrapper.

## The tail

```sql
parteval("make_record");
parteval("vector");

commit;
```

`parteval` marks these as **partially evaluable** — computable at compile
time when their arguments are known constants. That matters here because the
finalizer builds filter records out of `make_record1` calls; without partial
evaluation a constant filter would be rebuilt on every tuple.

---

# Part 2 — `mongo_optimizer.lsp`

## The operator table

```lisp
(defglobal _mongo-comparisons_
  (mapcar (f/l (pred op) (cons (theresolvent pred) op))
	  '(< > <= >= != =) '("$lt" "$gt" "$lte" "$gte" "$ne" "$eq")))
```

An association list from AMOS II comparison *function objects* to MongoDB
operator strings. Built at load time by resolving each operator name, so the
keys are the same OIDs that appear in ObjectLog predicates — which is what
lets `assq` match them later.

Six operators. Everything else stays behind as an AMOS II post-filter.

Two more globals hold resolvents used throughout:

```lisp
(defglobal _record-vref_ (theresolvent 'record.charstring.vref->object))
(defglobal _substv_ (theresolvent 'substv))
```

`_record-vref_` is the attribute-access predicate — `r["age"]`. Recognising
it is how the extractor knows which document fields a query touches.

## The extractor — what can MongoDB handle?

```lisp
(defun mongo-extractor (sp predl bnd)
  (let* ((rvar (third sp))
	 (attr-accesses (accessed-record-attributes rvar predl))
	 (attr-vars (accessed-record-values attr-accesses))
	 (known-vars (adjoin rvar (union attr-vars bnd)))
	 (comparisons (extractable-mongo-comparisons predl known-vars))
	 (extracted (append (list sp) attr-accesses comparisons))
	 (newrest (remove-predl extracted predl)))
    (make-extracted :preds extracted
		    :remaining newrest
		    :variables (variables-in-predl extracted))))
```

Read it as five steps:

1. **`rvar`** — the record variable, the third element of the source
   predicate. Everything hinges on this: it is the document the query is
   about.
2. **`attr-accesses`** — every `vref` on `rvar`. These are the fields
   touched: `r["age"]`, `r["Name"]`.
3. **`known-vars`** — a widened notion of "bound". The record variable, the
   variables holding its field values, and whatever was already bound. The
   widening is the key move: **a field value counts as known because MongoDB
   will produce it**, even though AMOS II has not computed it yet.
4. **`comparisons`** — comparisons over those now-known variables.
5. **The split** — source predicate + accesses + comparisons go to MongoDB;
   `remove-predl` leaves everything else for AMOS II.

The return value is an `extracted` struct with three fields: what was taken,
what remains, and which variables the taken part involves.

### Recognising what MongoDB can do

```lisp
(defun is-record-access (pred)
  (and (leaf-predicate-p pred)
       (eq (car pred) _record-vref_)
       (stringp (third pred))))
```

Note `(stringp (third pred))` — the field name must be a **literal string**.
`r[x]` where `x` is a variable is not extractable, because the filter
document needs a field name at compile time.

```lisp
(defun extractable-mongo-comparisons (predl bnd)
  (mapcan (f/l (pred)
	       (let ((p (getcalledpred pred)))
		 (and (leaf-predicate-p p)
		      (assq (first p) _mongo-comparisons_)
		      (and (variable-is-bound (second p) bnd)
			   (variable-is-bound (third p) bnd))
		      (list p))))
          predl))
```

Three conditions: it is a leaf predicate, its function is in the operator
table, and **both** operands are bound. A comparison between two unknowns
cannot go into a filter.

### Why this beats declared capabilities

`rewrite.txt` §1 criticises the built-in relational wrapper for exactly the
thing this avoids:

> If you have a source that can handle certain capabilities but not all
> combinations of these in a conjunction, the query optimizer will fail

An extractor declares nothing in advance. It inspects the actual conjunction
and claims the subset it can serve, leaving the rest — so an unsupported
combination degrades into post-filtering instead of failing.

## The cost model

```lisp
(defun mongo-costmodel (expression bnd)
  (let ((filter (expression-filter expression)))
    (cond ((null (cdr filter))                (list 100000 100000))
          ((not (is-executable (cons 'and filter) bnd)) nil)
          ((has-mongo-equality filter bnd)    (list 10 10))
          ((has-mongo-comparison filter bnd)  (list 100 100))
          (t                                  (list 1000 1000)))))
```

A `(cost fanout)` pair — `C_P` and `F_P` from Litwin & Risch 1992 §4.2.2, the
same currency `simple-pred-cost` returns and `dynprogsort` accumulates. That
common currency is the whole point: it lets the optimizer weigh a MongoDB
access against an entirely unrelated local predicate.

| Branch | Returns | Reading |
|---|---|---|
| `(null (cdr filter))` | 100000 | nothing but the source predicate — a full collection scan |
| not executable | **`nil`** | this binding pattern is impossible; reject the ordering |
| has an equality | 10 | probably an indexed lookup |
| has a comparison | 100 | a range — selective but more work |
| otherwise | 1000 | some extractable filter; better than a scan |

**Returning `nil` is the safety mechanism**, not a cost of zero. Litwin &
Risch §5.2 calls this reordering for safety: an ordering that calls a
predicate in an unsupported direction must be *rejected*, not merely priced
badly. The same rule the `dynprogsort` exercise implements when
`simple-pred-cost` returns nothing.

*(Inference: `filter` appears to be the extracted predicate list with the
source predicate at its head — that reading makes both `(cdr filter)` and
`(cons 'and filter)` coherent. Not verified.)*

The tiers are deliberately coarse. There is no attempt to estimate
selectivity, only to rank four situations against each other. Compare the
`(100 . 100)` default AMOS II gives an unannotated foreign function, measured
in [`../cost-based-vs-rule-based-optimization.md`](../cost-based-vs-rule-based-optimization.md)
— this wrapper's "some filter" tier is the same number, and its equality tier
is ten times better.

## The finalizer — building the query

`mongo-finalizer` is the largest function. Its job: replace the extracted
predicates with an actual call to `mongo_query`.

### Recovering the key

```lisp
(defun mongo-final-predl (sp predl)
  (let ((rvar (third sp))
	(kval (second sp)))
    (if (and kval (neq kval '*))
	(cons (list _record-vref_ rvar "_id" kval) (remove sp predl))
      (remove sp predl))))
```

If the source predicate's **key argument is bound**, it is turned into a
synthetic record access on `"_id"`. A lookup by key thereby becomes just
another field condition, and flows through the same filter-building code as
everything else. Neat — one code path instead of two.

### Assembling the filter

```lisp
(cond ((cdr compl) (setq compl (make-record1 "$and" (listtoarray compl))))
      ((null compl) (setq compl (make-record (vector))))
      (t (setq compl (car compl))))
```

Three cases: several conditions get wrapped in `$and`, no conditions become
an empty record (match everything), a single condition is used bare.

### Late-bound values

```lisp
(setq rvars (variables-in-record compl))
```

If the filter contains variables whose values are not known until run time,
the finalizer emits a `substv` call to substitute them into the record before
the query runs:

```lisp
`((mongo_connid ,ds ,ci)
  (,_vector-constructor_ ,varvec ,@ rvars)
  (,_substv_ ,(listtoarray rvars) ,varvec ,compl ,srec)
  (mongo_query ,ci ,db ,coll ,srec ,rvar)
  ,@ remaining)
```

Otherwise the simpler form, with the constant record passed straight in:

```lisp
`((mongo_connid ,ds ,ci)
  (mongo_query ,ci ,db ,coll ,compl ,rvar)
  ,@ remaining)
```

Either way the shape is the same: look up the connection, run the query,
then whatever predicates could not be absorbed. Those trailing `remaining`
predicates are the post-filter — the same split `rewrite.txt` §2 describes
for the B-tree case.

## `generate-mongo-query` — the translation itself

The function that actually produces BSON. For each accessed field, it scans
the predicates mentioning that field's variable and handles three shapes:

Note the shape it produces. A hand-written filter would combine two bounds on
one field into a single sub-document, `{age: {$gt:30, $lte:50}}`. This loop
pushes each comparison separately, so the finalizer wraps them in `$and`:
`{"$and": [{"age":{"$gt":30}}, {"age":{"$lte":50}}]}`. Equivalent, just less
idiomatic than what a person would write.

```lisp
;; 1. equality on a bound value            →  {field: var}
((is-mongo-attribute-equality pred bnd)
 (push (make-record1 field var) mq))

;; 2. (comp var val)                       →  {field: {$op: val}}
((and (eq var (second pred))
      (variable-is-bound (third pred) bnd))
 (push (make-record1 field
        (make-record1 (cassoc (car pred) _mongo-comparisons_)
                      (third pred))) mq))

;; 3. (comp val var)                       →  {field: {$inverse-op: val}}
((variable-is-bound (second pred) bnd)
 (push (make-record1 field
        (make-record1 (cassoc (inverse-comp (car pred)) _mongo-comparisons_)
                      (second pred))) mq))
```

Case 3 is the one worth pausing on. MongoDB filters always name the field
first, so `5 < age` must be emitted as `{"age": {"$gt": 5}}` — the operator
is **inverted**, via `inverse-comp`. AmosQL imposes no such ordering, so both
forms have to be handled.

Every predicate consumed is removed from `remaining`; the function returns
the pair `(filter . remaining)`.

---

## End to end

Given an imported type `Person` over `tutorial.person`, and:

```sql
select p from Person p where age(p) > 30 and age(p) <= 50;
```

| Stage | Result |
|---|---|
| ObjectLog | source predicate + `vref(p,"age",A)` + `(> A 30)` + `(<= A 50)` |
| **Extractor** | takes all four — `A` counts as known because MongoDB produces it |
| **Cost model** | comparisons but no equality → `(100 100)` |
| **`generate-mongo-query`** | `{"$and": [{"age":{"$gt":30}}, {"age":{"$lte":50}}]}` |
| **Finalizer** | `mongo_connid` lookup, then `mongo_query(ci, "tutorial", "person", filter, p)` |
| Post-filter | nothing left |

Both range predicates absorbed into one call — structurally what Step 5c of
[`../query-rewrite/building-a-rewrite-rule.md`](../query-rewrite/building-a-rewrite-rule.md)
achieves with `bar_range`, and what `rewrite.txt` §2 describes for `mbtree`.

*(Predicted from the code, not observed — the wrapper does not load here.)*

## Code observations

Things a reader should know before trusting the source:

**`has-mongo-unknown-comparison` is dead code.** Its body is
character-identical to `has-mongo-comparison`, and nothing calls it. Almost
certainly an abandoned edit.

**`mcomp` is never used.** Declared in `generate-mongo-query`'s `let`, never
referenced.

**`sb` is never used.** The finalizer takes five parameters — `(ds predl sb
bnd rest)` — and the body reads all but `sb`. Whatever the optimizer passes
there is ignored.

**A known limitation, admitted in a comment:**

```lisp
(if (and rest extracted);;does not work if filter is last in tbrl
    (smash rest (remove-predl extracted rest)))
```

`smash` is a destructive list update. The comment says the approach fails
when the filter is the last element of the TBR list — so predicate position
can change whether absorption works. Unresolved in the source as it stands.

**`set_property` rewrites whole documents** rather than using MongoDB's
`$set`. Correct, but writes more than needed, and combined with the
transaction caveat in `mongo_replace` (documented in
[`README.md`](README.md)) makes concurrent field updates lossy.

## Related

- [`README.md`](README.md) — the whole directory, and why it cannot be loaded.
- [`../query-rewrite/README.md`](../query-rewrite/README.md) — TBR-rewrite
  rules, the per-predicate alternative to an extractor.
- [`../litwin-risch-1992-objectlog.md`](../litwin-risch-1992-objectlog.md) —
  the cost model, binding patterns and safety rules this file inherits.
- [`../lisp-foreign-functions.md`](../lisp-foreign-functions.md) — the ALisp
  foreign-function interface.
