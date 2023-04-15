--Для каждого дня рассчитываем
--Выручку на пользователя (ARPU) за текущий день.
--Выручку на платящего пользователя (ARPPU) за текущий день.
--Выручку с заказа, или средний чек (AOV) за текущий день.

SELECT "date",
       round(revenue / user_amount::decimal, 2) as arpu,
       round(revenue / paying_users_amount::decimal, 2) as arppu,
       round(revenue / orders_amount::decimal, 2) as aov
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
        GROUP BY "date") t4 join (SELECT "date",
                                 count(distinct user_id) as user_amount,
                                 count(distinct user_id) filter(WHERE order_id not in (SELECT order_id
                                                                                FROM   user_actions
                                                                                WHERE  action = 'cancel_order')) as paying_users_amount, count(distinct order_id) filter(
                          WHERE  order_id not in (SELECT order_id
                                                  FROM   user_actions
                                                  WHERE  action = 'cancel_order')) as orders_amount
                          FROM   (SELECT time::date as "date",
                                         action,
                                         order_id,
                                         user_id
                                  FROM   user_actions) t5
                          GROUP BY "date") t6 using("date")
ORDER BY "date"
