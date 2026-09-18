create table customer22.cmap(
tab Varchar(50),
upv Varchar(10),
classid Varchar(100));

create table customer22.pmap(
tab Varchar(50),
col Varchar(50),
upv Varchar(10),
propid Varchar(100));


insert into customer22.cmap values ('part','cust22','http://user.it.uu.se/~udbl/sard/customer22#part');
insert into customer22.cmap values ('region','cust22','http://user.it.uu.se/~udbl/sard/customer22#region');
insert into customer22.cmap values ('customer','cust22','http://user.it.uu.se/~udbl/sard/customer22#customer');
insert into customer22.cmap values ('supplier','cust22','http://user.it.uu.se/~udbl/sard/customer22#supplier');
insert into customer22.cmap values ('nation','cust22','http://user.it.uu.se/~udbl/sard/customer22#nation');
insert into customer22.cmap values ('partsupp','cust22','http://user.it.uu.se/~udbl/sard/customer22#partsupp');
insert into customer22.cmap values ('orders','cust22','http://user.it.uu.se/~udbl/sard/customer22#orders');

insert into customer22.pmap values ('part','p_comment','cust22','http://user.it.uu.se/~udbl/sard/customer22#part_p_comment');
insert into customer22.pmap values ('part','p_price','cust22','http://user.it.uu.se/~udbl/sard/customer22#part_p_price');
insert into customer22.pmap values ('part','p_pack','cust22','http://user.it.uu.se/~udbl/sard/customer22#part_p_pack');
insert into customer22.pmap values ('part','p_size','cust22','http://user.it.uu.se/~udbl/sard/customer22#part_p_size');
insert into customer22.pmap values ('part','p_type','cust22','http://user.it.uu.se/~udbl/sard/customer22#part_p_type');
insert into customer22.pmap values ('part','p_brandname','cust22','http://user.it.uu.se/~udbl/sard/customer22#part_p_brandname');
insert into customer22.pmap values ('part','p_manufactname','cust22','http://user.it.uu.se/~udbl/sard/customer22#part_p_manufactname');
insert into customer22.pmap values ('part','p_name','cust22','http://user.it.uu.se/~udbl/sard/customer22#part_p_name');
insert into customer22.pmap values ('part','p_partkey','cust22','http://user.it.uu.se/~udbl/sard/customer22#part_p_partkey');
insert into customer22.pmap values ('region','r_comment','cust22','http://user.it.uu.se/~udbl/sard/customer22#region_r_comment');
insert into customer22.pmap values ('region','r_name','cust22','http://user.it.uu.se/~udbl/sard/customer22#region_r_name');
insert into customer22.pmap values ('region','r_regionkey','cust22','http://user.it.uu.se/~udbl/sard/customer22#region_r_regionkey');
insert into customer22.pmap values ('customer','c_custkey','cust22','http://user.it.uu.se/~udbl/sard/customer22#customer_c_custkey');
insert into customer22.pmap values ('customer','c_name','cust22','http://user.it.uu.se/~udbl/sard/customer22#customer_c_name');
insert into customer22.pmap values ('customer','c_address','cust22','http://user.it.uu.se/~udbl/sard/customer22#customer_c_address');
insert into customer22.pmap values ('customer','c_nationkey','cust22','http://user.it.uu.se/~udbl/sard/customer22#customer_c_nationkey');
insert into customer22.pmap values ('customer','c_phone','cust22','http://user.it.uu.se/~udbl/sard/customer22#customer_c_phone');
insert into customer22.pmap values ('customer','c_acctbal','cust22','http://user.it.uu.se/~udbl/sard/customer22#customer_c_acctbal');
insert into customer22.pmap values ('customer','c_mktsegment','cust22','http://user.it.uu.se/~udbl/sard/customer22#customer_c_mktsegment');
insert into customer22.pmap values ('customer','c_comment','cust22','http://user.it.uu.se/~udbl/sard/customer22#customer_c_comment');
insert into customer22.pmap values ('supplier','s_suppkey','cust22','http://user.it.uu.se/~udbl/sard/customer22#supplier_s_suppkey');
insert into customer22.pmap values ('supplier','s_name','cust22','http://user.it.uu.se/~udbl/sard/customer22#supplier_s_name');
insert into customer22.pmap values ('supplier','s_address','cust22','http://user.it.uu.se/~udbl/sard/customer22#supplier_s_address');
insert into customer22.pmap values ('supplier','s_phone','cust22','http://user.it.uu.se/~udbl/sard/customer22#supplier_s_phone');
insert into customer22.pmap values ('supplier','s_acctbal','cust22','http://user.it.uu.se/~udbl/sard/customer22#supplier_s_acctbal');
insert into customer22.pmap values ('supplier','s_comment','cust22','http://user.it.uu.se/~udbl/sard/customer22#supplier_s_comment');
insert into customer22.pmap values ('supplier','s_nationkey','cust22','http://user.it.uu.se/~udbl/sard/customer22#supplier_s_nationkey');
insert into customer22.pmap values ('nation','n_nationkey','cust22','http://user.it.uu.se/~udbl/sard/customer22#nation_n_nationkey');
insert into customer22.pmap values ('nation','n_name','cust22','http://user.it.uu.se/~udbl/sard/customer22#nation_n_name');
insert into customer22.pmap values ('nation','n_regionkey','cust22','http://user.it.uu.se/~udbl/sard/customer22#nation_n_regionkey');
insert into customer22.pmap values ('nation','n_comment','cust22','http://user.it.uu.se/~udbl/sard/customer22#nation_n_comment');
insert into customer22.pmap values ('partsupp','ps_partkey','cust22','http://user.it.uu.se/~udbl/sard/customer22#partsupp_ps_partkey');
insert into customer22.pmap values ('partsupp','ps_suppkey','cust22','http://user.it.uu.se/~udbl/sard/customer22#partsupp_ps_suppkey');
insert into customer22.pmap values ('partsupp','ps_availqty','cust22','http://user.it.uu.se/~udbl/sard/customer22#partsupp_ps_availqty');
insert into customer22.pmap values ('partsupp','ps_supplycost','cust22','http://user.it.uu.se/~udbl/sard/customer22#partsupp_ps_supplycost');
insert into customer22.pmap values ('partsupp','ps_comment','cust22','http://user.it.uu.se/~udbl/sard/customer22#partsupp_ps_comment');
insert into customer22.pmap values ('orders','o_orderkey','cust22','http://user.it.uu.se/~udbl/sard/customer22#orders_o_orderkey');
insert into customer22.pmap values ('orders','o_custkey','cust22','http://user.it.uu.se/~udbl/sard/customer22#orders_o_custkey');
insert into customer22.pmap values ('orders','o_sign','cust22','http://user.it.uu.se/~udbl/sard/customer22#orders_o_sign');
insert into customer22.pmap values ('orders','o_orderprice','cust22','http://user.it.uu.se/~udbl/sard/customer22#orders_o_orderprice');
insert into customer22.pmap values ('orders','o_orderdate','cust22','http://user.it.uu.se/~udbl/sard/customer22#orders_o_orderdate');
insert into customer22.pmap values ('orders','o_shippriority','cust22','http://user.it.uu.se/~udbl/sard/customer22#orders_o_shippriority');
insert into customer22.pmap values ('orders','o_clerkname','cust22','http://user.it.uu.se/~udbl/sard/customer22#orders_o_clerkname');
insert into customer22.pmap values ('orders','o_year','cust22','http://user.it.uu.se/~udbl/sard/customer22#orders_o_year');
insert into customer22.pmap values ('orders','o_comment','cust22','http://user.it.uu.se/~udbl/sard/customer22#orders_o_comment');

