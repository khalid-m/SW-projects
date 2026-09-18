pcfront\Debug\pcfront.exe scsq.dmp -O prepconfig.osql -l "(trace server-eval)" -ns
mpiexec -n 4 proc\Debug\proc.exe scsq.dmp
pcfront\Debug\pcfront.exe scsq.dmp

./front scsq.dmp -O prepconfig.osql -l "(trace server-eval)" -ns
mpirun -np 32 -partition R001_B01 -exe /bglst1/home/zeitler/amos/scsq -args "scsq.dmp" >> ScsqLog 2>&1
cqsub -q default -C /bglst1/home/zeitler/amos/out -t 120 -m co -n 32 /bglst1/home/zeitler/amos/scsq scsq.dmp
./front scsq.dmp


1. bgconfig.osql contains typical configurations for 
   - Astron BG/L
   - Edinburgh BG/L
   - Win32

   Important variables:
   :bghome       Directory where BG node I/O will go
   :bghostid     IP address of front computer used by BG nodes
   :bgsubmission Command string to start up SCSQ on BG node
                 Depends on submission method used, 
                 e.g. Cobalt, mpirun, or submitjob (Astron)
   :environment	 This variable affects faulteval. It is set to 
		 "batch" for real BG settings, or 
		 "interactive" for interactive MPI envs (e.g. Win32 pcsq).

2. UNIX
2.1. Compilation:
     make scsq
     - will compile
       - scsq (executes on BG/L) 
       - front (executes on front cluster)
     - it will also 
       - execute amos and build a SCSQ dmp
       - copy scsq executable to :bghome

2.2. Execution:
     ./front scsq.dmp

3. Win32
   Set enviroment variable MPI_HOME to home directory of MPICH2, 
e.g. C:\Program Files\MPICH2

   Include %MPI_HOME%\bin in PATH

   The following MSVS projects are relevant:
   pcscsq\pcscsq.dsw	  - interactive MPI. Teletype is on node 0.
   pcfront\pcfront.dsw	  - front executable on PC
   proc\proc.dsw	  - BG executable on PC

