DROP FUNCTION IF EXISTS is_accident_area;
DROP FUNCTION IF EXISTS get_accident_seg;
DROP FUNCTION IF EXISTS is_smashed;
DROP FUNCTION IF EXISTS giveme_smashed_pos;
DROP FUNCTION IF EXISTS giveme_smashed_xway;
DROP PROCEDURE IF EXISTS add_accident;
DROP PROCEDURE IF EXISTS add_stopped_car;
DROP PROCEDURE IF EXISTS remove_stopped_cars;
DROP PROCEDURE IF EXISTS add_smashed_car;
DROP PROCEDURE IF EXISTS collided_vids_at;
DROP PROCEDURE IF EXISTS add_accident_remove_order;
DROP PROCEDURE IF EXISTS remove_accidents;
DROP PROCEDURE IF EXISTS check_kill_accident;
DROP PROCEDURE IF EXISTS accident_check;

delimiter //

CREATE PROCEDURE add_accident( lrxway TINYINT, lrseg TINYINT, lrdir BOOLEAN,
  lrtime SMALLINT, lrmin INTEGER )
BEGIN
  DECLARE EXIT HANDLER FOR 1062 BEGIN END;
  INSERT INTO accidents(xway,segment,direction,time,min)
    VALUES(lrxway, lrseg, lrdir, lrtime, lrmin);
END;

CREATE FUNCTION is_accident_area( lrxway TINYINT, lrseg TINYINT, lrdir BOOLEAN )
RETURNS BOOLEAN
BEGIN
  DECLARE res BOOLEAN DEFAULT false;
  SELECT count(*)>0 INTO res FROM accidents WHERE xway=lrxway AND
    (lrdir=1 AND direction=1 AND segment<=lrseg AND segment>lrseg-5 AND
    get_minute()>min) OR (lrdir=0 AND direction=0 AND segment>=lrseg AND
    segment<lrseg+5 AND get_minute()>min);
  RETURN res;
END;

CREATE FUNCTION get_accident_seg( lrxway TINYINT )
RETURNS TINYINT
BEGIN
  DECLARE res INTEGER DEFAULT 0;
  SELECT max(time) INTO res FROM accidents WHERE xway=lrxway;
  SELECT segment INTO res FROM accidents WHERE xway=lrxway AND time=res;
  RETURN res;
END;

CREATE PROCEDURE add_stopped_car( lrvid INTEGER, lrxway TINYINT,
  lrpos MEDIUMINT, lrdir BOOLEAN, lrtime SMALLINT, lrlane TINYINT )
BEGIN
  DECLARE EXIT HANDLER FOR 1062 BEGIN END;
  INSERT INTO stopped_cars(pos,xway,direction,time,vid,lane)
    VALUES(lrpos, lrxway, lrdir, lrtime, lrvid, lrlane);
END;

CREATE PROCEDURE remove_stopped_cars(sec SMALLINT)
BEGIN
  DELETE FROM stopped_cars WHERE time<sec-120;
END;

CREATE PROCEDURE add_smashed_car(lrvid INTEGER, lrpos MEDIUMINT, lrxway TINYINT,
  lrseg TINYINT, lrdir BOOLEAN, lrlane TINYINT )
BEGIN
  DECLARE EXIT HANDLER FOR 1062 BEGIN END;
  INSERT INTO smashed_cars(pos,xway,direction,segment,vid,lane)
    VALUES(lrpos, lrxway, lrdir, lrseg, lrvid, lrlane);
END;

CREATE FUNCTION is_smashed( lrvid INTEGER )
RETURNS BOOLEAN
BEGIN
DECLARE res BOOLEAN;
  SELECT count(*) INTO res FROM smashed_cars WHERE vid=lrvid;
RETURN res;
END;

CREATE FUNCTION giveme_smashed_pos( lrvid INTEGER )
RETURNS MEDIUMINT
BEGIN
  DECLARE res MEDIUMINT;
  SELECT pos INTO res FROM smashed_cars WHERE vid=lrvid;
  RETURN res;
END;

CREATE FUNCTION giveme_smashed_xway( lrvid INTEGER )
RETURNS TINYINT
BEGIN
  DECLARE res TINYINT;
  SELECT xway INTO res FROM smashed_cars WHERE vid=lrvid;
  RETURN res;
END;

CREATE PROCEDURE collided_vids_at( lrxway TINYINT, lrpos MEDIUMINT,
  lrdir BOOLEAN, lrlane TINYINT )
BEGIN
  TRUNCATE TABLE collided_cars;
  TRUNCATE TABLE collided_cars_temp;
  INSERT INTO collided_cars_temp(vid) SELECT vid FROM stopped_cars WHERE
    pos=lrpos AND xway=lrxway AND direction=lrdir AND lane=lrlane;
  INSERT INTO collided_cars(vid,nr_stopped) SELECT vid,count(*)
    FROM collided_cars_temp GROUP BY vid;
  DELETE FROM collided_cars WHERE nr_stopped <4;
END;

CREATE PROCEDURE add_accident_remove_order( lrxway TINYINT, lrmin INTEGER )
BEGIN
  DECLARE EXIT HANDLER FOR 1062 BEGIN END;
  INSERT INTO accident_remove_order(xway,min) VALUES(lrxway, lrmin );
END;

CREATE PROCEDURE remove_accidents(lrxway TINYINT)
BEGIN
  DELETE FROM accidents WHERE xway=lrxway;
  DELETE FROM smashed_cars WHERE xway=lrxway;
  DELETE FROM accident_remove_order WHERE xway=lrxway;
END;

CREATE PROCEDURE check_kill_accident(lrxway TINYINT)
BEGIN
  DECLARE ifres BOOLEAN;
  SELECT get_minute() >= MAX(min) FROM accident_remove_order
    WHERE xway=lrxway INTO ifres;
  IF ifres = 1 THEN
    CALL remove_accidents(lrxway);
  END IF;
END;

CREATE PROCEDURE accident_check( lrsec SMALLINT, lrvid INTEGER, lrxway TINYINT,
  lrlane TINYINT, lrdir BOOLEAN, lrseg TINYINT, lrpos MEDIUMINT )
BEGIN
  DECLARE ifres BOOLEAN DEFAULT 0;
  DECLARE stopped_count INTEGER DEFAULT 0;
  SELECT is_smashed(lrvid) INTO ifres;
  IF ifres<1 THEN
    CALL add_stopped_car( lrvid, lrxway, lrpos, lrdir, lrsec, lrlane );
    CALL collided_vids_at( lrxway, lrpos, lrdir, lrlane );
    SELECT count(*) INTO stopped_count FROM collided_cars;
    IF stopped_count>1 THEN
    BEGIN
      DECLARE done INTEGER DEFAULT 0;
      DECLARE fetched_vid INTEGER;
      DECLARE cur CURSOR FOR SELECT vid FROM collided_cars;
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;
      OPEN cur;
      REPEAT
	FETCH cur INTO fetched_vid;
	CALL add_smashed_car(fetched_vid, lrpos, lrxway, lrseg, lrdir, lrlane);
      UNTIL DONE END REPEAT;
      CLOSE cur;
--       INSERT INTO print_accidents( xway, segment, direction, vid, time)
-- 	VALUES( lrxway, lrseg, lrdir, lrvid, lrsec );
      CALL add_accident( lrxway, lrseg, lrdir, lrsec, get_minute() );
    END;
    END IF;
  END IF;
END;
//
delimiter ;