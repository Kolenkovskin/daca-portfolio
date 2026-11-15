-- ============================================================
-- DACA · Неделя 4 · SQL агрегация · Роль B — Kliendid
-- Задача Anna / Kristi: кто приносит деньги? Насколько оборот
-- зависит от небольшой группы клиентов?
-- Источник: вид sales_v_puhas, период по 2025-02-28,
-- только продажи с известным клиентом (гости исключены).
-- ============================================================


-- ЗАПРОС 1 (R52): сегменты по сумме покупок клиента
WITH k AS (
    SELECT customer_id, SUM(total_price) AS summa
    FROM sales_v_puhas
    WHERE kuupaev <= DATE '2025-02-28'
      AND customer_id IS NOT NULL
    GROUP BY customer_id
),
seg AS (
    SELECT
        CASE
            WHEN summa >= 2000 THEN 'VIP'
            WHEN summa >= 500  THEN 'pusiklient'
            ELSE 'juhuslik'
        END AS segment,
        summa
    FROM k
)
SELECT
    segment,
    COUNT(*) AS kliente,
    ROUND(SUM(summa), 2) AS kaive,
    ROUND(100.0 * SUM(summa) / SUM(SUM(summa)) OVER (), 2) AS osakaal
FROM seg
GROUP BY segment
ORDER BY kaive DESC;
-- РЕЗУЛЬТАТ (2 558 клиентов, 2 657 179.11 €):
-- pusiklient  1 528  1 607 182.96  60.48%
-- VIP           213    834 606.23  31.41%
-- juhuslik      817    215 389.92   8.11%
-- CASE берёт первое верное условие, поэтому высокий порог стоит первым.
-- SUM(SUM(summa)) OVER () — общий итог всех строк в каждой строке.


-- ЗАПРОС 2 (R53): TOP-10 клиентов
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS nimi,
    INITCAP(TRIM(c.city)) AS linn,
    ROUND(SUM(s.total_price), 2) AS summa
FROM sales_v_puhas s
JOIN customers c ON s.customer_id = c.customer_id
WHERE s.kuupaev <= DATE '2025-02-28'
GROUP BY c.customer_id, nimi, linn
ORDER BY summa DESC
LIMIT 10;
-- РЕЗУЛЬТАТ: первая — Tiina Pärn (Tartu), 27 329.58 €; десятый —
-- 20 124.61 €. Вместе 230 732.86 € = 8.7% оборота клиентов.
-- 4 из 10 — из Pärnu (Pärnu не самый большой город).
-- Группируем по customer_id, чтобы тёзки не слились в одного.


-- ============================================================
-- ИТОГ ДЛЯ ANNA (роль B):
-- 8% клиентов (213 VIP) дают почти треть денег (31.41%), а треть
-- клиентов (817 «случайных») — только 8%. VIP-программа окупится
-- быстрее массовой рассылки; начать с Pärnu — 4 из TOP-10 оттуда.
-- ============================================================
