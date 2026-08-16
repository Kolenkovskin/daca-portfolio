# Andmete puhastamise raport — Nädal 2

**Domeen:** müügiandmed (`sales`), kontrolliga seotud tabelites `customers` ja `products`
**Andmebaas:** UrbanStyle, PostgreSQL (Supabase)
**Tellija:** Toomas Kask (IT Director) — puhaste numbrite ettevalmistus juhatuse koosolekuks

---

## 1. Äriprobleem

Kristi Tamm (CEO) nõuab käibenumbreid, mida saab usaldada. Toomas avastas dubleeritud tellimused ja palus hinnata probleemi ulatust kõigis domeenides.

Kontroll näitas, et aruandluses on **kaks sõltumatut viga, mis varjasid teineteist**: üks kergitas käivet, teine alandas. Kuna vead mõjusid vastassuundades, nägid lõppnumbrid usutavad välja ega tekitanud kahtlust.

---

## 2. Lähenemine

Töö käis Toomase reegli järgi: **testkoopia → puhastamine → kontroll → dokumenteerimine**. Tootmistabeleid ei muudetud.

| Etapp | Meetod |
|---|---|
| Duplikaatide diagnostika | `GROUP BY` + `HAVING count(*) > 1`, `count(*) − count(DISTINCT …)` |
| Duplikaatide eraldamine | `ROW_NUMBER() OVER (PARTITION BY … ORDER BY …)` + alampäring, filter `rn > 1` |
| Puuduvate väärtuste diagnostika | `count(*)` vs `count(veerg)`, `NULLIF(TRIM(…), '')` |
| Teksti normaliseerimine | `TRIM`, `INITCAP`, kontroll `LENGTH` abil |
| Kuupäevade teisendamine | `CASE` + `TO_DATE` formaadile `DD/MM/YYYY`, `CAST` ISO-formaadile |
| Perioodiaruandlus | `TO_CHAR(…, 'YYYY-MM')` + `GROUP BY` |

---

## 3. Tulemused «enne / pärast»

### 3.1 Tabel `sales`

| Näitaja | Enne puhastamist | Pärast puhastamist |
|---|---|---|
| Ridu | 15 234 | 10 118 |
| Unikaalseid `sale_id` | 10 118 | 10 118 |
| Duplikaate | 5 116 (33,58%) | 0 |
| Korduvaid `sale_id` | 4 013 | 0 |
| Kuupäevi formaadis `DD/MM/YYYY` | 457 (ei loetud) | 457 (teisendatud tüüpi `date`) |
| Müüke ilma `customer_id`-ta | 1 487 (9,8%) | 1 487 (märgistatud, mitte kustutatud) |

Duplikaatide kordsus: 3 091 kirjet on dubleeritud kaks korda, 759 — kolm korda, 147 — neli korda, 14 — viis korda, 2 — kuus korda.

### 3.2 Käive — võtmetulemus

| Aruande stsenaarium | Ridu | Käive |
|---|---|---|
| Naiivne aruanne (ainult ISO-kuupäevad, duplikaadid alles) | 14 777 | 4 230 939,69 € |
| Kuupäevad teisendatud, duplikaadid alles | 15 234 | 4 374 231,27 € |
| **Kuupäevad teisendatud + dedupliketsioon** | **10 118** | **2 909 177,98 €** |

**Naiivne aruanne kergitas käivet 45,4% võrra.**

### 3.3 Tabel `customers`

| Näitaja | Enne puhastamist | Pärast puhastamist |
|---|---|---|
| Ridu | 3 150 | 3 150 |
| Linnanimede kirjapilte | 54 | 12 |
| Üleliigseid kirjapildivariante | 42 | 0 |
| Kliente ilma e-mailita | 380 (12,1%) | 380 (märgistatud) |
| Kliente ilma `loyalty_tier`-ita | 1 260 (40,0%) | 1 260 (märgistatud) |
| Ridu dubleeritud e-mailiga | 130 (128 aadressi) | tuvastatud |
| `customer_id` duplikaate | 0 | 0 |

### 3.4 Tabel `products`

| Näitaja | Väärtus |
|---|---|
| Ridu | 362 |
| `product_id` duplikaate | 0 |
| Hinna lahknevusi valemist `retail_price × quantity` (üle 1 €) | 664 rida |

---

## 4. Ärijäreldused

**1. Aruandlus kergitas käivet 45,4% võrra — 4 230 939,69 € tegeliku 2 909 177,98 € asemel.**
Põhjuseid ei ole üks, vaid kaks, ja need mõjusid vastassuundades:
- duplikaadid lisasid **1 465 053,29 €** olematuid müüke;
- kuupäevaformaadi viga varjas samal ajal **143 291,58 €** tegelikke müüke.

Just vigade vastastikune kompenseerumine muutis numbrid väliselt usaldusväärseks. Kontroll ainult duplikaatide või ainult kuupäevaformaatide osas oleks avastanud poole probleemist ja andnud uue, sama ekslikku numbri.