/*************************************************************/

create table customer05.cmap(
tab Varchar(50),
upv Varchar(10),
classid Varchar(100));

create table customer05.pmap(
tab Varchar(50),
col Varchar(50),
upv Varchar(10),
propid Varchar(100));


insert into customer05.cmap values ('part','cust05','http://user.it.uu.se/~udbl/sard/customer05#part');
insert into customer05.cmap values ('region','cust05','http://user.it.uu.se/~udbl/sard/customer05#region');
insert into customer05.cmap values ('customer','cust05','http://user.it.uu.se/~udbl/sard/customer05#customer');
insert into customer05.cmap values ('supplier','cust05','http://user.it.uu.se/~udbl/sard/customer05#supplier');
insert into customer05.cmap values ('nation','cust05','http://user.it.uu.se/~udbl/sard/customer05#nation');
insert into customer05.cmap values ('partsupp','cust05','http://user.it.uu.se/~udbl/sard/customer05#partsupp');
insert into customer05.cmap values ('orders','cust05','http://user.it.uu.se/~udbl/sard/customer05#orders');

insert into customer05.pmap values ('part','p_comment','cust05','http://user.it.uu.se/~udbl/sard/customer05#part_p_comment');
insert into customer05.pmap values ('part','p_price','cust05','http://user.it.uu.se/~udbl/sard/customer05#part_p_price');
insert into customer05.pmap values ('part','p_pack','cust05','http://user.it.uu.se/~udbl/sard/customer05#part_p_pack');
insert into customer05.pmap values ('part','p_size','cust05','http://user.it.uu.se/~udbl/sard/customer05#part_p_size');
insert into customer05.pmap values ('part','p_type','cust05','http://user.it.uu.se/~udbl/sard/customer05#part_p_type');
insert into customer05.pmap values ('part','p_brandname','cust05','http://user.it.uu.se/~udbl/sard/customer05#part_p_brandname');
insert into customer05.pmap values ('part','p_manufactname','cust05','http://user.it.uu.se/~udbl/sard/customer05#part_p_manufactname');
insert into customer05.pmap values ('part','p_name','cust05','http://user.it.uu.se/~udbl/sard/customer05#part_p_name');
insert into customer05.pmap values ('part','p_partkey','cust05','http://user.it.uu.se/~udbl/sard/customer05#part_p_partkey');
insert into customer05.pmap values ('region','r_comment','cust05','http://user.it.uu.se/~udbl/sard/customer05#region_r_comment');
insert into customer05.pmap values ('region','r_name','cust05','http://user.it.uu.se/~udbl/sard/customer05#region_r_name');
insert into customer05.pmap values ('region','r_regionkey','cust05','http://user.it.uu.se/~udbl/sard/customer05#region_r_regionkey');
insert into customer05.pmap values ('customer','c_custkey','cust05','http://user.it.uu.se/~udbl/sard/customer05#customer_c_custkey');
insert into customer05.pmap values ('customer','c_name','cust05','http://user.it.uu.se/~udbl/sard/customer05#customer_c_name');
insert into customer05.pmap values ('customer','c_address','cust05','http://user.it.uu.se/~udbl/sard/customer05#customer_c_address');
insert into customer05.pmap values ('customer','c_nationkey','cust05','http://user.it.uu.se/~udbl/sard/customer05#customer_c_nationkey');
insert into customer05.pmap values ('customer','c_phone','cust05','http://user.it.uu.se/~udbl/sard/customer05#customer_c_phone');
insert into customer05.pmap values ('customer','c_acctbal','cust05','http://user.it.uu.se/~udbl/sard/customer05#customer_c_acctbal');
insert into customer05.pmap values ('customer','c_mktsegment','cust05','http://user.it.uu.se/~udbl/sard/customer05#customer_c_mktsegment');
insert into customer05.pmap values ('customer','c_comment','cust05','http://user.it.uu.se/~udbl/sard/customer05#customer_c_comment');
insert into customer05.pmap values ('supplier','s_suppkey','cust05','http://user.it.uu.se/~udbl/sard/customer05#supplier_s_suppkey');
insert into customer05.pmap values ('supplier','s_name','cust05','http://user.it.uu.se/~udbl/sard/customer05#supplier_s_name');
insert into customer05.pmap values ('supplier','s_address','cust05','http://user.it.uu.se/~udbl/sard/customer05#supplier_s_address');
insert into customer05.pmap values ('supplier','s_phone','cust05','http://user.it.uu.se/~udbl/sard/customer05#supplier_s_phone');
insert into customer05.pmap values ('supplier','s_acctbal','cust05','http://user.it.uu.se/~udbl/sard/customer05#supplier_s_acctbal');
insert into customer05.pmap values ('supplier','s_comment','cust05','http://user.it.uu.se/~udbl/sard/customer05#supplier_s_comment');
insert into customer05.pmap values ('supplier','s_nationkey','cust05','http://user.it.uu.se/~udbl/sard/customer05#supplier_s_nationkey');
insert into customer05.pmap values ('nation','n_nationkey','cust05','http://user.it.uu.se/~udbl/sard/customer05#nation_n_nationkey');
insert into customer05.pmap values ('nation','n_name','cust05','http://user.it.uu.se/~udbl/sard/customer05#nation_n_name');
insert into customer05.pmap values ('nation','n_regionkey','cust05','http://user.it.uu.se/~udbl/sard/customer05#nation_n_regionkey');
insert into customer05.pmap values ('nation','n_comment','cust05','http://user.it.uu.se/~udbl/sard/customer05#nation_n_comment');
insert into customer05.pmap values ('partsupp','ps_partkey','cust05','http://user.it.uu.se/~udbl/sard/customer05#partsupp_ps_partkey');
insert into customer05.pmap values ('partsupp','ps_suppkey','cust05','http://user.it.uu.se/~udbl/sard/customer05#partsupp_ps_suppkey');
insert into customer05.pmap values ('partsupp','ps_availqty','cust05','http://user.it.uu.se/~udbl/sard/customer05#partsupp_ps_availqty');
insert into customer05.pmap values ('partsupp','ps_supplycost','cust05','http://user.it.uu.se/~udbl/sard/customer05#partsupp_ps_supplycost');
insert into customer05.pmap values ('partsupp','ps_comment','cust05','http://user.it.uu.se/~udbl/sard/customer05#partsupp_ps_comment');
insert into customer05.pmap values ('orders','o_orderkey','cust05','http://user.it.uu.se/~udbl/sard/customer05#orders_o_orderkey');
insert into customer05.pmap values ('orders','o_custkey','cust05','http://user.it.uu.se/~udbl/sard/customer05#orders_o_custkey');
insert into customer05.pmap values ('orders','o_sign','cust05','http://user.it.uu.se/~udbl/sard/customer05#orders_o_sign');
insert into customer05.pmap values ('orders','o_orderprice','cust05','http://user.it.uu.se/~udbl/sard/customer05#orders_o_orderprice');
insert into customer05.pmap values ('orders','o_orderdate','cust05','http://user.it.uu.se/~udbl/sard/customer05#orders_o_orderdate');
insert into customer05.pmap values ('orders','o_shippriority','cust05','http://user.it.uu.se/~udbl/sard/customer05#orders_o_shippriority');
insert into customer05.pmap values ('orders','o_clerkname','cust05','http://user.it.uu.se/~udbl/sard/customer05#orders_o_clerkname');
insert into customer05.pmap values ('orders','o_year','cust05','http://user.it.uu.se/~udbl/sard/customer05#orders_o_year');
insert into customer05.pmap values ('orders','o_comment','cust05','http://user.it.uu.se/~udbl/sard/customer05#orders_o_comment');

