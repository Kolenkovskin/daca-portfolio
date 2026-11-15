-- ============================================================
-- DACA · Неделя 4 · SQL агрегация · ВИДЫ (запускать первыми)
-- Все файлы недели 4 считают деньги из вида sales_v_puhas.
-- Порядок: сначала sales_v, потом sales_v_puhas.
-- ============================================================


-- ВИД 1 (R45): sales_v — настоящая дата вместо текста.
-- В sales.sale_date два формата: 14 777 строк ГГГГ-ММ-ДД и 457 строк
-- ДД/ММ/ГГГГ. CASE с маской LIKE выбирает формат для TO_DATE.
CREATE VIEW sales_v AS
SELECT
    id, sale_id, customer_id, product_id, quantity, total_price,
    channel, store_location,
    CASE
        WHEN sale_date LIKE '____-__-__%' THEN TO_DATE(sale_date, 'YYYY-MM-DD')
        ELSE TO_DATE(sale_date, 'DD-MM-YYYY')
    END AS kuupaev
FROM sales;
-- ПРОВЕРКА: 15 234 строки, период 2023-01-01 … 2026-06-28.


-- ВИД 2 (R51): sales_v_puhas — без копий.
-- Копия = строка, совпавшая во всех 8 бизнес-столбцах; оставляем
-- первую по служебному id (nr = 1).
CREATE VIEW sales_v_puhas AS
SELECT id, sale_id, kuupaev, customer_id, product_id, quantity,
       total_price, channel, store_location
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY sale_id, kuupaev, customer_id, product_id,
                            quantity, total_price, channel, store_location
               ORDER BY id
           ) AS nr
    FROM sales_v
) t
WHERE nr = 1;
-- РЕЗУЛЬТАТ: 10 688 строк, 3 018 967.36 €.
-- Убрано 4 546 копий (было 4 374 231.27 €): 4 333 — категории A+B
-- недели 2 (совпало до строки) + 213 точных копий в смешанных группах.
