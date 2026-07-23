# Velocity Blue Design System Specification

## Brand Identity
**Name:** Velocity Blue
**Color Mode:** Dark
**Primary Color:** #00F5FF (Velocity Cyan)
**Surface Background:** #051424 (Deep Navy)
**Surface Container:** #0D1C2D (Slate Blue)
**Font Family:** Inter (Sans-serif)
**Corner Radius:** 24px (Main Container), 12px (Buttons/Inputs), 8px (Small Elements)

---

## Color Palette
- **Primary:** `#00F5FF` - High-visibility cyan for primary actions, active states, and brand highlights.
- **Surface:** `#051424` - Main background color for the dark theme.
- **Surface-Container:** `#0D1C2D` - Background for cards, form containers, and elevated surfaces.
- **On-Surface:** `#E1E2E5` - High-contrast text for dark backgrounds.
- **On-Surface-Variant:** `#C4C7CA` - Secondary text, labels, and inactive icon states.
- **Outline:** `#1A2130` - Border colors for inputs and containers.
- **Divider:** `rgba(255, 255, 255, 0.1)` - Subtle separators.

---

## Typography
- **Header 1 (H1):** `Inter`, Bold, 24px. Used for main titles (e.g., "Fuel Auto Pay").
- **Header 2 (H2):** `Inter`, Semi-Bold, 20px. Used for section headers.
- **Body Text:** `Inter`, Regular, 14px-16px. Standard interface text.
- **Label Text:** `Inter`, Medium/Semi-Bold, 12px. Used for buttons, input labels, and tags.

---

## Components

### Buttons
- **Primary Button (Login):** Filled `#00F5FF` background, black bold text, 12px corner radius.
- **Secondary Button (Biometric):** Transparent background with `#1A2130` border or subtle slate fill, `#E1E2E5` text, 12px corner radius.
- **Social Buttons (Google/GitHub):** Outlined buttons with brand icons, slate backgrounds (`#1A2130`), 12px corner radius.

### Input Fields
- **Standard Input:** `#0D1C2D` background, `#1A2130` border, 12px corner radius. 
- **Focus State:** 2px `#00F5FF` outline.
- **Icons:** Leading icons in `#C4C7CA`.

### Navigation
- **Bottom Navigation Bar:**
  - **Surface:** `#1A2130` with backdrop-blur.
  - **Active State:** Cyan background pill or colored icon with label.
  - **Inactive State:** `#44474A` slate grey icons and labels.

### Cards & Containers
- **Authentication Card:** White/Transparent overlay, 24px rounded top corners, padding: 24px.

---

## Assets
- **Hero Image:** Dark version of the futuristic refueling station (`{{DATA:IMAGE:IMAGE_63}}`).
- **Logos:** Transparent Google (`{{DATA:IMAGE:IMAGE_39}}`) and GitHub (`{{DATA:IMAGE:IMAGE_37}}`) logos.
- **Icons:** Custom Face ID icon (`{{DATA:IMAGE:IMAGE_33}}`) and Fingerprint icons.

---

## Technical implementation (Ionic/SCSS)
```scss
$velocity-blue: (
  "primary": #00F5FF,
  "surface": #051424,
  "on-surface": #e1e2e5,
  "surface-container": #0d1c2d,
  "on-surface-variant": #c4c7ca,
  "outline": #1a2130
);
```