import { defineConfig } from 'astro/config';
import react from '@astrojs/react';
import mdx from '@astrojs/mdx';
import embeds from 'astro-embed/integration';
import { unified } from '@astrojs/markdown-remark';

export default defineConfig({
  site: 'https://unstructured.fyi',
  integrations: [react(), embeds(), mdx()],
  // astro-embed turns bare URLs into embeds via a remark plugin, which only the
  // unified processor runs (Astro 7 defaults to Sätteri).
  markdown: { processor: unified() },
  // src/content is symlinked locally; resolve imports injected into posts
  // (e.g. astro-embed) from this project's node_modules, not the symlink target.
  vite: { resolve: { preserveSymlinks: true } },
});