3.1. Compilation
     In order to execute a BG-like environment, both pcfront and proc 
     must be built.
     compile using F7 (build ***.exe)
     (a SCSQ dmp will be built in the post-build step:
      ..\bin\amos2.exe -O "pc.osql", or
      ..\bin\amos2.exe -O "sc.osql"

     pc.osql and sc.osql read different configuration files
     (pcconfig.osql or bgconfig.osql). 
     Next, they both execute the same code
     (scsq.osql and scsq.lsp)
     Finally pc.osql and sc.osql dump to different files
     (pcsq.dmp and scsq.dmp, respectively).

3.2. Execution
     Interactive MPI (pcscsq):
        mpiexec.exe -n 4 pcscsq\pcscsq\Debug\pcsq.exe pcsq.dmp
     BG-like environment (pcfront):
        pcfront\Debug\pcfront.exe scsq.dmp
     (proc is called from within pcfront when a bg() is submitted.)

4. AmosQL examples:

   bg(iota(1,4));
   count(select bg(pair(merge(iota(1,100000),iota(1,100000)))));
   create function add1(integer i)->integer as select i+1;
   bg(add1(32));
   bg(eval('a')); /* Causes error on BG (semi colon missing) */

   count(select mpismerge(vectorof(select bagof(sn(i,cast (i+100 as integer))) from integer i where i=iota(1,2))));


   Create mpi stream (assuming CNC is on node 1 -- this is configured in scsq.lsp).
   lisp;
   (mpi-send-form '(setq s (open-mpi 0 5 10000)) 1)
   (mpi-send-form '(print "hej hej hej" s) 1)
   (mpi-send-form '(flush s) 1)
   (setq r (open-mpi 1 5 10000))
   (read r)

Blobstorlek: Så stor att parsning inte tar tid.

Kommunikation
0. BLOB, meddelandebaserad MPI
1. strömmad MPI
2. strömmad icke-blockad MPI

OBS: writebytes/readbytes måste finnas med!

Prova parametrar
- bufferstorlek
- antal strömmar
- beräkningsbelastning
  prova med blockande resp icke-blockande kommunikation
- synkfrekvens (emit, stop, eof-kontroll)
  inverkan på reconfigurability
- processorlayout: inverkan på bandbredd

Glöm inte komm. med fronten!
- reaktiviteten på användarinput. Kontroll?
- en ström i varje riktning kanske rundar problemet med vändande av enkelström?

Målfunktioner
- throughput
- delay

Kolla att QM automatiskt dör när TCP-interfacet stängs ner på front.

Fråga LOFAR om de har samma problem med att vända meddelandet mellan BG och front!

drystone (fuskbenchmark) -- riktiga program

###

PC:
amos2 -L scsq.lsp -O prepconfig.osql -l "(trace server-eval)" -ns
amos2 -O prepconfig.osql -O scsq.osql -l "(trace server-eval)" -ns
pcfront\Debug\pcfront.exe scsq.dmp -O prepconfig.osql -l "(trace server-eval)" -ns

UNIX:
AmosNT/bin/amos2 -O prepconfig.osql -L AmosNT/astro/scsq.lsp -l "(trace server-eval)" -ns
AmosNT/astro/front AmosNT/astro/scsq.dmp -O AmosNT/astro/prepconfig.osql -l "(trace server-eval)" -ns


mpiexec.exe -n 4 pcscsq\pcscsq\Debug\pcsq.exe pcsq.dmp

pcfront\Debug\pcfront.exe scsq.dmp

-- post link:
..\bin\amos2.exe ..\bin\amos2.dmp -O "pc.osql"
pcfront\Debug\pcfront.exe ..\bin\amos2.dmp -O "sc.osql"
prep\Debug\prep.exe ..\bin\amos2.dmp -O "prep.osql"

mpismerge(vectorof(select bagof(iota(1,cast(10*i as integer))) from integer i where i=iota(1,1 )));
mpismerge(vectorof(select bagof(iota(1,10 )) from integer i where i=iota(1,1 )));

select vectorof(select bagof(iota(1,10),iota(1,10)) );

mpismerge( vectorof(select bagof(signal(1))));

# Grundläggande test:
vectorof(select bagof(iota(1,10)));

lisp;
(mpi-send-form '(setq s (open-mpi 0 5 100)) 1)
(mpi-send-form '(print "hej hej hej" s) 1)
(mpi-send-form '(flush s) 1)
(setq r (open-mpi 1 5 100))
(read r)
:osql

select intblob2vec(v[j]) from vector of binary v, integer j where
v=mpismerge(vectorof(select bagof(randintblob(2,2 )) from integer i where i=iota(1,2)));

set :x={1000,10000};
select mpistreamtest (0, 1, 100, 80000, h) from integer h, integer i where h=:x[i];

select intblob2vec(v[i]) from vector of binary v, integer i where v=pair(mpimerge(randintblob(10,4), randintblob(10,4)));

# Profiler fcn used 2006-06-02/EZ
bg(mpismerge(vectorof(select bagof( stat(j,i, 1024,1)) from integer i,integer j where i=iota(1,6) and j=iota(1,4))));

bg(mpismerge ( vectorof(select bagof(
tcpsmerge(vectorof(select bagof(iota(1,10 )) from integer i where i=iota(1,3 )) ))
from integer j where j=iota(1,2))));

tcpsmerge(vectorof(select bagof(iota(1,10 )) from integer i where i=iota(1,1 )) );

bg(tcpsmerge(vectorof(select bagof(iota(1,10)) from integer i where i=iota(1,1))));

### Experiments 060918 prep ###

# Set up test
tcpsmerge(vectorof(select bagof(signals(5,1))));
count(bg(tcpsmerge(vectorof(select bagof(signals(5,1))))));
bg(count( select tcpsmerge(vectorof(select bagof(signals(5,1)) from integer i where i=iota(1,1)))));

# 1 fen, 1 ion
bg(count (select tcpsmerge(vectorof(select bagof(blobs(3,10)) from integer i where i=iota(1,2)))));

# 1 fen, N ion
bg(mpismerge(vectorof(select bagof(tcpsmerge(vectorof(select bagof(iota(3,10))))) from integer j where j=iota(1,2))));

# Try different _free-nodes_ lists, and do
select bg(count(mpismerge(vectorof(select bagof(tcpsmerge(vectorof(select bagof(blobs(3,10))))) from integer j where j=iota(1,k))))) from integer k where k=iota(1,4);
# => Many I/O nodes are superior to running on 1 and the same...
# => Distance between CN and I/O node doesn't seem to matter (if the info in my VRML file is correct, that is).

# N fen, 1 ion
# Make sure that :prephosts in prepconfig.osql contains appropriate FENs.
# :bgsubmission in bgconfig.osql should point to cqsub (non I/O-rich partition).
bg(mpismerge(vectorof(select bagof(tcpsmerge(vectorof(select bagof(iota(3,10))))) from integer j where j=iota(1,2))));
bg(count (select tcpsmerge(vectorof(select bagof(blobs(3,10)) from integer i where i=iota(1,2)))));

# N fen, N ion
select bg(count(mpismerge(vectorof(select bagof(tcpsmerge(vectorof(select bagof(blobs(3,100))))) from integer j where j=iota(1,k))))) from integer k where k=iota(1,4);
select bg(mpismerge(vectorof(select bagof(count(tcpsmerge(vectorof(select bagof(blobs(3,100)))))) from integer j where j=iota(1,k)))) from integer k where k=iota(1,4);

select bg(count(mpismerge(vectorof(select bagof(tcpsmerge(vectorof(select bagof(iota(1,1))))) from integer j where j=iota(1,k))))) from integer k where k=iota(1,4);


### Experiments 061012 prep ###

I: 111
local, IOpoor

select bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
  select bagof(blobs(3,100)) from integer j where j=iota(1,k))))))))
