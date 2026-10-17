import react from '@vitejs/plugin-react';
import { VitePWA } from 'vite-plugin-pwa';
import { defineConfig } from 'vitest/config';

export default defineConfig({
  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
      includeAssets: ['favicon.png', 'apple-touch-icon.png'],
      manifest: {
        name: 'Fencing Scoring Machine',
        short_name: 'Fencing',
        description: 'Fencing scoring machine with timer and video replay',
        // Fixed identity, so a future change of start_url does not create a second installed app.
        id: '/',
        start_url: '/',
        scope: '/',
        theme_color: '#111418',
        background_color: '#111418',
        // iOS has no fullscreen mode; standalone is the baseline and fullscreen is preferred where supported.
        display: 'standalone',
        display_override: ['fullscreen', 'standalone'],
        orientation: 'any',
        icons: [
          { src: 'icon-192.png', sizes: '192x192', type: 'image/png' },
          { src: 'icon-512.png', sizes: '512x512', type: 'image/png' },
          { src: 'icon-maskable-512.png', sizes: '512x512', type: 'image/png', purpose: 'maskable' },
        ],
      },
    }),
  ],
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./tests/setup.ts'],
  },
});
