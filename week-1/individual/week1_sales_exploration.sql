-- =====================================================
-- Week 1: UrbanStyle Sales Tabeli Uurimisuuring
-- Autor: Nikita Kolenkovski
-- Kuupäev: 2026-03-31
-- Eesmärk: Vastata Toomas Kaski küsimustele sales tabeli kohta
-- =====================================================

-- 1. Mitu rida on sales tabelis kokku?
SELECT COUNT(*) AS kogu_read FROM sales;
-- Tulemus: 15234 rida
-- Kommentaar: See on rohkem kui oodatud (~10118 unikaalset tehingut).
-- Vahe viitab duplikaatidele, mida Toomas mainis.

-- 2. Mitu unikaalset invoice_id on? Kui palju on duplikaate?
SELECT
    COUNT(*) AS kogu_read,
    COUNT(DISTINCT invoice_id) AS unikaalseid_arveid,
    COUNT(*) - COUNT(DISTINCT invoice_id) AS duplikaadid
FROM sales;
-- Tulemus: 15234 kokku, 10118 unikaalset, 5116 duplikaati
-- Kommentaar: 5116 duplikaati = 33.6% kogu ridadest!
-- Enne aruannete koostamist TULEB duplikaadid eemaldada,
-- muidu on käive ~34% üle paisutatud.

-- 3. Kõige suuremad müügid (TOP 10)
SELECT sale_id, sale_date, total_price, channel, store_location
FROM sales
ORDER BY total_price DESC
LIMIT 10;
-- Tulemus: Suurim müük 2170.40 EUR
-- Kommentaar: Suured müügid on peamiselt Tallinna poest.
-- Need võivad olla hulgiostud või kallid tooted.

-- 4. Kõige väiksemad müügid — kas on negatiivseid?
SELECT sale_id, sale_date, total_price, channel, store_location
FROM sales
ORDER BY total_price ASC
LIMIT 10;
-- Tulemus: Väikseim müük -1405.32 EUR (negatiivne!)
-- Kommentaar: Negatiivsed väärtused viitavad tagastustele.
-- Need tuleb eraldi analüüsida — kas tagastused on korrektselt kirjendatud?

-- 5. NULL väärtuste kontroll — mitu müüki on ilma kliendi ID-ta?
SELECT
    COUNT(*) - COUNT(customer_id) AS null_kliendid,
    COUNT(*) AS kokku,
    ROUND(100.0 * (COUNT(*) - COUNT(customer_id)) / COUNT(*), 1) AS null_protsent
FROM sales;
-- Tulemus: 1487 rida ilma customer_id-ta (9.8%)
-- Kommentaar: Need on ilmselt külalisostud (guest purchases),
-- kus klient ei registreerinud. Anna turundusmeeskond
-- peaks kaaluma registreerimise motiveerimist.

-- =====================================================
-- KOKKUVÕTE Toomasele:
-- 1. Sales tabelis on 5116 duplikaati (33.6%) — kriitiliselt oluline!
-- 2. Negatiivseid müüke on (tagastused) — vajavad eraldi käsitlemist
-- 3. 9.8% müükidest on ilma kliendi ID-ta (külalisostud)
-- 4. Soovitus: enne aruandlust TULEB duplikaadid eemaldada
-- =====================================================
