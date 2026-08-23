# Nädal 1: SQL Basics — UrbanStyle'i andmete uurimine

## Mida ma tegin
- Uurisin sales tabelit SQL päringutega (SELECT, WHERE, ORDER BY, DISTINCT, COUNT)
- Leidsin 5116 korduvat rida (33.6% kõigist ridadest)
- Avastasin negatiivseid müüke (tagastused) ja 1487 NULL customer_id väärtust
- Osalesin meeskonna andmemaastiku koostamisel

## Peamised õpid
- DISTINCT ja COUNT kombinatsioon on võimas tööriist korduste tuvastamiseks
- NULL tähendab "puudu", mitte "null" — seda kontrollitakse IS NULL operaatoriga
- Andmekvaliteedi probleemid (kordused, NULL-id, negatiivsed väärtused) on esimene asi, mida kontrollida

## Failid
- [`individual/week1_sales_exploration.sql`](individual/week1_sales_exploration.sql) — 5 SQL päringut koos kommentaaridega
- [`individual/week1_esitlus.pdf`](individual/week1_esitlus.pdf) — **esitlus** (vaadatav brauseris)
- [`individual/week1_esitlus.pptx`](individual/week1_esitlus.pptx) — esitluse lähtefail
- `individual/photo_*.jpg` — päringute tulemuste ekraanipildid

## Esitluse kokkuvõte
- **Järeldus:** müügitabelit ei saa praegusel kujul aruandluseks kasutada.
- **Otsus:** enne iga käibearuannet tuleb andmed puhastada.
- **Üllatus:** tabelis on tagastusi, mida keegi eraldi ei arvestanud.

## Meeskonna töö
- Data Landscape: iga liige uuris erinevat tabelit
- Koondvaade lisandub pärast grupitööd

## Märkus
Nädalal 1 loeti kõiki 5116 üleliigset rida duplikaatideks. Nädala 2 audit näitas, et
tõelisi duplikaate on 4 333 — vaata [`../week-2/README.md`](../week-2/README.md).
