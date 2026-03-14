# AGENTS.md — AI Agent Reference for unstructured

## Tech Stack

| Layer       | Technology                        |
| ----------- | --------------------------------- |
| Framework   | Astro 5 (static site generation)  |
| Interactive | React 19 (via `@astrojs/react`)   |
| Content     | Markdown + MDX 4                  |
| Language    | TypeScript 5.7 (strict mode)      |
| Package Mgr | Yarn                             |
| Node        | v22 (CI), v18+ (minimum)          |

## Directory Structure

```
├── .github/workflows/       # CI — build.yml
├── public/                  # Static assets (favicons only)
├── scripts/                 # generate-favicons.sh (Inkscape + ImageMagick)
├── src/
│   ├── components/
│   │   ├── Nav.astro            # Footer navigation
│   │   ├── PostList.astro       # Blog listing (sorted by date desc)
│   │   ├── ShrinkingTitle.astro # Scroll-responsive header
│   │   └── ThemeToggle.tsx      # Light/dark toggle (React, client:load)
│   ├── content/                 # GITIGNORED — pulled from external repo
│   │   └── posts/               # Markdown blog posts
│   ├── layouts/
│   │   ├── BaseLayout.astro     # Root layout: meta, fonts, theme script, nav
│   │   └── PostLayout.astro     # Wraps BaseLayout for individual posts
│   ├── pages/
│   │   ├── index.astro          # Home — post listing
│   │   ├── about.astro          # About page
│   │   └── posts/[slug].astro   # Dynamic post routes
│   ├── styles/
│   │   └── global.css           # All CSS: reset, variables, typography, theming
│   └── types/
│       └── content.ts           # PostFrontmatter and PostEntry interfaces
├── src/content.config.ts        # Content collection schema (Zod)
├── astro.config.ts              # Astro config (React + MDX integrations)
└── tsconfig.json                # Extends astro/tsconfigs/strict, react-jsx
```

## Content Management

Blog content lives in a **separate repository** (`bvigerzi/unstructured-content`) and is **not** committed to this repo.

- `src/content/` is in `.gitignore`
- CI clones the content repo and copies posts into `src/content/posts/` at build time
- For local development, symlink or copy markdown files into `src/content/posts/`

### Content Collection Schema

Defined in `src/content.config.ts` using Astro's Content Collections API with a glob loader.

| Field         | Type       | Required | Default |
| ------------- | ---------- | -------- | ------- |
| `title`       | `string`   | Yes      | —       |
| `pubDate`     | `Date`     | Yes      | —       |
| `description` | `string`   | No       | —       |
| `updatedDate` | `Date`     | No       | —       |
| `draft`       | `boolean`  | No       | `false` |
| `tags`        | `string[]` | No       | `[]`    |

Posts with `draft: true` are filtered out of public pages.

## Component Patterns

- **Default to `.astro` components.** Use Astro components for anything that doesn't need client-side interactivity.
- **Use `.tsx` (React) only when client-side state or effects are needed.** Add the `client:load` directive when importing React components into Astro templates.
- Currently only `ThemeToggle.tsx` is a React component — everything else is Astro.

### Layout Hierarchy

```
BaseLayout.astro
├── Inline <script> for theme flash prevention (reads localStorage)
├── <head>: meta, Google Fonts (Playfair Display, DM Sans), favicon links
├── ThemeToggle.tsx (client:load)
├── <slot /> (page content)
└── Nav.astro (footer)

PostLayout.astro (extends BaseLayout)
├── Post title (h1), pub date, updated date, tags
└── <slot /> (rendered markdown)
```

## Styling Conventions

All styles are in `src/styles/global.css`. No CSS frameworks, preprocessors, or CSS-in-JS.

- **Fonts:** Playfair Display (titles, serif, italic 600) · DM Sans (body, sans-serif, 300)
- **Layout:** max-width `42rem` for prose content
- **Responsive type:** `clamp()` for fluid font sizes
- **Transitions:** smooth color/background transitions for theme switching
- **Code blocks:** background color, border-radius, `overflow-x: auto`

### CSS Variables

```css
/* Light (default) */
--font-title: 'Playfair Display', Georgia, serif;
--font-body: 'DM Sans', system-ui, sans-serif;
--color-bg: #fff;
--color-text: #000;
--color-muted: #666;
--color-border: #e0e0e0;

/* Dark — [data-theme='dark'] */
--color-bg: #000;
--color-text: #fff;
--color-muted: #999;
--color-border: #333;
```

## Theming

Theme is controlled by the `data-theme` attribute on `<html>`.

1. **Flash prevention:** An inline `<script>` in BaseLayout reads `localStorage('theme')`, falling back to `prefers-color-scheme`, and sets `data-theme` before first paint.
2. **ThemeToggle.tsx** reads the current attribute on mount, toggles between `'light'` and `'dark'`, and persists to localStorage.
3. CSS variables under `[data-theme='dark']` handle all color changes.

## Commands

```bash
yarn dev       # Start dev server
yarn build     # Production build (static output to dist/)
yarn preview   # Preview production build locally
```

There is no test suite or linter configured. Use `yarn build` to verify changes.

## CI/CD

GitHub Actions workflow (`.github/workflows/build.yml`):

- **Triggers:** push to `main`, manual `workflow_dispatch`
- **Steps:**
  1. Checkout this repo
  2. Checkout `bvigerzi/unstructured-content` (main branch, using `CONTENT_REPO_TOKEN` secret)
  3. Copy content into `src/content/posts/`
  4. Setup Node.js v22 with yarn caching
  5. `yarn install --frozen-lockfile`
  6. `yarn build`

## Common Tasks

### Adding a new Astro component

1. Create `src/components/MyComponent.astro`
2. Import it in the page or layout where it's needed
3. Use scoped `<style>` tags or reference CSS variables from `global.css`

### Adding a new React component

1. Create `src/components/MyComponent.tsx`
2. Import in an Astro file with `client:load` (or `client:visible`, etc.)
3. Keep React usage minimal — prefer Astro components when possible

### Adding a new page

1. Create `src/pages/my-page.astro`
2. Import and use `BaseLayout` (or `PostLayout` for post-like pages)
3. The file path becomes the route (`/my-page`)

### Modifying styles

- Edit `src/styles/global.css`
- Use existing CSS variables for colors and fonts
- Add dark-mode overrides under `[data-theme='dark']` when introducing new colors

### Regenerating favicons

1. Edit `public/favicon.svg`
2. Run `bash scripts/generate-favicons.sh` (requires Inkscape + ImageMagick)

## Commit Style

Conventional commits, lowercase: `<type>: <description>`

Types: `feat`, `fix`, `chore`
