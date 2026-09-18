/*-*-sql-*-*******************************************************************
 * AMOS2
 *
 * Author: (c) 2008 Tore Risch, UDBL
 * $RCSfile: regress.sql,v $
 * $Revision: 1.1 $ $Date: 2012/03/21 10:28:53 $
 * $State: Exp $ $Locker:  $
 *
 * Description: SQL population script
 *
 ****************************************************************************
 * $Log: regress.sql,v $
 * Revision 1.1  2012/03/21 10:28:53  minzh812
 * *** empty log message ***
 *
 * Revision 1.1  2012/02/02 13:11:55  minzh812
 * *** empty log message ***
 *
 * Revision 1.8  2010/10/06 16:37:22  torer
 * Testing substituting very long string in JDBC
 *
 * Revision 1.7  2009/04/15 16:47:01  torer
 * Same currency (dollar) in several countries
 *
 * Revision 1.6  2009/03/05 19:18:22  torer
 * Regression now works with MySQL
 *
 * Revision 1.5  2008/08/13 08:52:09  torer
 * Moved drop table customer to avoid MySQL bug
 *
 * Revision 1.4  2008/08/07 20:08:37  torer
 * Same test for FireBird and MySQL
 *
 * Revision 1.3  2008/08/07 19:38:15  torer
 * Making regression scripts DBMS independent
 *
 ****************************************************************************/

create table COUNTRY (
    country   varchar(15),
    currency  varchar(10)
);

create table CUSTOMER (
    cust_no         integer not null,
    customer        varchar(25),
    contact_first   varchar(15),
    contact_last    varchar(20),
    phone_no        varchar(20),
    address_line1   varchar(30),
    address_line2   varchar(30),
    city            varchar(25),
    state_province  varchar(15),
    country         varchar(15),
    postal_code     varchar(12),
    on_hold         char(1),
    primary key(cust_no)
);

create table DEPARTMENT (
    dept_no     char(3) not null,
    department  varchar(25) not null,
    head_dept   char(3),
    mngr_no     smallint,
    budget      decimal(12,2),
    location    varchar(15),
    phone_no    varchar(20) default '555-1234',
    primary key(dept_no)
);

create table EMPLOYEE (
    emp_no       smallint not null,
    first_name   varchar(15) not null,
    last_name    varchar(20) not null,
    phone_ext    varchar(4),
    hire_date    timestamp not null,
    dept_no      char(3) not null,
    job_code     varchar(5) not null,
    job_grade    smallint not null,
    job_country  varchar(15) not null,
    salary       numeric(10,2) default 0.0,
    primary key(emp_no)
);

/*
 *  Add countries.
 */

insert into COUNTRY (country, currency) values ('usa',         'dollar');
insert into COUNTRY (country, currency) values ('england',     'pound'); 
insert into COUNTRY (country, currency) values ('canada',      'cdndlr');
insert into COUNTRY (country, currency) values ('switzerland', 'sfranc');
insert into COUNTRY (country, currency) values ('japan',       'yen');
insert into COUNTRY (country, currency) values ('italy',       'lira');
insert into COUNTRY (country, currency) values ('france',      'ffranc');
insert into COUNTRY (country, currency) values ('germany',     'd-mark');
insert into COUNTRY (country, currency) values ('australia',   'dollar');
insert into COUNTRY (country, currency) values ('hong kong',   'dollar');
insert into COUNTRY (country, currency) values ('netherlands', 'guilder');
insert into COUNTRY (country, currency) values ('belgium',     'bfranc');
insert into COUNTRY (country, currency) values ('austria',     'schilling');
insert into COUNTRY (country, currency) values ('fiji',        'dollar');

commit;

