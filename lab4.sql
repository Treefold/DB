-- 4.1 a) Daca vorbim de Sum, Min, Max sau Avg, valorile null sunt ignorate
-- 4.1 b) Where filtreaza liniile selectate inainte de grupare, pe cand Having filtreaza liniile de dupa grupare
-- 4.2
select round(max(salary)) "Maxim", round(min(salary)) "Minim", round(sum(salary)) "Suma", round(avg(salary)) "Media"
from employees;
-- 4.3
select job_id, round(max(salary)) "Maxim", round(min(salary)) "Minim", round(sum(salary)) "Suma", round(avg(salary)) "Media"
from employees
group by (job_id);
-- 4.4
select job_id, count(job_id) "Nr. angajati"
from employees
group by (job_id);
-- 4.5
select count(*) "Nr. manageri"
from (
    select manager_id 
    from employees
    where manager_id is not null
    group by (manager_id)
);
--4.6
select max(salary) - min(salary) dif
from employees;
-- 4.7
select d.department_id, d.department_name "numele depart", l.city "locatia", count(e.employee_id) "nr. angajati", round(avg(e.salary)) "salariu mediu"
from departments d
    join employees e on d.department_id = e.department_id(+)
    inner join locations l using (location_id)
group by (d.department_id, d.department_name, l.city);
-- 4.8 
select employee_id, last_name
from employees
where salary > (select avg(salary) from employees)
order by salary desc;
-- 4.9
select manager_id, min(salary) "Salariu minim"
from employees
group by (manager_id)
having manager_id is not null
    and min(salary) >= 1000
order by min(salary) desc;
-- 4.10
select d.department_id, d.department_name, max(e.salary)
from departments d inner join employees e on d.department_id = e.department_id(+)
group by (d.department_id, d.department_name)
having max(e.salary) > 3000;
-- 4.11
select min(salary)
from (
    select round(avg(salary)) salary
    from employees
    group by (job_id)
);
-- 4.12
select d.department_id, d.department_name, sum(e.salary)
from departments d inner join employees e on d.department_id = e.department_id(+)
group by (d.department_id, d.department_name);
-- 4.13
select max(salary)
from (
    select round(avg(salary)) salary
    from employees
    group by (job_id)
);
-- 4.14
select j.job_id, j.job_title, j_min.salary
from (
    select job_id, salary from ( -- get min from averages
        select job_id, round(avg(salary)) salary
        from employees
        group by (job_id)
        order by salary
    )
    where rownum = 1
) j_min inner join jobs j on j.job_id = j_min.job_id;
-- 4.15
select round(avg(salary)) salary
from employees
having round(avg(salary)) > 2500;
-- 4.16
select department_id, job_id, sum(salary)
from employees
group by (department_id, job_id);
-- 4.17
select d.department_name, d_avg_max.smin
from (
    select department_id, smin from ( -- get max from averages
        select department_id, round(avg(salary)), min(salary) smin 
        from employees 
        group by (department_id)
        order by round(avg(salary)) desc
    )
    where rownum = 1
) d_avg_max inner join departments d on d.department_id = d_avg_max.department_id;
-- 4.18
select d.department_id, d.department_name, needed_dep.cnt
from (
    select department_id, cnt from (
        select department_id, count(employee_id) cnt 
        from employees 
        where department_id is not null
        group by (department_id)
        order by cnt desc
    )
    where rownum = 1 -- max cnt     (a)
        or cnt < 4   -- less than 4 (b)
) needed_dep inner join departments d on d.department_id = needed_dep.department_id;
-- 4.19
select *
from employees
where to_char(hire_date, 'dd') = (
    select day from (
        select to_char(hire_date, 'dd') day
        from employees
        group by (to_char(hire_date, 'dd'))
        order by count(*) desc
    ) where rownum = 1
);
-- 4.20
select count(*) "Dep with nr emp >= 15"
from (
    select count(employee_id)
    from employees
    group by (department_id)
    having count(employee_id) >= 15
);
-- 4.21
select department_id, sum(salary) salary
from employees
where department_id != 30
group by (department_id)
having count(employee_id) > 10;
-- 4.22
select d.department_id, d.department_name, e.cnt, e.avg_salary, e.last_name, e.salary, e.job_id
from departments d join (
    select department_id, count (employee_id) cnt, round(avg(salary)) avg_salary, last_name, salary, job_id
    from employees
    group by (department_id, last_name, salary, job_id)
) e on d.department_id = e.department_id(+);
-- 4.23
select l.city orasul, d.department_name numele_dep, e.job_id jobul, sum_salary suma_salariilor
from departments d 
    inner join (
        select department_id, job_id, sum(salary) sum_salary
        from employees
        where department_id is not null
            and department_id > 80
        group by (department_id, job_id)
    ) e on d.department_id = e.department_id
    inner join locations l using(location_id);
-- 4.24
select *
from employees
where employee_id in (
    select employee_id
    from job_history
    group by (employee_id)
    having count(*) >= 2
);
-- 4.25
select avg(NVL(commission_pct, 0)*salary) "Comisionul mediu" from employees;
-- 4.26 Done (+ facut si in laboratorul online)
-- 4.27
select job_id "Job", 
    sum(decode(department_id, 30, salary, 0)) "Dep30",
    sum(decode(department_id, 50, salary, 0)) "Dep50",
    sum(decode(department_id, 80, salary, 0)) "Dep80",
    sum(salary) "Total"
from employees
group by (department_id, job_id);
-- 4.28
select count(*) "Total", 
    sum(decode(to_char(hire_Date, 'yyyy'), '1997', 1, 0)) "1997",
    sum(decode(to_char(hire_Date, 'yyyy'), '1998', 1, 0)) "1998",
    sum(decode(to_char(hire_Date, 'yyyy'), '1999', 1, 0)) "1999",
    sum(decode(to_char(hire_Date, 'yyyy'), '2000', 1, 0)) "2000"
from employees;
-- 4.29
select (select count(employee_id) from employees) "Total", 
    (select count(employee_id) from employees where to_char(hire_Date, 'yyyy') = '1997') "1997",
    (select count(employee_id) from employees where to_char(hire_Date, 'yyyy') = '1998') "1998",
    (select count(employee_id) from employees where to_char(hire_Date, 'yyyy') = '1999') "1999",
    (select count(employee_id) from employees where to_char(hire_Date, 'yyyy') = '2000') "2000"
from dual;
-- 4.30
select d.department_id, d.department_name, e.sum_sal "suma salariilor"
from departments d inner join (
    select department_id, sum(salary) sum_sal
    from employees
    group by (department_id)
) e on e.department_id(+) = d.department_id;
-- 3.31 salariul cui? (departamentul nu are salariu)
select d.department_name, d.department_id, e.avg_sal "salariul mediu"
from departments d inner join (
    select department_id, round(avg(salary), 2) avg_sal
    from employees
    group by (department_id)
) e on e.department_id(+) = d.department_id;
-- 3.32
select d.department_name, d.department_id, e.last_name, mi.min_sal "salariul minim"
from departments d inner join (
    select department_id, min(salary) min_sal
    from employees
    where department_id is not null
    group by (department_id)
) mi on mi.department_id = d.department_id
    inner join employees e 
        on mi.department_id = e.department_id
            and mi.min_sal = e.salary;
-- 3.33
select d.department_id, d.department_name, e.cnt, e.avg_salary, e.last_name, e.salary, e.job_id
from departments d join (
    select department_id, count (employee_id) cnt, round(avg(salary)) avg_salary, last_name, salary, job_id
    from employees
    group by (department_id, last_name, salary, job_id)
) e on d.department_id = e.department_id(+);