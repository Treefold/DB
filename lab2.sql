-- 2.1
select CONCAT(FIRST_NAME || ' ' || LAST_NAME || ' castiga ' || SALARY || ' lunar dar doreste ', 3 * SALARY) AS "Salariu Ideal" from EMPLOYEES;
-- 2.2.a
select INITCAP(FIRST_NAME) || ' ' || UPPER (LAST_NAME) || ' ' || LENGTH (LAST_NAME)
FROM EMPLOYEES
WHERE REGEXP_LIKE (LAST_NAME, '^[JM]|^..a');
-- 2.2.b
select INITCAP(FIRST_NAME) || ' ' || UPPER (LAST_NAME) || ' ' || LENGTH (LAST_NAME)
FROM EMPLOYEES
WHERE  SUBSTR (LAST_NAME, 1, 1) = 'J' 
    OR SUBSTR (LAST_NAME, 1, 1) = 'M'
    OR SUBSTR (LAST_NAME, 3, 1) = 'a';
-- 2.3
SELECT  EMPLOYEE_ID, TRIM(BOTH ' ' FROM LAST_NAME), DEPARTMENT_ID
FROM EMPLOYEES
WHERE UPPER(FIRST_NAME) LIKE '%STEVEN%';
-- 2.4
SELECT employee_id as Cod, last_name as Nume, length (last_name) Lungime, Decode(instr(lower(last_name), 'a'), 0, 'Nu exista', instr(lower(last_name), 'a')) Pozitie
FROM EMPLOYEES WHERE LAST_NAME LIKE '%e';
-- 2.5
select * from employees where mod(floor((SELECT SYSDATE FROM dual) - hire_date), 7) = 0;
-- 2.6
select employee_id, last_name, salary, round (1.15 * salary, 2)
from employees
where Mod (salary, 1000) != 0;
-- 2.7
select last_name "Nume angajat", hire_date as "Data angajarii"
from employees
where commission_pct IS NOT NULL;
-- 2.8
select systimestamp + interval '30' day
from dual;
-- 2.9
select round(to_date('01/01/' || (extract(year from sysdate)+1), 'DD/MM/YYYY')  - sysdate) as "days till new year eve"
from dual;
-- 2.10
select systimestamp + interval '12' hour as "time after 12 hours", systimestamp + interval '5' minute as "time after 5 minutes"
from dual;
-- 2.11
select first_name || ' ' || last_name name, hire_date angajare, next_day(add_months (hire_date, 6), 'Monday') negociere
from employees;
-- 2.12
select first_name || ' ' || last_name name, round(months_between ((select sysdate from dual), hire_date)) as "Luni lucrate"
from employees
order by "Luni lucrate";
-- 2.13
select first_name || ' ' || last_name name, hire_date, TO_CHAR(hire_date, 'DAY') Zi
from employees
order by (next_day(hire_date, 'MONDAY') - hire_date) desc;
-- 2.14
select first_name || ' ' || last_name name, nvl(to_Char(commission_pct), 'Fara Comision') Comision
from employees;
-- 2.15
select first_name || ' ' || last_name name, salary, nvl(commission_pct, 0) comision
from employees
where salary > 10000;
-- 2.16
select first_name || ' ' || last_name name, job_id, salary, salary * decode(job_id, 'IT_PROG', 1.2, 'SA_REP', 1.25, 'SA_MAN', 1.35, 1) "Salariu renegociat"
from employees;
-- 2.17
select e.first_name || ' ' || e.last_name name, d.department_id "Department ID", d.department_name "Department Name"
from employees e inner join departments d
on e.department_id = d.department_id;
-- 2.18
select distinct j.job_title title
from employees e inner join jobs j
on e.job_id = j.job_id
where e.department_id = 30;
-- 2.19
select e.first_name || ' ' || e.last_name name, d.department_name "Department name", l.city
from employees e
    inner join departments d on e.department_id = d.department_id
    inner join locations l on d.location_id = l.location_id
where nvl(e.commission_pct, 0) != 0;
-- 2.20
select e.last_name name, d.department_id "Department ID", d.department_name "Department Name"
from employees e inner join departments d
on e.department_id = d.department_id
where lower(e.last_name) like '%a%';
-- 2.21
select e.first_name || ' ' || e.last_name name, e.job_id, d.department_id, d.department_name
from employees e
    inner join departments d on e.department_id = d.department_id
    inner join locations l on d.location_id = l.location_id
where lower(l.city) = 'oxford';
-- 2.22
select a.employee_id "Ang#", a.first_name || ' ' || a.last_name "Angajat", m.employee_id "Mgr#", m.first_name || ' ' || m.last_name "Manager"
from employees a inner join employees m
on a.manager_id = m.employee_id
order by a.employee_id;
-- 2.23
select a.employee_id "Ang#", a.first_name || ' ' || a.last_name "Angajat", m.employee_id "Mgr#", m.first_name || ' ' || m.last_name "Manager"
from employees a left outer join employees m
on a.manager_id = m.employee_id
order by a.employee_id;
-- 2.24 -- listagg doesn't work in this environment
select department_id, listagg(last_name, ',') within group (order by last_name) "Colegi"
from employees
group by department_id
order by department_id;

-- example provided by oracle for listagg (not working): docs.oracle.com/cd/E11882_01/server.112/e41084/functions089.htm
SELECT department_id "Dept.",
       LISTAGG(last_name, '; ') WITHIN GROUP (ORDER BY hire_date) "Employees"
  FROM employees
  GROUP BY department_id
  ORDER BY department_id;

-- 2.25
select e.first_name || ' ' || e.last_name name, j.job_id, j.job_title, d.department_name, e.salary
from employees e
    inner join jobs j on e.job_id = j.job_id
    inner join departments d on e.department_id = d.department_id;
-- 2.26
select first_name || ' ' || last_name name, hire_date
from employees
where hire_date > (select hire_date from employees where last_name = 'Gates');
-- 2.27
select a.first_name || ' ' || a.last_name "Angajat", a.hire_date "Data_ang", m.first_name || ' ' || m.last_name "Manager", m.hire_date "Data_mgr"
from employees a inner join employees m
on a.manager_id = m.employee_id
where a.hire_date < m.hire_date
order by a.employee_id;





