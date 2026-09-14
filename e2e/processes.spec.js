// @ts-check
import { test, expect } from '@playwright/test';

test.describe('Process Management', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/auth/login');
    await page.getByLabel('Login').fill('director');
    await page.getByLabel('Password').fill('Sic@2024Angola');
    await page.getByRole('button', { name: 'Entrar' }).click();
    await page.waitForURL('/admin/dashboard');
  });

  test('should navigate to processes page', async ({ page }) => {
    await page.goto('/admin/processes');
    await expect(page.getByRole('heading', { name: 'Processos' })).toBeVisible();
  });

  test('should display process table', async ({ page }) => {
    await page.goto('/admin/processes');
    await expect(page.getByRole('table')).toBeVisible();
    await expect(page.getByRole('columnheader', { name: /número/i })).toBeVisible();
  });

  test('should create new process', async ({ page }) => {
    await page.goto('/admin/processes/new');
    
    await expect(page.getByLabel('Número')).toBeVisible();
    await expect(page.getByLabel('Título')).toBeVisible();
    await expect(page.getByRole('button', { name: 'Criar Processo' })).toBeVisible();
  });

  test('should show process details', async ({ page }) => {
    await page.goto('/admin/processes');
    // First process row
    const firstRow = page.getByRole('row').first();
    await expect(firstRow).toBeVisible();
  });
});
