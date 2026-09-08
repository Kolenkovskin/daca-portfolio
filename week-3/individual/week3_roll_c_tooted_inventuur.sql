-- ============================================================
-- DACA · Неделя 3 · SQL JOINs · Роль C — Tooted + Inventuur (LEFT JOIN)
-- Задача Anna + Toomas: какие товары никогда не продавались? Какие
-- продаются лучше всего? Что с остатками на складе?
-- ============================================================


-- ЗАПРОС 1: товары каталога, которые ни разу не были проданы
SELECT p.product_name, p.category, p.subcategory, p.retail_price
FROM products p
LEFT JOIN sales s ON p.product_id = s.product_id
WHERE s.sale_id IS NULL
ORDER BY p.retail_price DESC;
-- РЕЗУЛЬТАТ: 12 товаров из 362. 8 из 12 — категория "aksessuaarid".
-- Самый дорогой непроданный товар — "Moodne villane nahk sandaalid"
-- за 368.67 €.


-- ЗАПРОС 2: топ-10 самых продаваемых товаров
SELECT
    p.product_name,
    p.category,
    COUNT(s.sale_id) AS müüdud_kordi,
    SUM(s.total_price) AS kogumüük
FROM products p
INNER JOIN sales s ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY kogumüük DESC
LIMIT 10;
-- РЕЗУЛЬТАТ: 6 из 10 лидеров — категория "jalanõusid" (обувь).
-- Лидер — "Trendikas goretex oxfordid", 56 продаж на 43 041.80 €.


-- ЗАПРОС 3: выручка и число товаров по категориям
SELECT
    p.category,
    COUNT(DISTINCT p.product_id) AS tooteid,
    COUNT(s.sale_id) AS müüke,
    SUM(s.total_price) AS kogumüük
FROM products p
LEFT JOIN sales s ON p.product_id = s.product_id
GROUP BY p.category
ORDER BY kogumüük DESC;
-- РЕЗУЛЬТАТ: jalanõusid (1 171 288 €), meeste_riided (1 131 049 €) и
-- naiste_riided (1 025 488 €) заметно впереди aksessuaarid (586 267 €)
-- и laste_riided (460 138 €) — те же три категории, что оказались
-- выше средней выручки в контрольной подзадаче с подзапросом.


-- ЗАПРОС 4 (edasijõudnud, 3 таблицы): деньги, замороженные на складе
-- в непроданных товарах
SELECT
    p.product_name,
    p.category,
    p.retail_price,
    i.quantity_available,
    ROUND(p.retail_price * i.quantity_available, 2) AS kinni_olev_raha
FROM products p
LEFT JOIN sales s ON p.product_id = s.product_id
LEFT JOIN inventory i ON p.product_id = i.product_id
WHERE s.sale_id IS NULL
  AND i.quantity_available > 0
ORDER BY kinni_olev_raha DESC;
-- РЕЗУЛЬТАТ: 0 строк. Не потому что ошибка в запросе — потому что
-- ни у одного из 12 непроданных товаров вообще нет записи в
-- inventory (i.quantity_available = NULL для всех двенадцати,
-- проверено отдельным запросом). "> 0" не пропускает NULL, поэтому
-- пусто. Настоящая находка сильнее ожидаемой: дело не в том, что
-- товар залежался на складе — эти 12 товаров физически никогда не
-- поступали на склад. Это не "непроданный остаток", а "фантомная"
-- позиция каталога.


-- ============================================================
-- ИТОГ ДЛЯ ANNA И TOOMAS (резюме роли C):
-- 12 товаров из 362 (3,3%) ни разу не продавались — и ни один из них
-- физически не заведён на складе. Это не проблема спроса или цены,
-- это разрыв в процессе заведения товара: карточка создана в
-- products, но inventory для неё так и не завели. Топ продаж держит
-- обувь — 6 из 10 самых прибыльных товаров и самая прибыльная
-- категория целиком. Рекомендация Toomas'у: аудит процесса запуска
-- нового товара — искать другие карточки без inventory до того, как
-- их закупят и обнаружат ту же дыру.
-- ============================================================
