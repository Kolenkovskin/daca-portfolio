-- ============================================================
-- DACA · Неделя 2 · Очистка данных (SQL Puhastamine)
-- Задача Toomas Kask (IT Director, UrbanStyle): убрать дубли перед
-- заседанием правления. Kristi Tamm (CEO) требует чистые цифры.
-- Процесс: Test -> Verify -> Log -> Commit.
-- Доступ к Supabase: read/write под ролью postgres (учебный проект).
-- ============================================================


-- ШАГ 1 (TEST): тестовая копия — продакшн sales не трогаем
CREATE TABLE sales_test AS SELECT * FROM sales;
SELECT count(*) FROM sales_test;                 -- 15234 строки


-- ШАГ 2 (ДИАГНОСТИКА): найти задвоенные заказы.
-- Причина дублей: двойной импорт (касса POS + сайт грузили одни данные).
-- sale_date хранится как TEXT в разных форматах ('2023-01-16' ISO vs
-- '16/01/2023' европ.), поэтому база не схлопнула их -> дубли строк.
SELECT sale_id, count(*) AS koopiate_arv
FROM sales_test
GROUP BY sale_id
HAVING count(*) > 1
ORDER BY koopiate_arv DESC;                       -- 4013 задвоенных sale_id

-- Сколько ЛИШНИХ строк на удаление (НЕ равно числу задвоенных id!):
SELECT count(*)                           AS total,         -- 15234
       count(DISTINCT sale_id)            AS unique_sales,  -- 10118
       count(*) - count(DISTINCT sale_id) AS extra_rows     -- 5116 (33.58%)
FROM sales_test;


-- ШАГ 3 (ЧИСТКА): пронумеровать копии и оставить оригиналы.
-- ROW_NUMBER не схлопывает строки, а нумерует их внутри группы sale_id.
-- ORDER BY id -> оригинал = первая загрузка (меньший id).
-- rn нельзя фильтровать в WHERE там же, где он рождается -> подзапрос.
SELECT sale_id, id,
       ROW_NUMBER() OVER (PARTITION BY sale_id ORDER BY id) AS rn
FROM sales_test
ORDER BY sale_id
LIMIT 20;                                          -- у дублей видно rn 1,2,3,4...

-- Финальный дедуп: только rn = 1 (оригиналы), все столбцы через *
SELECT * FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY sale_id ORDER BY id) AS rn
    FROM sales_test
) AS t
WHERE rn = 1;                                      -- 10118 чистых строк


-- ШАГ 4 (COMMIT): сохранить чистые данные отдельной таблицей.
-- RLS отключён осознанно: учебный одиночный проект, доступ только под postgres.
CREATE TABLE sales_clean AS
SELECT * FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY sale_id ORDER BY id) AS rn
    FROM sales_test
) AS t
WHERE rn = 1;

-- ПРОВЕРКА: число сошлось с диагностикой
SELECT count(*) FROM sales_clean;                  -- 10118 = unique_sales


-- ============================================================
-- РЕЗУЛЬТАТ: 15234 -> 10118 строк, убрано 5116 дублей (33.58% таблицы).
-- Три стадии сохранены: sales (продакшн, нетронут), sales_test (с дублями),
-- sales_clean (чистая — рабочая база для следующих шагов).
-- ДАЛЬШЕ: sale_date всё ещё text в разных форматах -> CAST к date.
-- ============================================================