/*************************************/
create table customer1.cmap(
tab Varchar(50),
upv Varchar(10),
classid Varchar(100));

create table customer1.pmap(
tab Varchar(50),
col Varchar(50),
upv Varchar(10),
propid Varchar(100));

insert into customer1.cmap values ('part','cust1','http://user.it.uu.se/~udbl/sard/customer1#part');
insert into customer1.cmap values ('region','cust1','http://user.it.uu.se/~udbl/sard/customer1#region');
insert into customer1.cmap values ('customer','cust1','http://user.it.uu.se/~udbl/sard/customer1#customer');
insert into customer1.cmap values ('supplier','cust1','http://user.it.uu.se/~udbl/sard/customer1#supplier');
insert into customer1.cmap values ('nation','cust1','http://user.it.uu.se/~udbl/sard/customer1#nation');
insert into customer1.cmap values ('partsupp','cust1','http://user.it.uu.se/~udbl/sard/customer1#partsupp');
insert into customer1.cmap values ('orders','cust1','http://user.it.uu.se/~udbl/sard/customer1#orders');

insert into customer1.pmap values ('part','p_comment','cust1','http://user.it.uu.se/~udbl/sard/customer1#part_p_comment');
insert into customer1.pmap values ('part','p_price','cust1','http://user.it.uu.se/~udbl/sard/customer1#part_p_price');
insert into customer1.pmap values ('part','p_pack','cust1','http://user.it.uu.se/~udbl/sard/customer1#part_p_pack');
insert into customer1.pmap values ('part','p_size','cust1','http://user.it.uu.se/~udbl/sard/customer1#part_p_size');
insert into customer1.pmap values ('part','p_type','cust1','http://user.it.uu.se/~udbl/sard/customer1#part_p_type');
insert into customer1.pmap values ('part','p_brandname','cust1','http://user.it.uu.se/~udbl/sard/customer1#part_p_brandname');
insert into customer1.pmap values ('part','p_manufactname','cust1','http://user.it.uu.se/~udbl/sard/customer1#part_p_manufactname');
insert into customer1.pmap values ('part','p_name','cust1','http://user.it.uu.se/~udbl/sard/customer1#part_p_name');
insert into customer1.pmap values ('part','p_partkey','cust1','http://user.it.uu.se/~udbl/sard/customer1#part_p_partkey');
insert into customer1.pmap values ('region','r_comment','cust1','http://user.it.uu.se/~udbl/sard/customer1#region_r_comment');
insert into customer1.pmap values ('region','r_name','cust1','http://user.it.uu.se/~udbl/sard/customer1#region_r_name');
insert into customer1.pmap values ('region','r_regionkey','cust1','http://user.it.uu.se/~udbl/sard/customer1#region_r_regionkey');
insert into customer1.pmap values ('customer','c_custkey','cust1','http://user.it.uu.se/~udbl/sard/customer1#customer_c_custkey');
insert into customer1.pmap values ('customer','c_name','cust1','http://user.it.uu.se/~udbl/sard/customer1#customer_c_name');
insert into customer1.pmap values ('customer','c_address','cust1','http://user.it.uu.se/~udbl/sard/customer1#customer_c_address');
insert into customer1.pmap values ('customer','c_nationkey','cust1','http://user.it.uu.se/~udbl/sard/customer1#customer_c_nationkey');
insert into customer1.pmap values ('customer','c_phone','cust1','http://user.it.uu.se/~udbl/sard/customer1#customer_c_phone');
insert into customer1.pmap values ('customer','c_acctbal','cust1','http://user.it.uu.se/~udbl/sard/customer1#customer_c_acctbal');
insert into customer1.pmap values ('customer','c_mktsegment','cust1','http://user.it.uu.se/~udbl/sard/customer1#customer_c_mktsegment');
insert into customer1.pmap values ('customer','c_comment','cust1','http://user.it.uu.se/~udbl/sard/customer1#customer_c_comment');
insert into customer1.pmap values ('supplier','s_suppkey','cust1','http://user.it.uu.se/~udbl/sard/customer1#supplier_s_suppkey');
insert into customer1.pmap values ('supplier','s_name','cust1','http://user.it.uu.se/~udbl/sard/customer1#supplier_s_name');
insert into customer1.pmap values ('supplier','s_address','cust1','http://user.it.uu.se/~udbl/sard/customer1#supplier_s_address');
insert into customer1.pmap values ('supplier','s_phone','cust1','http://user.it.uu.se/~udbl/sard/customer1#supplier_s_phone');
insert into customer1.pmap values ('supplier','s_acctbal','cust1','http://user.it.uu.se/~udbl/sard/customer1#supplier_s_acctbal');
insert into customer1.pmap values ('supplier','s_comment','cust1','http://user.it.uu.se/~udbl/sard/customer1#supplier_s_comment');
insert into customer1.pmap values ('supplier','s_nationkey','cust1','http://user.it.uu.se/~udbl/sard/customer1#supplier_s_nationkey');
insert into customer1.pmap values ('nation','n_nationkey','cust1','http://user.it.uu.se/~udbl/sard/customer1#nation_n_nationkey');
insert into customer1.pmap values ('nation','n_name','cust1','http://user.it.uu.se/~udbl/sard/customer1#nation_n_name');
insert into customer1.pmap values ('nation','n_regionkey','cust1','http://user.it.uu.se/~udbl/sard/customer1#nation_n_regionkey');
insert into customer1.pmap values ('nation','n_comment','cust1','http://user.it.uu.se/~udbl/sard/customer1#nation_n_comment');
insert into customer1.pmap values ('partsupp','ps_partkey','cust1','http://user.it.uu.se/~udbl/sard/customer1#partsupp_ps_partkey');
insert into customer1.pmap values ('partsupp','ps_suppkey','cust1','http://user.it.uu.se/~udbl/sard/customer1#partsupp_ps_suppkey');
insert into customer1.pmap values ('partsupp','ps_availqty','cust1','http://user.it.uu.se/~udbl/sard/customer1#partsupp_ps_availqty');
insert into customer1.pmap values ('partsupp','ps_supplycost','cust1','http://user.it.uu.se/~udbl/sard/customer1#partsupp_ps_supplycost');
insert into customer1.pmap values ('partsupp','ps_comment','cust1','http://user.it.uu.se/~udbl/sard/customer1#partsupp_ps_comment');
insert into customer1.pmap values ('orders','o_orderkey','cust1','http://user.it.uu.se/~udbl/sard/customer1#orders_o_orderkey');
insert into customer1.pmap values ('orders','o_custkey','cust1','http://user.it.uu.se/~udbl/sard/customer1#orders_o_custkey');
insert into customer1.pmap values ('orders','o_sign','cust1','http://user.it.uu.se/~udbl/sard/customer1#orders_o_sign');
insert into customer1.pmap values ('orders','o_orderprice','cust1','http://user.it.uu.se/~udbl/sard/customer1#orders_o_orderprice');
insert into customer1.pmap values ('orders','o_orderdate','cust1','http://user.it.uu.se/~udbl/sard/customer1#orders_o_orderdate');
insert into customer1.pmap values ('orders','o_shippriority','cust1','http://user.it.uu.se/~udbl/sard/customer1#orders_o_shippriority');
insert into customer1.pmap values ('orders','o_clerkname','cust1','http://user.it.uu.se/~udbl/sard/customer1#orders_o_clerkname');
insert into customer1.pmap values ('orders','o_year','cust1','http://user.it.uu.se/~udbl/sard/customer1#orders_o_year');
insert into customer1.pmap values ('orders','o_comment','cust1','http://user.it.uu.se/~udbl/sard/customer1#orders_o_comment');


