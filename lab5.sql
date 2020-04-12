-- 5.1
select department_name, job_title, round(avg(salary), 2) avg_salary, grouping(department_name), grouping(job_title)
from employees
    join jobs using (job_id)
    join departments using (department_id)
group by rollup (department_name, job_title);
-- 5.2
select department_name, job_title, round(avg(salary), 2) avg_salary, decode(grouping(department_name), 1, 'Dep', NULL),  decode(grouping(job_title), 1, 'Job', NULL)
from employees
    join jobs using (job_id)
    join departments using (department_id)
group by cube (department_name, job_title);    
-- 5.3
select department_name, job_title, e.manager_id, round(avg(salary), 2) avg_salary --, grouping(department_name), grouping(job_title), grouping(e.manager_id)
from employees e
join departments using (department_id)
join jobs using (job_id)
group by grouping sets ((department_name, job_title), (job_title, e.manager_id), ());
-- 5.4
select case when max(salary) > 15000 then max(salary) else NULL end max_salary 
from employees;
-- 5.5 A
select *
from employees e
where salary > (select avg(salary) from employees where department_id = e.department_id);
-- 5.5 B -- no idea for subquerry in select
select * 
from employees
    inner join (
        select department_id, department_name, avg_salary, emp_cnt
        from departments inner join (
            select department_id, avg(salary) avg_salary, count(employee_id) emp_cnt
            from employees
            group by (department_id)
        ) using (department_id)
    ) using (department_id)
where salary > avg_salary;
-- 5.6 I
select last_name, salary
from employees
where salary > all (
    select avg(salary)
    from employees
    group by (department_id)
);
-- 5.6 II
select last_name, salary
from employees
where salary > (
    select max(avg(salary)) avg_sal
    from employees
    group by (department_id)
);
-- 5.7 I
select last_name, salary
from employees e
where salary = (
    select min(salary)
    from employees
    where department_id = e.department_id
); 
-- 5.7 II
select last_name, salary
from employees e
where (department_id, salary) in (
    select department_id, min(salary)
    from employees
    group by (department_id)
);
-- 5.7 III
select e.last_name, e.salary
from employees e
    inner join (
    select department_id, min(salary) salary
    from employees
    group by (department_id)
) d on e.department_id = d.department_id and e.salary = d.salary;
-- 5.8
select e.last_name, d.department_name
from departments d inner join employees e using (department_id)
where (department_id, hire_date) in (
    select department_id, min(hire_date)
    from employees
    group by (department_id)    
)
order by d.department_name;
-- 5.9
select last_name, e.department_id 
from employees e
where exists (
    select employee_id
    from employees
    where e.department_id = department_id -- departments 30 and 50
        and salary = (
            select min(salary)
            from employees
            where department_id = 30
        )
);
-- 5.10
select last_name, salary
from (
    select last_name, salary
    from employees
    where rownum <= 3
    order by salary desc
)
order by salary;
-- 5.11
select employee_id, last_name, first_name
from employees m
where 2 >= (
    select count(employee_id)
    from employees
    where manager_id = m.employee_id
);
-- 5.12
select *
from locations l
where exists (
    select department_id from departments
    where location_id = l.location_id
);
-- 5.12 alternative (slower)
select *
from locations l
where location_id in (
    select location_id from departments
    where location_id = l.location_id
);
-- 5.13 - all departments have at least one employee
select department_name
from departments d
where not exists (   
    select department_id from employees
    where department_id = d.department_id
);
-- 5.13 (uncorrelated querry)
select department_name
from departments
where not department_id in ( -- "in (" <=> "= any ("
    select distinct department_id from employees where department_id is not null
);
-- 5.14 A)
select employee_id, last_name, hire_date, salary, manager_id, level
from employees
start with last_name like 'De Haan'
connect by manager_id = prior employee_id
    and level <= 2;
