import path from 'node:path';
import { defineCollection } from 'astro:content';
import { glob } from 'astro/loaders';
import { z } from 'astro/zod';

const posts = defineCollection({
  loader: glob({
    pattern: '**/*.{md,mdx}',
    base: './src/content/posts',
    // The post's id (and URL slug) is its filename, so a flat post
    // (`my-post.mdx`) and a post in its own folder (`my-post/my-post.mdx`)
    // both map to /posts/my-post.
    generateId: ({ entry }) => path.basename(entry, path.extname(entry)),
  }),
  schema: z.object({
    title: z.string(),
    description: z.string().optional(),
    pubDate: z.coerce.date(),
    updatedDate: z.coerce.date().optional(),
    draft: z.boolean().optional().default(false),
    tags: z.array(z.string()).optional().default([]),
  }),
});

export const collections = { posts };
