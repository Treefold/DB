-- r2.27
select e.cod_agentie, e.destinatie, count(a.cnt) valoare_totala, grouping (e.cod_agentie), grouping(e.destinatie)
from (select cod_excursie, count (cod_excursie) cnt from achizitioneaza group by cod_excursie) a
    inner join excursie e on e.id_excursie = a.cod_excursie
group by cube (e.cod_agentie, e.destinatie);
-- r2.28
select e.cod_agentie, a.year, count(*) valoare_totala
from (select cod_excursie, to_char(data_achizitie, 'yyyy') year from achizitioneaza) a
    inner join excursie e on e.id_excursie = a.cod_excursie
group by (e.cod_agentie, a.year)
union
select null cod_agentie, null year, count(*) valoare_totala from achizitioneaza;
-- r2.29
select denumire from excursie where id_excursie not in (
    select distinct cod_excursie
    from achizitioneaza 
    where cod_turist in
        (select id_turist from turist where to_char(data_nastere, 'yyyy') = '1984')
);
-- r2.30
create table agentie_smd as select * from agentie;
alter table agentie_smd add primary key (id_agentie);
create table excursie_smd as select * from excursie;
alter table excursie_smd add (
    primary key (id_excursie), 
    constraint fk_exc_agn_smd foreign key (cod_agentie) references agentie_smd(id_agentie) on delete cascade
);
create table turist_smd as select * from turist;
alter table turist_smd add primary key (id_turist);
create table achizitioneaza_smd as select * from achizitioneaza;
alter table achizitioneaza_smd add (
    primary key (cod_excursie, cod_turist, data_start),
    foreign key (cod_excursie) references excursie_smd(id_excursie) on delete cascade,
    foreign key (cod_turist) references turist_smd(id_turist) on delete cascade
);
-- r2.31
update achizitioneaza_smd set discount = (select max(discount) from achizitioneaza) where cod_excursie in 
    (select id_excursie from excursie_smd where pret > (select avg(pret) from excursie_smd));
rollback;
-- r2.32
delete from excursie_smd e where pret < (
    select avg_pret from (
        select cod_agentie, avg(pret) avg_pret 
        from excursie_smd 
        group by cod_agentie
    ) a where e.cod_agentie = a.cod_agentie
);
rollback;
-- r2.33
alter table excursie_smd drop constraint fk_exc_agn_smd;
desc excursie_smd;
insert into excursie_smd (id_excursie, cod_agentie)
    values ((select max(id_excursie)+1 from excursie_smd), (select max(id_agentie) + 1 from agentie_smd));
insert into excursie_smd (id_excursie, cod_agentie)
    values ((select max(id_excursie)+1 from excursie_smd), (select max(id_agentie) + 1 from agentie_smd));
update excursie_smd set cod_agentie = null where cod_agentie not in (select id_agentie from agentie_smd);
rollback;
alter table excursie_smd add foreign key (cod_agentie) references agentie_smd(id_agentie) on delete cascade;
-- r2.34
create view v_excursie_smd as (select * from excursie_smd where cod_agentie = 10) with check option;
insert into v_excursie_smd (id_excursie, cod_agentie)
    values ((select max(id_excursie)+1 from excursie_smd), 10);
select * from excursie_smd;
commit;
drop view v_excursie_smd;
-- r2.35
truncate table achizitioneaza_smd;
savepoint a;
-- r2.36
insert into achizitioneaza_smd
select * from achizitioneaza where to_char(data_achizitie, 'yyyy') = '2010';
update achizitioneaza_smd set 
    data_start = add_months(data_start, 1),
    data_end   = add_months(data_end  , 1);
-- r2.37
update achizitioneaza_smd
set discount = case
    when discount is null then 0.1
    when discount+0.1 > 1 then 1 
    else discount+0.1 end 
where cod_excursie in (select id_excursie from excursie_smd where cod_agentie = 10);
-- r2.38
delete from achizitioneaza_smd 
where cod_turist in (select id_turist from turist_smd where data_nastere is null);
-- r2.39 - nu poate sterge datele care nu sunt din achiztioneaza (nu in oracle)
merge into achizitioneaza_smd target using achizitioneaza source
on (target.cod_excursie = source.cod_excursie 
and target.cod_turist   = source.cod_turist 
and target.data_start   = source.data_start) 
when matched then update set
    data_end = source.data_end,
    data_achizitie = source.data_achizitie,
    discount = source.discount
when not matched then insert values (source.cod_excursie, source.cod_turist, source.data_start, source.data_end, source.data_achizitie, source.discount);
rollback to a;
-- r2.39
insert into achizitioneaza_smd select * from achizitioneaza;
update excursie_smd set pret = 0.9 * pret where id_excursie in
    (select cod_excursie from achizitioneaza group by cod_excursie having count(*) =
        (select max(cnt) from (select count(*) cnt from achizitioneaza group by cod_Excursie)));
-- r2.40
alter table turist_smd add (
    check (nume is not null),
    unique (nume, prenume)
);
-- r2.41
alter table achizitioneaza_smd add check (data_start < data_end);
alter table achizitioneaza_smd modify data_achizitie default sysdate;
-- r2.42 explicat la laborator
-- r2.43
with excursii_turisti as (
    select cod_turist, count(*) cnt from achizitioneaza_smd where cod_excursie in
        (select distinct cod_excursie from achizitioneaza_smd where cod_turist in 
            (select id_turist from turist_smd where lower(nume) = 'stanciu'))
    group by cod_turist
) select nume, prenume from turist_smd where id_turist in (
    select cod_turist from excursii_turisti where cnt = (select max(cnt) from excursii_turisti)
);
-- r2.44
select nume, prenume from turist where id_turist not in (
    select distinct cod_turist from achizitioneaza_smd where cod_excursie not in
        (select distinct cod_excursie from achizitioneaza_smd where cod_turist in 
            (select id_turist from turist_smd where lower(nume) = 'stanciu'))
);
-- r2.45
with excursii_turisti as (
    select cod_turist, count(*) cnt from achizitioneaza_smd where cod_excursie in
        (select distinct cod_excursie from achizitioneaza_smd where cod_turist in 
            (select id_turist from turist_smd where lower(nume) = 'stanciu'))
    group by cod_turist
) select nume, prenume from turist_smd where id_turist in (
    select cod_turist from excursii_turisti where cnt = (select max(cnt) from excursii_turisti)
)
intersect
select nume, prenume from turist where id_turist not in (
    select distinct cod_turist from achizitioneaza_smd where cod_excursie not in
        (select distinct cod_excursie from achizitioneaza_smd where cod_turist in 
            (select id_turist from turist_smd where lower(nume) = 'stanciu'))
);
-- 46, 47 si 48 nu cred ca se pot face doar din sql (ar fi necesar pl/sql)
-- clean up
drop table achizitioneaza_smd;
drop table turist_smd;
drop table excursie_smd;
drop table agentie_smd;