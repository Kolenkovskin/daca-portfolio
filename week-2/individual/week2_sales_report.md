# Andmekvaliteedi audit — Nädal 2

**Domeen:** müügiandmed (`sales`), kontrolliga tabelites `customers` ja `products`
**Andmebaas:** UrbanStyle, PostgreSQL (Supabase)
**Tellija:** Toomas Kask (IT Director)
**Staatus:** defektid on **tuvastatud ja dokumenteeritud**. Andmeid ei ole muudetud ega kustutatud.

> Vastavalt nädala reeglile (`N2_0_1`): sel nädalal defektid tuvastatakse, dokumenteeritakse ja raporteeritakse — kustutamine toimub alles pärast põhjalikku kontrolli ja kontrollmehhanismi paigaldamist.

---

## 1. Äriprobleem

Kristi Tamm (CEO) vajab käibenumbreid, mida saab usaldada. Toomas avastas dubleeritud tellimused ja palus hinnata probleemi ulatust.

Audit näitas, et olukord on keerulisem kui esialgne hüpotees: korduv `sale_id` ei ole üks defekt, vaid **viie erineva probleemi ühine sümptom**, ja osa neist ei tohi kustutamise teel lahendada.

---

## 2. Lähenemine

| Etapp | Meetod |
|---|---|
| Korduste tuvastamine | `GROUP BY` + `HAVING count(*) > 1`, `count(*) − count(DISTINCT …)` |
| Korduste eraldamine | `ROW_NUMBER() OVER (PARTITION BY …)` + alampäring |
| **Rühmade homogeensuse kontroll** | `nunique` iga veeru kohta rühma sees |
| Puuduvate väärtuste audit | `count(*)` vs `count(veerg)`, `NULLIF(TRIM(…), '')` |
| Teksti normaliseerimine | `TRIM`, `INITCAP`, kontroll `LENGTH` abil |
| Kuupäevade teisendamine | `CASE` + `TO_DATE`, `CAST` |

Kolmas rida on auditi võtmesamm: enne kustutamise kaalumist kontrolliti, **kas korduvad read on omavahel identsed**. Selgus, et ei ole.

---

## 3. Korduva `sale_id` anatoomia

15 234 reast on 5 116 üleliigsed, jaotunud 4 013 rühma. Rühmad ei ole ühesugused:

| Kategooria | Rühmi | Üleliigseid ridu | Sisu |
|---|---|---|---|
| **A** täiesti identsed | 3 239 | 4 051 | topeltimport |
| **B** erineb ainult kuupäevaformaat | 213 | 282 | sama päev, erinev kirjaviis |
| **C** ühel real klient, teisel mitte | 370 | 517 | osaline kirje |
| **D** summad vastandmärgiga | 165 | 234 | **müük ja tagastus** |
| **E** erinevad päevad | 26 | 32 | **erinevad sündmused** |
| **Kokku** | **4 013** | **5 116** | |

Rühmade sees **ei erine kunagi**: `invoice_id`, `product_id`, `quantity`, `channel`, `store_location`, `payment_method`. Kliendid ei erine kunagi väärtuse poolest — ainult „on" versus „puudub". Summad erinevad **eranditult märgi poolest**, erinevaid suurusi ei esine.

### Järeldus kategooriate kaupa

- **A + B (3 452 rühma, 4 333 rida)** — tõelised duplikaadid. Kustutamine on ohutu.
- **C (370 rühma, 517 rida)** — ei ole duplikaat, vaid **puudulik kirje**. Alles tuleb jätta rida, kus klient on teada, muidu kaob seos ostjaga.
- **D (165 rühma, 234 rida)** — **ei ole duplikaadid**. `183.31` ja `−183.31` sama `sale_id` all on müük ja selle tühistamine. Mõlemad read on reaalsed sündmused.
- **E (26 rühma, 32 rida)** — erinevad päevad, seega erinevad tehingud, millele on ekslikult antud sama võti.

**Tõelisi duplikaate on 4 333, mitte 5 116.** Ülejäänud 783 rida kuuluvad kolme muu defekti alla.

