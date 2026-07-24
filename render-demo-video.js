#!/usr/bin/env node
/**
 * Renders the BotSquirrel hero demo videos from demo-video-source.html.
 *
 *   node render-demo-video.js          # both languages
 *   node render-demo-video.js en       # just the English cut
 *
 * Needs Playwright's chromium and ffmpeg. Playwright is not a dependency of
 * this repo, so the script resolves it from the app repo's node_modules; set
 * PLAYWRIGHT_PATH to override.
 *
 * How it works: demo-video-source.html exposes window.renderFrame(t). We step
 * t frame by frame at 30fps, screenshot each frame to a temp dir, then let
 * ffmpeg stitch them into H.264 (yuv420p, +faststart) and pull a poster frame
 * out of the middle of the thread. Nothing is timing-dependent, so re-renders
 * are byte-for-byte reproducible.
 */
const fs = require("fs");
const os = require("os");
const path = require("path");
const { execFileSync } = require("child_process");

const PW = process.env.PLAYWRIGHT_PATH ||
  "/Users/samkicheung/.claude/worktrees/botlocal-light-theme-redesign-86b66b/botlocal/node_modules/playwright";
const { chromium } = require(PW);

const ROOT = __dirname;
const FFMPEG = process.env.FFMPEG || "/opt/homebrew/bin/ffmpeg";
const FPS = 30;
const W = 1080, H = 1920;

const OUT = {
  en: { video: "botsquirrel-demo-en.mp4", poster: "demo-poster-en.jpg", posterAt: 17.5 },
  zh: { video: "botsquirrel-demo-zh.mp4", poster: "demo-poster-zh.jpg", posterAt: 22.2 },
};

async function render(lang) {
  const cfg = OUT[lang];
  const tmp = fs.mkdtempSync(path.join(os.tmpdir(), `bsq-${lang}-`));
  const browser = await chromium.launch({ args: ["--force-color-profile=srgb", "--font-render-hinting=none"] });
  const page = await browser.newPage({ viewport: { width: W, height: H }, deviceScaleFactor: 1 });

  await page.goto("file://" + path.join(ROOT, "demo-video-source.html") + "?lang=" + lang,
    { waitUntil: "load" });
  await page.waitForTimeout(600); // let fonts/emoji settle before the first measure

  const duration = await page.evaluate(() => window.DURATION);
  const total = Math.round(duration * FPS);
  process.stdout.write(`[${lang}] ${total} frames @ ${FPS}fps -> ${tmp}\n`);

  for (let i = 0; i < total; i++) {
    await page.evaluate((t) => window.renderFrame(t), i / FPS);
    await page.screenshot({
      path: path.join(tmp, String(i).padStart(5, "0") + ".jpg"),
      type: "jpeg", quality: 95,
    });
    if (i % 150 === 0) process.stdout.write(`[${lang}]   frame ${i}/${total}\n`);
  }
  await browser.close();

  const video = path.join(ROOT, cfg.video);
  // The JPEG frames are full-range; scale back to limited (tv) range so the
  // MP4 is plain yuv420p and plays identically everywhere.
  execFileSync(FFMPEG, [
    "-y", "-framerate", String(FPS), "-i", path.join(tmp, "%05d.jpg"),
    "-vf", "scale=in_range=full:out_range=tv,format=yuv420p",
    "-c:v", "libx264", "-profile:v", "high", "-level", "4.0",
    "-color_range", "tv", "-crf", "27", "-preset", "veryslow",
    "-movflags", "+faststart", "-an", video,
  ], { stdio: "inherit" });

  // poster: a strong frame from the middle of the thread, never the title card
  execFileSync(FFMPEG, [
    "-y", "-i", path.join(tmp, String(Math.round(cfg.posterAt * FPS)).padStart(5, "0") + ".jpg"),
    "-frames:v", "1", "-update", "1", "-q:v", "4", path.join(ROOT, cfg.poster),
  ], { stdio: "inherit" });

  fs.rmSync(tmp, { recursive: true, force: true });
  const kb = (fs.statSync(video).size / 1024).toFixed(0);
  process.stdout.write(`[${lang}] done: ${cfg.video} (${kb} KB), ${cfg.poster}\n`);
}

(async () => {
  const langs = process.argv[2] ? [process.argv[2]] : ["en", "zh"];
  for (const l of langs) await render(l);
})();
