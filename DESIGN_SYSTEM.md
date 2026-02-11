# Wamo Design & UI/UX System

**Last Updated:** February 4, 2026  
**Version:** 1.0 (MVP)

---

## Design Philosophy

**Calm. Human. Trustworthy.**

Wamo is often used in **stressful moments** (medical bills, emergencies).
The design must **reduce anxiety**, not amplify it.

### Key Principles

* Minimal, not empty
* Warm, not loud
* Clear, not clever
* Human-first, fintech-second

---

## Core Visual Style

### Overall Look & Feel

* Light background (mostly white)
* Rounded components (soft edges)
* Gentle spacing and breathing room
* No sharp dividers; use spacing instead
* Subtle elevation (very light shadows)

Think: *helpful*, not *corporate*.

---

## Colour Palette

### Primary Colours

#### **Wamo Teal (Primary)**

* Use for: main CTAs, progress bars, links
* Meaning: trust, calm, reliability
* Emotional effect: reassures users

**Example usage:**
* "Start a Fundraiser" button
* Donation confirmation highlights
* Progress indicators

---

#### **Wamo Orange (Secondary)**

* Use for: accents, highlights, icons
* Meaning: warmth, human connection, help
* Emotional effect: encouragement, optimism

**Example usage:**
* Icons (hands, heart)
* Success states
* Small emphasis text

---

### Neutral Colours

#### **Soft White / Off-White**

* Primary background
* Reduces eye strain
* Feels open and non-threatening

#### **Warm Grey (Text)**

* Primary body text
* Avoid pure black (too harsh)
* Improves readability on low-end screens

---

### Status Colours (Use Sparingly)

#### **Success (Soft Green)**

* Donation success
* Verification approved
* Payout completed

#### **Warning (Amber)**

* Verification pending
* Action needed
* Network delays

#### **Error (Muted Red)**

* Payment failed
* Verification rejected
* Never bright red

---

## Colour Usage Rules (Non-Negotiable)

* One primary colour per screen
* Never use more than **2 accent colours** at once
* Red only for real errors
* No **decorative** gradients in MVP UI
  - A single **subtle background tint transition** is allowed (2-stop, low contrast)
  - Example: `#FFFFFF → #F7F9FB`
* Colour must never be the only indicator (always pair with text/icons)

---

## Typography

### Font Style

* Rounded, modern sans-serif
* Friendly but professional
* Good readability at small sizes

**Font personality:**
* Headings: confident
* Body text: calm
* Buttons: clear, action-oriented

**Avoid:**
❌ Condensed fonts
❌ Script fonts
❌ All-caps body text

### Approved Fonts (Pick One for MVP)
**Primary (Recommended):** Manrope  
**Alternates:** Plus Jakarta Sans, Sora  
Use only one family in MVP to keep UI consistent.

### Type Scale (MVP)
| Style    | Size | Weight | Line Height | Usage                        | Flutter (Material 3) |
| -------- | ---- | ------ | ----------- | ---------------------------- | -------------------- |
| Display  | 28   | 700    | 36          | Screen headers               | `displaySmall`       |
| Title    | 22   | 700    | 28          | Section titles               | `titleLarge`         |
| Subtitle | 18   | 600    | 24          | Card titles, highlights      | `titleMedium`        |
| Body     | 16   | 400    | 24          | Default text                 | `bodyLarge`          |
| Small    | 14   | 400    | 20          | Secondary text, helper copy  | `bodyMedium`         |
| Caption  | 12   | 500    | 16          | Labels, metadata, timestamps | `labelSmall`         |

---

## Button Design

### Primary Button

* Teal background
* White text
* Rounded corners
* Full-width on mobile
* Clear action verbs

**Example:**
> **Start a Fundraiser**

---

### Secondary Button

* White background
* Teal outline
* Teal text

**Used for:**
* "Explore campaigns"
* "Post update"

---

## Inputs & Form Fields (MVP)

* Input height: **52–56px**
* Label above field, helper text below
* Left padding: `space.md`
* Border: `color.border.light`
* Focus state: `color.border.focus`
* Error state: `color.brand.error` + helper text

---

## Layout & Hierarchy Rules

* One primary CTA per screen
* Section headers: **Title** style
* Body text: **Body** style
* Use `space.lg` between sections
* Use `space.md` within cards/sections
* Avoid more than 2 text sizes in a single card