from integer k where k=iota(1,8);

select bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
  select bagof(blobs(3,100)) from integer j where j=iota(1,1))))))));
sleep(30);
select bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
  select bagof(blobs(3,100)) from integer j where j=iota(1,2))))))));
sleep(30);
select bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
  select bagof(blobs(3,100)) from integer j where j=iota(1,3))))))));
sleep(30);
select bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
  select bagof(blobs(3,100)) from integer j where j=iota(1,4))))))));
sleep(30);
select bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
  select bagof(blobs(3,100)) from integer j where j=iota(1,5))))))));
sleep(30);
select bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
  select bagof(blobs(3,100)) from integer j where j=iota(1,6))))))));
sleep(30);
select bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
  select bagof(blobs(3,100)) from integer j where j=iota(1,7))))))));
sleep(30);
select bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
  select bagof(blobs(3,100)) from integer j where j=iota(1,8))))))));

II: 11N
local, IOpoor

select bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
    select bagof(blobs(3,100))))))
  from integer j where j=iota(1,k))))
from integer k where k=iota(1,8);

III: 1NN
local, IORICH, query II (modify #fanout manually)

bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
    select bagof(blobs(3,100))))))
  from integer j where j=iota(1,1))));
sleep(20);
bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
    select bagof(blobs(3,100))))))
  from integer j where j=iota(1,2))));
sleep(20);
bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
    select bagof(blobs(3,100))))))
  from integer j where j=iota(1,3))));
sleep(20);
bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
    select bagof(blobs(3,100))))))
  from integer j where j=iota(1,4))));
sleep(20);
bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
    select bagof(blobs(3,100))))))
  from integer j where j=iota(1,5))));
sleep(20);
bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
    select bagof(blobs(3,100))))))
  from integer j where j=iota(1,6))));
sleep(20);
bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
    select bagof(blobs(3,100))))))
  from integer j where j=iota(1,7))));
sleep(20);
bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
    select bagof(blobs(3,100))))))
  from integer j where j=iota(1,8))));

IV: N11
SSH, IOpoor, query I

