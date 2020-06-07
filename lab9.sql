-- setup
create table emp_smd as (select * from employees);
select * from emp_smd;
create table dept_smd as (select * from departments);
select * from dept_smd;

-- 9.1
create global temporary table temp_tranz_smd (
    x number
) on commit delete rows;
insert into temp_tranz_smd values (10);
select * from temp_tranz_smd;
commit;
select * from temp_tranz_smd;
-- 9.2
create global temporary table temp_sesiune_smd (
    x number
) on commit preserve rows;
insert into temp_sesiune_smd values (10);
select * from temp_sesiune_smd;
commit;
select * from temp_sesiune_smd;
-- 9.3 *intr+o noua sesiune*
desc temp_tranz_smd;
desc temp_sesiune_smd;
insert into temp_tranz_smd values (10);
insert into temp_sesiune_smd values (10);
-- 9.4 doar doar daca ambele table sunt nefolosite (goale)
truncate table temp_tranz_smd;
truncate table temp_sesiune_smd;
drop table temp_tranz_smd;
drop table temp_sesiune_smd;
-- 9.5 - da, i se aloca spatiu necesar memorarii query-ului efectuat
create global temporary table angajati_azi_smd
on commit preserve rows
as select * from emp_smd where hire_date = SYSDATE; 
select * from angajati_azi_smd;
-- 9.6
insert into angajati_azi_smd (employee_id, last_name, email, hire_date, job_id)
    values (99, 'm', 'm', sysdate, 1);
desc angajati_azi_smd;
alter table angajati_azi_smd modify last_name char(25); -- nu se poate comita pana cand sesiunea curenta nu s+a incheiat
truncate table angajati_azi_smd;
alter table angajati_azi_smd modify last_name char(25); -- a mers deoarece nu are elemente -> sesiunea nu a inceput sau s+a terminat deja
drop table angajati_azi_smd;
-- 9.7
create view viz_emp30_smd as 
    (select employee_id, last_name, email, salary from emp_smd where department_id = 30);
desc viz_emp30_smd; 
-- vizualizarea este formata doar din coloanele selectate din emp_smd
-- s+au pastrat constrangerile de not null, dar nu si pentru cheia primara
insert into viz_emp30_smd values (13, 'm', 'm', 1500);
-- nu putem insera deoarece nu avem cum sa specificam data angajarii, care nu are voie sa fie null si nici nu al un not null default
--9.8
create or replace view viz_emp30_smd as 
    (select employee_id, last_name, email, salary, hire_date, job_id from emp_smd where department_id = 30);
insert into viz_emp30_smd values (300, 'm', 'm', 1500, sysdate, 1);
select * from emp_smd where employee_id = 300; -- a fost introdus in tabela emp_smd
select * from viz_emp30_smd where employee_id = 300; -- dar nu si in view deoarece nu este din departamentul 30
update viz_emp30_smd set hire_date=hire_date-15 where employee_id = 300; -- nu apare in view -> nu se modifica in tabela emp_smd
update emp_smd set department_id=30 where employee_id=300; -- acum emp cu id 300 apare in view
update viz_emp30_smd set hire_date=hire_date-15 where employee_id = 300; -- modifica atat ce este in view, cat si ce a fost adaugat in emp_smd
select * from emp_smd where employee_id = 300;
delete from viz_emp30_smd where employee_id = 300; -- este sters atat din view cat si din tabel
select * from emp_smd where employee_id = 300;
-- 9.9
create or replace view viz_emp50_smd as
    (select employee_id, last_name, email, job_id, hire_date, salary from emp_smd where department_id = 50);
desc viz_emp50_smd; --  s+au pastrat constrangerile de not null, dar nu si pentru cheia primara
-- 9.10 a)
insert into viz_emp50_smd values (301, 'm', 'm', 1, sysdate, 1500); -- inserata dar nu e vizibila in view(deparamentul nu e 50)
-- 9.10 b)
select * from USER_UPDATABLE_COLUMNS where lower(table_name) = 'viz_emp50_smd'; -- toate sunt
-- 9.10 c)
insert into viz_emp50_smd values (302, 'm', 'm', 1, sysdate, 1500); -- inserata dar nu e vizibila in view(deparamentul nu e 50)
-- 9.10 d) deoarece departamentul nu este 50, instanta introdusa nu este vizibila din view, dar a fost creata si se poate accesa din emp_smd
drop view viz_emp50_smd;
-- 9.11 a) 
create or replace view viz_emp_dep30_smd as
    (select v.*, d.* from viz_emp30_smd v, (select department_id, department_name from departments where department_id = 30) d);
