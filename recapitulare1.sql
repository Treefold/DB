-- 1
select e.denumire
from excursie e inner join achizitioneaza ac on e.id_excursie = ac.cod_excursie
where ac.data_achizitie = (select min(data_achizitie) from achizitioneaza);
-- 2
select cod_excursie, count(cod_turist)
from achizitioneaza
group by (cod_excursie);
-- 3
select ag.denumire, ag.oras, e.cnt, e.avg_price
from agentie ag inner join (
    select cod_agentie, count(id_excursie) cnt, round(avg(pret),2) avg_price
    from excursie
    group by (cod_agentie)
) e on ag.id_agentie = e.cod_agentie;
-- 4 a
select nume, prenume
from turist
where 1 < (select count(cod_turist) from achizitioneaza where cod_turist = id_turist);
-- 4 b
select count(id_turist)
from turist
where 1 < (select count(cod_turist) from achizitioneaza where cod_turist = id_turist);
-- 5
select * from turist 
where not exists (
    select ac.cod_excursie
    from achizitioneaza ac inner join excursie e on ac.cod_excursie = e.id_excursie
    where id_turist = cod_turist and e.destinatie like 'Paris'
);
-- 6
select id_turist, nume from turist 
where 1 < (
    select count (distinct e.destinatie)
    from achizitioneaza ac inner join excursie e on ac.cod_excursie = e.id_excursie
    where id_turist = cod_turist
);
-- 7
select ag.denumire, nvl(e_info.profit, 0) profit
from agentie ag inner join (
    select e.cod_agentie, sum((1-nvl(ac.discount, 0))*e.pret) profit
    from excursie e inner join achizitioneaza ac on e.id_excursie = ac.cod_excursie
    group by (e.cod_agentie)
) e_info on ag.id_agentie = e_info.cod_agentie(+);
-- 8
select denumire, oras
from agentie
where id_agentie in (
    select cod_agentie
    from excursie
    where pret < 2000
    group by (cod_agentie)
    having count(cod_agentie) >= 3
);
-- 9
select * from excursie where not id_excursie in (select distinct cod_excursie from achizitioneaza);
-- 10
select nvl(ag.denumire, 'Agentie necunoscuta') agentie, e.denumire, e.pret, e.destinatie
from excursie e inner join agentie ag on e.cod_agentie = ag.id_agentie(+);
-- 11
select * from excursie where pret > (select pret from excursie where cod_agentie = 10 and denumire like 'Orasul luminilor');
-- 12
select * from turist where id_turist in (
    select distinct cod_turist 
    from achizitioneaza
    where data_end-data_start >= 10
);
-- 13
select * from excursie where id_excursie in (
    select distinct ac.cod_excursie
    from achizitioneaza ac inner join turist t on ac.cod_turist = t.id_turist
    where t.data_nastere is not null 
        and months_between((select sysdate from dual) , t.data_nastere) < 12 * 40
);
-- 14
select * from turist where not id_turist in (
    select distinct ac.cod_turist from achizitioneaza ac 
    inner join excursie e on ac.cod_excursie = e.id_excursie
    inner join agentie ag on e.cod_agentie = ag.id_agentie
    where ag.oras like 'Bucuresti'
);
-- 15
select * from turist where id_turist in (
    select distinct ac.cod_turist from achizitioneaza ac 
    inner join excursie e on ac.cod_excursie = e.id_excursie
    inner join agentie ag on e.cod_agentie = ag.id_agentie
    where lower(e.denumire) like '%1 mai%'
        and ag.oras like 'Bucuresti'
);
-- 16
select t.nume, t.prenume, e.* from excursie e 
    inner join (
        select id_agentie from agentie where denumire like 'Smart Tour'
    ) ag on e.cod_agentie = ag.id_agentie
    inner join achizitioneaza ac on ac.cod_excursie = e.id_excursie
    inner join turist t on t.id_turist = ac.cod_turist;
-- 17
select cod_excursie, count(*) cnt from achizitioneaza
where data_start = to_date ('14-aug-2011', 'dd-mon-yyyy')
group by (cod_excursie)
having count(*) >= (select nr_locuri from excursie where id_excursie = cod_excursie);
-- 18 returns all if there are more achizitions in the same day
select cod_turist, cod_excursie
from achizitioneaza 
where (cod_turist, data_achizitie) in (
    select cod_turist, min(data_achizitie)
    from achizitioneaza
    group by (cod_turist)
);
-- 19 selects all that have the last pice the same
select * from excursie where pret in (select pret from (select pret from excursie order by pret desc) where rownum <= 5);
-- 20
select t.nume, t.data_nastere, ac.data_start from turist t 
    inner join achizitioneaza ac on t.id_turist = ac.cod_turist
where t.data_nastere is not null 
    and to_char(t.data_nastere, 'mon')  = to_char(ac.data_start, 'mon');
-- 21 prevent duplicated turist (one tursi might have bought more than one)
select * from turist where id_turist in (
    select ac.cod_turist 
    from (select id_excursie, cod_agentie from excursie where nr_locuri = 2) e
        inner join (select id_agentie from agentie where oras like 'Constanta') ag
            on e.cod_agentie = ag.id_agentie
        inner join achizitioneaza ac on e.id_excursie = ac.cod_excursie
);
-- 22 could also be resolved just by ordering by duration
select * from excursie order by case
    when durata <= 5 then 1
    when durata > 20 then 3
    else 2
end;
--23 bad (but it works fine)
select (select count(*) from excursie) "Numar excursii", 
    (select count(*) from excursie e inner join agentie ag on e.cod_agentie = ag.id_agentie where ag.oras = 'Constanta') "Nr. ex Constanta",
    (select count(*) from excursie e inner join agentie ag on e.cod_agentie = ag.id_agentie where ag.oras = 'Bucuresti') "Nr. ex Bucuresti"
from dual;
-- 23 good
select sum (nr) "Numar excursii",
    sum(decode(oras, 'Constanta', nr, 0)) "Nr. ex Constanta",
    sum(decode(oras, 'Bucuresti', nr, 0)) "Nr. ex Bucuresti"
from (
    select oras, count(*) nr
    from excursie e inner join agentie ag on e.cod_agentie = ag.id_agentie(+)
    group by (oras)
);
-- 24 all trips that have all turists of age X 
select * from excursie where not id_excursie in (
    select distinct cod_excursie -- returns the id of all trips that have al least one without the age X
    from achizitioneaza
    where not cod_turist in (
        select id_turist from turist -- return the id of all turist of age X
        where data_nastere is not null 
            and floor(months_between((select sysdate from dual) , data_nastere)/12) = 34 -- = X
    )
);
-- 25
select cod_agentie, destinatie, count(*) cnt, grouping(cod_agentie), grouping(destinatie)
from excursie
group by rollup (cod_agentie, destinatie);
-- 26
select ag.*, (
    select round(avg(pret),2)
    from excursie
    where cod_agentie != ag.id_agentie
        and cod_agentie in (
            select id_agentie from agentie
            where oras = ag.oras
        )
) op_price
from agentie ag;