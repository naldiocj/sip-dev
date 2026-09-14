// @ts-check
import { test, expect } from '@playwright/test';

test.describe('Dashboard', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/auth/login');
    await page.getByLabel('Login').fill('director');
    await page.getByLabel('Password').fill('Sic@2024Angola');
    await page.getByRole('button', { name: 'Entrar' }).click();
    await page.waitForURL('/admin/dashboard');
  });

  test('should display dashboard title', async ({ page }) => {
    await expect(page.getByText('Painel de Controlo')).toBeVisible();
  });

  test('should display KPI cards', async ({ page }) => {
    await expect(page.getByText('Total de Processos')).toBeVisible();
    await expect(page.getByText('Em Instrução')).toBeVisible();
    await expect(page.getByText('Distribuídos')).toBeVisible();
    await expect(page.getByText('Concluídos')).toBeVisible();
  });

  test('should display navigation menu', async ({ page }) => {
    await expect(page.getByText('Organizações')).toBeVisible();
    await expect(page.getByText('Utilizadores')).toBeVisible();
    await expect(page.getByText('Processos')).toBeVisible();
    await expect(page.getByText('Diligências')).toBeVisible();
  });

  test('should navigate to organizations', async ({ page }) => {
    await page.getByText('Organizações').click();
    await expect(page).toHaveURL('/admin/organizations');
  });

  test('should navigate to users', async ({ page }) => {
    await page.getByText('Utilizadores').click();
    await expect(page).toHaveURL('/admin/users');
  });
});
