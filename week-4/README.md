# Nädal 4 — SQL agregatsioon

**Ülesanne (Kristi, juhatuse koosolek):** koondada UrbanStyle'i müügi-, kliendi-, lao- ja kanalinumbrid üheks raportiks, millele juhatus saab otsuseid rajada.

**Andmete alus:** kõik summad on arvutatud vaatest `sales_v_puhas` — 10 688 rida, 3 018 967,36 € (topeltread eemaldatud, kaks kuupäevaformaati ühtlustatud). Periood 2023-01 … 2025-02.

**Staatus:** neli rolli (A–D) läbitud, kõik numbrid kontrollitud Supabase'is. Esitlus: [`week4_esitlus.pdf`](individual/week4_esitlus.pdf).

---

## Rollid ja peamised leiud

| Roll | Fookus | Peamine leid |
|---|---|---|
| **A** — Müük ajas | Kas äri kasvab? | 2024 kasvas 2023 suhtes **+18,13%**; kõik 14 kuud kasvasid, detsember 2024 **+34,88%**, aga veebruar 2025 vaid **+2,68%** |
| **B** — Kliendid | Kes toob raha? | 213 VIP-klienti (8% klientidest) toovad **31,41%** käibest; TOP-10 = 8,7%, neist 4 Pärnust |
| **C** — Ladu | Kas laoseis on usaldusväärne? | Laožurnaal kirjutab poe kohta maha ~20 000 tk, müüdud on 1 058–4 008 tk (5–20×) — žurnaal **ei ole seotud müügiga** |
| **D** — Kanalid | Kumb kanal kasvab? | Online **+35,4%**, pood **+10,1%**; kasv tuleb ostude arvust, keskmine ost langes veidi |

---

## Suurim üllatus

Topeltread muudavad summasid, aga peaaegu mitte kasvuprotsenti: käive 4,37 → 3,02 mln €, kasv 16,50% → 18,13%. Vanade raportite **protsentidele võib usaldada, summadele mitte**.

## Soovitus Kristile

1. Esitada juhatusele numbrid ainult `sales_v_puhas` põhjal — vanad summad on ~45% paisutatud.
2. Turunduseelarve kasv suunata online-kanalisse ja nõrkadele kuudele (jaanuar–veebruar), mitte detsembrisse, mis kasvab ise.
3. Enne laotellimuste automatiseerimist siduda laožurnaal kassaga — praegu laoseisu põhjal otsustada ei saa.

## Meil puudusid andmed

- Märts–november 2025 müük puudub (andmed katkevad 2025-02-28).
- Kampaaniate kulud — ROI arvutamiseks.
- Laožurnaali ja müügi seos (dokumendinumber, tellimuse ID).

---

## Artefaktid

| Fail | Sisu |
|---|---|
| [`individual/week4_vaated.sql`](individual/week4_vaated.sql) | **Käivita esimesena** — vaated `sales_v` (kuupäevad) ja `sales_v_puhas` (ilma koopiateta) |
| [`individual/week4_myyk_aggregation.sql`](individual/week4_myyk_aggregation.sql) | Roll A: parimad kuud, kasv sama kuu suhtes aasta tagasi (`LAG(…, 12)`), aasta kasv |
| [`individual/week4_kliendid_aggregation.sql`](individual/week4_kliendid_aggregation.sql) | Roll B: segmendid VIP / püsiklient / juhuslik, TOP-10 klienti |
| [`individual/week4_ladu_aggregation.sql`](individual/week4_ladu_aggregation.sql) | Roll C: Tartu žurnaal liikumistüüpide kaupa, žurnaal vs kassa (kaks CTE-d) |
| [`individual/week4_kanalid_aggregation.sql`](individual/week4_kanalid_aggregation.sql) | Roll D: kanalid aastate kaupa, kasvu jaotus ostude arvuks ja keskmiseks ostuks |
| [`individual/week4_andmekvaliteet.md`](individual/week4_andmekvaliteet.md) | Andmekvaliteedi leiud: kaks kuupäevaformaati, topeltread, andmete katkemine, laožurnaal |
| [`individual/week4_esitlus.pptx`](individual/week4_esitlus.pptx) | **Esitlus** — Kontekst → Rollid A–D → Suurim üllatus → Soovitus Kristile |
| [`individual/week4_esitlus.pdf`](individual/week4_esitlus.pdf) | Esitlus (vaadatav brauseris) |

## Kuidas käivitada

1. Ava Supabase → SQL Editor (andmebaas UrbanStyle, tabelid `sales`, `customers`, `inventory_movements`).
2. Käivita [`week4_vaated.sql`](individual/week4_vaated.sql) — loob vaated `sales_v` ja seejärel `sales_v_puhas`.
3. Käivita ükskõik milline rolli fail; iga päringu all on kommentaarina oodatav tulemus kontrollimiseks.

---

## Tööriistad

`GROUP BY`, `HAVING`, `CASE`, CTE (`WITH`, mitu CTE-d), `CREATE VIEW`, `ROW_NUMBER`, `LAG(…, 12)`, `SUM(SUM(x)) OVER ()`, `COUNT/SUM … FILTER`, `DATE_TRUNC`, `EXTRACT`, `LOWER` JOIN-võtmes.

## Õpitu ja väljakutsed

Raskeim oli `LAG` arvutuses: puudus jagamine, `LAG` ilma `OVER`-ita (viga 42809) ja jagamine sulgude sees andis usutava, aga vale tulemuse. Õppisin, et kasvuprotsent = vahe jagatud **vana** väärtusega ning et ilma vigadeta töötav päring võib ikka anda vale vastuse — numbrid tuleb alati kontrollida.

## AI kasutamine

Kasutasin Claude'i õpetajana: ta koostas ülesannete tekstid ja selgitas vigu (nt 42809, täisarvuline jagamine). Kõik päringud kirjutasin ja käivitasin ise Supabase'is ning kontrollisin numbrid üle; ärijäreldused on minu omad.

## Edasi

1. Kampaaniate tabeli (`promotions`) seos müügiga.
2. Nädal 5–6: visualiseerimine Power BI-s (sülearvutis, novembri lõpus).
