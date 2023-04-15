--Для каждого дня в таблице orders рассчитываем следующие показатели:
--Выручку, полученную в этот день.
--Суммарную выручку на текущий день.
--Прирост выручки, полученной в этот день, относительно значения выручки за предыдущий день.

SELECT "date",
       revenue,
       sum(revenue) OVER(ORDER BY "date") as total_revenue,
       round((revenue - lag(revenue, 1) OVER()) / lag(revenue, 1) OVER()::decimal * 100,
             2) as revenue_change
FROM   (SELECT creation_time::date as "date",
               sum(order_price) as revenue
        FROM   (SELECT order_id,
                       sum(price) as order_price
                FROM   (SELECT order_id,
                               unnest(product_ids) as product_id
                        FROM   orders) t1
                    RIGHT JOIN products using(product_id)
                GROUP BY order_id) t2 join orders using(order_id)
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')
        GROUP BY "date") t4
