# Nädal 2 — Andmete puhastamine (SQL Puhastamine)

**Ülesanne (Toomas Kask, IT Director):** leida ja dokumenteerida andmekvaliteedi defektid müügitabelis enne juhatuse koosolekut. Kristi Tamm (CEO) vajab käibenumbreid, mida saab usaldada.

**Staatus:** defektid on **tuvastatud ja dokumenteeritud**. Andmeid ei ole muudetud ega kustutatud.

> Nädala reegel (`N2_0_1`): sel nädalal defektid tuvastatakse, dokumenteeritakse ja raporteeritakse — kustutamine toimub alles pärast põhjalikku kontrolli ja kontrollmehhanismi paigaldamist.

---

## Protsess

| Samm | Tegevus | Tulemus |
|---|---|---|
| Testkoopia | `sales_test`, tootmistabelit ei puudutatud | 15 234 rida |
| Diagnostika | `GROUP BY` + `HAVING count(*) > 1` | 4 013 korduvat `sale_id` |
| Mastaap | `count(*) − count(DISTINCT sale_id)` | 5 116 üleliigset rida |
| **Homogeensuse kontroll** | `nunique` iga veeru kohta rühma sees | **kordused ei ole identsed** |
| Liigitamine | rühmad viide kategooriasse | 4 333 tõelist duplikaati |
| Dokumenteerimine | raport + soovitused Toomasele | kustutamine ootab ärireeglit |

---

## Peamine leid: viis probleemi ühe sümptomi all

| Kategooria | Rühmi | Ridu | Mis see tegelikult on |
|---|---|---|---|
| A · identsed | 3 239 | 4 051 | topeltimport — võib kustutada |
| B · ainult kuupäevaformaat | 213 | 282 | sama päev — võib kustutada |
| **C · klient on / puudub** | 370 | 517 | puudulik kirje — **ei tohi kustutada** |
| **D · summad vastandmärgiga** | 165 | 234 | müük + tagastus — **ei tohi kustutada** |
| **E · erinevad päevad** | 26 | 32 | eri sündmused — **ei tohi kustutada** |

**Tõelisi duplikaate on 4 333, mitte 5 116.** Ülejäänud 783 rida kuuluvad kolme muu defekti alla ja nende kustutamine hävitaks andmeid.

---

## Juurpõhjus

`sale_id` **ei ole allikas unikaalne võti** — sama väärtus antakse korduvale impordile, tehingu tühistamisele ja eraldi sündmustele.

Korduste vahetu põhjus on topeltimport: kassasüsteem (POS) ja veebipood laadisid samu tehinguid uuesti. Kuna `sale_date` on salvestatud **tekstina** kahes formaadis (`2023-01-16` ISO ja `16/01/2023`), ei tuvastanud süsteem kattuvaid kirjeid sama päevana. Üks defekt tuli välja teise kaudu.

---

## Käive

Ühte õiget arvu veel ei ole — tulemus sõltub sellest, millist rida loetakse originaaliks, ja see on äriotsus. Kolm stsenaariumi ja hajuvus 95 955 € on kirjeldatud raportis.

---

## Artefaktid

| Fail | Sisu |
|---|---|
| [`individual/week2_sales_report.md`](individual/week2_sales_report.md) | **Täielik audit:** viis kategooriat, käibestsenaariumid, eeldused, soovitused |
| [`individual/week2_deduplication.sql`](individual/week2_deduplication.sql) | Korduste tuvastamine ja liigitamine |
| [`individual/week2_null_audit.sql`](individual/week2_null_audit.sql) | Puuduvate ja maskeeritud tühjade väärtuste audit |
| [`individual/week2_esitlus.pdf`](individual/week2_esitlus.pdf) | **Esitlus** (vaadatav brauseris) |
| [`individual/week2_esitlus.pptx`](individual/week2_esitlus.pptx) | Esitluse lähtefail |

---

## Tööriistad

`GROUP BY` + `HAVING`, `count(DISTINCT)`, `ROW_NUMBER() OVER (PARTITION BY … ORDER BY …)`, alampäring, `COALESCE`/`NULLIF`, `TRIM`/`INITCAP`/`LENGTH`, `CASE`, `TO_DATE`/`TO_CHAR`, `CAST`, `UNION ALL`.

---

## Edasi

1. Kokku leppida ärireegel: milline rida on originaal kategoorias C.
2. Otsustada, kuidas tagastused (D) käibes kajastuvad.
3. Muuta `sale_date` tüübist `text` tüübiks `date` skeemi tasemel.
4. Alles seejärel kustutada kategooriad A ja B — testkoopial ja auditilogiga.
