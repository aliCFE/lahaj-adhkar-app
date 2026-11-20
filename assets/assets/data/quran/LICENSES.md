# Quran content & font — sources and licensing

## Quran text
- **Source**: Tanzil Project Uthmani script, served via api.alquran.cloud
  (edition id: `quran-uthmani`).
- **License**: Tanzil's Quran text is published for free use, including
  redistribution inside Quran applications, on the condition that the text
  is not modified. See https://tanzil.net/docs/visit_tanzil for the full
  terms. This is the same text source used by the large majority of
  open-source and commercial Quran apps.
- **Integrity**: fetched once (see `VALIDATION_REPORT.txt` in this folder
  for the automated + manual verification run against the downloaded data),
  stored verbatim in `ayahs.json`/`surahs.json`, and never mutated at
  runtime. Search and display always read the original fetched strings;
  nothing in the app rewrites, paraphrases, or regenerates Quran text.
- **Derived metadata** (page 1–604, juz 1–30, hizb 1–60, quarter-hizb 1–4,
  Meccan/Medinan classification) comes from the same API response
  (`page`, `juz`, `hizbQuarter`, `revelationType` fields), which follows the
  standard Madani Mushaf pagination used across the industry.

## Quran typography
- **Font**: Amiri Quran, by Khaled Hosny / the Amiri project — a distinct
  font family from general-purpose "Amiri," purpose-built for Uthmani
  Mushaf-style Quran display.
- **License**: SIL Open Font License 1.1 — free to use and redistribute,
  including inside applications, with attribution retained in the font
  metadata (handled automatically by the `google_fonts` package, which
  downloads/caches the font from Google Fonts on first use).

## What this means for the app
- No page-image scans of a printed Mushaf are bundled — redistribution
  rights for a specific publisher's page scans could not be verified in
  this session, so the app renders Quran text dynamically from the verified
  Uthmani dataset instead, using the page/juz/hizb boundaries from that same
  verified source (not invented or approximated).
