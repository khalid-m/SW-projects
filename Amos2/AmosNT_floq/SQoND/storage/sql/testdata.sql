-- 'manually' insert data from test/data/turtle/alltypes.ttl + one long string example

-- USE rdfstore2; 

INSERT INTO URI(id,uri) VALUES
(100,'http://example.org/ns#p'),
(101,'http://example.org/ns#x1'),
(102,'http://example.org/ns#x2'),
(103,'http://example.org/ns#x3'),
(104,'http://example.org/ns#x4'),
(105,'http://example.org/ns#x5'),
(106,'http://example.org/ns#x6'),
(107,'http://example.org/ns#x7'),
(108,'http://example.org/ns#x8'),
(109,'http://example.org/ns#x9'),
(110,'http://example.org/ns#x10'),
(111,'http://example.org/ns#x11'),
(112,'http://example.org/datatype#specialDatatype'),
(113,'http://example.org/ns#katze'),
(114,'_:felis'),
(115,'_:b0'),
(116,'http://example.org/ns#x12');

INSERT INTO URITriples(s,p,o) VALUES
(108,100,113),
(109,100,114),
(110,100,115);

INSERT INTO LiteralTriples(s,p,o,type) VALUES
(101,100,'5',1),
(102,100,'3.14',2),
(103,100,'true',3),
(104,100,'2005-02-28T00-00-00Z',4),
(105,100,'cat',5),
(106,100,'katt@sv',6),
(111,100,'chat',112);

INSERT INTO LongStrings(id,str) VALUES
(1,'Feles (-is, c.), sive felis (confer cattus, murilegus), est species parvorum mammiferorum carnivororum familiae Felidarum. Species ex una vel pluribus speciebus feris generis Felis orta est: Felis silvestris Europae, Felis libyca Africae, aut Felis manul Pallas Asiae.[1] Aegypti feles domesticos habuerunt tertio millennio a.C.n., fortasse etiam antea, cum hominibus ergo quattuor milia annorum feles convivit.[2] Felinologia est biologiae ramus qui de felinis, inter quas feles, tractat.@la');


INSERT INTO LiteralTriples(s,p,o,type,longstr) VALUES 
(116,100,'',6,1);

INSERT INTO ArrayTriples(s,p,type,arrayid,ndims,size0,size1)
VALUES (107,100,0,1,2,2,3);

INSERT INTO ArrayChunks(arrayid,chunkid,chunk) VALUES 
(1,0,x'010000000200000003000000040000000500000006000000');

