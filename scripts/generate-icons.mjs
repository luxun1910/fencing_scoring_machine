// Generates PWA icons in public/ from the master images in assets/icons/.
import sharp from 'sharp';

const src = 'assets/icons/icon.png';
const maskableFg = 'assets/icons/whiteborder_icon_adaptive_foreground.png';

const outputs = [
  ['public/favicon.png', 64],
  ['public/apple-touch-icon.png', 180],
  ['public/icon-192.png', 192],
  ['public/icon-512.png', 512],
];

for (const [file, size] of outputs) {
  await sharp(src).resize(size, size).png().toFile(file);
}

// Maskable icon: adaptive foreground over the same white background Android used.
await sharp(maskableFg)
  .resize(512, 512)
  .flatten({ background: '#ffffff' })
  .png()
  .toFile('public/icon-maskable-512.png');

console.log('Icons generated.');
