-- http://dev.mysql.com/doc/refman/5.0/en/

-- CREATE DATABASE IF NOT EXISTS rdfstore2;

-- USE rdfstore2;

-- ******* LOADABLE SCRIPT BEGIN *******

-- 0. Cleanup

DROP TABLE IF EXISTS URITriples;

DROP TABLE IF EXISTS LiteralTriples;

DROP TABLE IF EXISTS LongStrings;

DROP TABLE IF EXISTS ArrayChunks;

DROP TABLE IF EXISTS ArrayTriples;

DROP TABLE IF EXISTS URI;

DROP TABLE IF EXISTS Parameters;


-- 1. URI Table to store all URIs

CREATE TABLE Parameters (name VARCHAR(128) PRIMARY KEY,
                         value INTEGER);

CREATE TABLE URI (id INTEGER AUTO_INCREMENT PRIMARY KEY, 
                  uri VARCHAR(128) UNIQUE KEY)
	DEFAULT CHARACTER SET = utf8
	COLLATE = utf8_bin;

CREATE INDEX URI_id ON URI(id);

CREATE INDEX URI_uri ON URI(uri);

-- 2. URITriple Table 

CREATE TABLE URITriples (graph INTEGER, s INTEGER, p INTEGER, o INTEGER,
                         CONSTRAINT URITriples_graph_fk FOREIGN KEY (graph) REFERENCES URI(id),
                         CONSTRAINT URITriples_s_fk FOREIGN KEY (s) REFERENCES URI(id),
                         CONSTRAINT URITriples_p_fk FOREIGN KEY (p) REFERENCES URI(id),
                         CONSTRAINT URITriples_o_fk FOREIGN KEY (o) REFERENCES URI(id));

CREATE INDEX URITriples_graph on URITriples(graph);

CREATE INDEX URITriples_s on URITriples(s);

CREATE INDEX URITriples_p on URITriples(p);

CREATE INDEX URITriples_o on URITriples(o);


-- 3. LiteralTriples Table

CREATE TABLE LongStrings (id INTEGER AUTO_INCREMENT PRIMARY KEY,
                          str TEXT);

CREATE INDEX LongStrings_id on LongStrings(id);

CREATE TABLE LiteralTriples (graph INTEGER, s INTEGER, p INTEGER, 
                             o VARCHAR(32), 
                             type INTEGER,
                             longstr INTEGER,
                             CONSTRAINT LiteralTriples_graph_fk FOREIGN KEY (graph) REFERENCES URI(id),
                             CONSTRAINT LiteralTriples_s_fk FOREIGN KEY (s) REFERENCES URI(id),
                             CONSTRAINT LiteralTriples_p_fk FOREIGN KEY (p) REFERENCES URI(id),
                             CONSTRAINT LiteralTriples_type_fk FOREIGN KEY (type) REFERENCES URI(id),
                             CONSTRAINT LiteralTriples_long_fk FOREIGN KEY (longstr) REFERENCES LongStrings(id))
	DEFAULT CHARACTER SET = utf8
	COLLATE = utf8_bin;

CREATE INDEX LiteralTriples_graph on LiteralTriples(graph);

CREATE INDEX LiteralTriples_s on LiteralTriples(s);

CREATE INDEX LiteralTriples_p on LiteralTriples(o);

CREATE INDEX LiteralTriples_o on LiteralTriples(o);

CREATE INDEX LiteralTriples_type on LiteralTriples(type);


-- 4. ArrayTriples Table

CREATE TABLE ArrayTriples (graph INTEGER, s INTEGER, p INTEGER,
                           type INTEGER,
                           arrayid INTEGER AUTO_INCREMENT PRIMARY KEY,
                           ndims INTEGER,
                           size0 INTEGER DEFAULT 0, 
                           size1 INTEGER DEFAULT 0, 
                           size2 INTEGER DEFAULT 0, 
                           size3 INTEGER DEFAULT 0,
                           CONSTRAINT ArrayTriples_graph_fk FOREIGN KEY (graph) REFERENCES URI(id),
                           CONSTRAINT ArrayTriples_s_fk FOREIGN KEY (s) REFERENCES URI(id),
                           CONSTRAINT ArrayTriples_p_fk FOREIGN KEY (p) REFERENCES URI(id));


CREATE INDEX ArrayTriples_graph on ArrayTriples(graph);

CREATE INDEX ArrayTriples_s on ArrayTriples(s);

CREATE INDEX ArrayTriples_p on ArrayTriples(p);

-- chunk field width is changed later from setup.osql

CREATE TABLE ArrayChunks (arrayid INTEGER,
                          chunkid INTEGER,
                          chunk BLOB,
                          CONSTRAINT ArrayChunks_arrayid_fk FOREIGN KEY (arrayid) REFERENCES ArrayTriples(arrayid));

CREATE INDEX ArrayChunks_id on ArrayChunks(arrayid,chunkid);


-- 5. View definitions

CREATE OR REPLACE VIEW UView 
  AS SELECT tr.s AS s, tr.p AS p, o_URI.uri AS o
       FROM URITriples AS tr JOIN URI as o_URI ON o_URI.id = tr.o;

CREATE OR REPLACE VIEW LView
  AS SELECT tr.s AS s, tr.p AS p, CASE WHEN ls.str IS NULL THEN tr.o ELSE ls.str END AS o, tr.type AS otype 
       FROM LiteralTriples AS tr LEFT JOIN LongStrings AS ls ON tr.longstr = ls.id;

CREATE OR REPLACE VIEW AView
  AS SELECT tr.s AS s, tr.p AS p, CAST(CONCAT(tr.type,'|',tr.arrayid,'|',tr.ndims,'|',tr.size0,'|',tr.size1,'|',tr.size2,'|',tr.size3) AS CHAR) AS o
          FROM ArrayTriples AS tr;

CREATE OR REPLACE VIEW GENERALVIEW
  AS ( SELECT s, p, o, 0 AS otype FROM UView )
     UNION
     ( SELECT s, p, o, otype FROM LView )
     UNION
     ( SELECT s, p, o, 7 AS otype FROM AView );