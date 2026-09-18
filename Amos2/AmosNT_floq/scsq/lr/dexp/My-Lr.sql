DROP FUNCTION IF EXISTS hist_toll;
DROP FUNCTION IF EXISTS TimeDiffer;
DROP FUNCTION IF EXISTS lr0;
DROP PROCEDURE IF EXISTS init_time;
DROP PROCEDURE IF EXISTS prepare_start;
delimiter //

CREATE PROCEDURE init_time()
BEGIN
  TRUNCATE sim_time;
  INSERT INTO sim_time(Now) VALUES( NOW());
END;

CREATE FUNCTION TimeDiffer()
RETURNS SMALLINT
BEGIN
   DECLARE NowTime TIME;
   DECLARE result SMALLINT;
   SELECT NOW INTO NowTime FROM sim_time LIMIT 1;
   SELECT TIME_TO_SEC(SUBTIME(TIME(Now()),  NowTime)) INTO result;
   RETURN result;

END;




CREATE FUNCTION hist_toll( lrvid INTEGER, lrday TINYINT, lrxway TINYINT)
RETURNS DECIMAL(9,1)
BEGIN
  DECLARE result DECIMAL(9,1);
  SELECT toll INTO result FROM historical_toll WHERE vid=lrvid
    AND day=lrday AND xway=lrxway LIMIT 1;
  RETURN result;
END;


CREATE FUNCTION lr0( lrtype TINYINT, lrsec SMALLINT, lrvid INTEGER,
  lrxway TINYINT, lrquid INTEGER, lrday TINYINT )
RETURNS CHAR(50)
BEGIN  
DECLARE result CHAR(50);
DECLARE expenditure DECIMAL(9,1);
    SELECT hist_toll( lrvid, lrday, lrxway) INTO expenditure;
    IF expenditure IS NOT NULL THEN
	
	SELECT CONCAT_WS(',',lrsec, 0, lrquid, expenditure ) into result;  

    ELSE
	SELECT CONCAT_WS(',',lrsec, 0, lrquid, 0 ) into result;  	
    END IF;
RETURN result;      
END;

CREATE PROCEDURE prepare_start()
BEGIN
  
 
END;

//
delimiter ;