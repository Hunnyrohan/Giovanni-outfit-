// Smoke test for the Privacy & Security backend surface:
// change password, 2FA lifecycle (setup -> enable -> 2-step login -> disable),
// and account deletion. Hits the REAL running server on localhost:3000.
import { authenticator } from 'otplib';

const baseUrl = 'http://127.0.0.1:3000/api';

const requestJson = async (url, options = {}) => {
  const response = await fetch(url, options);
  return { status: response.status, body: await response.json() };
};

const jsonHeaders = (token) => ({
  'Content-Type': 'application/json',
  ...(token ? { Authorization: `Bearer ${token}` } : {}),
});

async function main() {
  const email = `security${Date.now()}@example.com`;
  const password = 'Password123';
  const newPassword = 'Password456';

  // 1. Register
  const register = await requestJson(`${baseUrl}/auth/register`, {
    method: 'POST',
    headers: jsonHeaders(),
    body: JSON.stringify({ fullName: 'Security Smoke', email, password }),
  });
  console.log('register:', register.status, '| twoFactorEnabled in dto:', register.body.data.user.twoFactorEnabled);
  let token = register.body.data.tokens.accessToken;

  // 2. Change password
  const changePw = await requestJson(`${baseUrl}/profile/password`, {
    method: 'PATCH',
    headers: jsonHeaders(token),
    body: JSON.stringify({ currentPassword: password, newPassword }),
  });
  console.log('change password:', changePw.status, changePw.body.message);

  // 3. Old password must now fail, new must work
  const oldLogin = await requestJson(`${baseUrl}/auth/login`, {
    method: 'POST', headers: jsonHeaders(), body: JSON.stringify({ email, password }),
  });
  console.log('login with OLD password (expect 401):', oldLogin.status);
  const newLogin = await requestJson(`${baseUrl}/auth/login`, {
    method: 'POST', headers: jsonHeaders(), body: JSON.stringify({ email, password: newPassword }),
  });
  console.log('login with NEW password:', newLogin.status);
  token = newLogin.body.data.tokens.accessToken;

  // 4. 2FA setup
  const setup = await requestJson(`${baseUrl}/auth/2fa/setup`, {
    method: 'POST', headers: jsonHeaders(token),
  });
  const secret = setup.body.data.secret;
  console.log('2fa setup:', setup.status, '| got secret:', Boolean(secret), '| otpauth url:', Boolean(setup.body.data.otpauthUrl));

  // 5. Enable with a wrong code first (expect 401), then the real code
  const badEnable = await requestJson(`${baseUrl}/auth/2fa/enable`, {
    method: 'POST', headers: jsonHeaders(token), body: JSON.stringify({ code: '000000' }),
  });
  console.log('2fa enable with WRONG code (expect 401):', badEnable.status);
  const enable = await requestJson(`${baseUrl}/auth/2fa/enable`, {
    method: 'POST', headers: jsonHeaders(token), body: JSON.stringify({ code: authenticator.generate(secret) }),
  });
  console.log('2fa enable with valid code:', enable.status, enable.body.data);

  // 6. Login now requires 2FA (no tokens in first response)
  const twoStepLogin = await requestJson(`${baseUrl}/auth/login`, {
    method: 'POST', headers: jsonHeaders(), body: JSON.stringify({ email, password: newPassword }),
  });
  const requires = twoStepLogin.body.data.requiresTwoFactor;
  const twoFactorToken = twoStepLogin.body.data.twoFactorToken;
  const leakedTokens = Boolean(twoStepLogin.body.data.tokens);
  console.log('login with 2FA on:', twoStepLogin.status, '| requiresTwoFactor:', requires, '| tokens leaked (must be false):', leakedTokens);

  // 7. Verify step - wrong code then right code
  const badVerify = await requestJson(`${baseUrl}/auth/2fa/verify`, {
    method: 'POST', headers: jsonHeaders(), body: JSON.stringify({ twoFactorToken, code: '000000' }),
  });
  console.log('2fa verify with WRONG code (expect 401):', badVerify.status);
  const verify = await requestJson(`${baseUrl}/auth/2fa/verify`, {
    method: 'POST', headers: jsonHeaders(), body: JSON.stringify({ twoFactorToken, code: authenticator.generate(secret) }),
  });
  console.log('2fa verify with valid code:', verify.status, '| tokens issued:', Boolean(verify.body.data?.tokens?.accessToken));
  token = verify.body.data.tokens.accessToken;

  // 8. Profile reflects twoFactorEnabled
  const profile = await requestJson(`${baseUrl}/profile`, { headers: jsonHeaders(token) });
  console.log('profile twoFactorEnabled:', profile.status, profile.body.data.user.twoFactorEnabled);

  // 9. Disable 2FA
  const disable = await requestJson(`${baseUrl}/auth/2fa/disable`, {
    method: 'POST', headers: jsonHeaders(token), body: JSON.stringify({ code: authenticator.generate(secret) }),
  });
  console.log('2fa disable:', disable.status, disable.body.data);

  // 10. Login is single-step again
  const plainLogin = await requestJson(`${baseUrl}/auth/login`, {
    method: 'POST', headers: jsonHeaders(), body: JSON.stringify({ email, password: newPassword }),
  });
  console.log('login after disable (single step):', plainLogin.status, '| tokens:', Boolean(plainLogin.body.data.tokens));
  token = plainLogin.body.data.tokens.accessToken;

  // 11. Delete account - wrong password first, then right one
  const badDelete = await requestJson(`${baseUrl}/profile`, {
    method: 'DELETE', headers: jsonHeaders(token), body: JSON.stringify({ password: 'WrongPass1' }),
  });
  console.log('delete account with WRONG password (expect 401):', badDelete.status);
  const del = await requestJson(`${baseUrl}/profile`, {
    method: 'DELETE', headers: jsonHeaders(token), body: JSON.stringify({ password: newPassword }),
  });
  console.log('delete account:', del.status, del.body.message);

  // 12. Deleted account can no longer log in
  const ghostLogin = await requestJson(`${baseUrl}/auth/login`, {
    method: 'POST', headers: jsonHeaders(), body: JSON.stringify({ email, password: newPassword }),
  });
  console.log('login after deletion (expect 401):', ghostLogin.status);
}

main().catch((error) => {
  console.error('SECURITY SMOKE FAILED', error);
  process.exit(1);
});
