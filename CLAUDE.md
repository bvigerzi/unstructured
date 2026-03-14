# CLAUDE.md

See [AGENTS.md](./AGENTS.md) for full project reference.

## Key Constraints

- **Use yarn**, not npm
- **No test suite** — verify changes with `yarn build`
- **Content is external** — never modify or commit files in `src/content/posts/` (gitignored, pulled from separate repo)
- **Prefer Astro components** over React — only use `.tsx` + `client:load` when client-side interactivity is required
- **Plain CSS only** — no frameworks, preprocessors, or CSS-in-JS; use CSS variables for theming
- **Commit format:** `<type>: <lowercase description>` (types: `feat`, `fix`, `chore`)
