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
  const baseUrl = `http://127.0.0.1:${server.address().port}/api/auth`;
  const email = `auth${Date.now()}@example.com`;

  try {
    const register = await requestJson(`${baseUrl}/register`, {
      method: 'POST',
      body: JSON.stringify({
        fullName: 'Auth Test',
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

    const accessToken = register.body.data.tokens.accessToken;
    const refreshToken = register.body.data.tokens.refreshToken;

    const login = await requestJson(`${baseUrl}/login`, {
      method: 'POST',
      body: JSON.stringify({
        email,
        password: 'Password123',
      }),
    });
    console.log('login', login.status, login.body.success);

    const me = await requestJson(`${baseUrl}/me`, {
      headers: { Authorization: `Bearer ${login.body.data.tokens.accessToken || accessToken}` },
    });
    console.log('me', me.status, me.body.success);

    const refresh = await requestJson(`${baseUrl}/refresh`, {
      method: 'POST',
      body: JSON.stringify({ refreshToken }),
    });
    console.log('refresh', refresh.status, refresh.body.success);

    const logout = await requestJson(`${baseUrl}/logout`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${refresh.body.data.tokens.accessToken}` },
    });
    console.log('logout', logout.status, logout.body.success);
  } finally {
    server.close();
  }
});