V: N1N
SSH, IOpoor, query II

VI: NNN
SSH, IOrich, query II (modify #fanout manually)

bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
    select bagof(blobs(3,100))))))
  from integer j where j=iota(1,1))));
sleep(20);
bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
    select bagof(blobs(3,100))))))
  from integer j where j=iota(1,2))));
sleep(20);
bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
    select bagof(blobs(3,100))))))
  from integer j where j=iota(1,3))));
sleep(20);
bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
    select bagof(blobs(3,100))))))
  from integer j where j=iota(1,4))));
sleep(20);
bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
    select bagof(blobs(3,100))))))
  from integer j where j=iota(1,5))));
sleep(20);
bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
    select bagof(blobs(3,100))))))
  from integer j where j=iota(1,6))));
sleep(20);
bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
    select bagof(blobs(3,100))))))
  from integer j where j=iota(1,7))));
sleep(20);
bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
    select bagof(blobs(3,100))))))
  from integer j where j=iota(1,8))));


###
# Startup times
###

QI

select bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
  select bagof(iota(3,100)) from integer j where j=iota(1,1))))))));
sleep(20);
select bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
  select bagof(iota(3,100)) from integer j where j=iota(1,2))))))));
sleep(20);
select bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
  select bagof(iota(3,100)) from integer j where j=iota(1,3))))))));
sleep(20);
select bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
  select bagof(iota(3,100)) from integer j where j=iota(1,4))))))));
sleep(20);
select bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
  select bagof(iota(3,100)) from integer j where j=iota(1,5))))))));
sleep(20);
select bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
  select bagof(iota(3,100)) from integer j where j=iota(1,6))))))));
sleep(20);
select bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
  select bagof(iota(3,100)) from integer j where j=iota(1,7))))))));
sleep(20);
select bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
  select bagof(iota(3,100)) from integer j where j=iota(1,8))))))));


QII

bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
    select bagof(iota(3,100))))))
  from integer j where j=iota(1,1))));
sleep(20);
bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
    select bagof(iota(3,100))))))
  from integer j where j=iota(1,2))));
sleep(20);
bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
    select bagof(iota(3,100))))))
  from integer j where j=iota(1,3))));
sleep(20);
bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
    select bagof(iota(3,100))))))
  from integer j where j=iota(1,4))));
sleep(20);
bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
    select bagof(iota(3,100))))))
  from integer j where j=iota(1,5))));
sleep(20);
bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
    select bagof(iota(3,100))))))
  from integer j where j=iota(1,6))));
sleep(20);
bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
    select bagof(iota(3,100))))))
  from integer j where j=iota(1,7))));
sleep(20);
bg(mpismerge(vectorof(
  select bagof(count(tcpsmerge(vectorof(
    select bagof(iota(3,100))))))
  from integer j where j=iota(1,8))));

###
# VN mode 061016
###

Same experiments I-VI as for CO mode above.

No improvement over CO mode could be seen with any of the other node
arrangements tried (see scsq.lsp).


###
# Port unification
###

# A chain of 2 stream processors
select extract(b) from vector a, vector b 
where a=port(vectorof (select bagof(iota(1,10))),1, {"tcp"})
and b=port(vectorof (select bagof({2}*extract(a))),1, {"tcp"});

# Take 2
extract(port(vectorof (select bagof({2}*extract(port(vectorof (select bagof(iota(1,10))),1, {"tcp"})))),1, {"tcp"}));


# merge an array of stream processors
extract(port(vectorof (select bagof(iota(1,10)) from integer i where i=iota(1,3)),1, {"tcp"}));

# merge two separate stream processors
select extract({in(a),in(b)}) from vector a, vector b
where a=port(vectorof (select bagof(iota(1,10))),1, {"tcp"})
and b=port(vectorof (select bagof(iota(1,10))),1, {"tcp"});

# "Romben"
select extract({in(a),in(b)}) from vector a, vector b, vector c
where a=port(vectorof (select bagof({2}*extract(c))),1, {"tcp"})
and b=port(vectorof (select bagof(in(extract(c)))),1, {"tcp"})
and c=port(vectorof (select bagof(iota(1,10))),2, {"tcp"});