select * from user_constraints where lower(table_name) = 'emp_smd';
-- 9.11 b) - nu poate insera deoarece viewul are compus din mai multe tabele
insert into viz_emp_dep30_smd values (3000, 'm', 'm', 1, sysdate, 'SA_REP', 30, 'Purchasing');
-- 9.11 c)
select * from USER_UPDATABLE_COLUMNS where lower(table_name) = 'viz_emp_dep30_smd'; -- nici una
-- 9.11 d) va sterge entitatea din tabelul caruia i s+a facut viewul respectiv
drop view viz_emp_dep30_smd;
-- 9.12 - compus deoarece contine grupari de data -> nu se poate actualiza nicio coloana
create or replace view viz_dept_sum_smd as (
    select department_id, min(salary) min_sal, max(salary) max_sal, round(avg(salary), 2) avg_sal 
    from employees group by department_id
);
drop view viz_dept_sum_smd;
-- 9.13
create or replace view viz_emp30_smd as 
    (select employee_id, last_name, email, salary, hire_date, job_id, department_id from emp_smd where department_id = 30)
    with check option; -- n+am gasit nici pe net cum ii dau si un nume acestui check
select * from user_constraints where lower(table_name) = 'viz_emp30_smd';
insert into viz_emp30_smd values (3000, 'm', 'm', 1, sysdate, 'SA_REP', 1); -- "with check option" clause vioation
drop view viz_emp30_smd;
-- 9.14 a) - se pot insera/actualiza linii prin intermediul ei doar in tabela emp_smd
--        - la stergerea din vizualizare se sterge linia si din emp_smd
create or replace view viz_emp_s_smd as (
    select e.* from emp_smd e inner join departments d on e.department_id = d.department_id
    where d.department_name like 'S%'
);
-- 9.14 b)
create or replace view viz_emp_s_smd as (
    select e.* from employees e inner join departments d on e.department_id = d.department_id
    where d.department_name like 'S%'
) with read only;
desc viz_emp_s_smd;
insert into viz_emp_s_smd (employee_id) values (300); -- Error: cannot perform a DML operation on a read-only view 
-- 9.15 
select view_name, text from user_views where view_name like '%SMD';
-- 9.16 - nu este necesara o vizualizare inline
select e.last_name, e.salary, e.department_id, dept.max_sal
from (select department_id, max(salary) max_sal from employees group by department_id) dept
    inner join employees e on e.department_id = dept.department_id;
-- 9.17
create or replace view viz_sal_smd as (
      select e.last_name ang_nume, d.department_name dep_nume, e.salary salariu, l.city oras
      from employees e inner join departments d on e.department_id = d.department_id
        inner join locations l on d.location_id = l.location_id      
);
select * from user_updatable_columns where lower(table_name) = 'viz_sal_smd'; -- doar ang_nume si salariu
drop view viz_sal_smd;
-- 9.18
create or replace view v_emp_smd as (select employee_id, last_name, first_name, email, phone_number from emp_smd);
alter view v_emp_smd add (
    constraint v_emp_smd_pk primary key (employee_id) disable novalidate,
    constraint c_v_emp_smd_mail unique (email) disable novalidate   
);
drop view v_emp_smd;
-- 9.19
alter view viz_emp_s_smd add constraint "pk_viz_emp_s_smd" primary key (employee_id) disable;
drop view viz_emp_s_smd;
-- 9.20
create sequence seq_dept_smd 
    minvalue 400
    increment by 10
    maxvalue 10000
    nocycle
    nocache;