CREATE VIEW customer1.customer_c_custkey(S,P,V)
AS SELECT CM.classid + '/_' +
CAST(C.c_custkey AS VARCHAR(25)),
PM.propid, CAST(C.c_custkey AS VARCHAR(25))
FROM customer1.customer C, customer1.cmap CM, customer1.pmap PM
WHERE PM.tab = 'customer' AND
PM.col = 'c_custkey' AND
PM.upv = 'cust1' AND
CM.tab = 'customer' AND
CM.upv = 'cust1';

CREATE VIEW customer1.customer_c_name(S,P,V)
AS SELECT CM.classid + '/_' +
CAST(C.c_custkey AS VARCHAR(25)),
PM.propid, CAST(C.c_name AS VARCHAR(25))
FROM customer1.customer C, customer1.cmap CM, customer1.pmap PM
WHERE PM.tab = 'customer' AND
PM.col = 'c_name' AND
PM.upv = 'cust1' AND
CM.tab = 'customer' AND
CM.upv = 'cust1';

CREATE VIEW customer1.customer_c_address(S,P,V)
AS SELECT CM.classid + '/_' +
CAST(C.c_custkey AS VARCHAR(25)),
PM.propid, CAST(C.c_address AS VARCHAR(25))
FROM customer1.customer C, customer1.cmap CM, customer1.pmap PM
WHERE PM.tab = 'customer' AND
PM.col = 'c_address' AND
PM.upv = 'cust1' AND
CM.tab = 'customer' AND
CM.upv = 'cust1';

