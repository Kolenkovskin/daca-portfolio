# Nädal 3 — SQL JOINid

**Ülesanne (Anna Mets, Marketing Lead + Toomas Kask, IT Director):** UrbanStyle andmed on eri tabelites (sales, customers, products, inventory). Anna vajab vastuseid, mis nõuavad mitme tabeli ühendamist: kes ostab, kes ei osta, mis müüb, mis ei müü, ja millised müügikanalid töötavad.

**Staatus:** kõik neli rolli (A–D) läbitud iseseisvalt, kokku 17 töötavat päringut neljas failis.

---

## Rollid ja peamised leiud

| Roll | Fookus | JOIN tüüp | Peamine leid |
|---|---|---|---|
| **A** — Müük + Kliendid | Kes ostab kõige rohkem? | INNER JOIN | Tallinn toob kõige rohkem käivet, aga Pärnu klient on keskmiselt 36% väärtuslikum |
| **B** — Kadunud kliendid | Kes registreerus, aga ei ostnud? | LEFT JOIN + IS NULL | 592 klienti (18,8%) pole kunagi ostnud; suurima osakaaluga on Valga (25,5%), mitte Tallinn |
| **C** — Tooted + Inventuur | Mis ei müü, mis müüb? | LEFT JOIN | 12 toodet (3,3%) pole kunagi müüdud — ja neist ühelgi pole ka laoandmeid |
| **D** — Müügikanalid | Milline kanal toimib? | INNER JOIN, 3 tabelit | Pood toob 41% rohkem käivet kliendi kohta, aga keskmine ostukorv on kanalites peaaegu ühesugune |

---

## Suurim üllatus

Rollide C ja rollide varasem leid (12 toodet ilma müügita) said täna teise seletuse. Nende toodete jaoks pole **ühtegi kirjet inventuuris** — need ei ole "seisma jäänud laovaru", vaid tooted, mida pole füüsiliselt kunagi lattu vastu võetud. Probleem pole hinnas ega nõudluses, vaid protsessis: tootekaart luuakse süsteemi enne, kui ladu selle üldse registreerib.

## Soovitus Annale

1. **Valga, mitte Tallinn** on kõige suurema kadumismääraga linn (25,5%) — sinna suunata kohalik win-back kampaania, mitte suurimasse linna.
2. **Turunduseelarve ostukorvi suurendamise asemel külastussagedusele** — kanalite keskmine ostusumma erineb vaid 3%, aga käive kliendi kohta erineb 41%. Kordusostude sagedus, mitte korvi suurus, otsustab kanali väärtuse.
3. **Enne VIP-kampaaniat täita loyalty_tier lüngad** — suurim "lojaalsusrühm" käibe järgi on tegelikult "andmed puuduvad" (1,63 mln €), mitte gold/silver/bronze.

## Meil puudusid andmed

- Miks kliendid lõpetasid ostmise (rahulolu, hind, konkurent?) — meil on ainult fakt "ei ostnud", mitte põhjus.
- Miks 12 toote jaoks inventuuri kirjet pole tehtud — kas see on protsessiviga tooteloomes või teadlik otsus.
- Kampaaniate maksumus kanaliti, et arvutada tegelik ROI, mitte ainult käivet.

---

## Artefaktid

| Fail | Sisu |
|---|---|
| [`individual/week3_roll_a_myyk_kliendid.sql`](individual/week3_roll_a_myyk_kliendid.sql) | TOP-10 klienti, käive linnade ja lojaalsustasemete kaupa, üle keskmise kulutajad (alampäring) |
| [`individual/week3_roll_b_kadunud_kliendid.sql`](individual/week3_roll_b_kadunud_kliendid.sql) | Antiliitmine (anti-JOIN), kadumismäär linnade kaupa, dünaamika registreerimiskuu järgi |
| [`individual/week3_roll_c_tooted_inventuur.sql`](individual/week3_roll_c_tooted_inventuur.sql) | Müümata tooted, TOP-10 müüdumad, kategooriate võrdlus, 3 tabeli JOIN inventuuriga |
| [`individual/week3_roll_d_muugikanalid.sql`](individual/week3_roll_d_muugikanalid.sql) | Kanalite ülevaade, kanal × linn, kanal × kategooria (3 tabelit), käive kliendi kohta |

---

## Tööriistad

`INNER JOIN`, `LEFT JOIN`, anti-JOIN (`LEFT JOIN` + `WHERE ... IS NULL`), 3 tabeli JOIN, alampäring (`FROM (SELECT ...) t`, `HAVING ... > (SELECT AVG(...))`), `COUNT(DISTINCT)`, `COUNT(*) FILTER (WHERE ...)`, `DATE_TRUNC`, `COALESCE`, `TRIM`/`INITCAP`, aliased tabelid.

## Edasi

1. Uurida, miks 12 toote jaoks inventuuri kirjet pole — kas viga tooteloome protsessis.
2. Täita loyalty_tier lüngad enne segmenteeritud kampaaniate käivitamist.
3. Nädal 4: SQL agregatsioon — GROUP BY, HAVING, CTE-d, window functions.
