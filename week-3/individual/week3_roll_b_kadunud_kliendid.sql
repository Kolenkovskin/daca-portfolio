-- ============================================================
-- DACA · Неделя 3 · SQL JOINs · Роль B — "Kadunud kliendid" (LEFT JOIN + IS NULL)
-- Задача Anna Mets: кто зарегистрировался, но никогда не купил?
-- Метод — антиджойн: LEFT JOIN сохраняет ВСЕХ клиентов, IS NULL на
-- первичном ключе правой таблицы (sale_id, не customer_id!) отсеивает
-- только тех, для кого правая сторона не нашлась ни разу.
-- ============================================================


-- ЗАПРОС 1: сколько клиентов вообще ни разу не купили
SELECT COUNT(*) AS kadunud_kliente,
       (SELECT COUNT(*) FROM customers) AS kliente_kokku,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customers), 1) AS protsent
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
WHERE s.sale_id IS NULL;
-- РЕЗУЛЬТАТ: 592 клиента из 3150 (18,8%) — почти каждый пятый, кто
-- завёл аккаунт, ни разу ничего не купил.


-- ЗАПРОС 2: доля потерянных клиентов по городам
-- ВАЖНО (молчаливая ловушка): нельзя писать COUNT(c.customer_id) без
-- DISTINCT — LEFT JOIN размножает строки клиента на число его продаж
-- (fan-out), и "kliente_kokku" через голый COUNT окажется завышен в
-- разы. Ниже — правильная версия с DISTINCT.
SELECT
    INITCAP(TRIM(c.city)) AS linn,
    COUNT(DISTINCT c.customer_id) AS kliente_kokku,
    COUNT(DISTINCT c.customer_id) FILTER (WHERE s.sale_id IS NULL) AS kadunud_kliente,
    ROUND(COUNT(DISTINCT c.customer_id) FILTER (WHERE s.sale_id IS NULL) * 100.0
          / COUNT(DISTINCT c.customer_id), 1) AS kadumise_protsent
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY INITCAP(TRIM(c.city))
ORDER BY kadumise_protsent DESC;
-- РЕЗУЛЬТАТ: по абсолютному числу больше всего потерянных в Tallinn
-- (229) — но это просто самый большой город. По ДОЛЕ реальный лидер —
-- Valga: 24 из 94 клиентов (25,5%) никогда не купили. Taллинн по доле
-- (18,5%) — на уровне со средним по сети, не хуже.


-- ЗАПРОС 3: когда регистрировались потерянные клиенты (динамика по месяцам)
SELECT
    DATE_TRUNC('month', c.registration_date) AS registreerimis_kuu,
    COUNT(DISTINCT c.customer_id) AS kadunud_kliente
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
WHERE s.sale_id IS NULL
GROUP BY DATE_TRUNC('month', c.registration_date)
ORDER BY registreerimis_kuu;
-- РЕЗУЛЬТАТ: число растёт к концу данных (пик — декабрь 2024 и
-- январь 2025, по 53 человека). Это не значит, что маркетинг стал
-- хуже работать: у недавно зарегистрированных просто было меньше
-- времени совершить первую покупку. Правильный вывод отсюда можно
-- сделать только сравнив с более старыми когортами на том же сроке
-- жизни, а не по абсолютной дате регистрации.


-- ЗАПРОС 4 (edasijõudnud): абсолютный список потерянных клиентов
SELECT
    c.first_name || ' ' || c.last_name AS klient,
    c.email,
    INITCAP(TRIM(c.city)) AS linn,
    c.registration_date,
    c.loyalty_tier
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
WHERE s.sale_id IS NULL
ORDER BY c.registration_date DESC
LIMIT 20;
-- РЕЗУЛЬТАТ: готовый список для email-кампании возврата — самые
-- недавние регистрации без покупки идут первыми (у них ещё тёплый
-- интерес).


-- ============================================================
-- ИТОГ ДЛЯ ANNA (резюме роли B):
-- 592 клиента (18,8% базы) зарегистрировались и никогда не купили.
-- Реальный проблемный город по доле — не Таллинн, а Валга (25,5%
-- потерь) — именно туда стоит целить локальную акцию, а не в
-- крупнейший город. Рост числа "потерянных" к концу периода — эффект
-- недавней регистрации, а не ухудшения работы с клиентами, поэтому
-- прежде чем бить тревогу, надо сравнивать когорты одного возраста.
-- Рекомендация: email-кампания win-back в первую очередь на Валгу и
-- на клиентов, зарегистрированных 2+ месяца назад без единой покупки.
-- ============================================================