---

## Component Specs (MVP)

These are the default component rules. If a screen needs something different, it must be justified (trust, accessibility, or platform requirement).

### AppBar

* Background: `color.bg.primary` (light) / `color.bg.primary.dark` (dark)
* Elevation: none (prefer a divider or spacing)
* Title style: **Title** (`titleLarge`)
* Actions: max 2 icons; use simple line icons
* Back button: always visible when navigable

### Bottom Navigation

* Max items: 3–5
* Icon style: outlined/rounded; consistent stroke weight
* Selected color: `color.brand.primary`
* Unselected color: `color.text.muted`
* Labels: sentence case, short (1 word)
* Badges: use small dot or count (never oversized)

### Chips & Badges

* Purpose: filters, tags, status indicators
* Height: ~32px; padding: `space.sm` horizontal
* Radius: `radius.full`
* Default chip background: `color.bg.secondary`
* Selected chip background: `color.brand.primary` (text: `color.text.inverse`)
* Status badge colors:
  - Success: `color.brand.success`
  - Warning: `color.brand.warning`
  - Error: `color.brand.error` (errors only)
* Never rely on color alone—pair with icon/text (e.g., “Verified”, “Pending”)

### Toasts / Snackbars

* Use for: confirmations, short errors, offline notices
* Duration: 3–4s (errors can be 4–6s)
* One action max (e.g., “Retry”)
* Colors:
  - Success: `color.brand.success`
  - Warning: `color.brand.warning`
  - Error: `color.brand.error`
* Copy rule: be direct and calm (no blame, no jargon)

### Empty States

* Always include:
  - Clear title (what’s missing)
  - One-sentence explanation
  - Primary CTA (what to do next)
* Visuals: optional icon (simple), no heavy illustration in MVP
* Example CTAs:
  - “Explore campaigns”
  - “Start a fundraiser”
  - “Post an update”

---

## Depth & Background Treatment

* Subtle depth only: `shadow.sm` for cards
* Background rule:
  - Default: flat backgrounds (`color.bg.primary`, `color.bg.secondary`)
  - Optional: one subtle **tint transition** per screen (2-stop only, low contrast)
* Do not use loud gradients, strong vignette effects, or heavy shadows

---

## Progress & Trust Indicators

### Progress Bar

* Teal fill
* Soft grey background
* Rounded ends
* Percentage text visible

### Verified Badge

* Small
* Green accent
* Simple check icon
* Never oversized or flashy

---

## Cards & Containers

* White cards on off-white background
* Light shadow or thin border
* Rounded corners
* Clear internal spacing

**Used for:**
* Campaign summaries
* Donation cards
* Updates

---

## Iconography

* Simple line icons
* Rounded strokes
* Consistent stroke width
* Avoid complex illustrations in MVP

Icons should support meaning, not decorate.

---

## Motion & Animation

* Subtle only
* No bouncing or flashy transitions
* Use fade-in or slide-up gently
* Loading indicators should be calm

Remember: stressed users hate jittery UI.

---

## Accessibility & Practicality

* High contrast text
* Large tap targets
* Works on small screens
* Legible in sunlight
* Color-blind safe combinations

---

## One Sentence Design Rule

> **Wamo should feel like a calm, reliable person helping you — not an app trying to impress you.**

---

# Design Tokens (Light Mode)

## 1. Color Tokens

### Brand Colors

| Token Name              | Hex       | Usage                                     |
| ----------------------- | --------- | ----------------------------------------- |
| `color.brand.primary`   | `#2FA4A9` | Primary CTA buttons, progress bars, links |
| `color.brand.secondary` | `#F39C3D` | Accents, icons, highlights                |
| `color.brand.success`   | `#3CB371` | Success states, verified badge            |
| `color.brand.warning`   | `#F2B705` | Pending states, alerts                    |
| `color.brand.error`     | `#D9534F` | Errors only (muted, never loud)           |

---

### Background & Surface

| Token Name               | Hex       | Usage               |
| ------------------------ | --------- | ------------------- |
| `color.bg.primary`       | `#FFFFFF` | Main app background |
| `color.bg.secondary`     | `#F7F9FB` | Section backgrounds |
| `color.surface.card`     | `#FFFFFF` | Cards, containers   |
| `color.surface.disabled` | `#E9ECEF` | Disabled states     |

