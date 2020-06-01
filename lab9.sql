-- setup
create table emp_smd as (select * from employees);
-- 9.1
create view viz_emp30_smd as 
    (select employee_id, last_name, email, salary from emp_smd where department_id = 30);
desc viz_emp30_smd; 
-- vizualizarea este formata doar din coloanele selectate din emp_smd
-- s+au pastrat constrangerile de not null, dar nu si pentru cheia primara
insert into viz_emp30_smd values (13, 'm', 'm', 1500);
-- nu putem insera deoarece nu avem cum sa specificam data angajarii, care nu are voie sa fie null si nici nu al un not null default
--9.2
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
-- 9.3
create or replace view viz_emp50_smd as
    (select employee_id, last_name, email, job_id, hire_date, salary from emp_smd where department_id = 50);
desc viz_emp50_smd; --  s+au pastrat constrangerile de not null, dar nu si pentru cheia primara
-- 9.4 a)
insert into viz_emp50_smd values (301, 'm', 'm', 1, sysdate, 1500); -- inserata dar nu e vizibila in view(deparamentul nu e 50)
-- 9.4 b)
select * from USER_UPDATABLE_COLUMNS where lower(table_name) = 'viz_emp50_smd'; -- toate sunt
-- 9.4 c)
insert into viz_emp50_smd values (302, 'm', 'm', 1, sysdate, 1500); -- inserata dar nu e vizibila in view(deparamentul nu e 50)
-- 9.4 d) deoarece departamentul nu este 50, instanta introdusa nu este vizibila din view, dar a fost creata si se poate accesa din emp_smd
-- 9.5 - compus deoarece contine grupari de data -> nu se poate actualiza nicio coloana
create or replace view viz_dept_sum_smd as (
    select department_id, min(salary) min_sal, max(salary) max_sal, round(avg(salary), 2) avg_sal 
    from employees group by department_id
);
-- 9.6 a) - se pot insera/actualiza linii prin intermediul ei doar in tabela emp_smd
--        - la stergerea din vizualizare se sterge linia si din emp_smd
create or replace view viz_emp_s_smd as (
    select e.* from employees e inner join departments d on e.department_id = d.department_id
    where d.department_name like 'S%'
);
-- 9.6 b)
create or replace view viz_emp_s_smd as (
    select e.* from employees e inner join departments d on e.department_id = d.department_id
    where d.department_name like 'S%'
) with read only;
desc viz_emp_s_smd;
insert into viz_emp_s_smd (employee_id) values (300); -- Error: cannot perform a DML operation on a read-only view 
-- 9.7 
select view_name, text from user_views where view_name like '%SMD';
-- 9.8
create or replace view viz_sal_smd as (
      select e.last_name ang_nume, d.department_name dep_nume, e.salary salariu, l.city oras
      from employees e inner join departments d on e.department_id = d.department_id
        inner join locations l on d.location_id = l.location_id      
);
select * from user_updatable_columns where lower(table_name) = 'viz_sal_smd'; -- doar ang_nume si salariu
-- 9.9
create or replace view v_emp_smd as (select employee_id, last_name, first_name, email, phone_number from emp_smd);
alter view v_emp_smd add (
    constraint v_emp_smd_pk primary key (employee_id) disable novalidate,
    constraint c_v_emp_smd_mail unique (email) disable novalidate   
);
-- 9.10
alter table emp_smd add constraint c_emp_smd_nume check (lower(last_name) not like 'wx%');
-- 9.11
create sequence seq_dept_smd 
    minvalue 400
    increment by 10
    maxvalue 10000
    nocycle
    nocache;
-- 9.12
select sequence_name nume, min_value, max_value, increment_by, last_number from user_sequences;
drop sequence seq_dept_smd;
-- 9.13
create sequence seq_emp_smd increment by 1 start with 1 nocycle nocache;
-- 9.14 - nu se pot actualiza emp_id si menager_id simultan fara a retine datele
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
-- 9.15
drop sequence seq_emp_smd;
-- 9.16
create global temporary table temp_tranz_smd (
    x number
) on commit delete rows;
insert into temp_tranz_smd values (10);
select * from temp_tranz_smd;
commit;
select * from temp_tranz_smd;
-- 9.17
create global temporary table temp_sesiune_smd (
    x number
) on commit preserve rows;
insert into temp_sesiune_smd values (10);
select * from temp_sesiune_smd;
commit;
select * from temp_sesiune_smd;
-- 9.18 *intr+o noua sesiune*
desc temp_tranz_smd;
desc temp_sesiune_smd;
insert into temp_tranz_smd values (10);
insert into temp_sesiune_smd values (10);
-- 9.19 - da, i se aloca spatiu necesar memorarii query-ului efectuat
create global temporary table angajati_azi_smd
on commit preserve rows
as select * from emp_smd where hire_date = SYSDATE; 
select * from angajati_azi_smd;
-- 9.20
insert into angajati_azi_smd (employee_id, last_name, email, hire_date, job_id)
    values (99, 'm', 'm', sysdate, 1);
desc angajati_azi_smd;
alter table angajati_azi_smd modify last_name char(25); -- nu se poate comita pana cand sesiunea curenta nu s+a incheiat
truncate table angajati_azi_smd;
alter table angajati_azi_smd modify last_name char(25); -- a mers deoarece nu are elemente -> sesiunea nu a inceput sau s+a terminat deja
drop table angajati_azi_smd;
-- clean up
drop vire v_emp_smd;
drop view viz_sal_smd;
drop view viz_emp_s_smd;
drop view viz_dept_sum_smd;
drop view viz_emp50_smd;
drop view viz_emp30_smd;
drop table emp_smd;

