DROP FUNCTION IF EXISTS hist_toll;
DROP FUNCTION IF EXISTS get_second;
DROP FUNCTION IF EXISTS get_minute;
DROP FUNCTION IF EXISTS get_stat_nov;
DROP FUNCTION IF EXISTS get_stat_avgv;
DROP PROCEDURE IF EXISTS init_time;
DROP PROCEDURE IF EXISTS set_second;
DROP PROCEDURE IF EXISTS set_minute;
DROP PROCEDURE IF EXISTS switch_stat_tables;
DROP PROCEDURE IF EXISTS add_stat;
DROP PROCEDURE IF EXISTS seg_stat;
DROP PROCEDURE IF EXISTS toll_calc;
DROP PROCEDURE IF EXISTS check_accident_cleared;
DROP PROCEDURE IF EXISTS lr0;
DROP PROCEDURE IF EXISTS prepare_start;

delimiter //

# begin time functions
CREATE PROCEDURE init_time()
BEGIN
  TRUNCATE sim_time;
  INSERT INTO sim_time(sim_minute,sim_second) VALUES(1,0);
END;

CREATE PROCEDURE set_second(newsec SMALLINT)
BEGIN
  UPDATE sim_time SET sim_second=newsec LIMIT 1;
END;

CREATE FUNCTION get_second()
RETURNS SMALLINT
BEGIN
  DECLARE result SMALLINT;
  SELECT sim_second INTO result FROM sim_time LIMIT 1;
  RETURN result;
END;

CREATE PROCEDURE set_minute(newmin SMALLINT UNSIGNED)
BEGIN
  UPDATE sim_time SET sim_minute=newmin LIMIT 1;
END;

CREATE FUNCTION get_minute()
RETURNS TINYINT UNSIGNED
BEGIN
  DECLARE result TINYINT UNSIGNED;
  SELECT sim_minute INTO result FROM sim_time LIMIT 1;
  RETURN result;
END;
# end time functions

CREATE PROCEDURE switch_stat_tables()
BEGIN
  TRUNCATE TABLE stat_nov_cached;
  TRUNCATE TABLE stat_lav_cached;
  TRUNCATE TABLE stat_min6;
  RENAME TABLE	stat_min1 TO stat_tmp1,
		stat_min2 TO stat_tmp2,
		stat_min3 TO stat_tmp3,
		stat_min4 TO stat_tmp4,
		stat_min5 TO stat_tmp5,
		stat_min6 TO stat_tmp6;
  RENAME TABLE	stat_tmp1 TO stat_min2,
		stat_tmp2 TO stat_min3,
		stat_tmp3 TO stat_min4,
		stat_tmp4 TO stat_min5,
		stat_tmp5 TO stat_min6,
		stat_tmp6 TO stat_min1;
END;
CREATE FUNCTION get_stat_nov( lrsegment TINYINT, lrxway TINYINT, lrdir BOOLEAN )
RETURNS SMALLINT
BEGIN
  DECLARE result SMALLINT;
  SELECT nov INTO result FROM stat_nov_cached WHERE xway=lrxway AND dir=lrdir
    AND segment=lrsegment LIMIT 1;
--   Calculate nov if it's not in cache
  IF result IS NULL THEN
    SELECT count(*) INTO result FROM stat_min2 WHERE xway=lrxway AND dir=lrdir
    AND segment=lrsegment LIMIT 1;
    IF result IS NULL THEN
      SET result = 0;
    END IF;
    INSERT INTO stat_nov_cached(segment, dir, xway,nov)
      VALUES(lrsegment,lrdir, lrxway,result);
  END IF;
  RETURN result;
END;
CREATE FUNCTION get_stat_avgv( lrsegment TINYINT, lrxway TINYINT,
  lrdir BOOLEAN )
