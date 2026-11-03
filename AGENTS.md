# AGENTS.md — AI Agent Reference for unstructured

## Tech Stack

| Layer       | Technology                        |
| ----------- | --------------------------------- |
| Framework   | Astro 7 (static site generation)  |
| Interactive | React 19 (via `@astrojs/react`)   |
| Content     | MDX 8 (Markdown also supported)   |
| Embeds      | astro-embed (link preview cards)  |
| Language    | TypeScript 5.7 (strict mode)      |
| Package Mgr | Yarn                             |
| Node        | v22.22+ (CI and minimum)          |

## Directory Structure

```
├── .github/workflows/       # CI — build.yml
├── docs/
│   └── no-ai-scraping.md    # How the no-AI crawler policy works
├── public/                  # Static assets: favicons, robots.txt, .well-known/tdmrep.json
├── scripts/                 # generate-favicons.sh (Inkscape + ImageMagick)
├── src/
│   ├── components/
│   │   ├── Nav.astro            # Footer navigation
│   │   ├── PostImage.astro      # Responsive renderer for Markdown images in posts
│   │   ├── PostList.astro       # Blog listing (sorted by date desc)
│   │   ├── ShrinkingTitle.astro # Scroll-responsive header
│   │   └── ThemeToggle.astro    # Light/dark toggle (inline script, no framework JS)
│   ├── content/                 # GITIGNORED — pulled from external repo
│   │   └── posts/               # MDX blog posts, one folder per post (<slug>/<slug>.mdx + images/)
│   ├── layouts/
│   │   ├── BaseLayout.astro     # Root layout: meta, fonts, theme script, nav
│   │   ├── PageLayout.astro     # Wraps BaseLayout: site title + page title (auxiliary pages)
│   │   └── PostLayout.astro     # Wraps PageLayout, adds dates and tags for posts
│   ├── pages/
│   │   ├── index.astro          # Home — post listing
│   │   ├── about.astro          # About page
│   │   └── posts/[slug].astro   # Dynamic post routes
│   ├── styles/
│   │   └── global.css           # All CSS: reset, variables, typography, theming
│   └── types/
│       └── content.ts           # PostFrontmatter and PostEntry interfaces
├── src/content.config.ts        # Content collection schema (Zod)
├── astro.config.ts              # Astro config (React, astro-embed, MDX integrations)
└── tsconfig.json                # Extends astro/tsconfigs/strict, react-jsx
```

## Content Management

Blog content lives in a **separate repository** (`bvigerzi/unstructured-content`) and is **not** committed to this repo.

- `src/content/` is in `.gitignore`
- CI clones the content repo and copies posts into `src/content/posts/` at build time
- For local development, symlink or copy post files into `src/content/posts/` (`vite.resolve.preserveSymlinks` in `astro.config.ts` lets symlinked posts resolve imports from this project's `node_modules`)

### Post Layout and IDs

Each post lives in its own folder: `posts/<slug>/<slug>.mdx`, with an optional `posts/<slug>/images/`. The glob loader in `src/content.config.ts` sets a custom `generateId` that uses the **filename only** (without extension) as the post id, so `my-post/my-post.mdx` maps to `/posts/my-post`. Flat files (`posts/my-post.mdx`) produce the same id, so both layouts work. Without the custom `generateId`, Astro's default id would be `my-post/my-post`, which breaks the single-segment `[slug].astro` route.

- Don't remove `generateId` while any post uses the folder layout
- Two posts with the same filename in different folders collide (Astro warns about duplicate ids)
- After moving post files locally, run `yarn build --force` (or `yarn dev --force`) once. The content-layer cache in `node_modules/.astro/` keeps stale file paths for unchanged entries, and the build fails with `failed to resolve import "astro:content-layer-deferred-module?...fileName=<old path>"`. CI always starts from a fresh checkout, so it's unaffected

### Post Images

Posts reference images with relative Markdown paths: `![alt](./images/photo.jpg)`. MDX turns these into Astro's `<Image>` component. `pages/posts/[slug].astro` overrides it with `<Content components={{ img: PostImage }} />`, and `components/PostImage.astro` renders a responsive image sized to the post column inside a `<figure class="post-image">`, with the alt text repeated as an italic `<figcaption>` (`aria-hidden` so screen readers don't read it twice; omitted when alt is empty). Markdown wraps a standalone image in `<p>`, which can't contain a `<figure>`, so `rehype-unwrap-images` (in `markdown.rehypePlugins`, inherited by MDX) removes that wrapper. Astro's built-in asset pipeline (`astro:assets` + `sharp`) then:

- Generates a WebP `srcset` in `dist/_astro/<name>.<hash>.webp`, using `layout="constrained"` with `width` set to the column's content width (`COLUMN_WIDTH = 624`: `.prose` 42rem max-width minus 2 × 1.5rem padding). Widths run from 624px to 2× (1248px) and are never larger than the original. The original is never emitted, so authors don't need to resize. Smaller images keep their own width and aren't upscaled
- Adds `width`/`height`, `sizes`, `loading="lazy"` and `decoding="async"`
- If `.prose` width or padding changes, update `COLUMN_WIDTH` to match
- Strips EXIF/GPS metadata from the output
- Fails the build on a missing file, so a broken reference never deploys
- Only emits images that a post references, so unreferenced files in the content repo are never deployed

