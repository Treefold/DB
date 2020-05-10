-- 6.1 2 * not exists
select * from employees where employee_id in (
    select distinct employee_id
    from works_on a
    where not exists (
      select 0 from projects p
      where to_char(start_date, 'yyyy') = '2006' 
            and to_char(start_date, 'mm') <= '06'
            and not exists (
                select 1 from works_on b
                where p.project_id=b.project_id
                    and b.employee_id=a.employee_id)
    )
);
-- 6.1 count
select * from employees where employee_id in (
    select employee_id
    from works_on
    where project_id in (
        select project_id from projects
        where to_char(start_date, 'yyyy') = '2006' 
            and to_char(start_date, 'mm') <= '06'
    )
    group by employee_id
    having count(project_id) = (
        select count(*) from projects
        where to_char(start_date, 'yyyy') = '2006' 
            and to_char(start_date, 'mm') <= '06'
    )
);
-- 6.1 minus
select * from employees where employee_id in (
    select distinct employee_id
    from works_on
    minus
    select employee_id from (
        select employee_id, project_id
        from (select employee_id from works_on),
             (select project_id from projects 
                where to_char(start_date, 'yyyy') = '2006' 
                    and to_char(start_date, 'mm') <= '06'
             )
        minus
        select employee_id, project_id from works_on
    )
);
-- 6.1 A include B => B\A = VID
select * from employees where employee_id in (
    select distinct employee_id
    from works_on a
    where not exists (
        select project_id from projects p
        where to_char(start_date, 'yyyy') = '2006' 
            and to_char(start_date, 'mm') <= '06' 
        minus
        select p.project_id from projects p, works_on b
        where p.project_id=b.project_id
            and b.employee_id=a.employee_id
    )
);
-- 6.2
select * from projects where project_id in (
    select distinct project_id from works_on
    minus
    select distinct project_id from works_on where employee_id not in (
        select employee_id from job_history
        group by employee_id
        having count(employee_id) >= 2
    )
);
-- 6.3
select count(*) emp_cnt from (
    select employee_id from job_history
    group by employee_id
    having count(employee_id) >= 2
);
-- 6.4 
select c.country_name, l.employees_number
from countries c inner join (
    select l.country_id, sum (e.dep_cnt) employees_number
    from departments d inner join (
        select department_id, count (employee_id) dep_cnt
        from employees
        group by department_id
    ) e on d.department_id = e.department_id
    inner join locations l on l.location_id = d.location_id
    group by l.country_id 
) l on c.country_id = l.country_id;
-- 6.5
select employee_id, last_name from employees where employee_id in (
    select employee_id from works_on where project_id in (
        select project_id from projects where deadline < delivery_date
    )
    group by employee_id
    having count(employee_id) >= 2
);
-- 6.6
select e.employee_id, w.project_id from employees e
    join works_on w on e.employee_id = w.employee_id(+);
-- 6.7
select * from employees where department_id in ( -- get all in those departments
    select distinct department_id from employees where employee_id in ( -- get their departments
        select distinct project_manager from projects where project_manager is not null -- get all project managers
    )
);
-- 6.8
select * from employees where department_id not in ( -- get all except from those departments
    select distinct department_id from employees where employee_id in ( -- get their departments
        select distinct project_manager from projects where project_manager is not null -- get all project managers
    )
);
-- 6.9
select * from departments where department_id in (
    select department_id from employees
    group by department_id
    having avg(salary) > &p
);
-- 6.10
select * from employees where employee_id in (
    select project_manager from projects 
    group by project_manager
    having count(*) >= 2
);
-- 6.11
select * from employees where employee_id in (
    select distinct employee_id from works_on
    minus
    select distinct employee_id from works_on where project_id not in (
        select project_id from projects where project_manager = 102
    )
);
-- 6.12 a
select last_name from employees where employee_id in (
    select distinct employee_id
    from works_on e
    where employee_id != 200
        and not exists (
            select project_id from works_on
            where employee_id = 200
            minus
            select project_id from works_on
            where employee_id = e.employee_id
        )
);
-- 6.12 b
select last_name from employees where employee_id in (
    select distinct employee_id
    from works_on e
    where employee_id != 200
        and not exists (
            select project_id from works_on
            where employee_id = e.employee_id
            minus
            select project_id from works_on
            where employee_id = 200
        )
);
-- 6.13
select last_name from employees where employee_id in (
    select distinct employee_id
    from works_on e
    where employee_id != 200
        and not exists (
                select project_id from works_on
                where employee_id = 200
                minus
                select project_id from works_on
                where employee_id = e.employee_id
            )
        and not exists (
                select project_id from works_on
                where employee_id = e.employee_id
                minus
                select project_id from works_on
                where employee_id = 200
            )
);
-- 6.14 a
DESCRIBE JOB_GRADES;
-- 6.14 b
explain plan for
select e.last_name, e.first_name, e.salary, (
    select grade_level from job_grades 
    where lowest_sal <= e.salary and e.salary <= highest_sal) salary_grid