CREATE VIEW customer1.customer_c_nationkey(S,P,V)
AS SELECT CM.classid + '/_' +
CAST(C.c_custkey AS VARCHAR(25)),
PM.propid, CAST(C.c_nationkey AS VARCHAR(25))
FROM customer1.customer C, customer1.cmap CM, customer1.pmap PM
WHERE PM.tab = 'customer' AND
PM.col = 'c_nationkey' AND
PM.upv = 'cust1' AND
CM.tab = 'customer' AND
CM.upv = 'cust1';

CREATE VIEW customer1.customer_c_phone(S,P,V)
AS SELECT CM.classid + '/_' +
CAST(C.c_custkey AS VARCHAR(25)),
PM.propid, CAST(C.c_phone AS VARCHAR(25))
FROM customer1.customer C, customer1.cmap CM, customer1.pmap PM
WHERE PM.tab = 'customer' AND
PM.col = 'c_phone' AND
PM.upv = 'cust1' AND
CM.tab = 'customer' AND
CM.upv = 'cust1';

CREATE VIEW customer1.customer_c_acctbal(S,P,V)
AS SELECT CM.classid + '/_' +
CAST(C.c_custkey AS VARCHAR(25)),
PM.propid, CAST(C.c_acctbal AS VARCHAR(25))
FROM customer1.customer C, customer1.cmap CM, customer1.pmap PM
WHERE PM.tab = 'customer' AND
PM.col = 'c_acctbal' AND
PM.upv = 'cust1' AND
CM.tab = 'customer' AND
CM.upv = 'cust1';

CREATE VIEW customer1.customer_c_mktsegment(S,P,V)
AS SELECT CM.classid + '/_' +
CAST(C.c_custkey AS VARCHAR(25)),
PM.propid, CAST(C.c_mktsegment AS VARCHAR(25))
FROM customer1.customer C, customer1.cmap CM, customer1.pmap PM
WHERE PM.tab = 'customer' AND
PM.col = 'c_mktsegment' AND
PM.upv = 'cust1' AND
CM.tab = 'customer' AND
CM.upv = 'cust1';

CREATE VIEW customer1.customer_c_comment(S,P,V)
AS SELECT CM.classid + '/_' +
CAST(C.c_custkey AS VARCHAR(25)),
PM.propid, CAST(C.c_comment AS VARCHAR(25))
FROM customer1.customer C, customer1.cmap CM, customer1.pmap PM
WHERE PM.tab = 'customer' AND
PM.col = 'c_comment' AND
PM.upv = 'cust1' AND
CM.tab = 'customer' AND
CM.upv = 'cust1';

CREATE VIEW customer1.nation_n_nationkey(S,P,V)
AS SELECT CM.classid + '/_' +
CAST(C.n_nationkey AS VARCHAR(25)),
PM.propid, CAST(C.n_nationkey AS VARCHAR(25))
FROM customer1.nation C, customer1.cmap CM, customer1.pmap PM
WHERE PM.tab = 'nation' AND
PM.col = 'n_nationkey' AND
PM.upv = 'cust1' AND
CM.tab = 'nation' AND
CM.upv = 'cust1';

CREATE VIEW customer1.nation_n_name(S,P,V)
AS SELECT CM.classid + '/_' +
CAST(C.n_nationkey AS VARCHAR(25)),
PM.propid, CAST(C.n_name AS VARCHAR(25))
FROM customer1.nation C, customer1.cmap CM, customer1.pmap PM
WHERE PM.tab = 'nation' AND
PM.col = 'n_name' AND
PM.upv = 'cust1' AND
CM.tab = 'nation' AND
CM.upv = 'cust1';

CREATE VIEW customer1.nation_n_regionkey(S,P,V)
AS SELECT CM.classid + '/_' +
CAST(C.n_nationkey AS VARCHAR(25)),
PM.propid, CAST(C.n_regionkey AS VARCHAR(25))
FROM customer1.nation C, customer1.cmap CM, customer1.pmap PM
WHERE PM.tab = 'nation' AND
PM.col = 'n_regionkey' AND
PM.upv = 'cust1' AND
CM.tab = 'nation' AND
CM.upv = 'cust1';

CREATE VIEW customer1.nation_n_comment(S,P,V)
AS SELECT CM.classid + '/_' +
CAST(C.n_nationkey AS VARCHAR(25)),
PM.propid, CAST(C.n_comment AS VARCHAR(25))
FROM customer1.nation C, customer1.cmap CM, customer1.pmap PM
WHERE PM.tab = 'nation' AND
PM.col = 'n_comment' AND
PM.upv = 'cust1' AND
CM.tab = 'nation' AND
CM.upv = 'cust1';

CREATE VIEW customer1.part_p_partkey(S,P,V)
AS SELECT CM.classid + '/_' +
CAST(C.p_partkey AS VARCHAR(25)),
PM.propid, CAST(C.p_partkey AS VARCHAR(25))
FROM customer1.part C, customer1.cmap CM, customer1.pmap PM
WHERE PM.tab = 'part' AND
PM.col = 'p_partkey' AND
PM.upv = 'cust1' AND
CM.tab = 'part' AND
CM.upv = 'cust1';

CREATE VIEW customer1.part_p_name(S,P,V)
AS SELECT CM.classid + '/_' +
CAST(C.p_partkey AS VARCHAR(25)),
PM.propid, CAST(C.p_name AS VARCHAR(25))
FROM customer1.part C, customer1.cmap CM, customer1.pmap PM
WHERE PM.tab = 'part' AND
PM.col = 'p_name' AND
PM.upv = 'cust1' AND
CM.tab = 'part' AND
CM.upv = 'cust1';


CREATE VIEW customer1.part_p_manufactname(S,P,V)
AS SELECT CM.classid + '/_' +
CAST(C.p_partkey AS VARCHAR(25)),
PM.propid, CAST(C.p_manufactname AS VARCHAR(25))
FROM customer1.part C, customer1.cmap CM, customer1.pmap PM
WHERE PM.tab = 'part' AND
PM.col = 'p_manufactname' AND
PM.upv = 'cust1' AND
CM.tab = 'part' AND
CM.upv = 'cust1';

