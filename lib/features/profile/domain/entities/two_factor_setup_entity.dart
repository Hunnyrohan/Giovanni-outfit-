/// The provisioning payload for turning on two-factor authentication:
/// the Base32 secret the user enters (or scans, via [otpauthUrl]) into an
/// authenticator app such as Google Authenticator or Authy.
class TwoFactorSetupEntity {
  const TwoFactorSetupEntity({required this.secret, required this.otpauthUrl});

  final String secret;
  final String otpauthUrl;
}
