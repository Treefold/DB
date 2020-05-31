-- 8.1
create table angajati_smd (
    cod_ang number(4) primary key,
    nume varchar2(20) not null, 
    prenume varchar2(20), 
    email char(15),
    data_ang date default sysdate, 
    job varchar2(10), 
    cod_sef number(4), 
    salariu number(8, 2) not null, 
    cod_dep number(2)
);
-- 8.2
insert into angajati_smd (cod_ang, nume, prenume, job, salariu, cod_dep) values
    (100, 'Nume1', 'Prenume1', 'Director', 20000, 10);
insert into angajati_smd values 
    (101, 'Nume2', 'Prenume2', 'Nume2', to_date('02-02-2004', 'dd-mm-yyyy'), 'Inginer', 100, 10000, 10);
insert into angajati_smd values 
    (102, 'Nume3', 'Prenume3', 'Nume3', to_date('05-06-2000', 'dd-mm-yyyy'), 'Analist', 101, 5000, 20);
insert into angajati_smd (cod_ang, nume, prenume, job,cod_sef, salariu, cod_dep) values 
    (103, 'Nume4', 'Prenume4', 'Inginer', 100, 9000, 20);
insert into angajati_smd values 
    (104, 'Nume5', 'Prenume5', 'Nume5', Null, 'Analist', 101, 3000, 30);
commit;
-- 8.3
create table angajati10_smd (cod_ang, nume, prenume, email, data_ang, job, cod_sef, salariu, cod_dep)
as (select * from angajati_smd);
desc angajati_smd; -- aici cod_ang este primary key -> not null constrain
desc angajati10_smd; -- aici s+au copiat not null constrains, dar nu si cea de la cod_ang deoarece contrainul de primary key nu s+a copiat si eil
-- 8.4
alter table angajati_smd add comision number(4,2);
-- 8.5 nu va merge deoarece incercam sa micsoram numarul de cifre din salatiu atunci cand coloana este populata ( cel putin un not null)
-- alter table angajati_smd modify salariu number(6,2);
-- 8.6
alter table angajati_smd modify salariu default 1500;
-- 8.7
alter table angajati_smd modify (comision number(2,2), salariu number(10,2));
-- 8.8
update angajati_smd set comision = 0.1 where job like 'A%';
commit;
-- 8.9
alter table angajati_smd modify email varchar2(15); -- must be the same size
-- 8.10
alter table angajati_smd add nr_telefon number(10) default 666013;
-- 8.11 - rollback nu va avea niciun efet, la alter table se efectuaeaza commit automat (operatie ireversibila)
select * from angajati_smd;
alter table angajati_smd drop (nr_telefon);
-- 8.12
rename angajati_smd to angajati3_smd;
-- 8.13 
select * from tab;
rename angajati3_smd to angajati_smd;
-- 8.14
truncate table angajati10_smd;
-- 8.15
create table departamente_smd (cod_dep# number(2), nume varchar2(15) not null, cod_director number(4));
DESC departamente_smd;
-- 8.16
insert into departamente_smd values (10, 'Administrativ', 100);
insert into departamente_smd values (20, 'Proiectare', 101);
insert into departamente_smd values (30, 'Programare', Null);
-- 8.17
alter table departamente_smd modify cod_dep# primary key;
-- 8.18 
alter table angajati_smd add ( 
    constraint fk_ang_dep foreign key (cod_dep) references departamente_smd(cod_dep#),
    constraint fk_ang_sef foreign key (cod_sef) references angajati_smd(cod_ang),
    constraint u_ang_numecomp unique (nume, prenume),
    constraint u_ang_email unique (email),
    constraint nn_ang_nume check (nume is not null), -- not null constraint
    check (cod_dep > 0),
    check (salariu > nvl(comision, 0) * 100)
);
-- 8.19 a
select cons.constraint_name, constraint_type, table_name from user_constraints where table_name='ANGAJATI_SMD' or table_name='DEPARTAMENTE_SMD';
-- 8.19 b
select cons.constraint_name, cons.constraint_type, cons.table_name, cc.column_name from user_cons_columns cc inner join 
    (select constraint_name, constraint_type, table_name from user_constraints where table_name='ANGAJATI_SMD' or table_name='DEPARTAMENTE_SMD')
    cons on cc.constraint_name=cons.constraint_name and cc.table_name=cons.table_name;
-- 8.20 - nu se poate deoarece nu exista departamentul 50
insert into angajati_smd (cod_ang, nume, salariu, cod_dep) values (1, 'a', 1500, 50);
-- 8.21
insert into departamente_smd values (60, 'Analiza', null);
commit;
-- 8.22 - nu se poate deoarece exita angajati afiliati acestui departament
delete from departamente_smd where cod_dep# = 20;
-- 8.23 
delete from departamente_smd where cod_dep# = 60;
rollback;
-- ?? - nu inteleg intrebarea
-- 8.24
alter table angajati_smd drop constraint fk_ang_dep;
alter table angajati_smd add constraint fk_ang_dep foreign key (cod_dep) references departamente_smd(cod_dep#) on delete cascade;
-- 8.25 - angajatii departamentului 20 au fost stersi impreuna cu departamentul 20
select * from angajati_smd;
delete from departamente_smd where cod_dep# = 20;
rollback;
-- 8.26
alter table angajati_smd add constraint c_ang_maxsal check (salariu <= 30000);
-- 8.27 - constrangerea c_ang_maxsal a fost incalcata -> updateul nu a fost efectuat
update angajati_smd set salariu = 35000 where cod_ang = 100; -- failed
-- 8.28 -- nu putem reactiva constrangerea atata timp cat aceasta nu este satisfacuta de entitatile existente in tabel
alter table angajati_smd modify constraint c_ang_maxsal disable;
update angajati_smd set salariu = 35000 where cod_ang = 100; -- success
alter table angajati_smd modify constraint c_ang_maxsal enable; -- failed
-- clean up
drop table angajati3_smd;
drop table angajati10_smd;
drop table angajati_smd;
drop table departamente_smd;





























