--На основе данных в таблице courier_actions для каждого дня рассчитываем, за сколько минут в среднем курьеры доставляли свои заказы.

SELECT "date",
       round(avg(delivery_time))::int as minutes_to_deliver
FROM   (SELECT order_id,
               max(time)::date as "date",
               extract(epoch
        FROM   max(time) - min(time)) / 60 as delivery_time
        FROM   courier_actions
        WHERE  order_id in (SELECT order_id
                            FROM   courier_actions
                            WHERE  action = 'deliver_order')
        GROUP BY order_id) t1
GROUP BY "date"
ORDER BY "date"