RETURNS TINYINT
BEGIN
  DECLARE result TINYINT;
  SELECT avgv INTO result FROM stat_lav_cached WHERE xway=lrxway AND dir=lrdir
    AND segment=lrsegment;
  IF result IS NULL THEN
  BEGIN
    SELECT floor( avg(r)) FROM (
      SELECT avg(lav) r FROM stat_min2 WHERE xway=lrxway AND dir=lrdir
	AND segment=lrsegment UNION ALL
      SELECT avg(lav) r FROM stat_min3 WHERE xway=lrxway AND dir=lrdir
	AND segment=lrsegment UNION ALL
      SELECT avg(lav) r FROM stat_min4 WHERE xway=lrxway AND dir=lrdir
	AND segment=lrsegment UNION ALL
      SELECT avg(lav) r FROM stat_min5 WHERE xway=lrxway AND dir=lrdir
	AND segment=lrsegment UNION ALL
      SELECT avg(lav) r FROM stat_min6 WHERE xway=lrxway AND dir=lrdir
	AND segment=lrsegment ) r INTO result;
    IF result IS NULL THEN
      SET result = -1;
    END IF;
    INSERT INTO stat_lav_cached( xway, dir, segment, avgv)
      VALUES(lrxway, lrdir, lrsegment, result);
    END;
  END IF;
  
  RETURN result;
END;
CREATE PROCEDURE add_stat(lrvid INTEGER, lrspeed TINYINT, lrxway TINYINT,
  lrdir BOOLEAN, lrsegment TINYINT)
BEGIN

  INSERT INTO stat_min1(segment, dir, xway,vid,lav,number)
    VALUES(lrsegment,lrdir, lrxway,lrvid, lrspeed,1) ON DUPLICATE KEY
    UPDATE lav=((lav*number+lrspeed)/(number+1)), number=number+1;
END;
CREATE PROCEDURE seg_stat(lrtime SMALLINT, lrvid INTEGER, lrspeed TINYINT,
  lrxway TINYINT, lrdir BOOLEAN, lrsegment TINYINT)
BEGIN
DECLARE current_second SMALLINT;
DECLARE current_minute TINYINT UNSIGNED;
SELECT get_second() INTO current_second;
  IF lrtime > current_second THEN
    CALL set_second(lrtime);
    CALL remove_stopped_cars(lrtime);

    SELECT get_minute() INTO current_minute;
    IF floor(lrtime/60)+1 > current_minute THEN
    BEGIN
        DECLARE loop_counter TINYINT DEFAULT 0;
	DECLARE new_minute TINYINT UNSIGNED DEFAULT 0;
	CALL set_minute( (floor(lrtime/60)+1) );	
  --       WHILE xway<100 DO
  -- 	CALL check_kill_accident(xway);
  -- 	SET xway = xway+1;
  --       END WHILE;
	CALL check_kill_accident(lrxway);
	SELECT get_minute() INTO new_minute;
-- 	INSERT INTO min_test(old, new) VALUES(current_minute, new_minute);
-- 	WHILE loop_counter<( new_minute-current_minute ) DO
	  CALL switch_stat_tables();
-- 	  SET loop_counter=loop_counter+1;
--         END WHILE;
      END;
      END IF;
    END IF;
    CALL add_stat(lrvid, lrspeed, lrxway, lrdir, lrsegment);
END;
CREATE FUNCTION hist_toll( lrvid INTEGER, lrday TINYINT, lrxway TINYINT)
RETURNS DECIMAL(9,1)
BEGIN
  DECLARE result DECIMAL(9,1);
  SELECT toll INTO result FROM historical_toll WHERE vid=lrvid
    AND day=lrday AND xway=lrxway LIMIT 1;
  RETURN result;
END;

# begin toll calculation
CREATE PROCEDURE toll_calc( lrsec SMALLINT, lrvid INTEGER, lrxway TINYINT,
  lrpos MEDIUMINT, lrseg TINYINT, lrdir BOOLEAN, lrspd TINYINT, lrlane TINYINT )
BEGIN
IF lrlane <> 4 THEN
  BEGIN
  DECLARE res BOOLEAN;
  SELECT check_new_seg_report( lrvid, lrseg, lrxway) INTO res;
  IF res=0 THEN
--   add toll from previous segment
    CALL add_previous_toll( lrsec, lrvid, lrxway, lrpos, lrseg, lrdir, lrspd );
--     calculate toll for the new segment
    CALL calc_toll( lrsec, lrvid, lrxway, lrpos, lrseg, lrdir, lrspd );
  END IF;
  END;
END IF;
END;

