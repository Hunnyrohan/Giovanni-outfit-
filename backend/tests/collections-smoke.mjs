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
  const email = `collections${Date.now()}@example.com`;

  try {
    const register = await requestJson(`${baseUrl}/auth/register`, {
      method: 'POST',
      body: JSON.stringify({
        fullName: 'Collections Test',
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

    const item1Id = await createWardrobeItem(baseUrl, authHeader, 'Summer Dress', 'DRESS');
    const item2Id = await createWardrobeItem(baseUrl, authHeader, 'Sun Hat', 'ACCESSORY');
    const item3Id = await createWardrobeItem(baseUrl, authHeader, 'Sandals', 'SHOES');
    console.log('created wardrobe items', item1Id, item2Id, item3Id);

    const createMissingName = await requestJson(`${baseUrl}/collections`, {
      method: 'POST',
      headers: authHeader,
      body: buildFormData({}),
    });
    console.log(
      'createMissingName (expect 400)',
      createMissingName.status,
      createMissingName.body.success,
    );

    const create = await requestJson(`${baseUrl}/collections`, {
      method: 'POST',
      headers: authHeader,
      body: buildFormData(
        { name: 'Summer Vibes', description: 'Beach and sunshine outfits' },
        'coverImage',
        'cover.png',
      ),
    });
    console.log(
      'create',
      create.status,
      create.body.success,
      create.body.data?.collection?.coverImageUrl,
    );
    if (!create.body.success) console.log(JSON.stringify(create.body, null, 2));

    const collectionId = create.body.data.collection.id;

    const createDuplicateName = await requestJson(`${baseUrl}/collections`, {
      method: 'POST',
      headers: authHeader,
      body: buildFormData({ name: 'Summer Vibes' }),
    });
    console.log(
      'createDuplicateName (expect 409)',
      createDuplicateName.status,
      createDuplicateName.body.success,
    );

    const list = await requestJson(`${baseUrl}/collections`, { headers: authHeader });
    console.log(
      'list',
      list.status,
      list.body.success,
      'count=' + list.body.data?.collections?.length,
      'itemCount=' + list.body.data?.collections?.[0]?.itemCount,
    );

    const addItem1 = await requestJson(`${baseUrl}/collections/${collectionId}/items`, {
      method: 'POST',
      headers: authHeader,
      body: JSON.stringify({ wardrobeItemId: item1Id }),
    });
    console.log(
      'addItem1',
      addItem1.status,
      addItem1.body.success,
      addItem1.body.data?.collection?.itemCount,
    );

    const addItem2 = await requestJson(`${baseUrl}/collections/${collectionId}/items`, {
      method: 'POST',
      headers: authHeader,
      body: JSON.stringify({ wardrobeItemId: item2Id }),
    });
    console.log('addItem2', addItem2.status, addItem2.body.success);

    const addItem3 = await requestJson(`${baseUrl}/collections/${collectionId}/items`, {
      method: 'POST',
      headers: authHeader,
      body: JSON.stringify({ wardrobeItemId: item3Id }),
    });
    console.log(
      'addItem3 (expect itemCount 3)',
      addItem3.status,
      addItem3.body.success,
      addItem3.body.data?.collection?.itemCount,
    );

    const addDuplicateItem = await requestJson(`${baseUrl}/collections/${collectionId}/items`, {
      method: 'POST',
      headers: authHeader,
      body: JSON.stringify({ wardrobeItemId: item1Id }),
    });
    console.log(
      'addDuplicateItem (expect 409)',
      addDuplicateItem.status,
      addDuplicateItem.body.success,
    );

    const getDetail = await requestJson(`${baseUrl}/collections/${collectionId}`, {
      headers: authHeader,
    });
    const orderBefore = getDetail.body.data.collection.items.map((i) => i.wardrobeItem.name);
    console.log('getDetail order before reorder', orderBefore);

    const reorder = await requestJson(`${baseUrl}/collections/${collectionId}/items/reorder`, {
      method: 'PATCH',
      headers: authHeader,
      body: JSON.stringify({ orderedWardrobeItemIds: [item3Id, item1Id, item2Id] }),
    });
    const orderAfter = reorder.body.data?.collection?.items?.map((i) => i.wardrobeItem.name);
    console.log('reorder', reorder.status, reorder.body.success, 'newOrder=', orderAfter);

    const reorderInvalid = await requestJson(`${baseUrl}/collections/${collectionId}/items/reorder`, {
      method: 'PATCH',
      headers: authHeader,
      body: JSON.stringify({ orderedWardrobeItemIds: [item1Id, item2Id] }),
    });
    console.log(
      'reorderInvalid (expect 400, missing item3)',
      reorderInvalid.status,
      reorderInvalid.body.success,
    );

    const removeItem = await requestJson(`${baseUrl}/collections/${collectionId}/items/${item2Id}`, {
      method: 'DELETE',
      headers: authHeader,
    });
    console.log(
      'removeItem (expect itemCount 2)',
      removeItem.status,
      removeItem.body.success,
      removeItem.body.data?.collection?.itemCount,
    );

    const removeItemAgain = await requestJson(`${baseUrl}/collections/${collectionId}/items/${item2Id}`, {
      method: 'DELETE',
      headers: authHeader,
    });
    console.log(
      'removeItemAgain (expect 404)',
      removeItemAgain.status,
      removeItemAgain.body.success,
    );

    const update = await requestJson(`${baseUrl}/collections/${collectionId}`, {
      method: 'PATCH',
      headers: authHeader,
      body: buildFormData({ description: 'Updated description' }),
    });
    console.log(
      'update',
      update.status,
      update.body.success,
      update.body.data?.collection?.description,
    );

    const invalidUpdate = await requestJson(`${baseUrl}/collections/${collectionId}`, {
      method: 'PATCH',
      headers: authHeader,
      body: buildFormData({}),
    });
    console.log('invalidUpdate (expect 400)', invalidUpdate.status, invalidUpdate.body.success);

    // Cross-user isolation: another user cannot add their own wardrobe item to this collection
    const otherEmail = `collections-other-${Date.now()}@example.com`;
    const registerOther = await requestJson(`${baseUrl}/auth/register`, {
      method: 'POST',
      body: JSON.stringify({ fullName: 'Other User', email: otherEmail, password: 'Password123' }),
    });
    const otherAuthHeader = {
      Authorization: `Bearer ${registerOther.body.data.tokens.accessToken}`,
    };
    const otherItemId = await createWardrobeItem(baseUrl, otherAuthHeader, 'Other Shirt', 'TOP');

    const crossUserAdd = await requestJson(`${baseUrl}/collections/${collectionId}/items`, {
      method: 'POST',
      headers: authHeader,
      body: JSON.stringify({ wardrobeItemId: otherItemId }),
    });
    console.log(
      "crossUserAdd (expect 404, can't add another user's wardrobe item)",
      crossUserAdd.status,
      crossUserAdd.body.success,
    );

    const crossUserGetCollection = await requestJson(`${baseUrl}/collections/${collectionId}`, {
      headers: otherAuthHeader,
    });
    console.log(
      "crossUserGetCollection (expect 404, not another user's collection)",
      crossUserGetCollection.status,
      crossUserGetCollection.body.success,
    );

    const del = await requestJson(`${baseUrl}/collections/${collectionId}`, {
      method: 'DELETE',
      headers: authHeader,
    });
    console.log('delete', del.status, del.body.success);

    const getAfterDelete = await requestJson(`${baseUrl}/collections/${collectionId}`, {
      headers: authHeader,
    });
    console.log('getAfterDelete (expect 404)', getAfterDelete.status, getAfterDelete.body.success);

    const wardrobeItemStillExists = await requestJson(`${baseUrl}/wardrobe/${item1Id}`, {
      headers: authHeader,
    });
    console.log(
      'wardrobeItemStillExists after collection delete (expect 200)',
      wardrobeItemStillExists.status,
      wardrobeItemStillExists.body.success,
    );
  } finally {
    server.close();
  }
});
