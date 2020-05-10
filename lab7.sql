-- 7.1
create table emp_smd  as select * from employees;
create table dept_smd as select * from departments;
-- 7.2
describe employees;
describe emp_smd;
describe departments;
describe dept_smd;
-- 7.3
select * from emp_smd;
select * from dept_smd;
-- 7.4
alter table emp_smd  add constraint pk_emp_smd  primary key (employee_id);
alter table dept_smd add constraint pk_dept_smd primary key (department_id);
alter table emp_smd  add constraint fk_emp_dept_smd foreign key (department_id) 
    references dept_smd(department_id);
-- 7.5 a - "not enough values" -> when using the default column order, all collumns must be specified
--insert into dept_smd values (300, 'Programare'); 
insert into dept_smd values (300, 'Programare', 100, 1);
rollback;
-- 7.5 b - ok (default value used for the unspecied columns)
insert into dept_smd (department_id, department_name) values (300, 'Programare'); 
rollback;
-- 7.5 c - "invalid number" -> the first column specified in values must be a varchar2(30)
--insert into dept_smd (department_name, department_id) values (300, 'Programare');
insert into dept_smd (department_name, department_id) values ('Programare', 300);
rollback;
-- 7.5 d - ok (default value used for the unspecied columns)
insert into dept_smd (department_id, department_name, location_id) values (300, 'Programare', null); 
rollback;
-- 7.5 e - "cannot insert NULL" -> department_id cannot be null
--insert into dept_smd (department_name, location_id) values ('Programare', null); 
insert into dept_smd (department_id, department_name, location_id) values (300, 'Programare', null); 
rollback;
-- 7.5 extra - "unique constraint" -> cannot add 2 department_id at the same time in this table
insert into dept_smd (department_id, department_name) values (300, 'Programare'); 
rollback;
-- 7.6
insert into emp_smd
values ((select max(employee_id)+1 from emp_smd), '', 'SMD', 'SMD', '', to_date('10/05/20', 'dd/mm/yy'), 'None', null, null, null, null);
rollback;
-- 7.7 - no department 300 -> use 270
insert into emp_smd (employee_id, last_name, email, hire_date, job_id, department_id)
values ((select max(employee_id)+1 from emp_smd), 'SMD', 'SMD', sysdate, 'None', 270);
rollback;
-- 7.8
insert into emp_smd (employee_id, last_name, email, hire_date, job_id, department_id)
values ((select max(employee_id)+1 from emp_smd), 'SMD', 'SMD', sysdate, 'None', 270);
rollback;
-- 7.9
create table emp1_smd as select * from employees where 0<>0;
insert into emp1_smd (select * from employees where commission_pct > 0.25);
drop table emp1_smd;
-- 7.10
insert into emp_smd (employee_id, first_name, last_name, email, hire_date, job_id)
values (0, user, user, 'TOTAL', sysdate, 'TOTAL');
rollback;
-- 7.11
insert into emp_smd (employee_id, last_name, first_name, email, hire_date, job_id, salary)
values (&p_codul, '&&p_nume', '&&p_prenume', concat(substr('&p_prenume', 0, 1), substr('&p_nume', 0, 7)), sysdate, 'None', &p_salariu);
undef p_nume;
undef p_prenume;
rollback;
-- 7.12
create table emp1_smd as select * from employees where 0<>0;
create table emp2_smd as select * from employees where 0<>0;
create table emp3_smd as select * from employees where 0<>0;
insert first
when salary < 5000 then into emp1_smd
when salary > 10000 then into emp3_smd
else into emp2_smd
select * from employees;
drop table emp1_smd;
drop table emp2_smd;
drop table emp3_smd;
-- 7.13
create table emp0_smd as select * from employees where 0<>0;
create table emp1_smd as select * from employees where 0<>0;
create table emp2_smd as select * from employees where 0<>0;
create table emp3_smd as select * from employees where 0<>0;
insert first
when department_id = 80 then into emp0_smd
when salary < 5000 then into emp1_smd
when salary > 10000 then into emp3_smd
else into emp2_smd
select * from employees;
drop table emp0_smd;
drop table emp1_smd;
drop table emp2_smd;
drop table emp3_smd;
-- 7.14
select employee_id, salary from emp_smd;
update emp_smd set salary = 1.05 * salary;
rollback;
-- 7.15
select employee_id, job_id from emp_smd where department_id = 80 and commission_pct > 0;
update emp_smd set job_id='SA_REP' where department_id = 80 and commission_pct > 0;
rollback;
-- 7.16
update dept_smd
set manager_id = (select employee_id from emp_smd where last_name = 'Grant' and first_name = 'Douglas')
where department_id = 20;
update emp_smd
set salary = salary + 1000
where employee_id = (select employee_id from emp_smd where last_name = 'Grant' and first_name = 'Douglas');
rollback;
-- 7.17
update emp_smd emp
set (salary, commission_pct) = (select salary, commission_pct from emp_smd where employee_id = emp.manager_id)
where salary = (select min(salary) from emp_smd);
rollback;
-- 7.18
update emp_smd
set email = concat(substr(last_name, 0, 1), nvl(first_name, '.'))
where (department_id, salary) in (
    select department_id, max(salary) 
    from emp_smd
    group by department_id
);
rollback;
-- 7.19
update emp_smd emp
set salary = (select avg(salary) from emp_smd)
where (department_id, hire_date) in (
    select department_id, min(hire_date) from emp_smd 
    group by department_id having department_id is not null
);
rollback;
-- 7.20
update emp_smd
set (job_id, department_id) = (select job_id, department_id from emp_smd where employee_id = 205)
where employee_id = 114;
rollback;
-- 7.21
update dept_smd
set department_id   = &&p_dep_id, 
    department_name = '&p_dep_name', 
    manager_id      = &p_manager_id, 
    location_id     = &p_location_id
where department_id = &p_dep_id;
undef p_dep_id;
rollback;
-- 7.22 - foreign key violation: cannot delete entity when other entity depends on at least one of it's collumns
delete from dept_smd;
rollback;
-- 7.23
delete from emp_smd where nvl (commission_pct, 0) = 0;
rollback;
-- 7.24
delete from dept_smd where department_id in (
    select department_id from dept_smd
    minus
    select department_id
    from emp_smd
    group by department_id
    having count(employee_id) != 0
);
rollback;
-- 7.25
select * from emp_smd where employee_id = &&p_emp_id;
delete from emp_smd where employee_id = &p_emp_id;
undef p_emp_id;
rollback;
-- 7.26
insert into emp_smd (employee_id, first_name, last_name, email, hire_date, job_id)
values (0, user, user, 'TOTAL', sysdate, 'TOTAL');
-- 7.27
savepoint intermediary_point;
-- 7.28
delete from emp_smd;
select * from emp_smd;
-- 7.29
rollback to intermediary_point;
-- 7.30
select * from emp_smd;
commit;
--7.31
delete from emp_smd where commission_pct > 0;
merge into emp_smd emp using employees e on (emp.employee_id = e.employee_id)
when matched then update set
    emp.last_name = e.last_name,
    emp.email     = e.email,
    emp.hire_date = e.hire_date,
    emp.job_id    = e.job_id
when not matched then insert (employee_id, last_name, email, hire_date, job_id)
values (e.employee_id, e.last_name, e.email, e.hire_date, e.job_id);
-- clear after yourself
drop table emp_smd;
drop table dept_smd;







