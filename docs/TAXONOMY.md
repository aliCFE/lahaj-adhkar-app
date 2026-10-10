# Adhkar App — Content Taxonomy & Architecture Proposal

Status: **proposal for review — no code written yet.**
Primary source for MVP content: *Hisn al-Muslim* ("Fortress of the Muslim") by Sa'id bin Ali bin Wahf Al-Qahtani — a widely published, scholar-reviewed compilation that cites Qur'an and hadith (Bukhari, Muslim, Abu Dawud, Tirmidhi, Nasa'i, Ibn Majah, Ahmad) for essentially every entry, cross-checked against general knowledge of these hadith. Where I am not fully confident of an exact wording, hadith number, or grading, the item is marked `needs-review` rather than guessed — per your instruction, accuracy outranks completeness.

---

## 1–3. Main Sections, Subsections, Expected Counts

Two-level hierarchy. Level 1 = the ~10 groups shown in "أذكار حسب الموقف". Level 2 = subcategories inside each. Counts are realistic estimates for *authentic, confidently-sourceable* items — not padded.

| # | Level 1 (Group) | Level 2 (Subcategories) | Est. items | MVP? |
|---|---|---|---|---|
| 1 | **اليوم — اليوميات العامة** | أذكار الصباح · أذكار المساء · أذكار بعد الصلاة · الاستغفار · التسبيح/التهليل/التحميد/التكبير (general) | 18 + 17 + 12 + 5 + 6 ≈ **58** | ✅ |
| 2 | **النوم** | قبل النوم (آية الكرسي، خواتيم البقرة، المعوذات×3، تسبيح فاطمة، دعاء النوم) · الاستيقاظ · التقلب بالليل · الفزع من النوم · رؤية ما يكره/يحب في المنام | **14** | ✅ |
| 3 | **الحياة اليومية** | دخول المنزل/الخروج منه · دخول الخلاء/الخروج منه · الطعام (قبل/بعد/نسيان البسملة) · الشراب · اللباس (اللبس/الخلع) · الضيف (للضيف/من الضيف) | **16** | ✅ |
| 4 | **الصلاة والمسجد** | الذهاب إلى المسجد · دخول المسجد/الخروج منه · أذكار متصلة بالصلاة لم تُذكر في "بعد الصلاة" (الأذان وإجابته، سجود السهو لا يُدرج كفقه) | **8** | ✅ |
| 5 | **السفر** | دعاء الركوب/السفر · النزول في مكان · دخول بلدة · الرجوع من السفر | **7** | ✅ |
| 6 | **التحصين والحماية** | المعوذتان وآية الكرسي (مرجع متكرر) · الخوف · العين والحسد (الثابت فقط) · الوسوسة · آخر آيتين من البقرة (مرجع متكرر لقسم النوم) | **9** | ✅ |
| 7 | **الهمّ والكرب والتوكل** | دعاء يونس عليه السلام · "حسبنا الله ونعم الوكيل" · دعاء الكرب النبوي · التوكل على الله | **7** | ✅ |
| 8 | **الاستغفار والتوبة** | سيد الاستغفار · صيغ الاستغفار الثابتة · أدعية التوبة القرآنية (ربنا ظلمنا أنفسنا، ربنا آتنا) | **6** | ✅ (cross-linked from §1) |
| 9 | **الشكر والحمد** | الحمد عند النعمة · الحمد في كل حال · عند رؤية ما يُحمد | **4** | ✅ |
| 10 | **الصحة والمرض** | دعاء زيارة المريض · الرقية الشرعية الثابتة (الفاتحة، آية الكرسي، المعوذات) · دعاء طلب العافية · دعاء الألم (وضع اليد وقول...) | **7** | ✅ |
| 11 | **المناسبات الاجتماعية** | العطاس (الحامد والمُشمِّت) · السلام · الدعاء لمن أحسن إليك · الغضب (الاستعاذة، الجلوس/الاتكاء، الوضوء بدليله) · عند سماع ما يسر/يكره | **8** | ✅ |
| 12 | **مناسبات الحياة** | الاستخارة (كاملة) · دعاء للمتزوجين (بارك الله لك) · عند فقد شيء (لا يوجد دعاء خاص ثابت لكل حالة — سيتم استثناء الصيغ غير الموثقة) | **4** | ✅ |
| 13 | **الطقس والظواهر الطبيعية** | المطر (عند نزوله وبعده) · الرعد · الريح · رؤية الهلال · الكسوف والخسوف (الذكر فقط، دون تفاصيل فقهية لصلاة الكسوف) | **6** | ✅ |
| 14 | **التعزية وذكر الآخرة** *(معاملة بحذر)* | دعاء المصاب ("إنا لله وإنا إليه راجعون" وتمامه) · الدعاء للميت (الصيغة العامة الثابتة) · دعاء زيارة القبور | **3** | ⚠️ optional at launch — see note below |
| 15 | **رمضان والصيام** *(بنية جاهزة، محتوى لاحق)* | دعاء الإفطار · ليلة القدر · الاعتكاف | 0 now | 🔜 Future module |
| 16 | **الحج والعمرة** *(بنية جاهزة، محتوى لاحق)* | التلبية · الطواف · السعي · المشاعر | 0 now | 🔜 Future module |

**Total MVP items: ≈ 150–165 authentic adhkar**, exactly in the range you asked for ("better 150 highly reliable than 500 questionable"). Sections 15–16 ship as empty, fully-modeled categories (schema supports them, UI can show "قريبًا") so no placeholder/fake content is ever shown as real.

Note on §14: it's short, respectful, and not alarming by design (your own requirement). If you'd rather hold it for a v1.1 release to keep the MVP tighter, that's a one-line config flag, not a rebuild — your call, not mine to assume.

---

## 4. MVP vs. Future Modules — summary

**MVP (ship v1):** §1–14 above (~150–165 items), full search, favorites, repetition engine, progress tracking, "ماذا تفعل الآن" situational picker, content-review screen (dev-only).

**Future modules (data model supports them, content added later under the same review process):** Ramadan/fasting adhkar, Hajj/Umrah adhkar, and potentially a "children's adhkar" sub-track (only if/when each item clears the same authenticity bar — not assumed authentic just because it's popular for kids).

---

## 5. Repetition patterns actually present in the MVP set

| Pattern | Example | Handling |
|---|---|---|
| 1× | Most du'as (e.g. دعاء الاستيقاظ) | Single "complete" tap |
| 3× | المعوذات قبل النوم، "أعوذ بكلمات الله التامات" | Counter 1/3 → 3/3 |
| 7× | "حسبي الله لا إله إلا هو" (بعض الروايات) | Counter 1/7 → 7/7, source note on variant |
| 10× | بعض صيغ التهليل/التسبيح المسائية | Counter |
| 33× / 33× / 34× | تسبيح فاطمة (قبل النوم) وتسبيح بعد الصلاة | Three linked counters that sum to 100 |
| 100× | "لا إله إلا الله وحده لا شريك له" (ضحى) — يُستثنى إن لم يثبت وقته هنا | Counter with milestone ticks every 10 |
| Variable/open | الاستغفار العام، الصلاة على النبي ﷺ خارج سياق محدد | No forced counter — free tally, user can tap indefinitely, counter still shown |

The repetition engine is generic (`currentCount / totalCount`, `remaining = total - current`) — not hardcoded per dhikr — so any future item with any count fits without new code.

---

## 6. Source / reference data structure

```ts
interface Source {
  sourceName: string;        // "صحيح البخاري", "صحيح مسلم", "حصن المسلم" (compiler, when primary hadith source is the compiled one)
  collection?: string;       // e.g. "كتاب الدعوات"
  hadithNumber?: string;     // only filled when confidently known — never invented
  narrator?: string;         // الراوي، إن ثبت
  authenticity:
    | "qaraan"               // Qur'anic text — not graded, cited by surah:ayah
    | "sahih"
    | "hasan"
    | "sahih_or_hasan_scholarly_disagreement"
    | "da'if_excluded"       // kept only in the dev review log, never shown to users
  sourceUrl?: string;        // only real, verifiable URLs (e.g. sunnah.com permalinks) — never fabricated
  notes?: string;            // e.g. "وردت بروايتين متقاربتين، أُدرجت الأشهر"
  reviewStatus: "verified" | "needs_review" | "excluded";
}

interface DhikrItem {
  id: string;
  categoryId: string;        // level-2 subcategory
  arabicText: string;        // full diacritized text
  transliteration?: string;
  translation?: string;      // plain, non-interpretive
  repeatCount: { type: "fixed"; n: number } | { type: "range"; min: number; max: number } | { type: "open" };
  occasion: string;          // short Arabic description
  situationTags: string[];   // for search + "ماذا تفعل الآن" (e.g. ["نوم","خوف من المنام"])
  source: Source[];          // array — some items have more than one supporting reference
  isRuqyah?: boolean;
  medicalDisclaimer?: boolean; // true for health-section items — surfaces the "not a medical substitute" note
}
```

Anything I can't confidently verify (exact hadith number, a disputed wording) is stored with `reviewStatus: "needs_review"` and is **excluded from the live app** until a human (you, or a qualified reviewer) confirms it in the content-review screen. Nothing with `da'if_excluded` or `needs_review` ever reaches end users.

---

## 7. Content review process

1. I draft each item from Hisn al-Muslim / direct Qur'anic text, with source fields filled as far as I can confidently verify.
2. Anything uncertain (wording variant, exact number, grading dispute) → flagged `needs_review`, excluded from production data, visible only in the dev **Content Review screen**.
3. The Content Review screen (dev-only, not in the shipped user-facing nav) lists: all items, by category, with source, authenticity, repetition, Arabic text, and flags for missing references or near-duplicate entries (e.g. morning/evening pairs that are intentionally similar vs. accidental dupes).
4. You (or anyone you designate) does a pass over `needs_review` items before they're promoted to `verified`. I will not unilaterally "promote" an item just to pad a category.
5. Scholarly-variance items (e.g. differing authentic wordings of the same du'a) are stored as siblings, both marked authentic, with a neutral note — not resolved into a single "correct" answer.

---

## 8. Navigation model (so 150+ items never feel like 150+ items)

- **Home:** "ماذا تريد أن تقرأ؟" + 5 one-tap shortcuts (الصباح / المساء / النوم / بعد الصلاة / التسبيح) + "أذكار حسب الموقف" (the 10 groups from the table above, not all 16 subcategory levels at once).
- **"ماذا تفعل الآن؟"**: optional situational picker (أنا ذاهب للنوم، استيقظت، ذاهب للصلاة، …) → jumps straight to the matching group/category. Off by default toggle not required — it's just an alternate entry point alongside the grid, not a forced flow.
- **"كل الأذكار"**: full browsable + searchable library with filters (category, favorites, recently used, repetition type), for when a user wants to explore rather than be guided.
- **Search**: local, offline (on-device index over Arabic text, situationTags, and category names) — typing "نوم" surfaces أذكار النوم + آية الكرسي + أذكار الاستيقاظ + الفزع من النوم, because all of those carry the `نوم`-family situationTags, not because of fuzzy text matching alone.
- Deepest path to the most common content (الصباح/المساء/بعد الصلاة) is **2 taps**: Home → shortcut.

---

## Platform & store-approval notes

- Cross-platform target: React Native (Expo), single codebase for iOS + Android.
- Content and favorites/progress stored **locally on-device** (SQLite or a local JSON store) — no server, no tracking of religious usage, satisfying your own "keep this local" requirement and simplifying App Store/Play privacy review (no account required, minimal/no analytics).
- No donation/payment flows, no political or sectarian framing, no unverified "miracle cure" language in the health section (explicit non-medical disclaimer instead) — these are exactly the things that cause App Store religious-app rejections, so avoiding them is a design decision, not an afterthought.
- A short privacy policy and an "About / Sources" screen (naming Hisn al-Muslim and the hadith collections cited) will be included — stores expect this for any app presenting religious/reference content.

---

## What I need from you before I start building

Nothing blocking — I can proceed directly to scaffolding the app and populating the verified MVP dataset against this structure. Flag now if you want: (a) §14 (تعزية) deferred to v1.1, (b) a different app name, or (c) Expo/React Native confirmed vs. a native stack per platform — otherwise I'll proceed with the plan above.