/*
 *  Add departments.
 *  Don't assign managers yet.
 *
 *  Department structure (4-levels):
 *
 *      Corporate Headquarters
 *          Finance
 *          Sales and Marketing
 *              Marketing
 *              Pacific Rim Headquarters (Hawaii)
 *                  Field Office: Tokyo
 *                  Field Office: Singapore
 *              European Headquarters (London)
 *                  Field Office: France
 *                  Field Office: Italy
 *                  Field Office: Switzerland
 *              Field Office: Canada
 *              Field Office: East Coast
 *          Engineering
 *              Software Products Division (California)
 *                  Software Development
 *                  Quality Assurance
 *                  Customer Support
 *              Consumer Electronics Division (Vermont)
 *                  Research and Development
 *                  Customer Services
 *
 *  Departments have parent departments.
 *  Corporate Headquarters is the top department in the company.
 *  Singapore field office is new and has 0 employees.
 *
 */
insert into DEPARTMENT
(dept_no, department, head_dept, budget, location, phone_no) values
('000', 'Corporate Headquarters', null, 1000000, 'Monterey','(408) 555-1234');

insert into DEPARTMENT
(dept_no, department, head_dept, budget, location, phone_no) values
('100', 'Sales and Marketing',  '000', 2000000, 'San Francisco',
'(415) 555-1234');

insert into DEPARTMENT
(dept_no, department, head_dept, budget, location, phone_no) values
('600', 'Engineering', '000', 1100000, 'Monterey', '(408) 555-1234');

insert into DEPARTMENT
(dept_no, department, head_dept, budget, location, phone_no) values
('900', 'Finance',   '000', 400000, 'Monterey', '(408) 555-1234');

insert into DEPARTMENT
(dept_no, department, head_dept, budget, location, phone_no) values
('180', 'Marketing', '100', 1500000, 'San Francisco', '(415) 555-1234');

insert into DEPARTMENT
(dept_no, department, head_dept, budget, location, phone_no) values
('620', 'Software Products Div.', '600', 1200000, 'Monterey', '(408) 555-1234');

insert into DEPARTMENT
(dept_no, department, head_dept, budget, location, phone_no) values
('621', 'Software Development', '620', 400000, 'Monterey', '(408) 555-1234');

insert into DEPARTMENT
(dept_no, department, head_dept, budget, location, phone_no) values
('622', 'Quality Assurance',    '620', 300000, 'Monterey', '(408) 555-1234');

insert into DEPARTMENT
(dept_no, department, head_dept, budget, location, phone_no) values
('623', 'Customer Support', '620', 650000, 'Monterey', '(408) 555-1234');

insert into DEPARTMENT
(dept_no, department, head_dept, budget, location, phone_no) values
('670', 'Consumer Electronics Div.', '600', 1150000, 'Burlington, VT',
'(802) 555-1234');

insert into DEPARTMENT
(dept_no, department, head_dept, budget, location, phone_no) values
('671', 'Research and Development', '670', 460000, 'Burlington, VT',
'(802) 555-1234');

insert into DEPARTMENT
(dept_no, department, head_dept, budget, location, phone_no) values
('672', 'Customer Services', '670', 850000, 'Burlington, VT', '(802) 555-1234');

insert into DEPARTMENT
(dept_no, department, head_dept, budget, location, phone_no) values
('130', 'Field Office: East Coast', '100', 500000, 'Boston', '(617) 555-1234');

insert into DEPARTMENT
(dept_no, department, head_dept, budget, location, phone_no) values
('140', 'Field Office: Canada',     '100', 500000, 'Toronto', '(416) 677-1000');

insert into DEPARTMENT
(dept_no, department, head_dept, budget, location, phone_no) values
('110', 'Pacific Rim Headquarters', '100', 600000, 'Kuaui', '(808) 555-1234');

insert into DEPARTMENT
(dept_no, department, head_dept, budget, location, phone_no) values
('115', 'Field Office: Japan',      '110', 500000, 'Tokyo', '3 5350 0901');

insert into DEPARTMENT
(dept_no, department, head_dept, budget, location, phone_no) values
('116', 'Field Office: Singapore',  '110', 300000, 'Singapore', '3 55 1234');

insert into DEPARTMENT
(dept_no, department, head_dept, budget, location, phone_no) values
('120', 'European Headquarters',    '100', 700000, 'London', '71 235-4400');

