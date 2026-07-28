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

const server = app.listen(0, async () => {
  const baseUrl = `http://127.0.0.1:${server.address().port}/api`;
  const email = `profile${Date.now()}@example.com`;

  try {
    const register = await requestJson(`${baseUrl}/auth/register`, {
      method: 'POST',
      body: JSON.stringify({
        fullName: 'Profile Test',
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
    const authHeader = { Authorization: `Bearer ${accessToken}` };

    const getProfile = await requestJson(`${baseUrl}/profile`, { headers: authHeader });
    console.log('getProfile', getProfile.status, getProfile.body.success);

    const updateProfile = await requestJson(`${baseUrl}/profile`, {
      method: 'PATCH',
      headers: authHeader,
      body: JSON.stringify({
        bio: 'Fashion enthusiast',
        phoneNumber: '+1 555-123-4567',
        dateOfBirth: '1995-05-20',
      }),
    });
    console.log('updateProfile', updateProfile.status, updateProfile.body.success, updateProfile.body.data?.user?.bio);
    if (!updateProfile.body.success) console.log(JSON.stringify(updateProfile.body, null, 2));

    const invalidUpdate = await requestJson(`${baseUrl}/profile`, {
      method: 'PATCH',
      headers: authHeader,
      body: JSON.stringify({}),
    });
    console.log('invalidUpdate (expect 400)', invalidUpdate.status, invalidUpdate.body.success);

    const tempImagePath = path.join(process.cwd(), 'tests', 'fixture.png');
    fs.writeFileSync(
      tempImagePath,
      Buffer.from(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
        'base64',
      ),
    );

    const form = new FormData();
    form.append('profileImage', new Blob([fs.readFileSync(tempImagePath)], { type: 'image/png' }), 'fixture.png');

    const uploadPicture = await requestJson(`${baseUrl}/profile/picture`, {
      method: 'POST',
      headers: authHeader,
      body: form,
    });
    console.log(
      'uploadPicture',
      uploadPicture.status,
      uploadPicture.body.success,
      uploadPicture.body.data?.user?.profileImage,
    );
    if (!uploadPicture.body.success) console.log(JSON.stringify(uploadPicture.body, null, 2));

    const deletePicture = await requestJson(`${baseUrl}/profile/picture`, {
      method: 'DELETE',
      headers: authHeader,
    });
    console.log(
      'deletePicture',
      deletePicture.status,
      deletePicture.body.success,
      deletePicture.body.data?.user?.profileImage,
    );

    const wrongPassword = await requestJson(`${baseUrl}/profile/password`, {
      method: 'PATCH',
      headers: authHeader,
      body: JSON.stringify({ currentPassword: 'WrongPass1', newPassword: 'NewPassword123' }),
    });
    console.log('wrongPassword (expect 401)', wrongPassword.status, wrongPassword.body.success);

    const changePassword = await requestJson(`${baseUrl}/profile/password`, {
      method: 'PATCH',
      headers: authHeader,
      body: JSON.stringify({ currentPassword: 'Password123', newPassword: 'NewPassword123' }),
    });
    console.log('changePassword', changePassword.status, changePassword.body.success);

    const loginWithOldPassword = await requestJson(`${baseUrl}/auth/login`, {
      method: 'POST',
      body: JSON.stringify({ email, password: 'Password123' }),
    });
    console.log('loginWithOldPassword (expect fail)', loginWithOldPassword.status, loginWithOldPassword.body.success);

    const loginWithNewPassword = await requestJson(`${baseUrl}/auth/login`, {
      method: 'POST',
      body: JSON.stringify({ email, password: 'NewPassword123' }),
    });
    console.log('loginWithNewPassword', loginWithNewPassword.status, loginWithNewPassword.body.success);

    const newAccessToken = loginWithNewPassword.body.data.tokens.accessToken;

    const deleteWrongPassword = await requestJson(`${baseUrl}/profile`, {
      method: 'DELETE',
      headers: { Authorization: `Bearer ${newAccessToken}` },
      body: JSON.stringify({ password: 'WrongPass1' }),
    });
    console.log('deleteWrongPassword (expect 401)', deleteWrongPassword.status, deleteWrongPassword.body.success);

    const deleteAccount = await requestJson(`${baseUrl}/profile`, {
      method: 'DELETE',
      headers: { Authorization: `Bearer ${newAccessToken}` },
      body: JSON.stringify({ password: 'NewPassword123' }),
    });
    console.log('deleteAccount', deleteAccount.status, deleteAccount.body.success);

    const getProfileAfterDelete = await requestJson(`${baseUrl}/profile`, {
      headers: { Authorization: `Bearer ${newAccessToken}` },
    });
    console.log('getProfileAfterDelete (expect 401)', getProfileAfterDelete.status, getProfileAfterDelete.body.success);

    fs.unlinkSync(tempImagePath);
  } finally {
    server.close();
  }
});
