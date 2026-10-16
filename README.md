# unstructured

A blog about language, structure, and thought in the era of LLMs.

## Tech stack

- [Astro 5](https://astro.build/) — static site generator
- [React 19](https://react.dev/) — interactive components
- [TypeScript](https://www.typescriptlang.org/)
- [MDX](https://mdxjs.com/) — Markdown with JSX support

## Getting started

**Prerequisites:** Node.js (v18+)

```bash
# Install dependencies
yarn

# Start dev server
yarn dev

# Build for production
yarn build

# Preview production build
yarn preview
```

## Project structure

```
src/
├── pages/          # Route pages
├── layouts/        # Page layouts
├── components/     # React & Astro components
├── content/posts/  # Blog posts (Markdown)
├── styles/         # Global styles
└── content.config.ts
```

## Adding content

Create a `.md` file in `src/content/posts/` with the following frontmatter:

```md
---
title: "Post Title"
pubDate: 2026-01-15
description: "Optional summary"  # optional
tags: ["tag1", "tag2"]           # optional, defaults to []
draft: false                     # optional, defaults to false
updatedDate: 2026-02-01          # optional
---

Post content here...
```

**Required:** `title`, `pubDate`

## Features

- Dark/light theme toggle
- Scroll-shrinking title
- Responsive typography
- Static site generation
- No-AI scraping policy (robots.txt, IETF `Content-Usage`, TDMRep) — see [docs/no-ai-scraping.md](docs/no-ai-scraping.md)

## License

[GPL-3.0](LICENSE)