insert into DEPARTMENT
(dept_no, department, head_dept, budget, location, phone_no) values
('121', 'Field Office: Switzerland','120', 500000, 'Zurich', '1 211 7767');

insert into DEPARTMENT
(dept_no, department, head_dept, budget, location, phone_no) values
('123', 'Field Office: France',     '120', 400000, 'Cannes', '58 68 11 12');

insert into DEPARTMENT
(dept_no, department, head_dept, budget, location, phone_no) values
('125', 'Field Office: Italy',      '120', 400000, 'Milan', '2 430 39 39');

commit;

/*
 *  Add employees.
 */


INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(2, 'Robert', 'Nelson', '600', 'VP', 2, 'USA', '1988-12-28', 98000, '250');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(4, 'Bruce', 'Young', '621', 'Eng', 2, 'USA', '1988-12-28', 90000, '233');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(5, 'Kim', 'Lambert', '130', 'Eng', 2, 'USA', '1989-02-06', 95000, '22');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(8, 'Leslie', 'Johnson', '180', 'Mktg',  3, 'USA', '1989-04-05', 62000, '410');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(9, 'Phil', 'Forest',   '622', 'Mngr',  3, 'USA', '1989-04-17', 72000, '229');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(11, 'K. J.', 'Weston', '130', 'SRep',  4, 'USA', '1990-01-17', 70000, '34');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(12, 'Terri', 'Lee', '000', 'Admin', 4, 'USA', '1990-05-01', 48000, '256');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(14, 'Stewart', 'Hall', '900', 'Finan', 3, 'USA', '1990-06-04', 62000, '227');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(15, 'Katherine', 'Young', '623', 'Mngr',  3,'USA', '1990-06-14',60000, '231');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(20, 'Chris', 'Papadopoulos', '671', 'Mngr', 3, 'USA', '1990-01-01', 80000,
'887');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(24, 'Pete', 'Fisher', '671', 'Eng', 3, 'USA', '1990-09-12', 73000, '888');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(28, 'Ann', 'Bennet', '120', 'Admin', 5, 'England', '1991-02-01', 20000, '5');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(29, 'Roger', 'De Souza', '623', 'Eng', 3, 'USA', '1991-02-18', 62000, '288');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(34, 'Janet', 'Baldwin', '110', 'Sales', 3, 'USA', '1991-03-21', 55000, '2');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(36, 'Roger', 'Reeves', '120', 'Sales', 3, 'England', '1991-04-25',30000, '6');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(37, 'Willie', 'Stansbury','120', 'Eng',4, 'England', '1991-04-25',35000, '7');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(44, 'Leslie', 'Phong', '623', 'Eng', 4, 'USA', '1991-06-03', 50000, '216');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(45, 'Ashok', 'Ramanathan', '621', 'Eng', 3, 'USA', '1991-08-01',72000, '209');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(46, 'Walter', 'Steadman', '900', 'CFO', 1, 'USA', '1991-08-09',120000, '210');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(52, 'Carol', 'Nordstrom', '180', 'PRel', 4, 'USA', '1991-10-02',41000, '420');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(61, 'Luke', 'Leung', '110', 'SRep',  4, 'USA', '1992-02-18', 60000, '3');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(65,'Sue Anne','O''Brien', '670', 'Admin',5, 'USA', '1992-03-23',30000, '877');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(71, 'Jennifer M.', 'Burbank', '622', 'Eng', 3, 'USA', '1992-04-15', 51000,
'289');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(72, 'Claudia', 'Sutherland', '140', 'SRep', 4, 'Canada', '1992-04-20', 88000,
null);

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(83, 'Dana', 'Bishop', '621', 'Eng',  3, 'USA', '1992-06-01', 60000, '290');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(85, 'Mary S.', 'MacDonald', '100', 'VP',2, 'USA', '1992-06-01',115000, '477');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(94, 'Randy', 'Williams', '672', 'Mngr', 4, 'USA', '1992-08-08', 54000, '892');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(105,'Oliver H.', 'Bender', '000', 'CEO',1, 'USA', '1992-10-08',220000, '255');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(107, 'Kevin', 'Cook', '670', 'Dir', 2, 'USA', '1993-02-01', 115000, '894');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(109, 'Kelly', 'Brown', '600', 'Admin', 5, 'USA', '1993-02-04', 27000, '202');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(110, 'Yuki', 'Ichida', '115', 'Eng', 3, 'Japan', '1993-02-04',
6000000, '22');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(113, 'Mary', 'Page', '671', 'Eng', 4, 'USA', '1993-04-12', 48000, '845');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(114, 'Bill', 'Parker', '623', 'Eng', 5, 'USA', '1993-06-01', 35000, '247');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(118, 'Takashi', 'Yamamoto', '115', 'SRep', 4, 'Japan', '1993-07-01',
6800000, '23');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(121, 'Roberto', 'Ferrari', '125', 'SRep',  4, 'Italy', '1993-07-12',
90000000, '1');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(127,'Michael', 'Yanowski', '100', 'SRep',4, 'USA', '1993-08-09',40000, '492');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(134, 'Jacques', 'Glon', '123', 'SRep',4, 'France', '1993-08-23',355000, null);

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(136, 'Scott', 'Johnson', '623', 'Doc', 3, 'USA', '1993-09-13', 60000, '265');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(138, 'T.J.', 'Green', '621', 'Eng', 4, 'USA', '1993-11-01', 36000, '218');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(141, 'Pierre', 'Osborne', '121', 'SRep', 4, 'Switzerland', '1994-01-03',
110000, null);

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(144, 'John', 'Montgomery', '672', 'Eng', 5, 'USA', '1994-03-30',35000, '820');