CREATE VIEW customer1.part_p_brandname(S,P,V)
AS SELECT CM.classid + '/_' +
CAST(C.p_partkey AS VARCHAR(25)),
PM.propid, CAST(C.p_brandname AS VARCHAR(25))
FROM customer1.part C, customer1.cmap CM, customer1.pmap PM
WHERE PM.tab = 'part' AND
PM.col = 'p_brandname' AND
PM.upv = 'cust1' AND
CM.tab = 'part' AND
CM.upv = 'cust1';

CREATE VIEW customer1.part_p_type(S,P,V)
AS SELECT CM.classid + '/_' +
CAST(C.p_partkey AS VARCHAR(25)),
PM.propid, CAST(C.p_type AS VARCHAR(25))
FROM customer1.part C, customer1.cmap CM, customer1.pmap PM
WHERE PM.tab = 'part' AND
PM.col = 'p_type' AND
PM.upv = 'cust1' AND
CM.tab = 'part' AND
CM.upv = 'cust1';

CREATE VIEW customer1.part_p_size(S,P,V)
AS SELECT CM.classid + '/_' +
CAST(C.p_partkey AS VARCHAR(25)),
PM.propid, CAST(C.p_size AS VARCHAR(25))
FROM customer1.part C, customer1.cmap CM, customer1.pmap PM
WHERE PM.tab = 'part' AND
PM.col = 'p_size' AND
PM.upv = 'cust1' AND
CM.tab = 'part' AND
CM.upv = 'cust1';

CREATE VIEW customer1.part_p_pack(S,P,V)
AS SELECT CM.classid + '/_' +
CAST(C.p_partkey AS VARCHAR(25)),
PM.propid, CAST(C.p_pack AS VARCHAR(25))
FROM customer1.part C, customer1.cmap CM, customer1.pmap PM
WHERE PM.tab = 'part' AND
PM.col = 'p_pack' AND
PM.upv = 'cust1' AND
CM.tab = 'part' AND
CM.upv = 'cust1';

CREATE VIEW customer1.part_p_price(S,P,V)
AS SELECT CM.classid + '/_' +
CAST(C.p_partkey AS VARCHAR(25)),
PM.propid, CAST(C.p_price AS VARCHAR(25))
FROM customer1.part C, customer1.cmap CM, customer1.pmap PM
WHERE PM.tab = 'part' AND
PM.col = 'p_price' AND
PM.upv = 'cust1' AND
CM.tab = 'part' AND
CM.upv = 'cust1';

CREATE VIEW customer1.part_p_comment(S,P,V)
AS SELECT CM.classid + '/_' +
CAST(C.p_partkey AS VARCHAR(25)),
PM.propid, CAST(C.p_comment AS VARCHAR(25))
FROM customer1.part C, customer1.cmap CM, customer1.pmap PM
WHERE PM.tab = 'part' AND
PM.col = 'p_comment' AND
PM.upv = 'cust1' AND
CM.tab = 'part' AND
CM.upv = 'cust1';

CREATE VIEW customer1.region_r_regionkey(S,P,V)
AS SELECT CM.classid + '/_' +
CAST(C.r_regionkey AS VARCHAR(25)),
PM.propid, CAST(C.r_regionkey AS VARCHAR(25))
FROM customer1.region C, customer1.cmap CM, customer1.pmap PM
WHERE PM.tab = 'region' AND
PM.col = 'r_regionkey' AND
PM.upv = 'cust1' AND
CM.tab = 'region' AND
CM.upv = 'cust1';


CREATE VIEW customer1.region_r_name(S,P,V)
AS SELECT CM.classid + '/_' +
CAST(C.r_regionkey AS VARCHAR(25)),
PM.propid, CAST(C.r_name AS VARCHAR(25))
FROM customer1.region C, customer1.cmap CM, customer1.pmap PM
WHERE PM.tab = 'region' AND
PM.col = 'r_name' AND
PM.upv = 'cust1' AND
CM.tab = 'region' AND
CM.upv = 'cust1';

CREATE VIEW customer1.region_r_comment(S,P,V)
AS SELECT CM.classid + '/_' +
CAST(C.r_regionkey AS VARCHAR(25)),
PM.propid, CAST(C.r_comment AS VARCHAR(25))
FROM customer1.region C, customer1.cmap CM, customer1.pmap PM
WHERE PM.tab = 'region' AND
PM.col = 'r_comment' AND
PM.upv = 'cust1' AND
CM.tab = 'region' AND
CM.upv = 'cust1';


CREATE VIEW customer1.supplier_s_suppkey(S,P,V)
AS SELECT CM.classid + '/_' +
CAST(C.s_suppkey AS VARCHAR(25)),
PM.propid, CAST(C.s_suppkey AS VARCHAR(25))
FROM customer1.supplier C, customer1.cmap CM, customer1.pmap PM
WHERE PM.tab = 'supplier' AND
PM.col = 's_suppkey' AND
PM.upv = 'cust1' AND
CM.tab = 'supplier' AND
CM.upv = 'cust1';

CREATE VIEW customer1.supplier_s_name(S,P,V)
AS SELECT CM.classid + '/_' +
CAST(C.s_suppkey AS VARCHAR(25)),
PM.propid, CAST(C.s_name AS VARCHAR(25))
FROM customer1.supplier C, customer1.cmap CM, customer1.pmap PM
WHERE PM.tab = 'supplier' AND
PM.col = 's_name' AND
PM.upv = 'cust1' AND
CM.tab = 'supplier' AND
CM.upv = 'cust1';

CREATE VIEW customer1.supplier_s_address(S,P,V)
AS SELECT CM.classid + '/_' +
CAST(C.s_suppkey AS VARCHAR(25)),
PM.propid, CAST(C.s_address AS VARCHAR(25))
FROM customer1.supplier C, customer1.cmap CM, customer1.pmap PM
WHERE PM.tab = 'supplier' AND
PM.col = 's_address' AND
PM.upv = 'cust1' AND
CM.tab = 'supplier' AND
CM.upv = 'cust1';

CREATE VIEW customer1.supplier_s_nationkey(S,P,V)
AS SELECT CM.classid + '/_' +
CAST(C.s_suppkey AS VARCHAR(25)),
PM.propid, CAST(C.s_nationkey AS VARCHAR(25))
FROM customer1.supplier C, customer1.cmap CM, customer1.pmap PM
WHERE PM.tab = 'supplier' AND
PM.col = 's_nationkey' AND
PM.upv = 'cust1' AND
CM.tab = 'supplier' AND
CM.upv = 'cust1';