# Dragspelet
select extract(port(vectorof(select bagof({i}*extract(c)) from integer i where i=iota(1,n)),1, {"tcp"})) 
from vector c, integer n
where c=port(vectorof (select bagof(iota(1,10))),n, {"tcp"})
and n=8;


# Klur
select extract({in(a),in(b),in(c)}) from vector a, vector b, vector c
where a=port(vectorof (select bagof(iota(1,10))),1, {"tcp"})
and b=port(vectorof (select bagof(iota(1,100))),2, {"tcp"})
and c=port(vectorof (select bagof({2}*extract(b))),1, {"tcp"});

# "Kör detta på en strömprocessor, sådan att..."
sp(vector of generator, integer split_count, vectorparams)->vector of port
en begränsning med sp() är att 

Relaterat: Tribeca. LÄS, VIKTIGT!
http://www.usenix.org/publications/library/proceedings/usenix98/full_papers/sullivan/sullivan.pdf


<idé>
-- Idé: bryt ned i beståndsdelar --

# "allokera n stycken strömprocessorer":
Node(proto,vector of location)->node

# "installera följande frågor på dessa strömprocessorer": 
Sp(vector of generator, integer split_count, vector of node)->sp

-> Varför skulle man någonsin allokera processorer utan att vilja köra något på dem?
</idé>

<idé>
Låt postfiltret komma uppifrån. 

Utöka extract till att även ta ett postfilter:
- extract(vector of port, vector of generator);

Nej förresten, definiera postfiltret redan i port-funktionen:
port(vector of generator function, integer n_sub, vector of generator postfilter, vector params)
-> vector of port;

Då måste extract-funktionen tala om vilket av postfiltren den ska prenumerera på:
extract(vector of port, vector of integer outputnumber)->bag of vector;
</idé>

# Merge av 3 noder
extract(port(vectorof(select bagof(iota(1,10)) from integer i where i=iota(1,3)),1, {"tcp"}));

Fysisk nivå: port ska ha signaturen
port(vector of bag, integer, location)->vector of Port

Logisk nivå:
port(vector of bag)->vector of Port

# BGOUT

extract(port(vectorof (select bagof(iota(1,10))),1, {"bgout", {2}}));

select extract (port(vectorof (select bagof(in(extract(b) ))),1, {"bgout", {2}}))
from vector b where b = port(vectorof (select bagof(iota(1,10))),1, {"tcp"});

select extract (port(vectorof (select bagof(in(extract(b) ))),1, {"bgout", {2}}))
from vector b where b = port(vectorof (select bagof(iota(1,10))),1, {"mpi", {3}});

# An mpi node sending to an output ("bgout") mpi node
select extract (port(vectorof (select bagof(in(extract(b)))),1, {"bgout", {0}}))
from vector b where b = port(vectorof (select bagof(iota(1,10))),1, {"mpi", {3}});

# A chain of 2 SPs
select extract(b) from vector a, vector b 
where a=port(vectorof (select bagof(iota(1,10))),1, {"mpi", {2}})
and b=port(vectorof (select bagof({2}*extract(a))),1, {"bgout", {3}});

# Mrg 2 sep SPs
select extract(port(vectorof(select bagof(extract({in(a),in(b)}))), 1, {"bgout",{0}}))
from vector a, vector b
where a=port(vectorof (select bagof(iota(1,100))),1, {"mpi", {2}})
and b=port(vectorof (select bagof(iota(1,10))),1, {"mpi", {3}});

# Dragspel i BG
select extract(port(vectorof(select bagof(extract(b))),1,{"bgout", {0}}))
from vector b, vector c, integer n
where b=port(vectorof(select bagof({i}*extract(c)) from integer i where i=iota(1,n)),1, {"mpi", {2,3,4,5}})
and c=port(vectorof (select bagof(iota(1,10))),n, {"tcp"})
and n=4;

