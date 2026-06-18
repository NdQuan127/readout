#!/usr/bin/env node
/**
 * export_deck_stage_pdf.mjs — PDF exporter for single-file <deck-stage> architecture
 *
 * Usage:
 *   node export_deck_stage_pdf.mjs --html <deck.html> --out <file.pdf> [--width 1920] [--height 1080]
 *
 * When to use this script?
 *   - Your deck is a **single HTML file**, all slides are `<section>` elements, wrapped in a `<deck-stage>`
 *   - In this case, `export_deck_pdf.mjs` (for multi-file decks) is not applicable
 *
 * Why you cannot just call `page.pdf()` (2026-04-20 debugging record):
 *   1. The shadow CSS of deck-stage `::slotted(section) { display: none }` makes only the active slide visible
 *   2. An outer `!important` rule under the "print" media query cannot override shadow DOM rules
 *   3. Result: The generated PDF will always have only 1 page (the active slide)
 *
 * Solution:
 *   After opening the HTML, use page.evaluate to extract all sections from the deck-stage slots,
 *   append them to a normal div under the body, inline styles to force position:relative + fixed size,
 *   add page-break-after: always to each section, and change the last one to auto to avoid a trailing blank page.
 *
 * Dependencies: playwright
 *   npm install playwright
 *
 * Output features:
 *   - Text remains vector (copyable, searchable)
 *   - 1:1 visual fidelity
 *   - Fonts must be loadable by Chromium (local fonts or Google Fonts)
 */

import { chromium } from 'playwright';
import fs from 'fs/promises';
import path from 'path';

function parseArgs() {
  const args = { width: 1920, height: 1080 };
  const a = process.argv.slice(2);
  for (let i = 0; i < a.length; i += 2) {
    const k = a[i].replace(/^--/, '');
    args[k] = a[i + 1];
  }
  if (!args.html || !args.out) {
    console.error('Usage: node export_deck_stage_pdf.mjs --html <deck.html> --out <file.pdf> [--width 1920] [--height 1080]');
    process.exit(1);
  }
  args.width = parseInt(args.width);
  args.height = parseInt(args.height);
  return args;
}

async function main() {
  const { html, out, width, height } = parseArgs();
  const htmlAbs = path.resolve(html);
  const outFile = path.resolve(out);

  await fs.access(htmlAbs).catch(() => {
    console.error(`HTML file not found: ${htmlAbs}`);
    process.exit(1);
  });

  console.log(`Rendering ${path.basename(htmlAbs)} → ${path.basename(outFile)}`);

  const browser = await chromium.launch();
  const ctx = await browser.newContext({ viewport: { width, height } });
  const page = await ctx.newPage();

  await page.goto('file://' + htmlAbs, { waitUntil: 'networkidle' });
  await page.waitForTimeout(2500);  // Wait for Google Fonts + deck-stage init

  // Core fix: extract sections from shadow DOM slot and flatten them
  const sectionCount = await page.evaluate(({ W, H }) => {
    const stage = document.querySelector('deck-stage');
    if (!stage) throw new Error('<deck-stage> not found - this script is only applicable to single-file deck-stage architecture');
    const sections = Array.from(stage.querySelectorAll(':scope > section'));
    if (!sections.length) throw new Error('No <section> found inside <deck-stage>');

    // Inject print styles
    const style = document.createElement('style');
    style.textContent = `
      @page { size: ${W}px ${H}px; margin: 0; }
      html, body { margin: 0 !important; padding: 0 !important; background: #fff; }
      deck-stage { display: none !important; }
    `;
    document.head.appendChild(style);

    // Flatten under body
    const container = document.createElement('div');
    container.id = 'print-container';
    sections.forEach(s => {
      // Inline styles get highest priority; ensure position:relative so absolute children are correctly bounded
      s.style.cssText = `
        width: ${W}px !important;
        height: ${H}px !important;
        display: block !important;
        position: relative !important;
        overflow: hidden !important;
        page-break-after: always !important;
        break-after: page !important;
        margin: 0 !important;
        padding: 0 !important;
      `;
      container.appendChild(s);
    });
    // No page break on the last page, to avoid a trailing blank page
    const last = sections[sections.length - 1];
    last.style.pageBreakAfter = 'auto';
    last.style.breakAfter = 'auto';
    document.body.appendChild(container);
    return sections.length;
  }, { W: width, H: height });

  await page.waitForTimeout(800);

  await page.pdf({
    path: outFile,
    width: `${width}px`,
    height: `${height}px`,
    printBackground: true,
    preferCSSPageSize: true,
  });

  await browser.close();

  const stat = await fs.stat(outFile);
  const kb = (stat.size / 1024).toFixed(0);
  console.log(`\n✓ Wrote ${outFile}  (${kb} KB, ${sectionCount} pages, vector)`);
  console.log(`  Verify pages: mdimport "${outFile}" && pdfinfo "${outFile}" | grep Pages`);
}

main().catch(e => { console.error(e); process.exit(1); });
