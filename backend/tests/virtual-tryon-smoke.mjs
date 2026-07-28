import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const baseUrl = 'http://127.0.0.1:3000/api';

const requestJson = async (url, options = {}) => {
  const response = await fetch(url, options);
  return { status: response.status, body: await response.json() };
};

const GARMENT_PNG_BYTES = fs.readFileSync(path.join(__dirname, 'fixtures', 'garment.png'));
const PERSON_PNG_BYTES = fs.readFileSync(path.join(__dirname, 'fixtures', 'person.png'));

async function main() {
  const email = `tryon${Date.now()}@example.com`;

  const register = await requestJson(`${baseUrl}/auth/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ fullName: 'TryOn Smoke', email, password: 'Password123' }),
  });
  console.log('register', register.status, register.body.success);
  const token = register.body.data.tokens.accessToken;
  const authHeader = { Authorization: `Bearer ${token}` };

  // Create a wardrobe item with a real image to use as the garment.
  const wardrobeForm = new FormData();
  wardrobeForm.append('name', 'Smoke Test Shirt');
  wardrobeForm.append('category', 'TOP');
  wardrobeForm.append('image', new Blob([GARMENT_PNG_BYTES], { type: 'image/png' }), 'shirt.png');

  const wardrobeItem = await requestJson(`${baseUrl}/wardrobe`, {
    method: 'POST',
    headers: authHeader,
    body: wardrobeForm,
  });
  console.log('create wardrobe item', wardrobeItem.status, wardrobeItem.body.success);
  if (!wardrobeItem.body.success) {
    console.log(JSON.stringify(wardrobeItem.body, null, 2));
    return;
  }
  const wardrobeItemId = wardrobeItem.body.data.item.id;

  // Create the virtual try-on job.
  const tryOnForm = new FormData();
  tryOnForm.append('wardrobeItemId', wardrobeItemId);
  tryOnForm.append('personImage', new Blob([PERSON_PNG_BYTES], { type: 'image/png' }), 'person.png');

  const created = await requestJson(`${baseUrl}/virtual-tryon`, {
    method: 'POST',
    headers: authHeader,
    body: tryOnForm,
  });
  console.log('create try-on', created.status, created.body.success, created.body.data?.tryOn?.status);
  if (!created.body.success) {
    console.log(JSON.stringify(created.body, null, 2));
    return;
  }
  const tryOnId = created.body.data.tryOn.id;

  // Poll until terminal.
  let finalTryOn = null;
  for (let attempt = 0; attempt < 40; attempt += 1) {
    await new Promise((resolve) => setTimeout(resolve, 3000));
    const statusResponse = await requestJson(`${baseUrl}/virtual-tryon/${tryOnId}`, { headers: authHeader });
    console.log(`poll #${attempt + 1}`, statusResponse.status, statusResponse.body.data?.tryOn?.status);
    if (!statusResponse.body.success) {
      console.log(JSON.stringify(statusResponse.body, null, 2));
      return;
    }
    if (['COMPLETED', 'FAILED'].includes(statusResponse.body.data.tryOn.status)) {
      finalTryOn = statusResponse.body.data.tryOn;
      break;
    }
  }

  if (!finalTryOn) {
    console.log('TIMED OUT waiting for try-on to finish');
    return;
  }

  console.log('final try-on', JSON.stringify(finalTryOn, null, 2));

  if (finalTryOn.status === 'COMPLETED') {
    const imageResponse = await fetch(`${baseUrl}${finalTryOn.resultImageUrl}`, { headers: authHeader });
    console.log('fetch result image', imageResponse.status, imageResponse.headers.get('content-type'));

    const saveResponse = await requestJson(`${baseUrl}/virtual-tryon/${tryOnId}/save`, {
      method: 'POST',
      headers: { ...authHeader, 'Content-Type': 'application/json' },
      body: JSON.stringify({ title: 'My Smoke Test Look' }),
    });
    console.log('save to outfits', saveResponse.status, saveResponse.body.success);
  }

  const historyResponse = await requestJson(`${baseUrl}/virtual-tryon/history`, { headers: authHeader });
  console.log('history', historyResponse.status, historyResponse.body.data?.tryOns?.length);

  const deleteResponse = await requestJson(`${baseUrl}/virtual-tryon/${tryOnId}`, {
    method: 'DELETE',
    headers: authHeader,
  });
  console.log('delete', deleteResponse.status, deleteResponse.body.success);
}

main().catch((error) => {
  console.error('SMOKE TEST FAILED', error);
  process.exit(1);
});