---

## 4. Käive: miks üht arvu ei ole

| Stsenaarium | Ridu | Käive |
|---|---|---|
| Naiivne aruanne (ainult ISO-kuupäevad, kordused alles) | 14 777 | 4 230 939,69 € |
| Kuupäevad teisendatud, kordused alles | 15 234 | 4 374 231,27 € |
| Kordused kokku surutud, originaaliks väikseim summa | 10 118 | 2 848 960,34 € |
| Kordused kokku surutud, originaaliks esimene rida | 10 118 | 2 909 177,98 € |
| Kordused kokku surutud, originaaliks suurim summa | 10 118 | 2 944 914,90 € |

**Kolme viimase hajuvus on 95 954,56 €.**

Põhjus: `ROW_NUMBER() OVER (PARTITION BY sale_id ORDER BY sale_id)` ei erista rühmasiseseid ridu — nende `sale_id` on identne. Seega otsustab originaali valiku füüsiline lugemisjärjekord, mitte reegel. Heterogeensetes rühmades (C, D, E) annab see iga korra erineva tulemuse.

**Ükski neist arvudest ei ole veel õige käive**, sest kõik kolm suruvad kokku ka kategooriad D ja E, mida kokku suruda ei tohi.

Korrektne arvutus nõuab kolme otsust, mis on **ärilised, mitte tehnilised**:
1. mida lugeda originaaliks kategoorias C (ettepanek: rida, kus klient on teada);
2. kas tagastused (D) kajastuvad käibes eraldi ridadena (ettepanek: jah, mõlemad read jäävad);
3. kuidas eristada kategooria E sündmusi, millel puudub kehtiv võti.

---

## 5. Muud tuvastatud defektid

### 5.1 Kuupäevaformaat

457 rida on formaadis `DD/MM/YYYY`, ülejäänud ISO-formaadis. Veerg `sale_date` on tüübilt **tekst, mitte kuupäev**.

Tagajärg: naiivne kuupäevapõhine aruanne jättis välja **143 291,58 €**. Kaldkriipsuga read jagunevad kogu perioodile 04.01.2023 – 09.06.2026: 193 kirjet 2023, 237 kirjet 2024, 26 kirjet 2025, 1 kirje 2026 — probleem oli massiline ja hääbus järk-järgult.

### 5.2 Negatiivsed summad

305 rida negatiivse summaga, kokku **−88 632,61 €**. Neist 168 asuvad korduvates rühmades (kategooria D), 137 on üksikud. Tagastusi ei ole seni eraldi arvestatud üheski aruandes.

### 5.3 Tabel `customers`

| Näitaja | Väärtus |
|---|---|
| Ridu | 3 150 |
| Linnanimede kirjapilte | 54 |
| Tegelikke linnu | 12 |
| Üleliigseid kirjapildivariante | 42 |
| Kliente ilma e-mailita | 380 (12,1%) |
| Kliente ilma `loyalty_tier`-ita | 1 260 (40,0%) |
| Ridu dubleeritud e-mailiga | 130 (128 aadressi) |
| `customer_id` duplikaate | 0 |

Kontrollitud eraldi: puuduvad e-mailid on **tõelised NULL-id**, mitte tühjad stringid — maskeeritud tühjust selles veerus ei ole.

### 5.4 Tabel `products`

362 rida, `product_id` duplikaate ei ole. **664 rida** tabelis `sales` ei vasta valemile `retail_price × quantity` rohkem kui 1 € võrra.

### 5.5 Puuduv klient tabelis `sales`

1 487 tehingut (9,8%) ilma `customer_id`-ta.

---

## 6. Eeldused ja nende kontroll

| Eeldus | Tulemus | Tõend |
|---|---|---|
| `sale_id` on unikaalne võti | **ümber lükatud** | 4 013 rühma korduva võtmega |
| Korduvad read on identsed | **ümber lükatud** | 774 rühma erinevad sisu poolest |
| `sale_date` on kuupäevatüüpi | **ümber lükatud** | tekst, kaks formaati |
| Puuduvad e-mailid on tühjad stringid | **ümber lükatud** | tõelised NULL-id |
| Linnanimed on ühtlustatud | **ümber lükatud** | 54 kirjapilti 12 linna kohta |

