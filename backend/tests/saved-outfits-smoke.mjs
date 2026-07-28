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
    if (Array.isArray(value)) {
      value.forEach((entry) => form.append(key, entry));
    } else {
      form.append(key, value);
    }
  }
  if (fileFieldName) {
    form.append(fileFieldName, new Blob([pngFixture], { type: 'image/png' }), filename);
  }
  return form;
};

const createWardrobeItem = async (baseUrl, authHeader, name, category) => {
  const response = await requestJson(`${baseUrl}/wardrobe`, {
    method: 'POST',
    headers: authHeader,
    body: buildFormData({ name, category }, 'image', 'item.png'),
  });
  return response.body.data.item.id;
};

const server = app.listen(0, async () => {
  const baseUrl = `http://127.0.0.1:${server.address().port}/api`;
  const email = `saved-outfits${Date.now()}@example.com`;

  try {
    const register = await requestJson(`${baseUrl}/auth/register`, {
      method: 'POST',
      body: JSON.stringify({
        fullName: 'Saved Outfits Test',
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

    const item1Id = await createWardrobeItem(baseUrl, authHeader, 'Denim Jacket', 'OUTERWEAR');
    const item2Id = await createWardrobeItem(baseUrl, authHeader, 'White Sneakers', 'SHOES');
    const item3Id = await createWardrobeItem(baseUrl, authHeader, 'Graphic Tee', 'TOP');
    console.log('created wardrobe items', item1Id, item2Id, item3Id);

    const createMissingItems = await requestJson(`${baseUrl}/saved-outfits`, {
      method: 'POST',
      headers: authHeader,
      body: buildFormData({ name: 'No Items Outfit' }),
    });
    console.log(
      'createMissingItems (expect 400, no wardrobeItemIds)',
      createMissingItems.status,
      createMissingItems.body.success,
    );

    const create = await requestJson(`${baseUrl}/saved-outfits`, {
      method: 'POST',
      headers: authHeader,
      body: buildFormData(
        {
          name: 'Weekend Casual',
          notes: 'Comfy weekend look',
          occasion: 'CASUAL',
          season: 'AUTUMN',
          wardrobeItemIds: [item1Id, item2Id],
        },
        'coverImage',
        'cover.png',
      ),
    });
    console.log(
      'create',
      create.status,
      create.body.success,
      create.body.data?.savedOutfit?.coverImageUrl,
      'itemCount=' + create.body.data?.savedOutfit?.itemCount,
    );
    if (!create.body.success) console.log(JSON.stringify(create.body, null, 2));

    const outfitId = create.body.data.savedOutfit.id;

    const list = await requestJson(`${baseUrl}/saved-outfits`, { headers: authHeader });
    console.log(
      'list',
      list.status,
      list.body.success,
      'count=' + list.body.data?.savedOutfits?.length,
      'itemCount=' + list.body.data?.savedOutfits?.[0]?.itemCount,
    );

    const filterBySeason = await requestJson(`${baseUrl}/saved-outfits?season=AUTUMN`, {
      headers: authHeader,
    });
    console.log(
      'filterBySeason (expect 1)',
      filterBySeason.status,
      filterBySeason.body.data?.savedOutfits?.length,
    );

    const filterByOccasionMismatch = await requestJson(`${baseUrl}/saved-outfits?occasion=FORMAL`, {
      headers: authHeader,
    });
    console.log(
      'filterByOccasionMismatch (expect 0)',
      filterByOccasionMismatch.status,
      filterByOccasionMismatch.body.data?.savedOutfits?.length,
    );

    const searchByName = await requestJson(`${baseUrl}/saved-outfits?search=weekend`, {
      headers: authHeader,
    });
    console.log(
      'searchByName (expect 1)',
      searchByName.status,
      searchByName.body.data?.savedOutfits?.length,
    );

    const getDetail = await requestJson(`${baseUrl}/saved-outfits/${outfitId}`, {
      headers: authHeader,
    });
    console.log(
      'getDetail',
      getDetail.status,
      getDetail.body.success,
      getDetail.body.data?.savedOutfit?.items?.map((i) => i.wardrobeItem.name),
    );

    const updateFieldsOnly = await requestJson(`${baseUrl}/saved-outfits/${outfitId}`, {
      method: 'PATCH',
      headers: authHeader,
      body: buildFormData({ name: 'Weekend Casual v2', occasion: 'TRAVEL' }),
    });
    console.log(
      'updateFieldsOnly',
      updateFieldsOnly.status,
      updateFieldsOnly.body.success,
      updateFieldsOnly.body.data?.savedOutfit?.name,
      updateFieldsOnly.body.data?.savedOutfit?.occasion,
    );

    const updateImageOnly = await requestJson(`${baseUrl}/saved-outfits/${outfitId}`, {
      method: 'PATCH',
      headers: authHeader,
      body: buildFormData({}, 'coverImage', 'cover2.png'),
    });
    console.log(
      'updateImageOnly (image-only update must not be rejected)',
      updateImageOnly.status,
      updateImageOnly.body.success,
    );

    const addItem = await requestJson(`${baseUrl}/saved-outfits/${outfitId}`, {
      method: 'PATCH',
      headers: authHeader,
      body: buildFormData({ addWardrobeItemIds: [item3Id] }),
    });
    console.log(
      'addItem (expect itemCount 3)',
      addItem.status,
      addItem.body.success,
      addItem.body.data?.savedOutfit?.itemCount,
    );

    const removeItem = await requestJson(`${baseUrl}/saved-outfits/${outfitId}`, {
      method: 'PATCH',
      headers: authHeader,
      body: buildFormData({ removeWardrobeItemIds: [item3Id] }),
    });
    console.log(
      'removeItem (expect itemCount 2)',
      removeItem.status,
      removeItem.body.success,
      removeItem.body.data?.savedOutfit?.itemCount,
    );

    const removeAllItems = await requestJson(`${baseUrl}/saved-outfits/${outfitId}`, {
      method: 'PATCH',
      headers: authHeader,
      body: buildFormData({ removeWardrobeItemIds: [item1Id, item2Id] }),
    });
    console.log(
      'removeAllItems (expect 400, cannot leave outfit with zero items)',
      removeAllItems.status,
      removeAllItems.body.success,
    );

    const invalidUpdate = await requestJson(`${baseUrl}/saved-outfits/${outfitId}`, {
      method: 'PATCH',
      headers: authHeader,
      body: buildFormData({}),
    });
    console.log('invalidUpdate (expect 400, no fields/items/image)', invalidUpdate.status, invalidUpdate.body.success);

    const setFavorite = await requestJson(`${baseUrl}/saved-outfits/${outfitId}/favorite`, {
      method: 'PATCH',
      headers: authHeader,
      body: JSON.stringify({ isFavorite: true }),
    });
    console.log(
      'setFavorite',
      setFavorite.status,
      setFavorite.body.success,
      setFavorite.body.data?.savedOutfit?.isFavorite,
    );

    const filterByFavorite = await requestJson(`${baseUrl}/saved-outfits?favorite=true`, {
      headers: authHeader,
    });
    console.log(
      'filterByFavorite (expect 1)',
      filterByFavorite.status,
      filterByFavorite.body.data?.savedOutfits?.length,
    );

    const duplicate = await requestJson(`${baseUrl}/saved-outfits/${outfitId}/duplicate`, {
      method: 'POST',
      headers: authHeader,
    });
    console.log(
      'duplicate',
      duplicate.status,
      duplicate.body.success,
      duplicate.body.data?.savedOutfit?.name,
      'itemCount=' + duplicate.body.data?.savedOutfit?.itemCount,
    );
    const duplicateId = duplicate.body.data?.savedOutfit?.id;

    const listAfterDuplicate = await requestJson(`${baseUrl}/saved-outfits`, { headers: authHeader });
    console.log(
      'listAfterDuplicate (expect 2)',
      listAfterDuplicate.status,
      listAfterDuplicate.body.data?.savedOutfits?.length,
    );

    // Cross-user isolation
    const otherEmail = `saved-outfits-other-${Date.now()}@example.com`;
    const registerOther = await requestJson(`${baseUrl}/auth/register`, {
      method: 'POST',
      body: JSON.stringify({ fullName: 'Other User', email: otherEmail, password: 'Password123' }),
    });
    const otherAuthHeader = {
      Authorization: `Bearer ${registerOther.body.data.tokens.accessToken}`,
    };
    const otherItemId = await createWardrobeItem(baseUrl, otherAuthHeader, 'Other Shirt', 'TOP');

    const crossUserCreate = await requestJson(`${baseUrl}/saved-outfits`, {
      method: 'POST',
      headers: authHeader,
      body: buildFormData({ name: 'Cross User Outfit', wardrobeItemIds: [otherItemId] }),
    });
    console.log(
      "crossUserCreate (expect 404, can't use another user's wardrobe item)",
      crossUserCreate.status,
      crossUserCreate.body.success,
    );

    const crossUserGet = await requestJson(`${baseUrl}/saved-outfits/${outfitId}`, {
      headers: otherAuthHeader,
    });
    console.log(
      "crossUserGet (expect 404, not another user's saved outfit)",
      crossUserGet.status,
      crossUserGet.body.success,
    );

    const del = await requestJson(`${baseUrl}/saved-outfits/${outfitId}`, {
      method: 'DELETE',
      headers: authHeader,
    });
    console.log('delete', del.status, del.body.success);

    const getAfterDelete = await requestJson(`${baseUrl}/saved-outfits/${outfitId}`, {
      headers: authHeader,
    });
    console.log('getAfterDelete (expect 404)', getAfterDelete.status, getAfterDelete.body.success);

    const wardrobeItemsStillExist = await requestJson(`${baseUrl}/wardrobe/${item1Id}`, {
      headers: authHeader,
    });
    console.log(
      'wardrobeItemStillExists after saved outfit delete (expect 200)',
      wardrobeItemsStillExist.status,
      wardrobeItemsStillExist.body.success,
    );

    const cleanupDuplicate = await requestJson(`${baseUrl}/saved-outfits/${duplicateId}`, {
      method: 'DELETE',
      headers: authHeader,
    });
    console.log('cleanupDuplicate', cleanupDuplicate.status, cleanupDuplicate.body.success);
  } finally {
    server.close();
  }
});
