-- ============================================================
-- DACA · Неделя 3 · SQL JOINs · Роль A — Müük + Kliendid (INNER JOIN)
-- Задача Anna Mets (Marketing Lead): кто наши лучшие клиенты?
-- Из какого города приходит больше всего выручки? Какой loyalty_tier
-- самый прибыльный? INNER JOIN — показывает только тех клиентов,
-- у кого реально есть покупки (кто без покупок — не появится, это
-- нормально для этой роли, "потерянных" ищет роль B).
-- ============================================================


-- ЗАПРОС 1: TOP-10 клиентов по общей сумме покупок
SELECT
    c.first_name || ' ' || c.last_name AS klient,
    c.city,
    COUNT(DISTINCT s.sale_id) AS ostude_arv,
    SUM(s.total_price) AS kogumüük
FROM sales s
INNER JOIN customers c ON s.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.city
ORDER BY kogumüük DESC
LIMIT 10;
-- РЕЗУЛЬТАТ: лидер — Tiina Pärn (Tartu), 75 покупок на 39 950.99 €.
-- Города в сырых данных пишутся вразнобой ("tartu" / "Tallinn") —
-- это тот самый мусор из недели 2, здесь его не чистим намеренно,
-- чтобы показать клиента таким, каким он лежит в базе.


-- ЗАПРОС 2: выручка по городам (с очисткой написания через N2)
SELECT
    INITCAP(TRIM(c.city)) AS linn,
    COUNT(DISTINCT c.customer_id) AS kliente,
    COUNT(s.sale_id) AS oste,
    SUM(s.total_price) AS kogumüük
FROM sales s
INNER JOIN customers c ON s.customer_id = c.customer_id
GROUP BY INITCAP(TRIM(c.city))
ORDER BY kogumüük DESC;
-- РЕЗУЛЬТАТ: Tallinn первый по объёму (1 520 761.89 €, 1009 клиентов),
-- но это размер рынка, не ценность клиента. Выручка на клиента:
-- Tallinn 1520761.89/1009 = 1507 €, Pärnu 564340.76/276 = 2045 €.
-- Клиент из Pärnu в среднем ценнее клиента из Tallinn на 36%.


-- ЗАПРОС 3: выручка по уровням лояльности
SELECT
    COALESCE(c.loyalty_tier, 'määramata') AS lojaalsustase,
    COUNT(DISTINCT c.customer_id) AS kliente,
    SUM(s.total_price) AS kogumüük
FROM sales s
INNER JOIN customers c ON s.customer_id = c.customer_id
GROUP BY COALESCE(c.loyalty_tier, 'määramata')
ORDER BY kogumüük DESC;
-- РЕЗУЛЬТАТ: самая крупная группа по выручке — "määramata" (не
-- заполнено), 1027 клиентов и 1 628 043.78 € — больше, чем gold,
-- silver и bronze по отдельности. Это не покупательская группа,
-- а дыра в данных: 40% клиентов вообще без loyalty_tier (найдено
-- ещё на неделе 2). Программа лояльности не работает так, как
-- кажется на первый взгляд — треть выручки просто не размечена.


-- ЗАПРОС 4 (edasijõudnud/подзапрос): сколько клиентов тратят выше среднего
SELECT
    COUNT(*) AS klienti_ule_keskmise,
    (SELECT COUNT(DISTINCT customer_id) FROM sales) AS kliente_kokku,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT customer_id) FROM sales), 1) AS protsent
FROM (
    SELECT customer_id, SUM(total_price) AS kliendi_müük
    FROM sales
    GROUP BY customer_id
    HAVING SUM(total_price) > (
        SELECT AVG(müük) FROM (
            SELECT SUM(total_price) AS müük FROM sales GROUP BY customer_id
        ) t
    )
) ule_keskmise;
-- РЕЗУЛЬТАТ: 751 из 2558 покупавших клиентов (29,4%) тратят выше
-- среднего чека по клиенту. Меньшинство держит основную выручку —
-- классическая асимметрия, которую стоит проверить дальше через RFM.


-- ============================================================
-- ИТОГ ДЛЯ ANNA (резюме роли A):
-- Лучший клиент по сумме — Тийна Пярн из Тарту (39 951 €). Пярну как
-- город даёт меньше денег, чем Таллинн, но каждый его клиент в
-- среднем ценнее на 36% — таллиннское лидерство держится на размере
-- базы, а не на качестве клиента. Самая крупная "группа лояльности"
-- по деньгам — это отсутствие данных о лояльности вообще (1,63 млн €
-- невидимы для программы лояльности). Рекомендация: прежде чем
-- запускать VIP-кампанию по tier'ам, заполнить пропуски в
-- loyalty_tier — иначе треть лучших клиентов просто не увидят письмо.
-- ============================================================
