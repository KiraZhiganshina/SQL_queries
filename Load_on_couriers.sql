--На основе данных в таблицах user_actions, courier_actions и orders для каждого дня рассчитываем следующие показатели:
--Число платящих пользователей на одного активного курьера.
--Число заказов на одного активного курьера.

SELECT "date",
       round(paying_users::decimal / active_couriers, 2) as users_per_courier,
       round(orders::decimal / active_couriers, 2) as orders_per_courier
FROM   (SELECT time::date as "date",
               count(distinct courier_id) as active_couriers
        FROM   courier_actions
        WHERE  action = 'accept_order'
           and order_id in (SELECT order_id
                         FROM   courier_actions
                         WHERE  action = 'deliver_order')
            or action = 'deliver_order'
        GROUP BY "date") t1 full join (SELECT time::date as "date",
                                      count(distinct user_id) as paying_users,
                                      count(distinct order_id) as orders
                               FROM   user_actions
                               WHERE  order_id not in (SELECT order_id
                                                       FROM   user_actions
                                                       WHERE  action = 'cancel_order')
                               GROUP BY "date") t2 using("date")
ORDER BY "date"
