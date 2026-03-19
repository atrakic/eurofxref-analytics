// @ts-check
import { test, expect } from '@playwright/test';

test.describe('Euro FX Reference Rates dashboard', () => {
    test.beforeEach(async ({ page }) => {
        await page.goto('/');
    });

    test('page title is correct', async ({ page }) => {
        await expect(page).toHaveTitle(/Euro FX Reference Rates/i);
    });

    test('KPI cards are visible', async ({ page }) => {
        // BigValue labels defined in index.md
        for (const label of [
            'Currencies Tracked',
            'Latest Data',
            'EUR / USD',
            'EUR / GBP',
            'EUR / JPY',
            'EUR / CHF',
        ]) {
            await expect(page.getByText(label)).toBeVisible();
        }
    });

    test('charts are rendered', async ({ page }) => {
        // Evidence renders charts as SVG elements
        const svgs = page.locator('svg');
        await expect(svgs.first()).toBeVisible();
        expect(await svgs.count()).toBeGreaterThanOrEqual(1);
    });

    test('data table is rendered', async ({ page }) => {
        await expect(page.getByRole('table')).toBeVisible();
        // Evidence DataTable rows may be visibility:hidden in virtualized tables
        const rows = page.locator('table tr');
        expect(await rows.count()).toBeGreaterThanOrEqual(2);
    });

    test('table search is functional', async ({ page }) => {
        // Use last() to target the DataTable search, not any global search dialog
        const searchInput = page.locator('input[placeholder="Search"]').last();
        await expect(searchInput).toBeVisible();
        await searchInput.fill('USD');
        await expect(page.getByRole('table').getByText('USD')).toBeVisible();
    });

    test('no console errors on load', async ({ page }) => {
        const errors = [];
        page.on('console', (msg) => {
            if (msg.type() === 'error') errors.push(msg.text());
        });
        await page.goto('/');
        await page.waitForLoadState('networkidle');
        expect(errors).toHaveLength(0);
    });
});