**2. Duplikaatide põhjus on topeltimport.**
Kassasüsteem (POS) ja veebipood (e-commerce) laadisid samu tehinguid korduvalt. Kuna `sale_date` on salvestatud tekstina kahes formaadis (`2023-01-16` ja `16/01/2023`), ei tuvastanud süsteem kattuvaid kirjeid sama päevana. Üks viga tuli välja teise kaudu.

**3. Kuupäevaformaadi viga puudutab kogu perioodi, mitte üksikut ebaõnnestunud importi.**
Kaldkriipsuga kuupäevad jagunevad ajavahemikus 04.01.2023 kuni 09.06.2026: 193 kirjet aastal 2023, 237 aastal 2024, 26 aastal 2025, 1 aastal 2026. Probleem oli massiline ja hääbus järk-järgult — tõenäoliselt pärast sisestussüsteemi vahetust. Praktiline järeldus: **kõik 2023.–2024. aasta kuupäevapõhised ajaloolised aruanded vajavad ümberarvutamist.**

**4. Linnade lõikes koostatud aruanded ei ole usaldusväärsed.**
54 kirjapildivarianti 12 tegeliku linna asemel tähendab, et iga linna järgi rühmitamine jagas ühe linna mitmeks reaks. Kõik regionaalsed näitajad olid enne normaliseerimist alahinnatud.

**5. 40% kliendibaasist on ilma lojaalsustasemeta.**
1 260 klienti 3 150-st ei ole andmelünk, vaid mittetoimiv äriprotsess: lojaalsusprogramm ei omista registreerimisel taset. Probleem on allika poolel ja SQL-puhastusega ei lahene.

---

## 5. Soovitused

| Prioriteet | Tegevus |
|---|---|
| Kõrge | Arvutada ümber 2023.–2026. aasta käibearuanded, arvestades mõlemat viga |
| Kõrge | Kõrvaldada POS-i ja e-poe topeltimport andmelaadimise tasemel |
| Kõrge | Muuta `sale_date` tüübist `text` tüübiks `date` skeemi tasemel |
| Keskmine | Rakendada linnanime normaliseerimine (`TRIM` + `INITCAP`) juba sisestamisel |
| Keskmine | Kontrollida 664 hinna lahknevust — võimalikud on skeemis kajastamata allahindlused |
| Keskmine | Selgitada välja 130 dubleeritud e-maili põhjus — tõenäolised kontode duplikaadid |
| Madal | Uurida 1 487 müüki ilma `customer_id`-ta — külaliskliendid või kadunud seos |

---

## 6. Õpitu ja väljakutsed

Nädala peamine õppetund ei olnud tehniline. Esialgne raport sisaldas viga: numbrid «enne» ja «pärast» olid võetud erinevatest arvutusstsenaariumitest ning tulemus nägi absurdne välja — käive kasvas pärast kolmandiku ridade eemaldamist. Viga ei tulnud välja koodi kontrollimisel, vaid küsimusest «miks see number ei klapi loogikaga».

Sellest reegel: **päringu tulemust tuleb kõrvutada terve mõistusega, mitte ainult süntaksiga.** Tehniliselt laitmatu päring võib anda mõttetu vastuse, ja seda suudab märgata üksnes see, kes mõistab, mida numbrid tähendavad.

Teine õppetund puudutab kattuvaid vigu. Kaks viga vastassuundades näivad usaldusväärsemad kui üks, sest need kompenseerivad teineteist. Seetõttu tuleb puhastamine viia lõpuni kõigi leitud vigade osas, mitte peatuda esimese juures.

Kolmas õppetund on tehniline: `NULL` ei võrdu tühja stringiga, `count(*)` ei võrdu `count(veerg)`-iga, ja `PARTITION BY` määrab duplikaadi mõiste enda. Veeru vahetamine `PARTITION BY` sees muudab kogu päringu tähendust.

---

## 7. AI kasutamine

Claude'i kasutasin õpetaja ja retsensendina: SQL-konstruktsioonide selgitamine, veateadete analüüs, arvutuste kontroll ja käesoleva raporti keeleline ülevaatus. Kõik päringud on kirjutatud iseseisvalt; arvutusstsenaariumite segiajamise viga tuli välja tulemuse omapoolsel kontrollimisel.

---

## 8. Artefaktid

- [`week2_deduplication.sql`](week2_deduplication.sql) — duplikaatide diagnostika ja eemaldamine
- [`week2_null_audit.sql`](week2_null_audit.sql) — puuduvate ja maskeeritud tühjade väärtuste audit

**Tööriistad:** PostgreSQL (Supabase), `GROUP BY`/`HAVING`, `ROW_NUMBER() OVER`, alampäringud, `COALESCE`/`NULLIF`, `TRIM`/`INITCAP`/`LENGTH`, `CASE`, `TO_DATE`/`TO_CHAR`, `CAST`, `UNION ALL`.
