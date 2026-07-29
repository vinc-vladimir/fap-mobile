---
name: Velocity Flux
colors:
  surface: '#f7f9fb'
  surface-dim: '#d8dadc'
  surface-bright: '#f7f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#191c1e'
  on-surface-variant: '#3e4949'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#6f797a'
  outline-variant: '#bec9c9'
  surface-tint: '#27676b'
  primary: '#004f53'
  on-primary: '#ffffff'
  primary-container: '#27676b'
  on-primary-container: '#a5e3e7'
  inverse-primary: '#93d1d5'
  secondary: '#565e74'
  on-secondary: '#ffffff'
  secondary-container: '#d7dff9'
  on-secondary-container: '#5a6278'
  tertiary: '#38475d'
  on-tertiary: '#ffffff'
  tertiary-container: '#505f76'
  on-tertiary-container: '#c9d9f4'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#afedf2'
  primary-fixed-dim: '#93d1d5'
  on-primary-fixed: '#002022'
  on-primary-fixed-variant: '#004f53'
  secondary-fixed: '#dae2fc'
  secondary-fixed-dim: '#bec6e0'
  on-secondary-fixed: '#131b2e'
  on-secondary-fixed-variant: '#3e465b'
  tertiary-fixed: '#d4e3ff'
  tertiary-fixed-dim: '#b8c7e2'
  on-tertiary-fixed: '#0c1c30'
  on-tertiary-fixed-variant: '#39485e'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
  vibrant-cyan: '#00f5ff'
  surface-glass: rgba(255, 255, 255, 0.85)
  success-glint: '#97e5eb'
  map-void: '#eceef0'
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
Velocity Flux is a high-performance navigation and utility interface designed for the modern urban traveler. The brand personality is **optimistic, technical, and frictionless**. It targets a tech-savvy audience that values efficiency and visual clarity.

The visual style is a sophisticated blend of **Corporate Modern** and **Glassmorphism**. It utilizes a "Surface-Glass" system for floating elements to maintain spatial awareness of the underlying map data, paired with high-fidelity cyan accents that evoke a sense of clean energy and digital precision. The interface feels light and airy, avoiding heavy solid blocks in favor of translucency and soft, layered depth.

## Colors
The palette is rooted in a professional "Teal & Slate" foundation. 

- **Primary & Accents:** The core primary (`#004f53`) provides grounding for text and icons, while a vibrant `vibrant-cyan` (`#00f5ff`) is used sparingly for critical path indicators and interactive strokes.
- **Surface Strategy:** The UI relies on a `surface-glass` effect for cards and headers to ensure the map remains the primary context. Backgrounds use a very cool-toned neutral (`#f7f9fb`) to keep the interface feeling "cold" and efficient rather than warm and organic.
- **Functional Colors:** Secondary and Tertiary tones are reserved for inactive states and metadata, ensuring a clear hierarchy of information.

## Typography
The system uses **Inter** exclusively to lean into a utilitarian, "system-font" aesthetic. 

- **Headlines:** Use tighter letter spacing and semi-bold/bold weights to create impact against the softer glass backgrounds.
- **Labels:** Utilize "Label MD" with increased letter-spacing (0.05em) for category headers and utility text to improve readability at small sizes.
- **Readability:** Body text maintains a standard 1.5x line-height ratio to ensure comfort during quick glances while navigating.

## Layout & Spacing
The layout follows a **Fluid Grid** approach for mobile, with fixed safe-area margins of 20px (`margin-main`). 

- **Vertical Rhythm:** Components are stacked using a 4px baseline. Most interactive elements are separated by `stack-md` (16px), while internal groupings use `stack-sm` (8px).
- **Safe Areas:** A 16px bottom-nav gutter ensures that floating action buttons (FABs) do not overlap with the primary navigation or system gestures.
- **Z-Index Strategy:** Layers are strictly defined: Map (0), Glass Overlays (40), Fixed Chrome (50).

## Elevation & Depth
Elevation is communicated through **Optical Layers** rather than heavy shadows.

- **The Glass Layer:** Floating cards use a 20px backdrop-blur with a 1px border (`rgba(0, 79, 83, 0.1)`) to define their edges without casting muddy shadows.
- **Ambient Depth:** High-priority cards (like the active station card) utilize `shadow-xl`, characterized by a very soft, diffused spread that suggests the card is hovering significantly above the map.
- **Functional Elevation:** FABs use a sharper shadow to indicate immediate "pressability" and tactile response.

## Shapes
The shape language is **Medium-Rounded**, balancing professional structure with modern softness.

- **Primary Containers:** Cards and large buttons use a 12px (`0.75rem`) or 16px (`1rem`) radius.
- **Interactive Pills:** Map markers and status tags are fully rounded (`pill-shaped`) to distinguish them from structural UI elements.
- **Small Elements:** Internal image containers and icons use 8px (`0.5rem`) rounding to maintain harmony with the larger card containers.

## Components
- **Buttons:** 
    - *Primary:* Fully rounded (pill), using `primary-container` fill with high-contrast text.
    - *Secondary (Glass):* Glass-morphic squares (rounded-xl) with centered icons for map utilities.
- **Cards:** Glass-morphic surfaces with internal padding of 16px. Use a subtle 1px border to ensure visibility on light map areas.
- **Map Markers:** Hybrid shapes—a circular or pill-shaped "head" containing text/logo, tethered by a small vertical "stem" to the specific coordinates.
- **Progress Bars:** Thin (6px) rounded tracks using `surface-container-highest` for the track and `primary` for the fill, used to show availability or fuel levels.
- **Bottom Navigation:** A fixed-height (64px) container with a high-contrast top border. Active states are indicated by a pill-shaped background "glow" behind the icon.
- **Status Chips:** Small, high-contrast labels used for fuel types (e.g., "Diesel Pro"). Use a background opacity of 10% of the primary color for a subtle, tinted look.