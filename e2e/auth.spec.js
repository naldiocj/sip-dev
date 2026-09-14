// @ts-check
import { test, expect } from '@playwright/test';

test.describe('Authentication', () => {
  test('should login with valid credentials', async ({ page }) => {
    await page.goto('/auth/login');
    
    await page.getByLabel('Login').fill('director');
    await page.getByLabel('Password').fill('Sic@2024Angola');
    await page.getByRole('button', { name: 'Entrar' }).click();
    
    await expect(page).toHaveURL('/admin/dashboard');
    await expect(page.getByText('Painel de Controlo')).toBeVisible();
  });

  test('should show error with invalid credentials', async ({ page }) => {
    await page.goto('/auth/login');
    
    await page.getByLabel('Login').fill('invalid');
    await page.getByLabel('Password').fill('wrongpassword');
    await page.getByRole('button', { name: 'Entrar' }).click();
    
    await expect(page.getByText(/Usuário não encontrado|Senha inválida/)).toBeVisible();
  });

  test('should logout successfully', async ({ page }) => {
    await page.goto('/auth/login');
    
    await page.getByLabel('Login').fill('director');
    await page.getByLabel('Password').fill('Sic@2024Angola');
    await page.getByRole('button', { name: 'Entrar' }).click();
    
    await expect(page).toHaveURL('/admin/dashboard');
    
    // Logout
    await page.getByRole('button', { name: /menu|perfil|avatar/ }).click();
    await page.getByRole('menuitem', { name: 'Sair' }).click();
    
    await expect(page).toHaveURL('/auth/login');
  });
});
