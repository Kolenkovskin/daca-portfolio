# Week 1 — Data Landscape (Meeskonna koondvaade)

## Meeskond: Tooteanalüüsi osakond (Product Analytics)

### Tabelite ülevaade

| Tabel | Uurija | Ridade arv | Peamine leid |
|-------|--------|------------|--------------|
| sales | Nikita | 15 234 | 5116 duplikaati (34%), negatiivsed väärtused (tagastused), 1487 NULL customer_id |
| customers | — | 3 150 | Täpsustamisel |
| products | — | 362 | Täpsustamisel |
| stores | — | — | Täpsustamisel |
| inventory | Kevin | 1 400 | Täpsustamisel |

### Sünteesiküsimused
1. **Suurim üllatus:** 34% müükidest on ilma kaupluse asukohata (NULL store_location)
2. **Soovitus Toomasele:** Enne aruandlust tuleb eemaldada duplikaadid ja uurida NULL väärtusi
3. **Puuduvad andmed:** Tagastuste põhjused, eraldi stores tabel puudub andmebaasist
