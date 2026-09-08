-- ============================================================
-- DACA · Неделя 3 · SQL JOINs · Роль D — Müügikanalid (INNER JOIN, 3 таблицы)
-- Задача Anna: какой канал продаж приносит больше денег? Какой
-- эффективнее в пересчёте на клиента? Есть ли разница по городам
-- и категориям товара?
-- ============================================================


-- ЗАПРОС 1: общий обзор по каналам
SELECT
    s.channel AS müügikanal,
    COUNT(DISTINCT s.customer_id) AS kliente,
    COUNT(s.sale_id) AS oste,
    SUM(s.total_price) AS kogumüük
FROM sales s
GROUP BY s.channel
ORDER BY kogumüük DESC;
-- РЕЗУЛЬТАТ: всего 2 канала. "pood" (магазин) — 2287 клиентов,
-- 2 847 955.50 €. "online" — 1730 клиентов, 1 526 275.77 €.
-- Магазин почти вдвое крупнее по общей выручке.


-- ЗАПРОС 2: клиенты и выручка канала в разрезе городов
SELECT
    s.channel AS müügikanal,
    INITCAP(TRIM(c.city)) AS linn,
    COUNT(DISTINCT c.customer_id) AS kliente,
    SUM(s.total_price) AS kogumüük
FROM sales s
INNER JOIN customers c ON s.customer_id = c.customer_id
GROUP BY s.channel, INITCAP(TRIM(c.city))
ORDER BY müügikanal, kogumüük DESC;
-- РЕЗУЛЬТАТ: Tallinn лидирует в обоих каналах, доля online выше
-- среднего именно в Tallinn и Pärnu — крупные города охотнее
-- покупают через интернет.


-- ЗАПРОС 3 (3 таблицы): каналы × категории товара
SELECT
    s.channel AS müügikanal,
    p.category AS tootekategooria,
    COUNT(s.sale_id) AS oste,
    SUM(s.total_price) AS kogumüük,
    ROUND(AVG(s.total_price), 2) AS keskmine_ost
FROM sales s
INNER JOIN products p ON s.product_id = p.product_id
GROUP BY s.channel, p.category
ORDER BY müügikanal, kogumüük DESC;
-- РЕЗУЛЬТАТ: jalanõusid — лидер в обоих каналах, но средний чек по
-- ней выше в online (405.39 €), чем в pood (369.57 €) — тот же товар
-- online покупают дороже в среднем (более дорогие модели заказывают
-- удалённо, а не в примерочной).


-- ЗАПРОС 4: эффективность канала — выручка на одного клиента
SELECT
    s.channel AS müügikanal,
    COUNT(DISTINCT s.customer_id) AS kliente,
    SUM(s.total_price) AS kogumüük,
    ROUND(SUM(s.total_price) / COUNT(DISTINCT s.customer_id), 2) AS müük_per_klient
FROM sales s
GROUP BY s.channel
ORDER BY müük_per_klient DESC;
-- РЕЗУЛЬТАТ: pood — 1245.28 € на клиента, online — 882.24 € на
-- клиента. Магазин приносит на 41% больше денег с одного клиента.
-- Но средний чек за ОДНУ покупку у каналов почти одинаков (283.90 €
-- pood vs 293.30 € online) — разница на клиента идёт не из размера
-- корзины, а из частоты визитов: в магазин просто заходят чаще.


-- ============================================================
-- ИТОГ ДЛЯ ANNA (резюме роли D):
-- Магазин обгоняет online по общей выручке и по деньгам с клиента,
-- но не потому, что там покупают больше за раз — средний чек в двух
-- каналах почти одинаков (разница 3%). Разница на клиента (41%)
-- идёт из частоты повторных визитов, а не размера корзины. Обувь —
-- сильнейшая категория в обоих каналах, и online-покупатель платит
-- за неё в среднем на 10% больше офлайн-покупателя. Рекомендация:
-- маркетинговый бюджет на удержание частоты покупок (email/push
-- напоминания) даст больше эффекта, чем скидки на увеличение чека.
-- ============================================================