---

### Text Colors

| Token Name             | Hex       | Usage                   |
| ---------------------- | --------- | ----------------------- |
| `color.text.primary`   | `#1F2933` | Headings                |
| `color.text.secondary` | `#4B5563` | Body text               |
| `color.text.muted`     | `#9CA3AF` | Helper text, labels     |
| `color.text.inverse`   | `#FFFFFF` | Text on primary buttons |

---

### Borders & Dividers

| Token Name           | Hex       | Usage                |
| -------------------- | --------- | -------------------- |
| `color.border.light` | `#E5E7EB` | Card borders, inputs |
| `color.border.focus` | `#2FA4A9` | Focused inputs       |

---

## 2. Spacing Tokens (8-point system)

> Use multiples of **8** for consistency and scalability.

| Token Name  | Value (px) | Usage            |
| ----------- | ---------- | ---------------- |
| `space.xs`  | 4          | Icon padding     |
| `space.sm`  | 8          | Tight spacing    |
| `space.md`  | 16         | Default padding  |
| `space.lg`  | 24         | Section spacing  |
| `space.xl`  | 32         | Large separation |
| `space.2xl` | 40         | Page padding     |

---

## 3. Radius Tokens (Rounded & friendly)

| Token Name    | Radius (px) | Usage           |
| ------------- | ----------- | --------------- |
| `radius.xs`   | 4           | Small elements  |
| `radius.sm`   | 8           | Inputs, chips   |
| `radius.md`   | 12          | Cards           |
| `radius.lg`   | 16          | Buttons         |
| `radius.xl`   | 24          | Modals / sheets |
| `radius.full` | 999         | Pills, avatars  |

---

## 4. Elevation / Shadow Tokens (Very subtle)

| Token Name    | Shadow                       |
| ------------- | ---------------------------- |
| `shadow.none` | none                         |
| `shadow.sm`   | `0 1px 2px rgba(0,0,0,0.05)` |
| `shadow.md`   | `0 4px 8px rgba(0,0,0,0.06)` |

> Use shadows sparingly. Prefer spacing over elevation.

---

## 5. Component Defaults

### Primary Button

| Property   | Token                                      |
| ---------- | ------------------------------------------ |
| Background | `color.brand.primary`                      |
| Text color | `color.text.inverse`                       |
| Radius     | `radius.lg`                                |
| Padding    | `space.md` vertical, `space.lg` horizontal |

---

### Card

| Property   | Token                |
| ---------- | -------------------- |
| Background | `color.surface.card` |
| Radius     | `radius.md`          |
| Padding    | `space.md`           |
| Border     | `color.border.light` |

---

### Progress Bar

| Property | Token                    |
| -------- | ------------------------ |
| Track    | `color.surface.disabled` |
| Fill     | `color.brand.primary`    |
| Radius   | `radius.full`            |

---

## 6. Accessibility Rules (Built into tokens)

* Text contrast ≥ WCAG AA
* Never rely on color alone for meaning
* Buttons minimum height: **48px**
* Tap targets ≥ **44px**

---

## 7. One-line System Rule

> **If a new UI element can't be built using these tokens, it doesn't belong in Wamo.**

---

# Dark Mode Design Tokens

## Dark Mode Philosophy

* Reduce eye strain
* Maintain emotional warmth
* Preserve trust cues
* Avoid pure black backgrounds
* Keep brand colors recognizable

> Dark mode is not inverted light mode — it is *rebalanced*.

---

## 1. Background & Surface (Dark)

| Token Name                    | Hex       | Usage               |
| ----------------------------- | --------- | ------------------- |
| `color.bg.primary.dark`       | `#0F172A` | Main app background |
| `color.bg.secondary.dark`     | `#111827` | Section backgrounds |
| `color.surface.card.dark`     | `#1F2933` | Cards, containers   |
| `color.surface.disabled.dark` | `#374151` | Disabled states     |

---

## 2. Brand Colors (Dark-Adjusted)

> Brand colors are slightly softened for dark surfaces.