INSERT INTO EMPLOYEE (emp_no, first_name, last_name, dept_no, job_code,
job_grade, job_country, hire_date, salary, phone_ext) VALUES
(145,'Mark', 'Guckenheimer', '622', 'Eng',5, 'USA', '1994-05-02',32000, '221');


COMMIT;


/*
 *  Set department managers.
 *  A department manager can be a director, a vice president, a CFO,
 *  a sales rep, etc.  Several departments have no managers (TBH).
 */
UPDATE DEPARTMENT SET mngr_no = 105 WHERE dept_no = '000';
UPDATE DEPARTMENT SET mngr_no = 85 WHERE dept_no = '100';
UPDATE DEPARTMENT SET mngr_no = 2 WHERE dept_no = '600';
UPDATE DEPARTMENT SET mngr_no = 46 WHERE dept_no = '900';
UPDATE DEPARTMENT SET mngr_no = 9 WHERE dept_no = '622';
UPDATE DEPARTMENT SET mngr_no = 15 WHERE dept_no = '623';
UPDATE DEPARTMENT SET mngr_no = 107 WHERE dept_no = '670';
UPDATE DEPARTMENT SET mngr_no = 20 WHERE dept_no = '671';
UPDATE DEPARTMENT SET mngr_no = 94 WHERE dept_no = '672';
UPDATE DEPARTMENT SET mngr_no = 11 WHERE dept_no = '130';
UPDATE DEPARTMENT SET mngr_no = 72 WHERE dept_no = '140';
UPDATE DEPARTMENT SET mngr_no = 118 WHERE dept_no = '115';
UPDATE DEPARTMENT SET mngr_no = 36 WHERE dept_no = '120';
UPDATE DEPARTMENT SET mngr_no = 141 WHERE dept_no = '121';
UPDATE DEPARTMENT SET mngr_no = 134 WHERE dept_no = '123';
UPDATE DEPARTMENT SET mngr_no = 121 WHERE dept_no = '125';
UPDATE DEPARTMENT SET mngr_no = 34 WHERE dept_no = '110';


COMMIT;

/*
 *  Generate some salary history records.
 */

UPDATE EMPLOYEE SET salary = salary + salary * 0.10 
    WHERE hire_date <= '1991-08-01' AND job_grade = 5;