CREATE PROCEDURE check_accident_cleared( lrsec SMALLINT, lrvid INTEGER,
  lrpos MEDIUMINT, lrseg TINYINT, lrxway TINYINT )
BEGIN
  DECLARE ifres INTEGER DEFAULT 0;
--   SELECT is_smashed(lrvid) INTO ifres;
--   IF ifres > 0 THEN
      SELECT giveme_smashed_pos(lrvid) INTO ifres;
      IF ( ifres <> lrpos)  THEN
      BEGIN
	CALL add_accident_remove_order( giveme_smashed_xway(lrvid),
	  ceil((lrsec+120)/60) );
-- 	INSERT INTO print_accidents(xway,segment,direction,vid,time)
-- 	  VALUES(-1,get_minute(),ceil((lrsec+120)/60),lrvid,get_second());
	END;
      END IF;
--   END IF;
END;
# end stopped calculation

CREATE PROCEDURE lr0( lrtype TINYINT, lrsec SMALLINT, lrvid INTEGER,
  lrspd TINYINT, lrxway TINYINT, lrlane TINYINT, lrdir BOOLEAN, lrseg TINYINT,
  lrpos MEDIUMINT, lrquid INTEGER, lrday TINYINT )
BEGIN
  DECLARE ifres BOOLEAN DEFAULT 0;
  IF lrspd=0 THEN
    CALL accident_check( lrsec, lrvid, lrxway, lrlane, lrdir, lrseg, lrpos );
  END IF;
  CASE lrtype
  WHEN 0 THEN
  BEGIN
    SELECT is_smashed(lrvid) INTO ifres;
    IF ifres>0 THEN
      CALL check_accident_cleared( lrsec, lrvid, lrpos, lrseg, lrxway );
    END IF;
    CALL seg_stat( lrsec, lrvid, lrspd, lrxway, lrdir, lrseg );
    CALL toll_calc( lrsec, lrvid, lrxway, lrpos, lrseg, lrdir, lrspd, lrlane );
  END;
  WHEN 3 THEN
  BEGIN
    DECLARE expenditure DECIMAL(9,1);
    SELECT hist_toll( lrvid, lrday, lrxway) INTO expenditure;
    IF expenditure IS NOT NULL THEN
      INSERT INTO output_daily_exp(time, emit_time,quid,expenditure)
	VALUES(lrsec, 0, lrquid, expenditure );
    END IF;
  END;
  WHEN 2 THEN
  BEGIN
    DECLARE lrlasttime SMALLINT;
    DECLARE lrbalance DECIMAL(9,1);
    SELECT giveme_lasttime(lrvid) INTO lrlasttime;
    SELECT giveme_balance(lrvid) INTO lrbalance;
    /* Account balance */
    IF lrbalance IS NOT NULL THEN
      INSERT INTO output_account_balance(time, emit_time,quid,lasttime,balance)
	VALUES(lrsec, 0, lrquid, lrlasttime, lrbalance );
    ELSE
      INSERT INTO output_account_balance(time, emit_time,quid,lasttime,balance)
	VALUES(lrsec, 0, lrquid, lrsec, 0.0 );
    END IF;
  END;
  WHEN 4 THEN
  BEGIN
--     Ignore travel time estimation requests
  END;
  END CASE;
END;


CREATE PROCEDURE prepare_start()
BEGIN
  TRUNCATE accident_remove_order;
  TRUNCATE accidents;
  TRUNCATE collided_cars;
  TRUNCATE output_accident_alert;
  TRUNCATE output_account_balance;
  TRUNCATE output_daily_exp;
  TRUNCATE output_toll_alert;
  TRUNCATE sim_time;
  TRUNCATE smashed_cars;
  TRUNCATE stat_min1;
  TRUNCATE stat_min2;
  TRUNCATE stat_min3;
  TRUNCATE stat_min4;
  TRUNCATE stat_min5;
  TRUNCATE stat_min6;
  TRUNCATE stat_lav_cached;
  TRUNCATE stat_nov_cached;
  TRUNCATE stopped_cars;
  TRUNCATE vehicle_info;
  CALL init_time();
END;
//
delimiter ;

-- source accidents.sql;
-- source toll.sql;