| Token Name                   | Hex       | Usage                       |
| ---------------------------- | --------- | --------------------------- |
| `color.brand.primary.dark`   | `#3FBFC4` | Primary CTAs, progress bars |
| `color.brand.secondary.dark` | `#F6B15A` | Accents, icons              |
| `color.brand.success.dark`   | `#4FD1A5` | Success states              |
| `color.brand.warning.dark`   | `#FACC15` | Pending / alerts            |
| `color.brand.error.dark`     | `#F87171` | Errors (muted)              |

---

## 3. Text Colors (Dark)

| Token Name                  | Hex       | Usage                  |
| --------------------------- | --------- | ---------------------- |
| `color.text.primary.dark`   | `#F9FAFB` | Headings               |
| `color.text.secondary.dark` | `#D1D5DB` | Body text              |
| `color.text.muted.dark`     | `#9CA3AF` | Helper text            |
| `color.text.inverse.dark`   | `#0F172A` | Text on bright buttons |

---

## 4. Borders & Dividers (Dark)

| Token Name                | Hex       | Usage                |
| ------------------------- | --------- | -------------------- |
| `color.border.light.dark` | `#374151` | Card borders, inputs |
| `color.border.focus.dark` | `#3FBFC4` | Focused inputs       |

---

## 5. Overlays & Feedback

| Token Name                 | Hex               | Usage          |
| -------------------------- | ----------------- | -------------- |
| `color.overlay.scrim.dark` | `rgba(0,0,0,0.6)` | Modals, sheets |
| `color.overlay.toast.dark` | `#1F2933`         | Toast messages |

---

## 6. Elevation / Shadow (Dark)

> Shadows become *softer and wider* in dark mode.

| Token Name       | Shadow                       |
| ---------------- | ---------------------------- |
| `shadow.sm.dark` | `0 1px 2px rgba(0,0,0,0.4)`  |
| `shadow.md.dark` | `0 6px 12px rgba(0,0,0,0.5)` |

---

## 7. Component Defaults (Dark Mode)

### Primary Button

| Property   | Token                      |
| ---------- | -------------------------- |
| Background | `color.brand.primary.dark` |
| Text color | `color.text.inverse.dark`  |
| Radius     | `radius.lg`                |
| Padding    | `space.md` / `space.lg`    |

---

### Card

| Property   | Token                     |
| ---------- | ------------------------- |
| Background | `color.surface.card.dark` |
| Radius     | `radius.md`               |
| Padding    | `space.md`                |
| Border     | `color.border.light.dark` |

---

### Progress Bar

| Property | Token                         |
| -------- | ----------------------------- |
| Track    | `color.surface.disabled.dark` |
| Fill     | `color.brand.primary.dark`    |
| Radius   | `radius.full`                 |

---

## 8. Dark Mode Rules (Non-Negotiable)

* Never use pure black (`#000000`)
* Avoid pure white text on dark surfaces
* Keep contrast high but gentle
* Brand colors must remain identifiable
* Error red must be muted, never alarming

---

## 9. Light ↔ Dark Mapping Rule

| Light Token           | Dark Token                 |
| --------------------- | -------------------------- |
| `color.bg.primary`    | `color.bg.primary.dark`    |
| `color.surface.card`  | `color.surface.card.dark`  |
| `color.text.primary`  | `color.text.primary.dark`  |
| `color.brand.primary` | `color.brand.primary.dark` |

This allows **automatic theme switching** in Flutter.

---

## 10. System Rule

> **Dark mode should feel like Wamo at night — calm, steady, and dependable.**

---

## Implementation Notes

### Flutter Integration

These design tokens can be directly mapped to Flutter's `ThemeData`:

```dart
// Light Theme
ThemeData(
  primaryColor: Color(0xFF2FA4A9),
  scaffoldBackgroundColor: Color(0xFFFFFFFF),
  cardColor: Color(0xFFFFFFFF),
  // ... etc
)

// Dark Theme
ThemeData.dark().copyWith(
  primaryColor: Color(0xFF3FBFC4),
  scaffoldBackgroundColor: Color(0xFF0F172A),
  cardColor: Color(0xFF1F2933),
  // ... etc
)
```

### Flutter TextTheme Mapping (MVP)

Use the following `TextTheme` mapping for the type scale defined above:

