import { chromium } from "playwright";
import { fileURLToPath, pathToFileURL } from "node:url";
import path from "node:path";

const here = path.dirname(fileURLToPath(import.meta.url));
const browser = await chromium.launch({
  headless: true,
  executablePath: "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
});
const page = await browser.newPage({ viewport: { width: 1920, height: 1080 }, deviceScaleFactor: 1 });

await page.goto(pathToFileURL(path.join(here, "styleframes.html")).href);
await page.evaluate(() => document.fonts.ready);

for (let index = 1; index <= 3; index += 1) {
  const frame = page.locator(`#frame-${index}`);
  await frame.screenshot({ path: path.join(here, "out", `debate-chamber-${index}.png`) });
}

await browser.close();
