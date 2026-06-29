import { test, expect } from '@playwright/test';
import fs from 'fs';
import path from 'path';

/**
 * Universal smoke test — customize heading and nav labels per project.
 * Reads optional .qa/project.yaml navigation labels from env or hardcode below.
 */
const EVIDENCE_DIR = '.qa/evidence/smoke';

test.beforeAll(() => {
  fs.mkdirSync(EVIDENCE_DIR, { recursive: true });
});

test('app loads and shows main shell', async ({ page }) => {
  const errors: string[] = [];
  page.on('pageerror', (e) => errors.push(e.message));

  await page.goto('/');
  await expect(page.locator('body')).toBeVisible();

  await page.screenshot({
    path: path.join(EVIDENCE_DIR, '01-app-loads.png'),
    fullPage: true,
  });

  expect(errors, `Console errors: ${errors.join(', ')}`).toEqual([]);
});

test('primary navigation is reachable', async ({ page }) => {
  await page.goto('/');

  // Customize: match nav button text from your App header
  const navLabels = process.env.QA_NAV_LABELS?.split(',') ?? ['Home'];

  for (let i = 0; i < navLabels.length; i++) {
    const label = navLabels[i].trim();
    const btn = page.getByRole('button', { name: label }).or(page.getByRole('link', { name: label }));
    if (await btn.count()) {
      await btn.first().click();
      await page.screenshot({
        path: path.join(EVIDENCE_DIR, `02-nav-${i + 1}-${label.replace(/\s+/g, '-').toLowerCase()}.png`),
        fullPage: true,
      });
    }
  }
});