No separate upload step exists: CI's `cp -r _content/posts/*` copies image folders along with posts, and the Bunny deploy uploads `dist/`. Because `enable-delete-action` is on, images removed from posts are deleted from the storage zone on the next deploy. Hashed filenames mean a changed image gets a new URL, so there's no stale CDN cache.

Styles: `.prose .post-image` (and its `img` / `figcaption`) in `global.css`. It's scoped to the class so link preview card thumbnails are unaffected.

### Link Preview Cards

Posts are `.mdx` so the `astro-embed` integration can auto-embed URLs. A bare URL **on its own line** becomes a `<LinkPreview>` card (Open Graph title, description and image, fetched at render time in both dev and build). YouTube, Bluesky, Gist, Vimeo, Tweet and Mastodon URLs become rich embeds instead. Inline URLs and `[text](url)` links stay normal links. If a fetch fails, the card falls back to the plain URL.

- `embeds()` must come **before** `mdx()` in `integrations`
- `astro-embed` is pinned to `~0.14.0` (requires Astro 7.2.4+)
- Its URL transform is a remark plugin, so `astro.config.ts` sets `markdown.processor: unified()` (from `@astrojs/markdown-remark`) instead of Astro 7's default Sätteri processor. Without it the build fails, or (under Sätteri) bare URLs render as plain text
- Card styles live in `global.css` under `.prose .link-preview`

### Content Collection Schema

Defined in `src/content.config.ts` using Astro's Content Collections API with a glob loader (`**/*.{md,mdx}`, filename-based `generateId`, see above).

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
- There are currently no React components, so no framework JS ships to the client. The `@astrojs/react` integration stays installed for when one is genuinely needed. Small interactions (like `ThemeToggle.astro`) use an `is:inline` script instead, so they add no request to the critical path.

### Layout Hierarchy

```
BaseLayout.astro
├── Inline <script> for theme flash prevention (reads localStorage)
├── <head>: meta, <Font /> (self-hosted, preloaded), favicon links
├── ThemeToggle.astro
├── <slot /> (page content)
└── Nav.astro (footer)

PageLayout.astro (extends BaseLayout) — static, undated auxiliary pages (e.g. /about)
├── Site title link, page title (h1)
├── <slot name="meta" /> (optional, used by PostLayout)
└── <slot /> (page content)

PostLayout.astro (extends PageLayout)
├── meta slot: pub date, updated date, tags
└── <slot /> (rendered markdown)
```

## Styling Conventions

All styles are in `src/styles/global.css`. No CSS frameworks, preprocessors, or CSS-in-JS.

- **Fonts:** Playfair Display (titles, serif, italic 600) · DM Sans (body, sans-serif, 300). Configured in `astro.config.ts` via Astro's Fonts API (`fonts`, Google provider): files are downloaded at build time, served from `/_astro/fonts/`, and preloaded by `<Font />` in BaseLayout, with metric-matched fallbacks generated automatically. Don't link to fonts.googleapis.com (it adds an HTML → CSS → font request chain). To add a weight/style, edit `weights`/`styles` in the config.
- **Layout:** max-width `42rem` for prose content
- **Responsive type:** `clamp()` for fluid font sizes
- **Transitions:** smooth color/background transitions for theme switching
- **Code blocks:** background color, border-radius, `overflow-x: auto`

### CSS Variables

```css
/* Defined by <Font /> from astro.config.ts, not global.css */
--font-title  /* Playfair Display, Georgia, serif */
--font-body   /* DM Sans, system-ui, sans-serif */

/* Light (default) */
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
2. **ThemeToggle.astro** toggles between `'light'` and `'dark'` and persists to localStorage via an inline script. Its glyph (● / ○) comes from CSS keyed on `[data-theme]`, so it's correct on first paint without hydration.
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

- **Triggers:** push to `main`, pull requests targeting `main`, manual `workflow_dispatch`
- **PR checks:** the `build` job runs on every PR and must pass before merging (enforced via a required status check on `main`). PR runs build only — they never deploy. Superseded PR runs are cancelled
- **Steps:**
  1. Checkout this repo
  2. Checkout `bvigerzi/unstructured-content` (main branch, using `CONTENT_REPO_TOKEN` secret)
  3. Copy content into `src/content/posts/`
  4. Setup Node.js v26 (LTS) with yarn caching
  5. `yarn install --frozen-lockfile`
  6. `yarn build`
  7. Deploy `dist/` to Bunny.net (push to `main` / manual dispatch on `main` only)

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
2. Import and use `PageLayout` for static auxiliary pages (or `BaseLayout` for fully custom pages)
3. Add a link in `Nav.astro` if it should appear in the footer
4. The file path becomes the route (`/my-page`)

### Modifying styles

- Edit `src/styles/global.css`
- Use existing CSS variables for colors and fonts
- Add dark-mode overrides under `[data-theme='dark']` when introducing new colors

### Updating the AI crawler blocklist

Refresh section 1 of `public/robots.txt` from upstream ai.robots.txt — see [docs/no-ai-scraping.md](./docs/no-ai-scraping.md#refreshing-the-list). Don't add `Content-Usage` back to robots.txt (it fails Lighthouse's robots.txt audit); it lives only in the Bunny edge rule in `infra/cdn/main.tf`.

### Regenerating favicons

1. Edit `public/favicon.svg`
2. Run `bash scripts/generate-favicons.sh` (requires Inkscape + ImageMagick)

## Commit Style

Conventional commits, lowercase: `<type>: <description>`

Types: `feat`, `fix`, `chore`
