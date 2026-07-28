import app from '../src/app.js';

const requestJson = async (url, options = {}) => {
  const response = await fetch(url, {
    ...options,
    headers: {
      Accept: 'application/json',
      ...(options.body ? { 'Content-Type': 'application/json' } : {}),
      ...(options.headers || {}),
    },
  });

  return {
    status: response.status,
    body: await response.json(),
  };
};

const server = app.listen(0, async () => {
  const baseUrl = `http://127.0.0.1:${server.address().port}/api`;
  const email = `ai${Date.now()}@example.com`;

  try {
    const register = await requestJson(`${baseUrl}/auth/register`, {
      method: 'POST',
      body: JSON.stringify({
        fullName: 'AI Smoke Test',
        email,
        password: 'Password123',
        gender: 'OTHER',
      }),
    });
    console.log('register', register.status, register.body.success);

    const accessToken = register.body.data.tokens.accessToken;
    const authHeader = { Authorization: `Bearer ${accessToken}` };

    const chat1 = await requestJson(`${baseUrl}/ai/chat`, {
      method: 'POST',
      headers: authHeader,
      body: JSON.stringify({ message: 'What should I wear to a business meeting?' }),
    });
    console.log('chat (new conversation)', chat1.status, chat1.body.success);
    if (!chat1.body.success) {
      console.log(JSON.stringify(chat1.body, null, 2));
    }

    const chatId = chat1.body.data?.chat?.id;

    if (chatId) {
      const chat2 = await requestJson(`${baseUrl}/ai/chat`, {
        method: 'POST',
        headers: authHeader,
        body: JSON.stringify({ chatId, message: 'What color shoes go with that?' }),
      });
      console.log('chat (continue conversation)', chat2.status, chat2.body.success);
    }

    const recommend = await requestJson(`${baseUrl}/ai/recommend`, {
      method: 'POST',
      headers: authHeader,
      body: JSON.stringify({ occasion: 'wedding', notes: 'outdoor, summer' }),
    });
    console.log('recommend', recommend.status, recommend.body.success);
    if (!recommend.body.success) {
      console.log(JSON.stringify(recommend.body, null, 2));
    }

    const history = await requestJson(`${baseUrl}/ai/history`, { headers: authHeader });
    console.log('history list', history.status, history.body.success, `chats=${history.body.data?.chats?.length}`);

    if (chatId) {
      const historyDetail = await requestJson(`${baseUrl}/ai/history/${chatId}`, { headers: authHeader });
      console.log(
        'history detail',
        historyDetail.status,
        historyDetail.body.success,
        `messages=${historyDetail.body.data?.chat?.messages?.length}`,
      );

      const deleteOne = await requestJson(`${baseUrl}/ai/history/${chatId}`, {
        method: 'DELETE',
        headers: authHeader,
      });
      console.log('delete one', deleteOne.status, deleteOne.body.success);
    }

    const deleteAll = await requestJson(`${baseUrl}/ai/history`, {
      method: 'DELETE',
      headers: authHeader,
    });
    console.log('delete all', deleteAll.status, deleteAll.body.success);

    const unauthenticated = await requestJson(`${baseUrl}/ai/chat`, {
      method: 'POST',
      body: JSON.stringify({ message: 'hi' }),
    });
    console.log('chat without auth (expect 401)', unauthenticated.status, unauthenticated.body.success === false);
  } finally {
    server.close();
  }
});