---

## 7. Soovitused

| Prioriteet | Tegevus |
|---|---|
| Kõrge | Selgitada välja, miks `sale_id` ei ole unikaalne — võtme genereerimise viga allikas |
| Kõrge | Enne kustutamist jagada kordused viide kategooriasse; kustutada tohib ainult A ja B |
| Kõrge | Muuta `sale_date` tüübist `text` tüübiks `date` skeemi tasemel |
| Kõrge | Kõrvaldada POS-i ja e-poe topeltimport andmelaadimise tasemel |
| Keskmine | Kokku leppida reegel kategooria C jaoks: milline kirje on originaal |
| Keskmine | Lisada tagastuste eraldi arvestus aruandlusse |
| Keskmine | Rakendada linnanime normaliseerimine (`TRIM` + `INITCAP`) sisestamisel |
| Keskmine | Kontrollida 664 hinna lahknevust |
| Madal | Uurida 1 487 tehingut ilma kliendita — külaliskliendid või kadunud seos |

Kustutamist ei alustata enne, kui on olemas testkoopia ja auditilogi.

---

## 8. Õpitu ja väljakutsed

Auditi käigus tuli parandada kahte omaenda järeldust.

**Esimene parandus.** Esialgses versioonis olid arvud „enne" ja „pärast" võetud erinevatest arvutusstsenaariumitest ning tulemus nägi absurdne välja: käive kasvas pärast kolmandiku ridade eemaldamist. Viga ei tulnud välja koodi kontrollimisel, vaid küsimusest „miks see number ei klapi loogikaga".

**Teine parandus, olulisem.** Esialgu loeti kõik 5 116 üleliigset rida duplikaatideks. Kontroll näitas, et 783 neist ei ole duplikaadid: nende hulgas on tagastusi, puudulikke kirjeid ja eraldi sündmusi. Viga tekkis sellest, et loendati **kordade arvu**, kontrollimata **sisu**. Programm hoiatab täpselt selle eest — kontrollida tuleb, kas korduvad kirjed omavahel erinevad, sest erinevus viitab andmete ühendamise veale.

Kolm reeglit, mis sellest järeldusid:

1. **Päringu tulemust tuleb kõrvutada terve mõistusega, mitte ainult süntaksiga.** Tehniliselt laitmatu päring võib anda mõttetu vastuse.
2. **Enne dubleerituse eemaldamist tuleb tõestada rühmade homogeensus.** Kui read rühma sees erinevad, ei ole tegemist duplikaatidega ja kustutamine hävitab andmeid.
3. **Eeldused tuleb kirja panna ja kontrollida.** Kõik viis käesolevas auditis kirja pandud eeldust osutusid vääraks — ükski neist ei oleks avastatud ilma sihipärase kontrollita.

---

## 9. AI kasutamine

Claude'i kasutasin õpetaja ja retsensendina: SQL-konstruktsioonide selgitamine, veateadete analüüs, arvutuste kontroll ja raporti keeleline ülevaatus. Kõik päringud on kirjutatud iseseisvalt. Mõlemad ülalkirjeldatud parandused tulid välja tulemuse omapoolsel kontrollimisel, mitte automaatselt.

---

## 10. Artefaktid

- [`week2_deduplication.sql`](week2_deduplication.sql) — korduste tuvastamine
- [`week2_null_audit.sql`](week2_null_audit.sql) — puuduvate ja maskeeritud tühjade väärtuste audit

**Tööriistad:** PostgreSQL (Supabase), `GROUP BY`/`HAVING`, `ROW_NUMBER() OVER`, alampäringud, `COALESCE`/`NULLIF`, `TRIM`/`INITCAP`/`LENGTH`, `CASE`, `TO_DATE`/`TO_CHAR`, `CAST`, `UNION ALL`.
