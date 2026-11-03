import { defineConfig, fontProviders } from 'astro/config';
import react from '@astrojs/react';
import mdx from '@astrojs/mdx';
import embeds from 'astro-embed/integration';
import { unified } from '@astrojs/markdown-remark';
import rehypeUnwrapImages from 'rehype-unwrap-images';

export default defineConfig({
  site: 'https://unstructured.fyi',
  integrations: [react(), embeds(), mdx()],
  // Fonts are downloaded at build time and served from this origin, so the
  // browser fetches the woff2 files directly (preloaded) instead of going
  // HTML -> fonts.googleapis.com CSS -> fonts.gstatic.com.
  fonts: [
    {
      provider: fontProviders.google(),
      name: 'Playfair Display',
      cssVariable: '--font-title',
      weights: [600],
      styles: ['italic'],
      fallbacks: ['Georgia', 'serif'],
    },
    {
      provider: fontProviders.google(),
      name: 'DM Sans',
      cssVariable: '--font-body',
      weights: [300],
      styles: ['normal'],
      fallbacks: ['system-ui', 'sans-serif'],
    },
  ],
  // astro-embed turns bare URLs into embeds via a remark plugin, which only the
  // unified processor runs (Astro 7 defaults to Sätteri).
  // rehype-unwrap-images drops the <p> Markdown wraps around a standalone
  // image, so PostImage can render a <figure> (not valid inside a <p>).
  markdown: { processor: unified(), rehypePlugins: [rehypeUnwrapImages] },
  // src/content is symlinked locally; resolve imports injected into posts
  // (e.g. astro-embed) from this project's node_modules, not the symlink target.
  vite: { resolve: { preserveSymlinks: true } },
});