(setq r (open-mpi 1 1 1000))
(mpi-send-form '(setq w (open-mpi 0 1 1000)) 1)
(mpi-send-form '(print "hej hej" w) 1)
(mpi-send-form '(flush w) 1)
(read r)


# Experiments revisited

select extract(b) from vector a, vector b 
where a=port(vectorof (select bagof(iota(1,10))),1, {"tcp"})
and b=

extract(port(vectorof (select bagof(extract(port(vectorof (select bagof(iota(1,10))),1, {"mpi",{2}})))),1, {"bgout", {0}}));
extract(port(vectorof (select bagof(iota(1,10))),1,{"bgout", {0}}));

select r
from vector p, vector q, vector r, integer n
where p=port(vectorof (select bagof(iota(1,10))),n, {"tcp"})
and q=port(vectorof(select bagof({i}*extract(p)) from integer i where i=iota(1,n)),1, {"tcp"})
and r=port(vectorof(select bagof(extract(vectorof({in(q)} * {100} )))), 1, {"tcp"})
and n=4;

select extract({bagof(r)})
and r in q



create function f2(vector q)->vector r as
select vectorof(select port(vectorof(select bagof(extract({q1}))),1,{"tcp"})
from object q1
where q1 in q);

create function flatten(vector v)->vector as
select vectorof(select cast(v[i] as vector)[0] from integer i);

select q into :v
from vector p, vector q, integer n
where p=port(vectorof (select bagof(iota(1,10))),n, {"tcp"})
and q=port(vectorof(select bagof({i}*extract(p)) from integer i where i=iota(1,n)),1, {"tcp"})
and n=4;

set :w=f2(:v);
extract(flatten(:w));

##
# ICDE 2007
##

== Q1 ==

select extract(c) from
vector a, vector b, vector c, integer n
where c=port(vectorof(select bagof(extract(b))),1,{"bgout", {0}})
and   b=port(vectorof(select bagof(count(select extract(a)))),1,{"mpi", {2}})
and   a=port(vectorof(select bagof(blobs(3,100)) from integer i where i in iota(1,n))
             ,1,{"tcp"})
and n=4;

== Q2 ==

select extract(c) from
vector a, vector b, vector c, integer n
where c=port(vectorof(select bagof(extract(b))),1,{"bgout", {0}})
and   b=port(vectorof(select bagof(count(select extract(a)))),1,{"mpi", {2}})
and   a=port(vectorof(select bagof(blobs(3,100)) from integer i where i in iota(1,n))
             ,1,{"tcp"})
and n=4;


select extract(c) from
vector a, vector b, vector c, integer n
where c=port(vectorof(select bagof(extract(b))),1,{"bgout", {0}})
and   b=port(vectorof(select bagof(count(select extract(a)))),1,{"mpi", {2}})
and   a=port(vectorof(select bagof(iota(3,100)) from integer i where i in iota(1,n))
             ,1,{"tcp"})
and n=4;

select extract(a), extract(b)
from vector a, vector b
where a=port(vectorof(select bagof(iota(1,3))), {"tcp"})
and   b=port(vectorof(select bagof(iota(1,3))), {"tcp"});

##
# radix fft
##

front
lisp;
(storagestat t)
:osql

set :len=16384;

set :i = carray(vectorof(real(iota(0,:len-1))), vectorof(real(0*iota(0,:len-1))));

set :r=fft(:i);

set :q = fftpart(even(:i),:len);

set :t = fftpart(odd (:i),:len);

set :a = radix2combine({:q,:t});

enorm(:a-:r);
enorm(ifft(:a) - :i);

select radix2combine(cast(merge({a,b}) as vector of carray)) from sp a, sp b, sp c 
where a=sp(streamof(fftpart(even(cast(extract(c) as carray)), 8)),'tcp') 
and   b=sp(streamof(fftpart(odd (cast(extract(c) as carray)), 8)),'tcp') 
and   c=sp(streamof(carray(vectorof(real(iota(0,7))), vectorof(real(0*iota(0,7))))),2,'tcp');
