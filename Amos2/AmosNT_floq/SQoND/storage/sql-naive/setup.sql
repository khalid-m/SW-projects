-- http://dev.mysql.com/doc/refman/5.0/en/

-- CREATE DATABASE IF NOT EXISTS rdfstore;

-- USE rdfstore;

-- ******* LOADABLE SCRIPT BEGIN *******

DROP TABLE IF EXISTS Triples;

CREATE TABLE Triples (s VARCHAR(100), p VARCHAR(100), o VARCHAR(520), otype INTEGER);

CREATE INDEX s_index ON Triples(s);

CREATE INDEX p_index ON Triples(p);

-- CREATE INDEX o_index ON Triples(o);

CREATE INDEX ot_intex ON Triples(otype,o);

-- ******* LOADABLE SCRIPT END *******

-- Test data:

-- INSERT INTO Triples VALUES ("<http://s", "http://p", "http://o", 1);