from employees e;
select * from table(dbms_xplan.display);
-- 6.15 I. 
SELECT employee_id, last_name, salary, department_id
FROM employees
WHERE employee_id = &p_cod;
-- 6.15 II.
DEFINE p_cod; -- Ce efect are?
SELECT employee_id, last_name, salary, department_id
FROM employees
WHERE employee_id = &p_cod;
UNDEFINE p_cod;
-- 6.15 III.
DEFINE p_cod=100;
SELECT employee_id, last_name, salary, department_id
FROM employees
WHERE employee_id = &&p_cod;
UNDEFINE p_cod;
-- 6.15 IV.
ACCEPT p_cod PROMPT "cod= ";
SELECT employee_id, last_name, salary, department_id
FROM employees
WHERE employee_id = &p_cod;
UNDEFINE p_cod;
-- 6.16
select last_name, department_id, 12*salary anual_salary from employees
where job_id='&p_job_id';
-- 6.17
select last_name, department_id, 12*salary anual_salary from employees
where hire_date >= to_date('&p_date', 'dd-mm-yyyy');
-- 6.18
SELECT &&p_coloana
FROM &p_tabel
WHERE &p_where
ORDER BY &p_coloana;
-- 6.19
ACCEPT p_DataStart PROMPT "start date (format 'MM/DD/YY'): ";
ACCEPT p_DataFinal PROMPT "final date (format 'MM/DD/YY'): ";
select last_name || ', ' || job_id "Angajati" from employees
where to_date('&p_DataStart', 'MM/DD/YY')  <= to_date(hire_date, 'dd-MON-yy')
    and to_date(hire_date, 'dd-MON-yy') <= to_date('&p_DataFinal', 'MM/DD/YY');
UNDEFINE p_DataStart;
UNDEFINE p_DataFinal;
-- 6.20
select e.last_name, e.job_id, e.salary, d.department_name, l.city
from employees e inner join departments d on e.department_id = d.department_id
    inner join locations l on d.location_id = l.location_id
where lower (l.city) = lower ('&p_city');
-- 6.21 a
ACCEPT p_DataStart PROMPT "start date (format 'dd-mm-yyyy): ";
ACCEPT p_DataFinal PROMPT "final date (format 'dd-mm-yyyy): ";
select to_date('&p_DataStart', 'dd-mm-yyyy')+rownum-1 dates_between
from dual
connect by rownum <= to_date('&p_DataFinal', 'dd-mm-yyyy') - to_date('&p_DataStart', 'dd-mm-yyyy')+1;
UNDEFINE p_DataStart;
UNDEFINE p_DataFinal;
-- 6.21 b
ACCEPT p_DataStart PROMPT "start date (format 'dd-mm-yyyy): ";
ACCEPT p_DataFinal PROMPT "final date (format 'dd-mm-yyyy): ";
select dates_between working_days_between from (
    select to_date('&p_DataStart', 'dd-mm-yyyy')+rownum-1 dates_between
    from dual
    connect by rownum <= to_date('&p_DataFinal', 'dd-mm-yyyy') - to_date('&p_DataStart', 'dd-mm-yyyy')+1
) where mod(to_char(dates_between, 'd'),7) > 1;
UNDEFINE p_DataStart;
UNDEFINE p_DataFinal;