UPDATE EMPLOYEE SET salary = salary + salary * 0.05 + 3000
    WHERE hire_date <= '1991-08-01' AND job_grade in (1, 2);
UPDATE EMPLOYEE SET salary = salary + salary * 0.075
    WHERE hire_date <= '1991-08-01' AND job_grade in (3, 4) AND emp_no > 9;

UPDATE EMPLOYEE SET salary = salary + salary * 0.0425
    WHERE hire_date < '1993-02-01' AND job_grade >= 3;

UPDATE EMPLOYEE SET salary = salary - salary * 0.0325
    WHERE salary > 110000 AND job_country = 'USA';

UPDATE EMPLOYEE SET salary = salary + salary * 0.10
    WHERE job_code = 'SRep' AND hire_date < '1993-12-20';

COMMIT;

/*
 *  Add a few customer records.
 */


INSERT INTO CUSTOMER
(cust_no, customer, contact_first, contact_last, phone_no, address_line1,
address_line2, city, state_province, country, postal_code, on_hold) VALUES
(1001, 'Signature Design', 'Dale J.', 'Little', '(619) 530-2710',
'15500 Pacific Heights Blvd.', null, 'San Diego', 'CA', 'USA', '92121', null);

INSERT INTO CUSTOMER
(cust_no, customer, contact_first, contact_last, phone_no, address_line1,
address_line2, city, state_province, country, postal_code, on_hold) VALUES
(1002, 'Dallas Technologies', 'Glen', 'Brown', '(214) 960-2233',
'P. O. Box 47000', null, 'Dallas', 'TX', 'USA', '75205', null);

INSERT INTO CUSTOMER
(cust_no, customer, contact_first, contact_last, phone_no, address_line1,
address_line2, city, state_province, country, postal_code, on_hold) VALUES
(1003, 'Buttle, Griffith and Co.', 'James', 'Buttle', '(617) 488-1864',
'2300 Newbury Street', 'Suite 101', 'Boston', 'MA', 'USA', '02115', null);

INSERT INTO CUSTOMER
(cust_no, customer, contact_first, contact_last, phone_no, address_line1,
address_line2, city, state_province, country, postal_code, on_hold) VALUES
(1004, 'Central Bank', 'Elizabeth', 'Brocket', '61 211 99 88',
'66 Lloyd Street', null, 'Manchester', null, 'England', 'M2 3LA', null);

INSERT INTO CUSTOMER
(cust_no, customer, contact_first, contact_last, phone_no, address_line1,
address_line2, city, state_province, country, postal_code, on_hold) VALUES
(1005, 'DT Systems, LTD.', 'Tai', 'Wu', '(852) 850 43 98',
'400 Connaught Road', null, 'Central Hong Kong', null, 'Hong Kong', null, null);

INSERT INTO CUSTOMER
(cust_no, customer, contact_first, contact_last, phone_no, address_line1,
address_line2, city, state_province, country, postal_code, on_hold) VALUES
(1006, 'DataServe International', 'Tomas', 'Bright', '(613) 229 3323',
'2000 Carling Avenue', 'Suite 150', 'Ottawa', 'ON', 'Canada', 'K1V 9G1', null);

INSERT INTO CUSTOMER
(cust_no, customer, contact_first, contact_last, phone_no, address_line1,
address_line2, city, state_province, country, postal_code, on_hold) VALUES
(1007, 'Mrs. Beauvais', null, 'Mrs. Beauvais', null,
'P.O. Box 22743', null, 'Pebble Beach', 'CA', 'USA', '93953', null);

INSERT INTO CUSTOMER
(cust_no, customer, contact_first, contact_last, phone_no, address_line1,
address_line2, city, state_province, country, postal_code, on_hold) VALUES
(1008, 'Anini Vacation Rentals', 'Leilani', 'Briggs', '(808) 835-7605',
'3320 Lawai Road', null, 'Lihue', 'HI', 'USA', '96766', null);

INSERT INTO CUSTOMER
(cust_no, customer, contact_first, contact_last, phone_no, address_line1,
address_line2, city, state_province, country, postal_code, on_hold) VALUES
(1009, 'Max', 'Max', null, '22 01 23',
'1 Emerald Cove', null, 'Turtle Island', null, 'Fiji', null, null);

