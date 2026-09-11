const fs = require('node:fs');
const path = require('node:path');
const sharp = require('sharp');
const root = path.resolve(__dirname, '..');
const brand = require('../design/brand/mark.json');
const res = 'android/app/src/main/res';
function write(file, data) {
  const target = path.join(root, file);
  fs.mkdirSync(path.dirname(target), {recursive: true});
  fs.writeFileSync(target, data);
}
function mark(color = 'white') {
  return `<g transform="translate(12 8) scale(.76)"><path fill="${color}" fill-rule="evenodd" d="${brand.shield}${brand.letter}"/></g>`;
}
function svg(body, width = 100, height = width) {
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">${body}</svg>`;
}
function tile(inset = 0, round = false) {
  return svg(`<g transform="translate(${inset} ${inset}) scale(${1-inset/50})"><rect width="100" height="100" rx="${round ? 50 : 24}" fill="${brand.blue}"/>${mark()}</g>`);
}
async function png(file, source, size, height = size) {
  const data = await sharp(Buffer.from(source)).resize(size * 4, height * 4).png().toBuffer();
  const output = await sharp(data).resize(size, height).png().toBuffer();
  write(file, output);
  return output;
}
function vector(splash = false) {
  const scale = '.76';
  const x = 12;
  const y = 8;
  const geometry = `<group android:translateX="${x}" android:translateY="${y}" android:scaleX="${scale}" android:scaleY="${scale}"><path android:fillColor="#FFFFFF" android:fillType="evenOdd" android:pathData="${brand.shield}${brand.letter}"/></group>`;
  const body = splash ? `<path android:fillColor="${brand.blue}" android:pathData="M116,96H172C183.05,96 192,104.95 192,116V172C192,183.05 183.05,192 172,192H116C104.95,192 96,183.05 96,172V116C96,104.95 104.95,96 116,96Z"/><group android:translateX="96" android:translateY="96" android:scaleX=".96" android:scaleY=".96">${geometry}</group>` : `<group android:translateX="15" android:translateY="15" android:scaleX=".78" android:scaleY=".78">${geometry}</group>`;
  const size = splash ? 288 : 108;
  return `<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="${size}dp" android:height="${size}dp" android:viewportWidth="${size}" android:viewportHeight="${size}">${body}</vector>\n`;
}
async function main() {
  write('design/brand/mark.svg', svg(mark()));
  write('design/brand/mark-small.svg', svg(mark()));
  write('design/brand/mark-monochrome.svg', svg(mark('#000000')));
  write('design/brand/icon.svg', tile());
  await png('assets/images/icon.png', tile(), 512);
  await png('assets/pic/appicon.png', tile(), 1024);
  await png('assets/pic/logo.png', svg(mark(brand.blue)), 1024);
  const desktopSizes = [16, 24, 32, 48, 64, 128, 256];
  const frames = [];
  for (const size of desktopSizes) frames.push(await png(`design/brand/desktop-${size}.png`, tile(6), size));
  const header = Buffer.alloc(6 + frames.length * 16);
  header.writeUInt16LE(1, 2);
  header.writeUInt16LE(frames.length, 4);
  let offset = header.length;
  frames.forEach((frame, i) => {
    const at = 6 + i * 16;
    header[at] = header[at + 1] = desktopSizes[i] % 256;
    header.writeUInt16LE(1, at + 4);
    header.writeUInt16LE(32, at + 6);
    header.writeUInt32LE(frame.length, at + 8);
    header.writeUInt32LE(offset, at + 12);
    offset += frame.length;
  });
  const ico = Buffer.concat([header, ...frames]);
  write('windows/runner/resources/app_icon.ico', ico);
  write('assets/images/icon.ico', ico);
  for (const size of [16, 32, 64, 128, 256, 512, 1024]) await png(`macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_${size}.png`, tile(5), size);
  await png('assets/images/icon-linux.png', tile(6), 512);
  const densities = {mdpi: 48, hdpi: 72, xhdpi: 96, xxhdpi: 144, xxxhdpi: 192};
  for (const [density, size] of Object.entries(densities)) {
    await png(`${res}/mipmap-${density}/ic_launcher.png`, tile(4), size);
    await png(`${res}/mipmap-${density}/ic_launcher_round.png`, tile(4, true), size);
    await png(`${res}/mipmap-television-${density}/ic_launcher.png`, tile(4), size);
  }
  await png('android/app/src/main/ic_launcher-playstore.png', svg(`<rect width="100" height="100" fill="${brand.blue}"/>${mark()}`), 512);
  const banner = svg(`<rect width="320" height="180" fill="${brand.blue}"/><g transform="translate(110 12)">${mark()}</g><text x="160" y="145" text-anchor="middle" fill="white" font-family="sans-serif" font-size="22" font-weight="600">Silent Shield</text>`, 320, 180);
  await png(`${res}/mipmap-xhdpi/ic_banner.png`, banner, 640, 360);
  write(`${res}/drawable/ic_launcher_foreground.xml`, vector());
  write(`${res}/drawable/ic_launcher_foreground_tv.xml`, vector());
  write(`${res}/drawable/ic_launcher_monochrome.xml`, vector());
  write(`${res}/drawable/splash_icon.xml`, vector(true));
  write(`${res}/values/ic_launcher_background.xml`, `<resources><color name="ic_launcher_background">${brand.blue}</color></resources>\n`);
  for (const [folder, color] of [['values', brand.light], ['values-night', brand.dark]]) write(`${res}/${folder}/splash_colors.xml`, `<resources><color name="splash_background">${color}</color></resources>\n`);
  for (const folder of ['mipmap-anydpi-v33', 'mipmap-television-anydpi-v33']) {
    for (const name of folder.includes('television') ? ['ic_launcher'] : ['ic_launcher', 'ic_launcher_round']) write(`${res}/${folder}/${name}.xml`, '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android"><background android:drawable="@color/ic_launcher_background"/><foreground android:drawable="@drawable/ic_launcher_foreground"/><monochrome android:drawable="@drawable/ic_launcher_monochrome"/></adaptive-icon>\n');
  }
  const splash = svg(`<rect x="96" y="96" width="96" height="96" rx="20" fill="${brand.blue}"/><g transform="translate(96 96) scale(.96)">${mark()}</g>`, 288);
  await png('assets/images/splash.png', splash, 864);
  write('design/brand/splash.svg', splash);
  console.log('Brand assets generated.');
}
main().catch(error => {console.error(error); process.exitCode = 1;});
