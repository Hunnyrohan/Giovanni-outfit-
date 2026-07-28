export const toUserDto = (user) => ({
  id: user.id,
  fullName: user.fullName,
  email: user.email,
  gender: user.gender,
  profileImage: user.profileImage,
  role: user.role,
  isEmailVerified: user.isEmailVerified,
  twoFactorEnabled: user.twoFactorEnabled ?? false,
  createdAt: user.createdAt,
  updatedAt: user.updatedAt,
});

export const toAuthDto = ({ user, accessToken, refreshToken }) => ({
  user: toUserDto(user),
  token: accessToken,
  refreshToken,
  tokens: {
    accessToken,
    refreshToken,
    tokenType: 'Bearer',
  },
});
