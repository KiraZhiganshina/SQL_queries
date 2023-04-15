--На основе данных в таблице orders для каждого часа в сутках рассчитываем следующие показатели:
--Число успешных (доставленных) заказов.
--Число отменённых заказов.
--Долю отменённых заказов в общем числе заказов (cancel rate).

SELECT date_part('hour', creation_time)::int as hour,
       count(distinct order_id) filter (WHERE order_id in (SELECT order_id
                                                    FROM   courier_actions
                                                    WHERE  action = 'deliver_order')) as successful_orders, count(distinct order_id) filter (
WHERE  order_id in (SELECT order_id
                    FROM   user_actions
                    WHERE  action = 'cancel_order')) as canceled_orders, round(count(distinct order_id) filter (
WHERE  order_id in (SELECT order_id
                    FROM   user_actions
                    WHERE  action = 'cancel_order')) / count(distinct order_id)::decimal, 3) as cancel_rate
FROM   orders
GROUP BY hour
ORDER BY hour
