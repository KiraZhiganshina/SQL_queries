--Для каждого дня, представленного в таблице user_actions, рассчитываем следующие показатели:
--Общее число заказов.
--Число первых заказов (заказов, сделанных пользователями впервые).
--Число заказов новых пользователей (заказов, сделанных пользователями в тот же день, когда они впервые воспользовались сервисом).
--Долю первых заказов в общем числе заказов.
--Долю заказов новых пользователей в общем числе заказов.

SELECT "date",
       orders,
       first_orders,
       new_users_orders,
       round(first_orders / orders::decimal * 100, 2) as first_orders_share,
       round(new_users_orders / orders::decimal * 100, 2) as new_users_orders_share
FROM   (SELECT "date",
               count(distinct order_id) as orders
        FROM   (SELECT action,
                       order_id,
                       time::date as "date",
                       user_id
                FROM   user_actions
                WHERE  order_id not in (SELECT order_id
                                        FROM   user_actions
                                        WHERE  action = 'cancel_order')) t1
        GROUP BY "date") table1 full join (SELECT count(distinct user_id) as first_orders,
                                          "date"
                                   FROM   (SELECT user_id,
                                                  min("date") as "date"
                                           FROM   (SELECT action,
                                                          order_id,
                                                          time::date as "date",
                                                          user_id
                                                   FROM   user_actions
                                                   WHERE  order_id not in (SELECT order_id
                                                                           FROM   user_actions
                                                                           WHERE  action = 'cancel_order')) t2
                                           GROUP BY user_id) t3
                                   GROUP BY "date") table2 using("date") full join (SELECT "date",
                                                        count(distinct order_id) as new_users_orders
                                                 FROM   (SELECT action,
                                                                order_id,
                                                                time::date as "date",
                                                                user_id,
                                                                min(time::date) OVER(PARTITION BY user_id) as min_date
                                                         FROM   user_actions) t4
                                                 WHERE  "date" = min_date
                                                    and order_id not in (SELECT order_id
                                                                      FROM   user_actions
                                                                      WHERE  action = 'cancel_order')
                                                 GROUP BY "date") table3 using("date")
