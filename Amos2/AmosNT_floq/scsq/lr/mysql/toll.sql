DROP PROCEDURE IF EXISTS set_vehicle_info;
DROP PROCEDURE IF EXISTS add_vehicle_info;
DROP PROCEDURE IF EXISTS add_previous_toll;
DROP PROCEDURE IF EXISTS update_vehicle_info;
DROP PROCEDURE IF EXISTS update_vehicle_toll;
DROP PROCEDURE IF EXISTS calc_toll;
DROP FUNCTION IF EXISTS check_new_seg_report;
DROP FUNCTION IF EXISTS giveme_balance;
DROP FUNCTION IF EXISTS giveme_lasttime;

delimiter //

CREATE PROCEDURE set_vehicle_info( lrvid INTEGER, lrxway TINYINT,
  lrpos MEDIUMINT, lrseg TINYINT, lrdir BOOLEAN, lrbal DECIMAL(9,1),
  lrlastupdate SMALLINT, lrvav TINYINT, lrnextexp DECIMAL(9,1) )
BEGIN
  INSERT INTO vehicle_info(vid, xway, segment, direction, pos, balance,
    lastupdate, vav, nextexp) VALUES(lrvid, lrxway, lrseg, lrdir, lrpos, lrbal,
    lrlastupdate, lrvav, lrnextexp) ON DUPLICATE KEY UPDATE xway=lrxway,
    segment=lrseg, direction=lrdir, pos=lrpos, balance=lrbal,
    lastupdate=lrlastupdate, vav=lrvav, nextexp=lrnextexp;
END;

CREATE PROCEDURE add_vehicle_info( lrvid INTEGER, lrxway TINYINT,
  lrpos MEDIUMINT, lrseg TINYINT, lrdir BOOLEAN, lrbal DECIMAL(9,1),
  lrlastupdate SMALLINT, lrvav TINYINT, lrnextexp DECIMAL(9,1) )
BEGIN
  DECLARE EXIT HANDLER FOR 1062 BEGIN END;
  INSERT INTO vehicle_info(vid, xway, segment, direction, pos, balance,
  lastupdate, vav, nextexp) VALUES(lrvid, lrxway, lrseg, lrdir, lrpos, lrbal,
  lrlastupdate, lrvav, lrnextexp);
END;

CREATE FUNCTION check_new_seg_report( lrvid INTEGER, lrseg TINYINT,
  lrxway TINYINT )
RETURNS BOOLEAN
BEGIN
  DECLARE res BOOLEAN;
  SELECT count(*)>0 INTO res FROM vehicle_info WHERE vid=lrvid
    AND segment=lrseg AND xway=lrxway;
  RETURN res;
END;

CREATE PROCEDURE add_previous_toll( lrsec SMALLINT, lrvid INTEGER,
  lrxway TINYINT, lrpos MEDIUMINT, lrseg TINYINT, lrdir BOOLEAN, lrspd TINYINT )
BEGIN
  DECLARE upbalance DECIMAL(9,1) DEFAULT 0;
  SELECT nextexp+balance INTO upbalance FROM vehicle_info WHERE vid=lrvid;
  CALL set_vehicle_info( lrvid, lrxway, lrpos, lrseg,
    lrdir, upbalance, lrsec, lrspd, 0.0 );
END;

CREATE FUNCTION giveme_balance( lrvid INTEGER )
RETURNS DECIMAL(9,1)
BEGIN
DECLARE res DECIMAL(9,1);
SELECT balance INTO res FROM vehicle_info WHERE vid=lrvid;
RETURN res;
END;

CREATE FUNCTION giveme_lasttime( lrvid INTEGER )
RETURNS SMALLINT
BEGIN
DECLARE res SMALLINT;
SELECT lastupdate INTO res FROM vehicle_info WHERE vid=lrvid;
RETURN res;
END;

CREATE PROCEDURE update_vehicle_info( lrsec SMALLINT, lrvid INTEGER,
  lrxway TINYINT, lrpos MEDIUMINT, lrseg TINYINT, lrdir BOOLEAN, lrspd TINYINT)
BEGIN
  CALL add_previous_toll( lrsec, lrvid, lrxway, lrpos, lrseg, lrdir, lrspd);
END;

CREATE PROCEDURE update_vehicle_toll( lrsec SMALLINT, lrvid INTEGER, lrxway
  TINYINT, lrpos MEDIUMINT, lrseg TINYINT,
  lrdir BOOLEAN, lrspd TINYINT, lrtoll DECIMAL(9,1))
BEGIN
  DECLARE EXIT HANDLER FOR 1048 BEGIN END;
  CALL set_vehicle_info( lrvid, lrxway, lrpos, lrseg, lrdir,
  giveme_balance(lrvid) ,lrsec, lrspd, lrtoll );
END;

CREATE PROCEDURE calc_toll( lrsec SMALLINT, lrvid INTEGER, lrxway TINYINT,
  lrpos MEDIUMINT, lrseg TINYINT, lrdir BOOLEAN, lrspd TINYINT )
BEGIN
  DECLARE action_area_res BOOLEAN DEFAULT 0;
  DECLARE lrtoll DECIMAL(9,1);
  DECLARE lravgv DECIMAL(9,1);
  SELECT is_accident_area(lrxway,lrseg, lrdir) INTO action_area_res;
  IF action_area_res=1 THEN
    INSERT INTO output_accident_alert( time, emit_time, vid, segment)
      VALUES(lrsec, 0, lrvid, get_accident_seg(lrxway) );
    SET lrtoll = 0.0;
    SELECT get_stat_avgv( lrseg, lrxway, lrdir ) INTO lravgv;
  ELSE
    BEGIN
      DECLARE nr_of_cars MEDIUMINT DEFAULT 0;
      SELECT get_stat_nov( lrseg, lrxway, lrdir ) INTO nr_of_cars;
      SELECT get_stat_avgv( lrseg, lrxway, lrdir ) INTO lravgv;
      IF (nr_of_cars<=50) OR (lravgv>=40) THEN 
	SET lrtoll=0.0;
      ELSE
	SET lrtoll=2*(nr_of_cars-50)*(nr_of_cars-50);
      END IF;
--      INSERT INTO toll_debug(sec, num_cars, avgv, vid, toll)
--   	VALUES(lrsec, nr_of_cars,lravgv, lrvid, lrtoll);
    END;
  END IF;
  CALL update_vehicle_toll( lrsec, lrvid, lrxway, lrpos, lrseg, lrdir, lrspd, lrtoll );
  INSERT INTO output_toll_alert( vid, time, emit_time, vavg, toll)
    VALUES(lrvid, lrsec, 0, lravgv, lrtoll );
END;
//
delimiter ;