---
name: Arun Crackers POS Mobile
colors:
  surface: '#ffffff'
  surface-dim: '#d8dadc'
  surface-bright: '#f7f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#0f172a'
  on-surface-variant: '#64748b'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#cbd5e1'
  outline-variant: '#e2e8f0'
  surface-tint: '#bc0b3b'
  primary: '#b90538'
  on-primary: '#ffffff'
  primary-container: '#dc2c4f'
  on-primary-container: '#fffbff'
  inverse-primary: '#ffb2b7'
  secondary: '#515f74'
  on-secondary: '#ffffff'
  secondary-container: '#d5e3fc'
  on-secondary-container: '#57657a'
  tertiary: '#006947'
  on-tertiary: '#ffffff'
  tertiary-container: '#00855b'
  on-tertiary-container: '#f5fff6'
  error: '#ef4444'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdadb'
  primary-fixed-dim: '#ffb2b7'
  on-primary-fixed: '#40000d'
  on-primary-fixed-variant: '#92002a'
  secondary-fixed: '#d5e3fc'
  secondary-fixed-dim: '#b9c7df'
  on-secondary-fixed: '#0d1c2e'
  on-secondary-fixed-variant: '#3a485b'
  tertiary-fixed: '#6ffbbe'
  tertiary-fixed-dim: '#4edea3'
  on-tertiary-fixed: '#002113'
  on-tertiary-fixed-variant: '#005236'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  headline-lg:
    fontFamily: Work Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Work Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  headline-sm:
    fontFamily: Work Sans
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 22px
  body-md:
    fontFamily: Work Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Work Sans
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  data-lg:
    fontFamily: JetBrains Mono
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.02em
  data-md:
    fontFamily: JetBrains Mono
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
  data-sm:
    fontFamily: JetBrains Mono
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.05em
  label-caps:
    fontFamily: Work Sans
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.08em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  unit: 4px
  touch-target-min: 44px
  gutter: 8px
  margin-mobile: 12px
  stack-sm: 4px
  stack-md: 12px
  stack-lg: 20px
---

## Brand & Style

The design system is engineered for high-velocity retail environments, specifically tailored for mobile and handheld POS terminals. It emphasizes **Technical Utility** and **Industrial Precision**, ensuring that operators can process transactions with zero friction under high-pressure conditions.

The aesthetic follows a **High-Contrast Corporate** movement. It balances a clean, sterile workspace with vibrant, mission-critical accents. The emotional response is one of absolute reliability and tactical speed. By prioritizing structural clarity over decorative flourishes, the design system minimizes cognitive load, allowing numerical accuracy to take center stage. Every visual element is optimized for rapid scanning, immediate recognition of states, and effortless touch interaction.

## Colors

The color strategy is strictly functional, utilizing a Material-inspired tonal system to define hierarchy. 

*   **Primary (#f43f5e):** Reserved for "Commit" actions and active focus states. This high-visibility Rose serves as the "Safety" color, signaling the primary path forward.
*   **Neutral Palette:** The system uses a clean **Surface (#ffffff)** for actionable cards and an **Application Background (#f8fafc)** to provide soft contrast between UI layers.
*   **Semantic Feedback:** **Tertiary Green (#10b981)** indicates success or "online" status, while **Error Red (#ef4444)** is used exclusively for destructive actions like voiding items or critical inventory alerts.
*   **Contrast:** All text levels adhere to high-contrast ratios against the surface colors to ensure legibility in varying lighting conditions, from bright retail floors to outdoor stalls.

## Typography

This design system utilizes a dual-font architecture to separate UI metadata from transactional data.

*   **Work Sans** handles the human element. It is used for all instructional text, button labels, and section headings. It provides a grounded, approachable feel to the administrative side of the POS.
*   **JetBrains Mono** is the engine of the system. It is mandatory for all numerical values, SKUs, quantities, and currency. Its monospaced nature ensures that decimal points and quantities align perfectly in vertical lists, which is critical for rapid visual auditing of bills.

For mobile layouts, avoid font sizes smaller than 11px. Ensure all `data-lg` elements (Total amounts) are high-contrast and prominent.

## Layout & Spacing

The layout philosophy follows a **High-Density Fluid** model. On mobile, the goal is to maximize information per square inch while maintaining "Fat-Finger" accessibility.

*   **Baseline Grid:** A strict 4px rhythm dictates all gaps and paddings.
*   **Touch Targets:** Every interactive element—buttons, row items, and steppers—must maintain a minimum height of 44-48px. 
*   **Mobile Structure:** Use a 4-column fluid grid. Page-edge margins are set to 12px to allow content to breathe while maximizing horizontal space for SKU names.
*   **Responsive Reflow:** In inventory views, use high-density vertical lists with 6px-8px vertical cell padding. For checkout, transition to a split-view where the "Total" is always anchored to the bottom.

## Elevation & Depth

The design system conveys hierarchy through **Tonal Tiering** and **Ghost Borders** rather than traditional ambient shadows. This maintains a performant, "flat" industrial feel.

*   **Surface Tiers:** Use `surface-container-low` (#f8fafc) for the background and `surface` (#ffffff) for actionable cards and inputs. This creates a natural "lift" for interactive zones.
*   **Outlines:** Use 1px solid `outline-variant` (#e2e8f0) for standard containers and dividers.
*   **Focus State:** When an input is active, use a 2px solid `primary` (#f43f5e) border with a soft, low-opacity glow (4px spread) to pull the element to the foreground.
*   **Sticky Elements:** Floating action bars at the bottom of the screen use a subtle `shadow-md` (Slate/10) to indicate they are positioned above the scrolling content.

## Shapes

The shape language is disciplined and professional. A **Soft (4px)** radius is the standard for almost all interactive components, including buttons, input fields, and search bars. This subtle rounding prevents the UI from feeling "aggressive" while maintaining the rigid structure associated with industrial software.

*   **Badges & Chips:** Use a `rounded-full` (pill) shape for status indicators (e.g., "Online" or "Item Units") to distinguish them from actionable buttons.
*   **Containers:** Main card containers may use `rounded-lg` (8px) for a slightly softer presentation when grouping large sections of data.

## Components

### Buttons & Chips
Primary buttons must be high-contrast with #f43f5e backgrounds. Secondary buttons use a white surface with a slate outline. Chips used for quantity status should utilize `data-sm` typography.

### Input Fields & Steppers
Numeric inputs are the core of this POS. Use large "-" and "+" stepper buttons flanking the input field, with a combined height of 48px. SKU inputs should trigger a numeric keypad by default on mobile devices.

### Action Bar (Mobile-Specific)
The "Checkout" bar is a sticky component at the bottom of the viewport. It contains the subtotal in `data-md`, the Grand Total in `data-lg` (JetBrains Mono), and a full-width primary button. Use a 1px top border and a subtle shadow to separate it from the list.

### Inventory Lists
For mobile inventory, use vertical list items with 12px horizontal padding. Include swipe actions for "Delete" (swipe left) or "Edit" (swipe right). Each row should clearly separate the Item Name (Work Sans) from the Price/Stock (JetBrains Mono).

### Collapsible Filters
Filters should be tucked into a bottom-sheet or a full-width collapsible header to preserve screen real estate for the product list. Use 44px high list items for category selection.