select seq_dept_smd.nextval from dual;
-- 9.21
select sequence_name nume, min_value, max_value, increment_by, last_number from user_sequences;
-- 9.22
create sequence seq_emp_smd increment by 1 start with 1 nocycle nocache;
-- 9.23 - nu se pot actualiza emp_id si menager_id simultan fara a retine datele
--      - acest lucru este esential pentru a nu legatura dintre date
create global temporary table emp_smd_new_id (
    old_id number unique not null,
    new_id number -- unique not null default on null seq_emp_smd.nextval -- nu a mers
) on commit delete rows;
insert into emp_smd_new_id(old_id) select distinct employee_id from emp_smd;
update emp_smd_new_id set new_id = seq_emp_smd.nextval; -- nu a mers defaultul
select * from emp_smd_new_id;
update emp_smd set 
    employee_id = (select new_id from emp_smd_new_id where old_id = employee_id),
    manager_id  = (select new_id from emp_smd_new_id where old_id = manager_id);
select * from emp_smd;
commit;
drop table emp_smd_new_id;
-- 9.24
insert into emp_smd (employee_id, last_name, email, hire_date, job_id) 
    values (seq_emp_smd.nextval, 'm', 'm', sysdate, 1);
desc dept_smd;
insert into dept_smd (department_id, department_name) values (seq_dept_smd.nextval, 'new');
-- 9.25
select seq_emp_smd.currval "seq_emp_smd", seq_dept_smd.currval "seq_dept_smd" from dual;
-- 9.26
drop sequence seq_dept_smd;
drop sequence seq_emp_smd;
-- clean up
drop table emp_smd;
-- 9.27
create index idx_emp_last_name_smd on emp_smd(last_name);
-- 9.28 - automat
alter table emp_smd add (primary key (employee_id), unique (last_name, first_name, hire_date));
-- 9.28 - manual
create index idx_emp_id_smd on emp_smd(employee_id);
create index idx_emp_unique_smd on emp_smd (last_name, first_name, hire_date);
-- 9.29
create index idx_emp_dep_smd on emp_smd (department_id);
-- 9.30
create index idx_emp_lower_name_smd on emp_smd(lower(last_name));
create index idx_dept_upper_name_smd on dept_smd(upper(department_name));
-- 9.31
select uic.index_name, uic.column_name, uic.column_position , ui.uniqueness
from USER_IND_COLUMNS uic inner join USER_INDEXES ui on uic.index_name = ui.index_name
where uic.table_name = 'EMP_SMD' or uic.table_name = 'DEPT_SMD';
-- 9.32
drop index idx_emp_last_name_smd;
-- 9.33
create cluster angajati_smd (angajat number(6))
size 512 storage (initial 100 next 50);
-- 9.34 
create index idx_angajati_smd on cluster angajati_smd;
-- 9.35
create table ang_1_smd cluster angajati_smd (employee_id)
as select * from employees where salary < 5000;
create table ang_2_smd cluster angajati_smd (employee_id)
as select * from employees where salary between 5000 and 10000;
create table ang_3_smd cluster angajati_smd (employee_id)
as select * from employees where salary > 10000;
-- 9.36
select * from user_clusters;
-- 9.37
select cluster_name from user_tables where table_name = 'ANG_3_SMD';
-- 9.38 n+am idee si nici nu am gasit net
-- 9.39
select cluster_name from user_tables where table_name = 'ANG_3_SMD';
-- 9.40
drop table ang_2_smd;
select table_name from user_tables where cluster_name = 'ANGAJATI_SMD';
-- 9.41
drop cluster angajati_smd including tables cascade constraints;
-- 9.42
create synonym emp_public_smd for emp_smd;
-- 9.43 
create synonym v30_smd for viz_emp30_smd;
-- 9.44
create synonym dept_public_smd for dept_smd;
select * from dept_public_smd;
rename dept_smd to dept_ssmd;
select * from dept_public_smd; -- no longer vailid
rename dept_ssmd to dept_smd;
select * from dept_public_smd; -- valid again
-- 9.45 nu stiu sa fac un script si nici nu pot zice ca inteleg scriptul scris deja ca model
drop synonym emp_public_smd;
drop synonym v30_smd;
drop synonym dept_public_smd;
-- restul (cele de la snapshot) sunt deja facute in laborator
-- clear setup
drop table dept_smd;
drop table emp_smd;