-- 5.14 B)
select employee_id, last_name, hire_date, salary, manager_id, level
from employees
start with last_name like 'De Haan'
connect by manager_id = prior employee_id;
-- 5.Obs
select employee_id, last_name, hire_date, salary, manager_id, level
from employees
start with last_name like 'De Haan'
connect by prior manager_id = employee_id;
-- 5.15
select employee_id, last_name, hire_date, salary, manager_id, level
from employees
start with employee_id = 114
connect by manager_id = prior employee_id;
-- 5.16 nu a zis cu cel mult 2 nivele sub (ci exact pe nivelul 2 sub el)
-- 5.16 the requirement said that it has to 2 levels under De Haan
select *
from ( 
    select employee_id, manager_id, last_name, level lvl
    from employees
    start with last_name like 'De Haan'
    connect by manager_id = prior employee_id
        and level <= 3
) where lvl = 3;
-- 5.17
select employee_id, manager_id, level
from employees
connect by manager_id = prior employee_id
order by level; -- 107 on level 1 <=> each emplyee is the root at one moment
-- 5.18
select employee_id, last_name, hire_date, salary, level, manager_id
from employees
start with salary = (select max(salary) from employees)
connect by manager_id = prior employee_id
    and salary > 5000;
-- 5.19
with deps_s as (
    select department_id, sum(salary) salary
    from employees
    group by (department_id)
)
select d.department_name, deps_s.salary
from departments d inner join deps_s using (department_id)
where deps_s.salary > (select avg(salary) from employees);
-- 5.20
with h as (
    select *
    from ( 
        select employee_id, manager_id, first_name, last_name, job_id, hire_date, level lvl
        from employees
        start with last_name like 'King' and first_name like 'Steven'
        connect by manager_id = prior employee_id
    )
    where lvl > 1 -- only his descendents    
        and to_char(hire_date, 'yyyy') >= '1994' -- in order to have more than one
    order by hire_date
)
select lvl || ' ' || first_name || ' ' || last_name ID, job_id, hire_date
from h where hire_date = (select min(hire_date) from h);
-- 5.21
select * from employees 
where salary in
    -- to have more with the last highest salary
    (select salary from (select salary from employees order by salary desc) where rownum <= 11) 
order by salary;
-- 5.22
select job_id, job_title from jobs 
where job_id in (
        select job_id
        from (select job_id, avg(salary) avg_sal from employees group by (job_id) order by avg_sal)
        where rownum <= 3
    );
-- 5.23
select 'Departamentul '|| d.department_name ||
    ' este condus de '|| decode(nvl(d.manager_id, 0), 0, 'nimeni', d.manager_id) ||
    ' si '|| decode(nvl(e.cnt, 0), 0, 'nu are salariati', 'are num?rul de salaria?i ' || e.cnt) as info
from departments d join (
    select department_id, count(employee_id) cnt
    from employees
    group by (department_id)
) e on d.department_id = e.department_id(+);
-- 5.24
select last_name, first_name, nullif(length(last_name), length(first_name)) len from employees;
-- 5.25
select last_name, hire_date, salary,
    salary * decode(to_char(hire_Date, 'yyyy'), '1989', 1.2, '1990', 1.15, '1991', 1.1, 1) raise
from employees
order by hire_Date;
-- 5.26
with j_info as (
    select job_id, sum(salary) sum_sal, avg(salary) avg_sal, max(salary) max_sal, min(salary) min_sal
    from employees
    group by (job_id)
)
select j.job_id, j.job_title, ji.sum_sal, ji.avg_sal, ji.max_sal, ji.min_sal, case
    when lower(j.job_title) like 's%' then '1 ' || ji.sum_sal
    when ji.max_sal = (select max(max_sal) from j_info) then '2 ' || ji.avg_sal
    else '3 ' || ji.min_sal
end as info
from jobs j  join j_info ji on j.job_id = ji.job_id(+)
order by info;
-- 5.26 - with Decode
with j_info as (
    select job_id, sum(salary) sum_sal, avg(salary) avg_sal, max(salary) max_sal, min(salary) min_sal
    from employees
    group by (job_id)
)
select j.job_id, j.job_title, ji.sum_sal, ji.avg_sal, ji.max_sal, ji.min_sal, 
    decode (instr(lower(j.job_title),'s'), 1, '1 ' || ji.sum_sal, -- else
    (
        decode (ji.max_sal, (select max(max_sal) from j_info), '2 ' || ji.avg_sal,
            '3 ' || ji.min_sal) -- else
    )) as info
from jobs j  join j_info ji on j.job_id = ji.job_id(+)
order by info;