CREATE VIEW customer1.supplier_s_phone(S,P,V)
AS SELECT CM.classid + '/_' +
CAST(C.s_suppkey AS VARCHAR(25)),
PM.propid, CAST(C.s_phone AS VARCHAR(25))
FROM customer1.supplier C, customer1.cmap CM, customer1.pmap PM
WHERE PM.tab = 'supplier' AND
PM.col = 's_phone' AND
PM.upv = 'cust1' AND
CM.tab = 'supplier' AND
CM.upv = 'cust1';

CREATE VIEW customer1.supplier_s_acctbal(S,P,V)
AS SELECT CM.classid + '/_' +
CAST(C.s_suppkey AS VARCHAR(25)),
PM.propid, CAST(C.s_acctbal AS VARCHAR(25))
FROM customer1.supplier C, customer1.cmap CM, customer1.pmap PM
WHERE PM.tab = 'supplier' AND
PM.col = 's_acctbal' AND
PM.upv = 'cust1' AND
CM.tab = 'supplier' AND
CM.upv = 'cust1';

CREATE VIEW customer1.supplier_s_comment(S,P,V)
AS SELECT CM.classid + '/_' +
CAST(C.s_suppkey AS VARCHAR(25)),
PM.propid, CAST(C.s_comment AS VARCHAR(25))
FROM customer1.supplier C, customer1.cmap CM, customer1.pmap PM
WHERE PM.tab = 'supplier' AND
PM.col = 's_comment' AND
PM.upv = 'cust1' AND
CM.tab = 'supplier' AND
CM.upv = 'cust1';

CREATE VIEW customer1.orders_o_orderkey(S,P,V)
AS
select cm.classid +'/_'+ cast(t.o_orderkey as Varchar(25)), pm.propid, cast (t.o_orderkey as Varchar(25)) 
FROM customer1.orders t, customer1.cmap cm, customer1.pmap pm WHERE cm.tab='orders' AND cm.upv='cust1' and cm.upv='cust1' 
AND pm.tab='orders' and pm.col='o_orderkey' and pm.upv='cust1';

CREATE VIEW customer1.orders_o_custkey(S,P,V)
AS
select cm.classid +'/_'+ cast(t.o_orderkey as Varchar(25)), pm.propid, cast (t.o_custkey as Varchar(25)) 
FROM customer1.orders t, customer1.cmap cm, customer1.pmap pm WHERE cm.tab='orders' AND cm.upv='cust1' and cm.upv='cust1' 
AND pm.tab='orders' and pm.col='o_custkey' and pm.upv='cust1';

CREATE VIEW customer1.orders_o_sign(S,P,V)
AS
select cm.classid +'/_'+ cast(t.o_orderkey as Varchar(25)), pm.propid, cast (t.o_sign as Varchar(25)) 
FROM customer1.orders t, customer1.cmap cm, customer1.pmap pm WHERE cm.tab='orders' AND cm.upv='cust1' and cm.upv='cust1' 
AND pm.tab='orders' and pm.col='o_sign' and pm.upv='cust1';

CREATE VIEW customer1.orders_o_orderprice(S,P,V)
AS
select cm.classid +'/_'+ cast(t.o_orderkey as Varchar(25)), pm.propid, cast (t.o_orderprice as Varchar(25)) 
FROM customer1.orders t, customer1.cmap cm, customer1.pmap pm WHERE cm.tab='orders' AND cm.upv='cust1' and cm.upv='cust1' 
AND pm.tab='orders' and pm.col='o_orderprice' and pm.upv='cust1';

CREATE VIEW customer1.orders_o_orderdate(S,P,V)
AS
select cm.classid +'/_'+ cast(t.o_orderkey as Varchar(25)), pm.propid, cast (t.o_orderdate as Varchar(100)) 
FROM customer1.orders t, customer1.cmap cm, customer1.pmap pm WHERE cm.tab='orders' AND cm.upv='cust1' and cm.upv='cust1' 
AND pm.tab='orders' and pm.col='o_orderdate' and pm.upv='cust1';

CREATE VIEW customer1.orders_o_shippriority(S,P,V)
AS
(select cm.classid +'/_'+ cast(t.o_orderkey as Varchar(25)), pm.propid, cast (t.o_shippriority as Varchar(25)) 
FROM customer1.orders t, customer1.cmap cm, customer1.pmap pm WHERE cm.tab='orders' AND cm.upv='cust1' and cm.upv='cust1' 
AND pm.tab='orders' and pm.col='o_shippriority' and pm.upv='cust1') ;

CREATE VIEW customer1.orders_o_clerkname(S,P,V)
AS
(select cm.classid +'/_'+ cast(t.o_orderkey as Varchar(25)), pm.propid, cast (t.o_clerkname as Varchar(25)) 
FROM customer1.orders t, customer1.cmap cm, customer1.pmap pm WHERE cm.tab='orders' AND cm.upv='cust1' and cm.upv='cust1' 
AND pm.tab='orders' and pm.col='o_clerkname' and pm.upv='cust1'); 

CREATE VIEW customer1.orders_o_year(S,P,V)
AS
(select cm.classid +'/_'+ cast(t.o_orderkey as Varchar(25)), pm.propid, cast (t.o_year as Varchar(25)) 
FROM customer1.orders t, customer1.cmap cm, customer1.pmap pm WHERE cm.tab='orders' AND cm.upv='cust1' and cm.upv='cust1' 
AND pm.tab='orders' and pm.col='o_year' and pm.upv='cust1'); 


CREATE VIEW customer1.orders_o_comment(S,P,V)
AS
(select cm.classid +'/'+ cast(t.o_orderkey as Varchar(25)), pm.propid, cast (t.o_comment as Varchar(500)) 
FROM customer1.orders t, customer1.cmap cm, customer1.pmap pm WHERE cm.tab='orders' AND cm.upv='cust1' and cm.upv='cust1' 
AND pm.tab='orders' and pm.col='o_comment' and pm.upv='cust1'); 

