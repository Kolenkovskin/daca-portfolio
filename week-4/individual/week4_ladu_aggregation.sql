-- ============================================================
-- DACA · Неделя 4 · SQL агрегация · Роль C — Ladu
-- Задача Liis: можно ли доверять журналу склада при заказах?
-- Источник: inventory_movements (2024-01-01 … 2025-02-28; точки
-- ladu, pärnu, tallinn, tartu — все маленькими буквами)
-- и вид sales_v_puhas за тот же период.
-- ============================================================


-- ЗАПРОС 1 (R54): журнал Tartu по типам движения
SELECT
    movement_type,
    COUNT(*) AS ridu,
    SUM(quantity) AS kogus
FROM inventory_movements
WHERE location = 'tartu'
GROUP BY movement_type
ORDER BY ridu DESC;
-- РЕЗУЛЬТАТ:
-- OUT         773  -19 361
-- IN          693   73 420
-- TRANSFER    279     -633
-- ADJUSTMENT  204      120
-- '=' различает регистр: 'Tartu' с большой буквы не нашёл бы ничего.


-- ЗАПРОС 2 (R55): списано по журналу против продано по кассе
WITH m AS (
    SELECT location, -SUM(quantity) AS maha
    FROM inventory_movements
    WHERE movement_type = 'OUT'
    GROUP BY location
),
s AS (
    SELECT LOWER(store_location) AS location, SUM(quantity) AS myydud
    FROM sales_v_puhas
    WHERE kuupaev BETWEEN DATE '2024-01-01' AND DATE '2025-02-28'
    GROUP BY LOWER(store_location)
)
SELECT
    m.location,
    m.maha,
    s.myydud,
    ROUND(1.0 * m.maha / s.myydud, 2) AS kordaja
FROM m
JOIN s ON m.location = s.location
ORDER BY kordaja DESC;
-- РЕЗУЛЬТАТ:
-- pärnu    20 726  1 058  19.59
-- tartu    19 361  1 939   9.99
-- tallinn  20 767  4 008   5.18
-- LOWER() выравнивает регистр: в продажах 'Tartu', в журнале 'tartu'.
-- JOIN без слова = INNER JOIN.


-- ============================================================
-- ИТОГ ДЛЯ LIIS (роль C):
-- Журнал списывает почти одинаково (~20 000 шт.) на каждую точку,
-- хотя продажи различаются в 4 раза. Списания в 5–20 раз больше
-- продаж — журнал не опирается на кассу. Пока они не связаны
-- (номер чека / заказа), остатки полок для заказов использовать нельзя.
-- ============================================================
