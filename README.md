# unstructured

A blog about language, structure, and thought in the era of LLMs.

## Tech stack

- [Astro 7](https://astro.build/) — static site generator
- [React 19](https://react.dev/) — interactive components
- [TypeScript](https://www.typescriptlang.org/)
- [MDX](https://mdxjs.com/) — Markdown with JSX support

## Getting started

**Prerequisites:** Node.js (v22.22+)

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
├── content/posts/  # Blog posts (gitignored, from unstructured-content)
├── styles/         # Global styles
└── content.config.ts
```

## Adding content

Posts live in the separate `bvigerzi/unstructured-content` repo, one folder per post (`posts/my-post/my-post.mdx`, with images in `posts/my-post/images/`). See that repo's README for the frontmatter, image and embed conventions. CI copies the posts into `src/content/posts/` at build time; locally, symlink `src/content` to your checkout of the content repo.

## Features

- Dark/light theme toggle
- Scroll-shrinking title
- Responsive typography
- Static site generation
- No-AI scraping policy (robots.txt, IETF `Content-Usage`, TDMRep) — see [docs/no-ai-scraping.md](docs/no-ai-scraping.md)

## License

[GPL-3.0](LICENSE)