```dart
final textTheme = TextTheme(
  displaySmall: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 36 / 28,
  ),
  titleLarge: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 28 / 22,
  ),
  titleMedium: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
  ),
  bodyLarge: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
  ),
  bodyMedium: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
  ),
  labelSmall: TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
  ),
);
```

### Flutter ThemeData Mapping (MVP)

```dart
final lightTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Manrope',
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF2FA4A9),
    primary: const Color(0xFF2FA4A9),
    secondary: const Color(0xFFF39C3D),
    surface: const Color(0xFFFFFFFF),
    background: const Color(0xFFFFFFFF),
    error: const Color(0xFFD9534F),
  ),
  scaffoldBackgroundColor: const Color(0xFFFFFFFF),
  cardColor: const Color(0xFFFFFFFF),
  dividerColor: const Color(0xFFE5E7EB),
  textTheme: textTheme.apply(
    bodyColor: const Color(0xFF4B5563),
    displayColor: const Color(0xFF1F2933),
  ),
  inputDecorationTheme: InputDecorationTheme(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFF2FA4A9)),
      borderRadius: BorderRadius.circular(8),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFFD9534F)),
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF2FA4A9),
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  ),
);
```

```dart
final darkTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Manrope',
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF3FBFC4),
    primary: const Color(0xFF3FBFC4),
    secondary: const Color(0xFFF6B15A),
    surface: const Color(0xFF1F2933),
    background: const Color(0xFF0F172A),
    error: const Color(0xFFF87171),
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: const Color(0xFF0F172A),
  cardColor: const Color(0xFF1F2933),
  dividerColor: const Color(0xFF374151),
  textTheme: textTheme.apply(
    bodyColor: const Color(0xFFD1D5DB),
    displayColor: const Color(0xFFF9FAFB),
  ),
  inputDecorationTheme: InputDecorationTheme(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFF374151)),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFF3FBFC4)),
      borderRadius: BorderRadius.circular(8),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFFF87171)),
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF3FBFC4),
      foregroundColor: const Color(0xFF0F172A),
      minimumSize: const Size.fromHeight(48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  ),
);
```

### Figma Integration

Export these tokens as Figma styles for consistent design-to-development handoff.

### Figma Style Mapping (MVP)

**Color Styles**
- `Brand/Primary` → `color.brand.primary` `#2FA4A9`
- `Brand/Secondary` → `color.brand.secondary` `#F39C3D`
- `Brand/Success` → `color.brand.success` `#3CB371`
- `Brand/Warning` → `color.brand.warning` `#F2B705`
- `Brand/Error` → `color.brand.error` `#D9534F`
- `Text/Primary` → `color.text.primary` `#1F2933`
- `Text/Secondary` → `color.text.secondary` `#4B5563`
- `Text/Muted` → `color.text.muted` `#9CA3AF`
- `BG/Primary` → `color.bg.primary` `#FFFFFF`
- `BG/Secondary` → `color.bg.secondary` `#F7F9FB`
- `Surface/Card` → `color.surface.card` `#FFFFFF`
- `Border/Light` → `color.border.light` `#E5E7EB`

**Text Styles**
- `Display` → 28 / 700 / 36
- `Title` → 22 / 700 / 28
- `Subtitle` → 18 / 600 / 24
- `Body` → 16 / 400 / 24
- `Small` → 14 / 400 / 20
- `Caption` → 12 / 500 / 16

**Effects**
- `Shadow/Sm` → `0 1px 2px rgba(0,0,0,0.05)`
- `Shadow/Md` → `0 4px 8px rgba(0,0,0,0.06)`

### Auto-Switch Logic

Implement system-based theme switching:

```dart
MaterialApp(
  theme: lightTheme,
  darkTheme: darkTheme,
  themeMode: ThemeMode.system, // Follows device settings
)
```

---

## Version History

| Version | Date           | Changes                       |
| ------- | -------------- | ----------------------------- |
| 1.1     | Feb 4, 2026    | Added typography scale, layout rules, inputs, subtle gradients |
| 1.0     | Feb 4, 2026    | Initial design system created |

---

## Related Documentation

* [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) - Technical implementation roadmap
* [WAMO_PROJECT_SPEC.md](WAMO_PROJECT_SPEC.md) - Product requirements
* [WAMO_SCREENS.md](WAMO_SCREENS.md) - Screen-by-screen implementation status
