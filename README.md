# DACA Portfoolio — Nikita Kolenkovski

## Minust
Õpin andmeanalüüsi DACA (Andmeanalüütiku Karjäärikiirendi) programmis.
Fookus: SQL, Python, visualiseerimine ja andmepõhised otsused.

## Eesmärk
Ehitada professionaalne andmeanalüütiku portfoolio, kasutades UrbanStyle.ltd simulatsiooniandmeid.

## Peamised leiud siiani

- **Müügiandmed olid ~45% paisutatud:** 15 234 rida → 10 688 pärast koopiate eemaldamist; käive 4,37 → 3,02 mln € ([nädal 2](week-2/README.md), [nädal 4](week-4/README.md)).
- **Äri kasvab +18,13% aastas**, aga ebaühtlaselt: detsember +34,88%, talvekuud ~+2% ([nädal 4](week-4/README.md)).
- **8% klientidest toob 31% käibest** — 213 VIP-klienti ([nädal 4](week-4/README.md)).
- **Laožurnaal ei ole müügiga seotud** — maha kantakse 5–20× rohkem, kui müüakse ([nädal 4](week-4/README.md)).

## Nädala kaupa

| Nädal | Teema | Staatus | Peamine väljund |
|-------|-------|---------|-----------------|
| 0 | Onboarding | ✅ Tehtud | [Keskkonna seadistus](week-0/README.md) |
| 1 | SQL Basics | ✅ Tehtud | [Müügitabeli uurimine](week-1/README.md): kordused, NULL-id, tagastused |
| 2 | SQL Cleaning | ✅ Tehtud | [Andmekvaliteedi audit](week-2/README.md): 5 116 kordust = 5 eri defekti, tõelisi duplikaate 4 333 |
| 3 | SQL JOINs | ✅ Tehtud | [Mitme tabeli analüüs](week-3/README.md): 18,8% klientidest pole kunagi ostnud, Valga kõige suurema kadumismääraga |
| 4 | SQL Aggregation | ✅ Tehtud | [Koondraport juhatusele](week-4/README.md): CTE, `LAG`, segmendid, kanalite kasv |
| 5-6 | Visualiseerimine | 🔄 Järgmine | Power BI |
| 7-8 | Python | Tulemas | |
| 9-10 | Portfoolio + Karjäär | Tulemas | |

Igas nädala kaustas: SQL failid kommentaaride ja oodatavate tulemustega, README ning esitlus (`.pptx` + `.pdf`).

## Tööriistad
- PostgreSQL / Supabase — `GROUP BY`/`HAVING`, JOIN-id, CTE, vaated, aknafunktsioonid (`ROW_NUMBER`, `LAG`)
- GitHub (Termux git tahvelarvutis)
- Power BI / Python Plotly (nädal 5–6)

## AI kasutamine
Kasutan Claude'i õpetaja ja ülevaatajana: ülesannete koostamine, vigade selgitamine, README teksti viimistlemine. Päringud kirjutan ja käivitan ise ning kontrollin numbrid andmebaasis üle; analüütilised järeldused on minu omad.
