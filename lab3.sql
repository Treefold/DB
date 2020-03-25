-- 3.1 c and C are used because there is no name containing both a and A
select *
from (
    select e2.last_name, to_char(e2.hire_date, 'Mon-YYYY') Angajare
    from employees e1 inner join employees e2 
    on e1.department_id = e2.department_id
        and e1.last_name = 'Gates' 
        and e2.last_name != 'Gates' 
        and e2.last_name like '%c%'
    union all
    select e2.last_name, to_char(e2.hire_date, 'Mon-YYYY') Angajare
    from employees e1 inner join employees e2 
    on e1.department_id = e2.department_id
        and e1.last_name = 'Gates' 
        and e2.last_name != 'Gates' 
        and e2.last_name like '%C%'
    )
order by last_name;    
-- 3.2: SQL standard
select e1.employee_id, e1.last_name, e2.employee_id, e2.last_name
from employees e1 inner join employees e2
on e1.department_id = e2.department_id 
    and e2.last_name like '%t'
order by e1.last_name;
-- 3.2: where clause
select e1.employee_id, e1.last_name, e2.employee_id, e2.last_name
from employees e1
inner join (
    select department_id, employee_id, last_name
    from employees
    where last_name like '%t' -- condition in where
    order by last_name
) e2
using (department_id)
order by e1.last_name;
-- 3.3
select e.last_name, e.salary, j.job_title, l.city, c.country_name
from employees m
inner join departments d on d.manager_id = m.employee_id and m.last_name = 'King'
inner join employees e on e.department_id = d.department_id
inner join locations l on l.location_id = d.location_id
inner join jobs j on j.job_id = e.job_id
inner join countries c on c.country_id = l.country_id
order by e.last_name;
-- 3.4
select d.department_id, d.department_name, e.last_name, j.job_title, TO_CHAR(e.salary,'L99G999D99')
from departments d
    inner join employees e on d.department_id = e.department_id
    inner join jobs j      on e.job_id        = j.job_id
where e.last_name like '%ti%'
order by d.department_name, e.last_name;
-- 3.5
select e.last_name, d.department_id, d.department_name, l.city, j.job_title
from employees e 
    inner join departments d on e.department_id = d.department_id
    inner join locations l   on d.location_id   = l.location_id
    inner join jobs j        on e.job_id        = j.job_id
where l.city like 'Oxford';
-- 3.6
select e.employee_id, e.last_name, e.salary
from employees e
inner join (
    select department_id, (MIN(salary)+Max(salary))/2 msalary
    from employees
    group by department_id
) d on e.department_id = d.department_id
where e.salary > d.msalary;
-- 3.7 a
select e.last_name, d.department_name
from departments d 
    right outer join employees e using (department_id);
-- 3.7 b
select e.last_name, d.department_name
from employees e
    join departments d on e.department_id = d.department_id(+);
-- 3.8 a
select e.last_name, d.department_name
from employees e
    right outer join departments d using (department_id);
-- 3.8 b
select e.last_name, d.department_name
from employees e
    join departments d on e.department_id(+) = d.department_id;
-- 3.9 a write full outer join
select e.last_name, d.department_name
from employees e
    full outer join departments d using (department_id);
-- 3.9 b union
select e.last_name, d.department_name
from employees e
    join departments d on e.department_id(+) = d.department_id
union
select e.last_name, d.department_name
from employees e
    join departments d on e.department_id = d.department_id(+);
-- 3.10
select department_id
from departments
where department_name like '%re%'
union
select department_id
from employees
where job_id like 'SA_REP';
-- 3.11 union all won't eliminate the duplicates
-- 3.12 a
select distinct department_id from departments
minus select department_id from employees;
-- 3.12 b
select distinct d.department_id
from departments d join employees e 
        on d.department_id = e.department_id(+)
where e.employee_id is NULL
order by department_id;
-- 3.13
select department_id
from departments
where department_name like '%re%'
intersect
select department_id
from employees
where job_id like 'HR_REP';
-- 3.14
select e.employee_id, e.job_id, e.last_name
from employees e
inner join (
    select department_id, (MIN(salary)+Max(salary))/2 msalary
    from employees
    group by department_id
) d on e.department_id = d.department_id
where e.salary >= d.msalary;
-- 3.15
select last_name, hire_date
from employees
where hire_date > (
    select hire_date
    from employees
    where last_name like 'Gates' 
        and rownum = 1
);
-- 3.16 when the subquerry returns more than one row we cannot replace "in" with "="
select last_name, salary
from employees inner join (
    select department_id
    from employees
    where last_name like 'Gates' 
        and rownum = 1
) using (department_id)
minus 
select last_name, salary
from employees
where last_name like 'Gates' 
    and rownum = 1;
-- 3.17
select last_name, salary
from employees e inner join (
        select employee_id
        from employees
        where manager_id is null
            and rownum = 1
) prez on e.manager_id = prez.employee_id;
-- 3.18
select e.last_name, e.department_id, e.salary
from employees e
where e.department_id in (
    select department_id
    from employees c
    where e.salary = c.salary 
        and c.commission_pct is not null
        and c.commission_pct > 0
);
-- 3.19
select e.employee_id, e.last_name, e.salary
from employees e
inner join (
    select department_id, (MIN(salary)+Max(salary))/2 msalary
    from employees
    group by department_id
) d on e.department_id = d.department_id
where e.salary > d.msalary;
-- 3.20 the employee will be showed if there is at least one clerk with the salary less than him
select *
from employees
where salary > all (
    select salary 
    from employees 
    where job_id like '%CLERK%'
)
order by salary desc;
-- 3.21
select nc.last_name, d.department_name, nc.salary
from employees nc inner join departments d using (department_id)
where (nc.commission_pct is null or nc.commission_pct = 0)
    and (
            select max(rownum) 
            from employees c
            where c.manager_id = nc.manager_id
                and c.commission_pct is not null 
                and c.commission_pct > 0
        ) is not null;
-- 3.22
select e.last_name, de.department_name, e.salary, e.job_id
from employees e inner join departments de using (department_id)
where (
        select max(rownum) 
        from employees o
            inner join departments using (department_id)
            inner join locations l using (location_id)
        where e.salary = o.salary
            and e.commission_pct = o.commission_pct
            and l.city like 'Oxford'
        ) is not null;
-- 3.23
select e.last_name, department_id, e.job_id
from employees e
    inner join departments using (department_id)
    inner join locations l using (location_id)
where l.city like 'Toronto';