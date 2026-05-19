# Field Test Results — MedicalSnap OCR Robustness Study

**Generated:** 2026-05-19  
**Data source:** `data/field_test_data_rows.csv`  
**Study period:** 2025-12-14 – 2025-12-17

---

## Summary

| Metric | Value |
|---|---|
| Total scans | 42 |
| Unique products | 39 |
| Study period | 2025-12-14 → 2025-12-17 |
| Scans with risk substances detected | 35 (83.3%) |
| Scans with no risk substances | 7 (16.7%) |
| Manually verified | 40 / 42 |

---

## Detected Substances (Frequency)

| Substance | Detections | % of all scans |
|---|---|---|
| PHOSPHAT/SÄURE | 20 | 47.6% |
| KALIUM | 18 | 42.9% |
| NATRIUMNITRIT | 6 | 14.3% |
| GESCHMACKSVERSTÄRKER | 2 | 4.8% |
| E341 | 1 | 2.4% |
| E450 (Diphosphat) | 1 | 2.4% |

---

## Packaging Types Tested

| Material | Count | % |
|---|---|---|
| Kunststoff | 22 | 52.4% |
| Verbundstoffe | 10 | 23.8% |
| Metall | 5 | 11.9% |
| Pappe/Papier | 4 | 9.5% |
| Glas | 1 | 2.4% |

---

## Researcher Notes (Selected)

The following entries include manual field notes documenting OCR edge cases:

**Maggi 5 Minuten Terrine Gulasch Topf**  
> V.1.0 Beim niedrige Lichtquelle (nur Monitor) hat das App nicht die Schlüsselwörter gefunden. Problemstelle gefunden: kalumjodat statt Kaliumjodat Grund: Es ist eine Rundigen Becher und die Wöter war genau auf dem Kurven gedruckt und deswegen war die wörter ausgebreiten. OCR hat den lagen "li" z...

**7Days croissant with cocoa filling**  
> V1.1 Tageslichtbedingung gemacht mit Reflex

**Demae Ramen Sesam **  
> V1.0  Bei Tageslicht Bedinung und mit reflexen gefunden

**Natsu Onigiri Lachs Edamame**  
> V1.1 Tageslichtbedingung.   Zutatenlisten war auf dem Papier geklebt. In Rewe.

**Qualitäts Metzgerei Wilhelm Brandenburg**  
> V1.1 Tageslichtbedingung.  In Rewe.

**REWE Beste Wahl Mini-Bites**  
> V1.1 Tageslichtbedingung.  Zutatenlisten war auf dem Papier. In Rewe.

**Redbull Dosen 250ml**  
> V1.1 Tageslichtbedingung. Keine Meldung bei Redbull, weil Redbull benutzt Citronensäure als Säuerungsmittel, nicht wie Coca Cola die benutzten Phosphorsäure als Säuerungsmittel.  Korrekterweise als frei von Zusatzstoffen gekennzeichnet. Und Bei Säureregulatoren benutzt Redbull, Natriumcarbonate u...

**Coca Cola 0,5l Pfandflasche**  
> V1.0 Bei Tageslicht bedinung gemacht.  Mit ne leichtes Reflex

**Tuc Cracker Paprika**  
> V1.1 Tageslichtbedingung.  Mit Reflexen und Klein Langgezogene Wörter In Rewe.

**Tulip Corned Beef**  
> V1.1 Tageslichtbedingung.  In Rewe

---

## Files

| File | Description |
|---|---|
| `data/field_test_data_rows.csv` | Raw export from Supabase `field_test_data` table |
| `data/RESULTS.md` | This analysis report |

---

*Data collected for research purposes only. Not for medical use. See [Disclaimer](../README.md#%EF%B8%8F-medical-disclaimer).*
