/*-*-sql-*-*******************************************************************
 * AMOS2
 *
 * Author: (c) 2008 Tore Risch, UDBL
 * $RCSfile: mysqldrop.sql,v $
 * $Revision: 1.1 $ $Date: 2012/03/21 10:28:52 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Empty regression database with MySQL
 *
 ****************************************************************************
 * $Log: mysqldrop.sql,v $
 * Revision 1.1  2012/03/21 10:28:52  minzh812
 * *** empty log message ***
 *
 * Revision 1.1  2012/02/02 13:11:54  minzh812
 * *** empty log message ***
 *
 * Revision 1.4  2009/03/05 20:22:57  torer
 * MySQL test bug fix
 *
 * Revision 1.3  2009/03/05 19:18:22  torer
 * Regression now works with MySQL
 *
 * Revision 1.2  2008/08/13 08:52:08  torer
 * Moved drop table customer to avoid MySQL bug
 *
 * Revision 1.1  2008/08/07 19:38:14  torer
 * Making regression scripts DBMS independent
 *
 ****************************************************************************/

drop table if exists LINEITEM;
drop table if exists ORDERS;
drop table if exists CUSTOMER;
drop table if exists COUNTRY;
drop table if exists DEPARTMENT;
drop table if exists EMPLOYEE;

drop table if exists PERSON_TELEPHONES;
drop table if exists SWEDISH_PERSON;
drop table if exists PERSON;
drop table if exists PERSON2;
drop table if exists PERSON_TELEPHONES;

drop table if exists PERSON3;
drop table if exists JOBB;
drop table if exists MARRIED;



