import fs from 'fs';
import path from 'path';
import app from '../src/app.js';

const requestJson = async (url, options = {}) => {
  const response = await fetch(url, {
    ...options,
    headers: {
      Accept: 'application/json',
      ...(options.body && !(options.body instanceof FormData) ? { 'Content-Type': 'application/json' } : {}),
      ...(options.headers || {}),
    },
  });

  return {
    status: response.status,
    body: await response.json(),
  };
};

const pngFixture = Buffer.from(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
  'base64',
);

const buildFormData = (fields, fileFieldName, filename) => {
  const form = new FormData();
  for (const [key, value] of Object.entries(fields)) {
    form.append(key, value);
  }
  if (fileFieldName) {
    form.append(fileFieldName, new Blob([pngFixture], { type: 'image/png' }), filename);
  }
  return form;
};

const server = app.listen(0, async () => {
  const baseUrl = `http://127.0.0.1:${server.address().port}/api`;
  const email = `wardrobe${Date.now()}@example.com`;

  try {
    const register = await requestJson(`${baseUrl}/auth/register`, {
      method: 'POST',
      body: JSON.stringify({
        fullName: 'Wardrobe Test',
        email,
        password: 'Password123',
        gender: 'OTHER',
      }),
    });
    console.log('register', register.status, register.body.success);
    if (!register.body.success) {
      console.log(JSON.stringify(register.body, null, 2));
      return;
    }

    const authHeader = { Authorization: `Bearer ${register.body.data.tokens.accessToken}` };

    const createMissingImage = await requestJson(`${baseUrl}/wardrobe`, {
      method: 'POST',
      headers: authHeader,
      body: buildFormData({ name: 'No Image Jacket', category: 'outerwear' }),
    });
    console.log(
      'createMissingImage (expect 400)',
      createMissingImage.status,
      createMissingImage.body.success,
    );

    const create = await requestJson(`${baseUrl}/wardrobe`, {
      method: 'POST',
      headers: authHeader,
      body: buildFormData(
        {
          name: 'Beige Trench Coat',
          description: 'Long trench coat for autumn',
          category: 'outerwear',
          subCategory: 'coat',
          primaryColor: 'beige',
          colors: 'beige,tan',
          brand: 'Zara',
          size: 'M',
          material: 'cotton',
          season: 'autumn',
          occasion: 'casual,travel',
          tags: 'coat,autumn,favorite-fit',
        },
        'image',
        'coat.png',
      ),
    });
    console.log('create', create.status, create.body.success, create.body.data?.item?.imageUrl);
    if (!create.body.success) console.log(JSON.stringify(create.body, null, 2));

    const itemId = create.body.data.item.id;

    const create2 = await requestJson(`${baseUrl}/wardrobe`, {
      method: 'POST',
      headers: authHeader,
      body: buildFormData(
        { name: 'Blue Denim Jeans', category: 'bottom', primaryColor: 'blue', season: 'all_season' },
        'image',
        'jeans.png',
      ),
    });
    console.log('create2', create2.status, create2.body.success);

    const list = await requestJson(`${baseUrl}/wardrobe`, { headers: authHeader });
    console.log(
      'list',
      list.status,
      list.body.success,
      'count=' + list.body.data?.items?.length,
      'total=' + list.body.data?.pagination?.total,
    );

    const filtered = await requestJson(`${baseUrl}/wardrobe?category=OUTERWEAR&search=trench`, {
      headers: authHeader,
    });
    console.log(
      'filtered (expect 1)',
      filtered.status,
      filtered.body.success,
      filtered.body.data?.items?.length,
    );

    const getOne = await requestJson(`${baseUrl}/wardrobe/${itemId}`, { headers: authHeader });
    console.log('getOne', getOne.status, getOne.body.success, getOne.body.data?.item?.name);

    const getMissing = await requestJson(`${baseUrl}/wardrobe/00000000-0000-0000-0000-000000000000`, {
      headers: authHeader,
    });
    console.log('getMissing (expect 404)', getMissing.status, getMissing.body.success);

    const update = await requestJson(`${baseUrl}/wardrobe/${itemId}`, {
      method: 'PATCH',
      headers: authHeader,
      body: buildFormData({ name: 'Beige Trench Coat (Updated)', brand: 'Mango' }),
    });
    console.log(
      'update',
      update.status,
      update.body.success,
      update.body.data?.item?.name,
      update.body.data?.item?.brand,
    );

    const updateWithImage = await requestJson(`${baseUrl}/wardrobe/${itemId}`, {
      method: 'PATCH',
      headers: authHeader,
      body: buildFormData({}, 'image', 'coat-v2.png'),
    });
    console.log(
      'updateWithImage',
      updateWithImage.status,
      updateWithImage.body.success,
      updateWithImage.body.data?.item?.imageUrl,
    );

    const invalidUpdate = await requestJson(`${baseUrl}/wardrobe/${itemId}`, {
      method: 'PATCH',
      headers: authHeader,
      body: buildFormData({}),
    });
    console.log('invalidUpdate (expect 400)', invalidUpdate.status, invalidUpdate.body.success);

    const favorite = await requestJson(`${baseUrl}/wardrobe/${itemId}/favorite`, {
      method: 'PATCH',
      headers: authHeader,
      body: JSON.stringify({ isFavorite: true }),
    });
    console.log(
      'favorite',
      favorite.status,
      favorite.body.success,
      favorite.body.data?.item?.isFavorite,
    );

    const favoriteFiltered = await requestJson(`${baseUrl}/wardrobe?favorite=true`, {
      headers: authHeader,
    });
    console.log(
      'favoriteFiltered (expect 1)',
      favoriteFiltered.status,
      favoriteFiltered.body.data?.items?.length,
    );

    const stats = await requestJson(`${baseUrl}/wardrobe/stats`, { headers: authHeader });
    console.log('stats', stats.status, stats.body.success, JSON.stringify(stats.body.data?.stats));

    const otherUserEmail = `wardrobe-other-${Date.now()}@example.com`;
    const registerOther = await requestJson(`${baseUrl}/auth/register`, {
      method: 'POST',
      body: JSON.stringify({
        fullName: 'Other User',
        email: otherUserEmail,
        password: 'Password123',
      }),
    });
    const otherAuthHeader = {
      Authorization: `Bearer ${registerOther.body.data.tokens.accessToken}`,
    };
    const crossUserGet = await requestJson(`${baseUrl}/wardrobe/${itemId}`, {
      headers: otherAuthHeader,
    });
    console.log(
      'crossUserGet (expect 404, not another user\'s item)',
      crossUserGet.status,
      crossUserGet.body.success,
    );

    const del = await requestJson(`${baseUrl}/wardrobe/${itemId}`, {
      method: 'DELETE',
      headers: authHeader,
    });
    console.log('delete', del.status, del.body.success);

    const getAfterDelete = await requestJson(`${baseUrl}/wardrobe/${itemId}`, {
      headers: authHeader,
    });
    console.log('getAfterDelete (expect 404)', getAfterDelete.status, getAfterDelete.body.success);
  } finally {
    server.close();
  }
});
