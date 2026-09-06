const buildMetadata = String.fromEnvironment(
  'BUILD_METADATA',
  defaultValue: '',
);

const projectHomeUrl = 'https://github.com/wisnij/unitary';

/// Canonical location of the current privacy policy.
///
/// The app bundles `PRIVACY.md` and renders it offline, so this points readers
/// at the copy that tracks the default branch when they want the latest.
const privacyPolicyUrl = 'https://wisnij.github.io/unitary/privacy';
