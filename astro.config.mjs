import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://pianokaoru.com',
  integrations: [sitemap()],
});
