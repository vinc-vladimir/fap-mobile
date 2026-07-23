---
name: Velocity Blue
colors:
  surface: '#051424'
  surface-dim: '#051424'
  surface-bright: '#2c3a4c'
  surface-container-lowest: '#010f1f'
  surface-container-low: '#0d1c2d'
  surface-container: '#122131'
  surface-container-high: '#1c2b3c'
  surface-container-highest: '#273647'
  on-surface: '#d4e4fa'
  on-surface-variant: '#b9caca'
  inverse-surface: '#d4e4fa'
  inverse-on-surface: '#233143'
  outline: '#849495'
  outline-variant: '#3a494a'
  surface-tint: '#00dce5'
  primary: '#e9feff'
  on-primary: '#003739'
  primary-container: '#00f5ff'
  on-primary-container: '#006c71'
  inverse-primary: '#00696e'
  secondary: '#c0c6da'
  on-secondary: '#293040'
  secondary-container: '#42495a'
  on-secondary-container: '#b1b8cc'
  tertiary: '#faf9ff'
  on-tertiary: '#2c303b'
  tertiary-container: '#d9ddec'
  on-tertiary-container: '#5c616e'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#63f7ff'
  primary-fixed-dim: '#00dce5'
  on-primary-fixed: '#002021'
  on-primary-fixed-variant: '#004f53'
  secondary-fixed: '#dce2f7'
  secondary-fixed-dim: '#c0c6da'
  on-secondary-fixed: '#141b2a'
  on-secondary-fixed-variant: '#404757'
  tertiary-fixed: '#dee2f1'
  tertiary-fixed-dim: '#c2c6d5'
  on-tertiary-fixed: '#171c26'
  on-tertiary-fixed-variant: '#424752'
  background: '#051424'
  on-background: '#d4e4fa'
  surface-variant: '#273647'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Inter
    fontSize: 10px
    fontWeight: '500'
    lineHeight: 14px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  margin-main: 20px
  gutter: 16px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 24px
  container-padding: 16px
---

## Brand & Style

This design system shifts the brand identity from a utility-focused "gas station" aesthetic to a premium "mobility lifestyle" experience. The personality is sophisticated, reliable, and forward-thinking. It moves away from high-vibrancy oranges to a palette that suggests high-performance technology and environmental mindfulness.

The design style is **Corporate / Modern** with a **Dark Mode First** philosophy. It utilizes a deep color foundation to reduce eye strain during nighttime refueling while using vibrant teal and neon accents to highlight rewards and calls to action. The aesthetic is defined by high-quality typography, intentional whitespace, and a layered depth model that makes the interface feel like a tangible, high-end dashboard.

## Colors

The color palette is built on a "Deep Sea" foundation. 
- **Primary:** An electric Cyan (#00F5FF) serves as the primary action color, used for buttons, active states, and progress indicators. It provides high contrast against the dark background.
- **Secondary/Surface:** A muted Navy (#1A2130) is used for cards and elevated containers.
- **Tertiary/Background:** A near-black Slate (#0B101A) forms the base background layer.
- **Accents:** A subtle Emerald is used for positive financial growth or rewards, while a muted Gold is reserved for "Elite" or "Gold" status levels to maintain a sense of prestige without clashing with the tech-focused palette.

## Typography

This design system uses **Inter** exclusively to achieve a systematic, utilitarian, and clean look. 
- **Headlines:** Use tight letter spacing and bold weights to create a strong visual hierarchy for totals and station names.
- **Numbers:** Large financial figures or point totals should use semi-bold weights to ensure immediate readability at a glance.
- **Labels:** Use uppercase for small UI labels (like "Next Level" or "Vehicle ID") to differentiate them from body copy.
- **Readability:** Maintain a high contrast ratio (minimum 4.5:1) for all body text against dark backgrounds.

## Layout & Spacing

The layout follows a **Fluid Grid** model optimized for mobile devices. 
- **Margins:** A consistent 20px side margin ensures content does not feel cramped against the bezel.
- **Rhythm:** An 8px linear scale (8, 16, 24, 32, 48) is used for vertical spacing between elements.
- **Density:** The analytics and station details use a slightly more compact vertical rhythm (stack-sm) to keep essential information "above the fold" without excessive scrolling.
- **Safe Areas:** Navigation bars and top headers respect hardware notches and home indicators with a minimum 44px safe-zone.

## Elevation & Depth

Visual hierarchy is established through **Tonal Layering** and **Ambient Shadows**.
- **Base Layer:** The tertiary background color (#0B101A).
- **Surface Layer:** Cards and containers use the secondary color (#1A2130).
- **Depth:** Surfaces are given a subtle 1px inner-border (stroke) with 10% white opacity to define edges against the dark background.
- **Shadows:** Use extra-diffused, soft shadows (Y: 8px, Blur: 24px) with a color tint of the primary cyan at 5% opacity to create a subtle "glow" effect for active cards or the current gas station.
- **Interactive States:** Pressed states are indicated by a slight scale down (0.98x) rather than a heavy shadow change.

## Shapes

The shape language is **Rounded**, conveying friendliness and modernity without feeling "childish."
- **Standard Cards:** 16px (rounded-lg) for the main dashboard cards and reward tiles.
- **Input Fields & Buttons:** 12px for a comfortable, touch-friendly feel.
- **Chips & Badges:** 8px for smaller status indicators.
- **Visual Continuity:** Circular elements (like the reward progress gauge) are paired with these rounded rectangles to balance the geometric and organic feel of the UI.

## Components

- **Buttons:** Primary buttons use a solid Cyan background with dark Navy text. Secondary buttons use an outlined style with the 1px white stroke.
- **Cards:** Reward cards should feature high-quality imagery on the left, masked with a subtle gradient overlay that fades into the card's secondary background color on the right.
- **Analytics Charts:** Line charts should use a Primary Cyan stroke with a soft gradient fill (Cyan to transparent) underneath the path. Grid lines should be minimal and set to 5% white opacity.
- **Status Gauges:** The point progress gauge should be a thick, semi-circular ring. The "empty" part of the ring should be 10% white opacity, while the "filled" part uses a Primary Cyan to Teal gradient.
- **Navigation Bar:** A blurred glassmorphism effect (Backdrop Blur: 20px) on a dark navy base, ensuring the icons are sharp and high-contrast.
- **Inputs:** Dropdowns and text fields use the secondary background color with a 12px corner radius and a clear "active" state indicated by a Primary Cyan border.