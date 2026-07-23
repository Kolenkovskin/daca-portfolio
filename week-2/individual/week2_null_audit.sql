-- ============================================================
-- DACA · Nädal 2 · Andmete puhastamine (N2)
-- FAIL: week2_null_audit.sql
--
-- EESMÄRK: leida puuduvad väärtused ENNE analüüsi algust.
-- Reegel GIGO: vale sisend annab vale väljundi.
--
-- Audit eristab KAHTE liiki tühjust:
--   1) aus NULL             -> COUNT(veerg) jätab selle vahele
--   2) maskeeritud tühjus   -> '' ja tühikud, mida COUNT LOEB väärtuseks!
--
-- Lahendus: NULLIF(TRIM(veerg), '') muudab maskeeritud tühjuse NULL-iks,
-- alles siis jätab COUNT selle vahele ja loendus on aus.
--
-- Päring on READ-ONLY: andmeid ei muudeta, ainult loetakse.
-- Andmebaas: isiklik Supabase projekt, standardtabelid.
-- ============================================================


-- ============================================================
-- BLOKK 1: customers — puuduvate väärtuste pass
-- ============================================================
-- Literaal 'customers' on lihtsalt tekstisilt, et kahe bloki
-- tulemusi ei saaks omavahel segamini ajada.
SELECT
    'customers'                                       AS tabel,
    COUNT(*)                                          AS ridu_kokku,

    -- email: aus NULL vs maskeeritud tühjus
    COUNT(*) - COUNT(email)                           AS email_null,
    COUNT(email) - COUNT(NULLIF(TRIM(email), ''))     AS email_tuhi_string,
    ROUND(
        100.0 * (COUNT(*) - COUNT(NULLIF(TRIM(email), ''))) / COUNT(*)
    , 1)                                              AS email_puudub_pct,

    -- loyalty_tier: sama loogika
    COUNT(*) - COUNT(loyalty_tier)                    AS tier_null,
    COUNT(loyalty_tier)
        - COUNT(NULLIF(TRIM(loyalty_tier), ''))       AS tier_tuhi_string,
    ROUND(
        100.0 * (COUNT(*) - COUNT(NULLIF(TRIM(loyalty_tier), ''))) / COUNT(*)
    , 1)                                              AS tier_puudub_pct
FROM customers;

-- TÄHELEPANU: 100.0 punktiga on KOHUSTUSLIK.
-- Kui kirjutada 100, teeb Postgres täisarvulise jagamise ja tulemus on 0.
--
-- Tulemus: ridu_kokku ____ | email puudub ____ | loyalty_tier puudub ____
-- CSV-faili põhjal ootus: 3150 rida, 380 puuduvat e-maili, 1260 puuduvat taset.


-- ============================================================
-- BLOKK 2: sales — kas arvutused on usaldusväärsed?
-- ============================================================
SELECT
    'sales'                          AS tabel,
    COUNT(*)                         AS ridu_kokku,
    COUNT(*) - COUNT(customer_id)    AS customer_id_null,
    ROUND(100.0 * (COUNT(*) - COUNT(customer_id)) / COUNT(*), 1)
                                     AS customer_id_puudub_pct,
    COUNT(*) - COUNT(total_price)    AS total_price_null
FROM sales;

-- MIKS see loeb: SUM ja AVG jätavad NULL-id vaikselt vahele.
-- Kui total_price_null = 0, siis kogusumma ja keskmine katavad KÕIKI ridu.
-- Kui total_price_null > 0, tuleb aruandes see eraldi välja öelda.
-- Puuduv customer_id = "kummitusost": tehing toimus, aga ostjat ei tunta.


-- ============================================================
-- BLOKK 3: peidetud probleem — sama linn mitmes kirjapildis
-- ============================================================
-- Inimene näeb, et " Tallinn", "Tallinn " ja "TALLINN" on sama linn.
-- SQL näeb kolme erinevat väärtust. See lõhub iga GROUP BY tulemuse.

-- 3.1 Kokkuvõte: mitu kirjapilti vs mitu tegelikku linna
SELECT
    COUNT(DISTINCT city)                        AS erinevaid_kirjapilte,
    COUNT(DISTINCT INITCAP(TRIM(city)))         AS tegelikke_linnu,
    COUNT(DISTINCT city)
        - COUNT(DISTINCT INITCAP(TRIM(city)))   AS liigseid_variante
FROM customers;

-- Tulemus: kirjapilte ____ | tegelikke linnu ____ | liigseid variante ____


-- 3.2 Detailvaade: iga kirjapilt eraldi, kõrvuti puhastatud kujuga
SELECT
    city                    AS algne_kirjapilt,
    LENGTH(city)            AS margi_pikkus,
    INITCAP(TRIM(city))     AS normaliseeritud,
    COUNT(*)                AS klientide_arv
FROM customers
GROUP BY city
ORDER BY normaliseeritud, algne_kirjapilt;

-- margi_pikkus paljastab peidetud tühikud: "Tallinn" = 7 märki,
-- aga " Tallinn" = 8 märki. Silmaga vahet ei näe, numbriga näed kohe.


-- 3.3 loyalty_tier: millised väärtused üldse esinevad?
SELECT
    loyalty_tier            AS algne_vaartus,
    COUNT(*)                AS klientide_arv
FROM customers
GROUP BY loyalty_tier
ORDER BY klientide_arv DESC;

-- TÄHELEPANU: GROUP BY koondab KÕIK NULL-id ühte gruppi.
-- Nii näed korraga nii olemasolevaid tasemeid kui ka puuduvate hulka.


-- ============================================================
-- KOKKUVÕTE JA JÄRGMINE SAMM
--
-- Auditi loogika: kõigepealt loeme puudujäägid kokku (blokk 1-2),
-- seejärel otsime tühjust, mis end väärtuseks maskeerib (blokk 3).
--
-- Otsustusreegel puuduva osakaalu järgi:
--   alla  5%  -> tavaliselt saab täita või read välja jätta
--   üle  30%  -> veerg on ebausaldusväärne, tuleb parandada allikas
--                või märkida aruandes selgelt ebatäielikuks
--
-- JÄRGMINE SAMM: linnanimede ühtlustamine (TRIM + INITCAP)
-- ja puuduvate väärtuste käsitlemine COALESCE abil.
-- ============================================================
