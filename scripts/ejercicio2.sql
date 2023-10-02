--https://github.com/DanyBecerra/Sakila-Daniel
use sakila;

with prestamos as (
    select
        concat(city, ',', country) as tienda,
        staff_id,
        year(rental_date) as anno,
        month(rental_date) as mes,
        count(rental_id) as total_prestamos
    from country
        inner join city using(country_id)
        inner join address using(city_id)
        inner join store using(address_id)
        inner join staff using(store_id)
        inner join rental using(staff_id)
    where year(rental_date) = 2005 and (month(rental_date) in (5, 6, 7))
    group by tienda, staff_id, anno, mes
),
pagos as (
    select
        concat(city, ',', country) as tienda,
        staff_id,
        year(payment_date) as anno,
        month(payment_date) as mes,
        sum(amount) as total_pagos
    from country
        inner join city using(country_id)
        inner join address using(city_id)
        inner join store using(address_id)
        inner join staff using(store_id)
        inner join payment using(staff_id)
    where year(payment_date) = 2005 and (month(payment_date) in (5, 6, 7))
    group by tienda, staff_id, anno, mes
),
pivote as (
    select 
        tienda,
        sum(case when mes = 5 then total_pagos/total_prestamos else 0 end) as mayo,
        sum(case when mes = 6 then total_pagos/total_prestamos else 0 end) as junio,
        sum(case when mes = 7 then total_pagos/total_prestamos else 0 end) as julio
    from prestamos 
    join pagos using(tienda, staff_id, mes, anno)
    group by tienda
)
select 
    tienda,
    mayo,
    junio,
    (junio-mayO) as dif1,
    (junio-mayo)/mayo * 100 as perc1,
    julio,
    (julio-junio) as dif2,
    (julio-junio)/junio * 100 as perc2
from pivote
limit 5;




