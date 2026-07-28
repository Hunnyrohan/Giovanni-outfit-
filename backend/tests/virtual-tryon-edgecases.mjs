import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const baseUrl = 'http://127.0.0.1:3000/api';

const requestJson = async (url, options = {}) => {
  const response = await fetch(url, options);
  let body = null;
  try {
    body = await response.json();
  } catch {
    body = null;
  }
  return { status: response.status, body };
};

const GARMENT_PNG_BYTES = fs.readFileSync(path.join(__dirname, 'fixtures', 'garment.png'));
const PERSON_PNG_BYTES = fs.readFileSync(path.join(__dirname, 'fixtures', 'person.png'));

const results = [];
const record = (name, pass, detail) => {
  results.push({ name, pass, detail });
  console.log(`${pass ? 'PASS' : 'FAIL'} - ${name}${detail ? ` (${detail})` : ''}`);
};

async function main() {
  const email = `edge${Date.now()}@example.com`;
  const register = await requestJson(`${baseUrl}/auth/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ fullName: 'Edge Case Tester', email, password: 'Password123' }),
  });
  const token = register.body.data.tokens.accessToken;
  const authHeader = { Authorization: `Bearer ${token}` };

  const wardrobeForm = new FormData();
  wardrobeForm.append('name', 'Edge Case Shirt');
  wardrobeForm.append('category', 'TOP');
  wardrobeForm.append('image', new Blob([GARMENT_PNG_BYTES], { type: 'image/png' }), 'shirt.png');
  const wardrobeItem = await requestJson(`${baseUrl}/wardrobe`, {
    method: 'POST',
    headers: authHeader,
    body: wardrobeForm,
  });
  const wardrobeItemId = wardrobeItem.body.data.item.id;

  // 1. Invalid JWT
  {
    const form = new FormData();
    form.append('wardrobeItemId', wardrobeItemId);
    form.append('personImage', new Blob([PERSON_PNG_BYTES], { type: 'image/png' }), 'person.png');
    const res = await requestJson(`${baseUrl}/virtual-tryon`, {
      method: 'POST',
      headers: { Authorization: 'Bearer not-a-real-token' },
      body: form,
    });
    record('Invalid JWT -> 401', res.status === 401, `status=${res.status}`);
  }

  // 2. Deleted wardrobe item
  {
    const tempWardrobeForm = new FormData();
    tempWardrobeForm.append('name', 'Temp Shirt To Delete');
    tempWardrobeForm.append('category', 'TOP');
    tempWardrobeForm.append('image', new Blob([GARMENT_PNG_BYTES], { type: 'image/png' }), 'shirt.png');
    const tempItem = await requestJson(`${baseUrl}/wardrobe`, {
      method: 'POST',
      headers: authHeader,
      body: tempWardrobeForm,
    });
    const tempItemId = tempItem.body.data.item.id;
    const delRes = await requestJson(`${baseUrl}/wardrobe/${tempItemId}`, {
      method: 'DELETE',
      headers: authHeader,
    });

    const form = new FormData();
    form.append('wardrobeItemId', tempItemId);
    form.append('personImage', new Blob([PERSON_PNG_BYTES], { type: 'image/png' }), 'person.png');
    const res = await requestJson(`${baseUrl}/virtual-tryon`, {
      method: 'POST',
      headers: authHeader,
      body: form,
    });
    record(
      'Deleted/archived wardrobe item -> 404 (not 500)',
      res.status === 404 || (res.status !== 500 && res.status !== 201 && res.status !== 202),
      `delete_status=${delRes.status}, tryon_status=${res.status}, body=${JSON.stringify(res.body)}`,
    );
  }

  // 3. Missing person image
  {
    const form = new FormData();
    form.append('wardrobeItemId', wardrobeItemId);
    const res = await requestJson(`${baseUrl}/virtual-tryon`, {
      method: 'POST',
      headers: authHeader,
      body: form,
    });
    record('Missing person image -> 400 (not 500)', res.status === 400, `status=${res.status}, body=${JSON.stringify(res.body)}`);
  }

  // 4. Invalid image format (a .txt file posing as personImage)
  {
    const form = new FormData();
    form.append('wardrobeItemId', wardrobeItemId);
    form.append('personImage', new Blob([Buffer.from('this is not an image')], { type: 'text/plain' }), 'notanimage.txt');
    const res = await requestJson(`${baseUrl}/virtual-tryon`, {
      method: 'POST',
      headers: authHeader,
      body: form,
    });
    record(
      'Invalid image format -> rejected gracefully (not 201/202, not 500)',
      res.status !== 201 && res.status !== 202 && res.status !== 500,
      `status=${res.status}, body=${JSON.stringify(res.body)}`,
    );
  }

  // 5. Nonexistent wardrobe item id (valid UUID format, doesn't exist)
  {
    const form = new FormData();
    form.append('wardrobeItemId', '00000000-0000-0000-0000-000000000000');
    form.append('personImage', new Blob([PERSON_PNG_BYTES], { type: 'image/png' }), 'person.png');
    const res = await requestJson(`${baseUrl}/virtual-tryon`, {
      method: 'POST',
      headers: authHeader,
      body: form,
    });
    record('Nonexistent wardrobeItemId -> 404 (not 500)', res.status === 404, `status=${res.status}, body=${JSON.stringify(res.body)}`);
  }

  // 6. Status check for nonexistent try-on job id
  {
    const res = await requestJson(`${baseUrl}/virtual-tryon/00000000-0000-0000-0000-000000000000`, {
      headers: authHeader,
    });
    record('Status check on nonexistent job -> 404', res.status === 404, `status=${res.status}`);
  }

  // 7. Concurrent duplicate requests (simulating double-tap on Generate)
  {
    const makeForm = () => {
      const form = new FormData();
      form.append('wardrobeItemId', wardrobeItemId);
      form.append('personImage', new Blob([PERSON_PNG_BYTES], { type: 'image/png' }), 'person.png');
      return form;
    };
    const [resA, resB] = await Promise.all([
      requestJson(`${baseUrl}/virtual-tryon`, { method: 'POST', headers: authHeader, body: makeForm() }),
      requestJson(`${baseUrl}/virtual-tryon`, { method: 'POST', headers: authHeader, body: makeForm() }),
    ]);
    const bothHandled = [resA.status, resB.status].every((s) => s === 202 || s === 429);
    record(
      'Concurrent duplicate requests -> both handled (202 or rate-limited 429), no crash',
      bothHandled,
      `statusA=${resA.status}, statusB=${resB.status}`,
    );

    // Clean up any jobs created by this test.
    for (const res of [resA, resB]) {
      if (res.status === 202 && res.body?.data?.tryOn?.id) {
        await requestJson(`${baseUrl}/virtual-tryon/${res.body.data.tryOn.id}`, {
          method: 'DELETE',
          headers: authHeader,
        });
      }
    }
  }

  console.log('\n=== SUMMARY ===');
  const failed = results.filter((r) => !r.pass);
  console.log(`${results.length - failed.length}/${results.length} passed`);
  if (failed.length > 0) {
    console.log('FAILURES:', JSON.stringify(failed, null, 2));
    process.exitCode = 1;
  }
}

main().catch((error) => {
  console.error('EDGE CASE TEST SCRIPT FAILED', error);
  process.exit(1);
});
