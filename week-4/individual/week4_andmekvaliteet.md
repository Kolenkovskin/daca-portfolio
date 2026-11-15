# Nädal 4 — Andmekvaliteedi leiud

Enne agregeerimist tuli kontrollida, kas numbrid üldse kehtivad. Leidsin neli probleemi; kõik nädala 4 summad on arvutatud alles pärast nende lahendamist (vaated failis [`week4_vaated.sql`](week4_vaated.sql)).

## 1. Kaks kuupäevaformaati (Toomasele)

- `sales.sale_date` on tekst, mitte kuupäev: **14 777** rida formaadis `AAAA-KK-PP` ja **457** rida formaadis `PP/KK/AAAA`.
- Vale formaat jaotub ühtlaselt kõigi müügikohtade vahel (Tartu 3,43%, Pärnu 3,15%, Tallinn 2,95%, online 2,79%; χ² ≈ 2,7 < 7,81 vabadusastmetel 3) — viga ei ole ühes kassas, vaid ühises andmete laadimise teekonnas.
- 262 kaldkriipsuga reast 457-st on ISO-formaadis „kaksik“ sama `sale_id`-ga.
- **Lahendus:** vaade `sales_v` — `CASE` + `LIKE`-mask valib `TO_DATE` formaadi. Kontroll: 15 234 / 15 234 rida, periood 2023-01-01 … 2026-06-28.

## 2. Topeltread

- Täpselt sama müük (kõik 8 äriveergu ühesugused) esineb mitu korda.
- **Lahendus:** vaade `sales_v_puhas` — `ROW_NUMBER() OVER (PARTITION BY …)` ja `nr = 1`.
- Tulemus: 15 234 → **10 688** rida; käive 4 374 231,27 € → **3 018 967,36 €**. Eemaldatud 4 546 koopiat = 4 333 (nädala 2 kategooriad A+B, kattus rea pealt) + 213 täpset koopiat segagruppides.
- Vanad summad olid **~45% paisutatud**, kasvuprotsent aga muutus vähe (2024/2023: 16,50% → 18,13%).

## 3. Andmed katkevad 2025-02-28

- Märts–november 2025 müüki pole üldse; pärast 28.02.2025 on vaid **50** juhuslikku rida (0,33% müükidest, 13 622,36 €) 33 erineva kuu peale.
- Puuduv kuu ei anna rida nulliga — seda lihtsalt pole; see paistab välja ainult ridu loendades.
- **Lahendus:** kõik ajaanalüüsid kuni `2025-02-28`. Müük ei langenud — katkes eksport.

## 4. Laožurnaal ei ole müügiga seotud (Liisile)

- Žurnaal kannab igas poes maha ~20 000 tk, kassa järgi müüdi 1 058 (Pärnu), 1 939 (Tartu) ja 4 008 (Tallinn) tk — vahe 5–20 korda.
- Lisaks erinevad asukohanimed registri poolest (`tartu` vs `Tartu`) — JOIN vajab `LOWER()`-it.
- **Järeldus:** laoseisu põhjal tellimusi automatiseerida ei saa, enne tuleb žurnaal siduda kassaga (tšeki või tellimuse number).

## Mis jäi kontrollimata

- Kliendi ID puudub umbes 10% müükidest (külalisostud) — osakaal on aastate ja poodide lõikes stabiilne (~90% leitud), seega segmentides on need lihtsalt välja jäetud.
- Kampaaniate tabel (`promotions`, 120 rida) — seos müügiga jääb järgmistesse nädalatesse.
