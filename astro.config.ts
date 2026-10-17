import { defineConfig } from 'astro/config';
import react from '@astrojs/react';
import mdx from '@astrojs/mdx';
import embeds from 'astro-embed/integration';

export default defineConfig({
  site: 'https://unstructured.fyi',
  integrations: [react(), embeds(), mdx()],
  // src/content is symlinked locally; resolve imports injected into posts
  // (e.g. astro-embed) from this project's node_modules, not the symlink target.
  vite: { resolve: { preserveSymlinks: true } },
});