INSERT INTO CUSTOMER
(cust_no, customer, contact_first, contact_last, phone_no, address_line1,
address_line2, city, state_province, country, postal_code, on_hold) VALUES
(1010, 'MPM Corporation', 'Miwako', 'Miyamoto', '3 880 77 19',
'2-64-7 Sasazuka', null, 'Tokyo', null, 'Japan', '150', null);

INSERT INTO CUSTOMER
(cust_no, customer, contact_first, contact_last, phone_no, address_line1,
address_line2, city, state_province, country, postal_code, on_hold) VALUES
(1011, 'Dynamic Intelligence Corp', 'Victor', 'Granges', '01 221 16 50',
'Florhofgasse 10', null, 'Zurich', null, 'Switzerland', '8005', null);

INSERT INTO CUSTOMER
(cust_no, customer, contact_first, contact_last, phone_no, address_line1,
address_line2, city, state_province, country, postal_code, on_hold) VALUES
(1012, '3D-Pad Corp.', 'Michelle', 'Roche', '1 43 60 61',
'22 Place de la Concorde', null, 'Paris', null, 'France', '75008', null);

INSERT INTO CUSTOMER
(cust_no, customer, contact_first, contact_last, phone_no, address_line1,
address_line2, city, state_province, country, postal_code, on_hold) VALUES
(1013, 'Lorenzi Export, Ltd.', 'Andreas', 'Lorenzi', '02 404 6284',
'Via Eugenia, 15', null, 'Milan', null, 'Italy', '20124', null);

INSERT INTO CUSTOMER
(cust_no, customer, contact_first, contact_last, phone_no, address_line1,
address_line2, city, state_province, country, postal_code, on_hold) VALUES
(1014, 'Dyno Consulting', 'Greta', 'Hessels', '02 500 5940',
'Rue Royale 350', null, 'Brussels', null, 'Belgium', '1210', null);

INSERT INTO CUSTOMER
(cust_no, customer, contact_first, contact_last, phone_no, address_line1,
address_line2, city, state_province, country, postal_code, on_hold) VALUES
(1015, 'GeoTech Inc.', 'K.M.', 'Neppelenbroek', '(070) 44 91 18',
'P.0.Box 702', null, 'Den Haag', null, 'Netherlands', '2514', null);

COMMIT;

/*
 *  Put some customers on-hold.
 */

UPDATE CUSTOMER SET on_hold = '*' WHERE cust_no = 1002;
UPDATE CUSTOMER SET on_hold = '*' WHERE cust_no = 1009;

COMMIT;

/******************************/
/* Tables for regress2.amosql */
/******************************/

create table PERSON (ssn integer not null,
	                     name varchar(200),
			     salary real,
                             constraint ssn_constr primary key (ssn));

create table PERSON2 (ssn integer not null,
	                     name varchar(10),
			     salary real,
                             primary key (ssn));

create table SWEDISH_PERSON(birthdate integer not null,
                                     last_digits integer not null,
			             salary real,
                                     constraint personnummer primary key
                                     (birthdate, last_digits));

create table PERSON_TELEPHONES
                (ssn integer not null,
                 phone_number integer not null,
                 constraint fs FOREIGN KEY (ssn) references PERSON(ssn),
		 constraint onlyk unique (ssn, phone_number));

INSERT INTO PERSON2 VALUES (1234,'Kalle',1000.0);

INSERT INTO PERSON2 VALUES (2345,'Ulla',2000.0);

INSERT INTO PERSON2 VALUES (3456,'Ville',3000.0);

/***********************************/
/* Tables for testConstructor.osql */
/***********************************/

create table PERSON3(ssn integer not null primary key, 
                                first_name varchar(15));

create table JOBB(ssn integer not null references person, 
                             title varchar(15));

create table MARRIED(
  ssn integer not null,
  cid integer not null,
  score integer,
  primary key (ssn,cid));