CREATE VIEW customer1.partsupp_ps_partkey(S,P,V)
AS
(select cm.classid +'/_'+ cast(t.ps_partkey as Varchar(25)) + '_' + cast(t.ps_suppkey as Varchar(25)), pm.propid, cast (t.ps_partkey as Varchar(25)) 
FROM customer1.partsupp t, customer1.cmap cm, customer1.pmap pm WHERE cm.tab='partsupp' AND cm.upv='cust1' and cm.upv='cust1' 
AND pm.tab='partsupp' and pm.col='ps_partkey' and pm.upv='cust1') ;


CREATE VIEW customer1.partsupp_ps_suppkey(S,P,V)
AS
(select cm.classid +'/_'+ cast(t.ps_partkey as Varchar(25)) + '_' + cast(t.ps_suppkey as Varchar(25)), pm.propid, cast (t.ps_suppkey as Varchar(25)) 
FROM customer1.partsupp t, customer1.cmap cm, customer1.pmap pm WHERE cm.tab='partsupp' AND cm.upv='cust1' and cm.upv='cust1' 
AND pm.tab='partsupp' and pm.col='ps_suppkey' and pm.upv='cust1'); 

CREATE VIEW customer1.partsupp_ps_availqty(S,P,V)
AS
(select cm.classid +'/_'+ cast(t.ps_partkey as Varchar(25)) + '_' + cast(t.ps_suppkey as Varchar(25)), pm.propid, cast (t.ps_availqty as Varchar(25)) 
FROM customer1.partsupp t, customer1.cmap cm, customer1.pmap pm WHERE cm.tab='partsupp' AND cm.upv='cust1' and cm.upv='cust1' 
AND pm.tab='partsupp' and pm.col='ps_availqty' and pm.upv='cust1'); 

CREATE VIEW customer1.partsupp_ps_supplycost(S,P,V)
AS
(select cm.classid +'/_'+ cast(t.ps_partkey as Varchar(25)) + '_' + cast(t.ps_suppkey as Varchar(25)), pm.propid, cast (t.ps_supplycost as Varchar(25)) 
FROM customer1.partsupp t, customer1.cmap cm, customer1.pmap pm WHERE cm.tab='partsupp' AND cm.upv='cust1' and cm.upv='cust1' 
AND pm.tab='partsupp' and pm.col='ps_supplycost' and pm.upv='cust1'); 


CREATE VIEW customer1.partsupp_ps_comment(S,P,V)
AS
(select cm.classid +'/_'+ cast(t.ps_partkey as Varchar(25)) + '_' + cast(t.ps_suppkey as Varchar(200)), pm.propid, cast (t.ps_comment as Varchar(25)) 
FROM customer1.partsupp t, customer1.cmap cm, customer1.pmap pm WHERE cm.tab='partsupp' AND cm.upv='cust1' and cm.upv='cust1' 
AND pm.tab='partsupp' and pm.col='ps_comment' and pm.upv='cust1') ;


CREATE VIEW customer1.cust1(S,P,V)
AS	(SELECT * from customer1.customer_c_acctbal)	UNION ALL
	(SELECT * from customer1.customer_c_address)	UNION ALL
	(SELECT * from customer1.customer_c_comment)	UNION ALL	
	(SELECT * from customer1.customer_c_custkey)	UNION ALL
	(SELECT * from customer1.customer_c_mktsegment)	UNION ALL
	(SELECT * from customer1.customer_c_name)		UNION ALL
	(SELECT * from customer1.customer_c_nationkey)	UNION ALL
	(SELECT * from customer1.customer_c_phone)		UNION ALL
	(SELECT * from customer1.nation_n_comment)		UNION ALL
	(SELECT * from customer1.nation_n_name)			UNION ALL
	(SELECT * from customer1.nation_n_nationkey)	UNION ALL
	(SELECT * from customer1.nation_n_regionkey)	UNION ALL
	(SELECT * from customer1.part_p_brandname)		UNION ALL
	(SELECT * from customer1.part_p_comment)		UNION ALL	
	(SELECT * from customer1.part_p_manufactname)	UNION ALL
	(SELECT * from customer1.part_p_name)			UNION ALL
	(SELECT * from customer1.part_p_pack)			UNION ALL
	(SELECT * from customer1.part_p_partkey)		UNION ALL
	(SELECT * from customer1.part_p_price)			UNION ALL
	(SELECT * from customer1.part_p_size)			UNION ALL
	(SELECT * from customer1.part_p_type)			UNION ALL
	(SELECT * from customer1.region_r_comment)		UNION ALL
	(SELECT * from customer1.region_r_name)			UNION ALL
	(SELECT * from customer1.region_r_regionkey)	UNION ALL
	(SELECT * from customer1.supplier_s_acctbal)	UNION ALL
	(SELECT * from customer1.supplier_s_comment)	UNION ALL
	(SELECT * from customer1.supplier_s_name)		UNION ALL
	(SELECT * from customer1.supplier_s_nationkey)	UNION ALL
	(SELECT * from customer1.supplier_s_phone)		UNION ALL
	(SELECT * from customer1.supplier_s_suppkey)	UNION ALL
	(SELECT * from customer1.supplier_s_suppkey)	UNION ALL
	(SELECT * from customer1.orders_o_orderkey)		UNION ALL
	(SELECT * from customer1.orders_o_custkey)		UNION ALL
	(SELECT * from customer1.orders_o_sign)			UNION ALL
	(SELECT * from customer1.orders_o_orderprice)	UNION ALL
	(SELECT * from customer1.orders_o_orderdate)	UNION ALL
	(SELECT * from customer1.orders_o_shippriority)	UNION ALL
	(SELECT * from customer1.orders_o_clerkname)	UNION ALL
	(SELECT * from customer1.orders_o_year)			UNION ALL
	(SELECT * from customer1.orders_o_comment)		UNION ALL
	(SELECT * from customer1.partsupp_ps_partkey)	UNION ALL
	(SELECT * from customer1.partsupp_ps_suppkey)	UNION ALL
	(SELECT * from customer1.partsupp_ps_availqty)	UNION ALL
	(SELECT * from customer1.partsupp_ps_supplycost)	UNION ALL
	(SELECT * from customer1.partsupp_ps_comment);




























