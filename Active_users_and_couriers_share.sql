--Для каждого дня, представленного в таблицах user_actions и courier_actions, рассчитываем следующие показатели:
--Число платящих пользователей.
--Число активных курьеров.
--Долю платящих пользователей в общем числе пользователей на текущий день.
--Долю активных курьеров в общем числе курьеров на текущий день.

with subq1 as (SELECT start_date as "date",
                      new_users,
                      new_couriers,
                      (sum(new_users) OVER (ORDER BY start_date))::int as total_users,
                      (sum(new_couriers) OVER (ORDER BY start_date))::int as total_couriers
               FROM   (SELECT start_date,
                              count(courier_id) as new_couriers
                       FROM   (SELECT courier_id,
                                      min(time::date) as start_date
                               FROM   courier_actions
                               GROUP BY courier_id) t_1
                       GROUP BY start_date) t_2
                   LEFT JOIN (SELECT start_date,
                                     count(user_id) as new_users
                              FROM   (SELECT user_id,
                                             min(time::date) as start_date
                                      FROM   user_actions
                                      GROUP BY user_id) t_3
                              GROUP BY start_date) t_4 using (start_date))
SELECT "date",
       paying_users,
       active_couriers,
       round(paying_users::decimal / total_users * 100, 2) as paying_users_share,
       round(active_couriers::decimal / total_couriers * 100, 2) as active_couriers_share
FROM   (SELECT time::date as "date",
               count(distinct user_id) as paying_users
        FROM   user_actions
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')
        GROUP BY "date") t1 full join (SELECT time::date as "date",
                                      count(distinct courier_id) as active_couriers
                               FROM   courier_actions
                               WHERE  order_id in (SELECT order_id
                                                   FROM   courier_actions
                                                   WHERE  action = 'deliver_order')
                               GROUP BY "date") t2 using("date")
    LEFT JOIN subq1 using("date")
ORDER BY "date"
