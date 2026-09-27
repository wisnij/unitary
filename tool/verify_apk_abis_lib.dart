/// Core library for the release native-library layout check.
///
/// Contains the grouping of an APK's or app bundle's entries by ABI directory
/// and the verdict against the required layout.  The two formats hold the same
/// native libraries under different roots, `lib/` in an APK and `base/lib/` in
/// a bundle, and are otherwise checked identically.  The executable wrapper,
/// which lists the archive's entries and reports the result, lives in
/// `verify_apk_abis.dart`.
library;

/// Directory holding an APK's native libraries, one subdirectory per ABI.
const String apkLibraryRoot = 'lib/';

/// Directory holding an app bundle's native libraries, one subdirectory per
/// ABI.
const String bundleLibraryRoot = 'base/lib/';

/// Returns the native-library root for an archive, chosen by its extension:
/// [apkLibraryRoot] for `.apk`, [bundleLibraryRoot] for `.aab`, ignoring case.
/// Returns null for any other file name.
String? libraryRootFor(String path) {
  final name = path.split('/').last.toLowerCase();
  if (name.length > 4 && name.endsWith('.apk')) {
    return apkLibraryRoot;
  }
  if (name.length > 4 && name.endsWith('.aab')) {
    return bundleLibraryRoot;
  }
  return null;
}

/// ABIs the release APK and bundle must carry, and the only ones they may
/// carry.
///
/// Both ARM ABIs are kept because current low-RAM devices still ship 32-bit-only
/// userspace, often on 64-bit chips.  x86_64 is left out: no phone or tablet
/// that can install Unitary needs it, and x86 Chromebooks translate 32-bit ARM.
const Set<String> expectedAbis = {'arm64-v8a', 'armeabi-v7a'};

/// Libraries every ABI directory in the release APK and bundle must contain.
///
/// The package manager picks the device's preferred ABI whenever the APK has
/// any library for it, so a directory holding a dependency's library but not
/// the Flutter engine makes the app crash on launch instead of falling back to
/// another ABI.
const Set<String> requiredLibraries = {'libflutter.so', 'libapp.so'};

/// Groups an archive's native libraries by ABI.
///
/// Takes the archive's entry names, as listed by `unzip -Z1`, and returns a map
/// from each ABI directory under [root] to the file names inside it.  [root] is
/// [apkLibraryRoot] for an APK and [bundleLibraryRoot] for a bundle.  Entries
/// outside [root], directory entries, and files directly under [root] are
/// ignored, so an ABI appears in the result only if it holds at least one file.
Map<String, Set<String>> nativeLibraries(
  Iterable<String> entries, {
  String root = apkLibraryRoot,
}) {
  final libraries = <String, Set<String>>{};
  for (final entry in entries) {
    if (!entry.startsWith(root)) {
      continue;
    }
    final parts = entry.substring(root.length).split('/');
    if (parts.length < 2 || parts.first.isEmpty || parts.last.isEmpty) {
      continue;
    }
    libraries
        .putIfAbsent(parts.first, () => <String>{})
        .add(parts.sublist(1).join('/'));
  }
  return libraries;
}

/// The kinds of layout problem [checkApkAbis] reports.
enum AbiProblemKind {
  /// An ABI directory other than those in [expectedAbis] is present.
  unexpectedAbi,

  /// An ABI directory in [expectedAbis] is absent.
  missingAbi,

  /// An expected ABI directory lacks one of [requiredLibraries].
  missingLibrary,
}

/// One way in which an archive's native-library layout departs from the
/// required one.
final class AbiProblem {
  /// An ABI directory that must not be present.
  const AbiProblem.unexpectedAbi(this.abi, {this.root = apkLibraryRoot})
    : kind = AbiProblemKind.unexpectedAbi,
      library = null;

  /// An expected ABI directory that is absent.
  const AbiProblem.missingAbi(this.abi, {this.root = apkLibraryRoot})
    : kind = AbiProblemKind.missingAbi,
      library = null;

  /// A required library absent from an expected ABI directory.
  const AbiProblem.missingLibrary(
    this.abi,
    String this.library, {
    this.root = apkLibraryRoot,
  }) : kind = AbiProblemKind.missingLibrary;

  final AbiProblemKind kind;
  final String abi;

  /// The directory holding the ABI directories: [apkLibraryRoot] or
  /// [bundleLibraryRoot].
  final String root;

  /// The missing library, for [AbiProblemKind.missingLibrary] only.
  final String? library;

  /// A one-line description for the executable's report.
  String get message => switch (kind) {
    AbiProblemKind.unexpectedAbi => 'unexpected ABI directory $root$abi/',
    AbiProblemKind.missingAbi => 'missing ABI directory $root$abi/',
    AbiProblemKind.missingLibrary => '$root$abi/ is missing $library',
  };

  @override
  bool operator ==(Object other) =>
      other is AbiProblem &&
      other.kind == kind &&
      other.abi == abi &&
      other.root == root &&
      other.library == library;

  @override
  int get hashCode => Object.hash(kind, abi, root, library);

  @override
  String toString() => 'AbiProblem($message)';
}

/// Checks an archive's native-library layout against [expectedAbis] and
/// [requiredLibraries].
///
/// Takes the archive's entry names and returns every problem found, or an
/// empty list when the layout is valid.  [root] is [apkLibraryRoot] for an APK
/// and [bundleLibraryRoot] for a bundle, as in [nativeLibraries].  Problems are
/// ordered by kind (unexpected, then missing ABIs, then missing libraries), and
/// alphabetically within each kind, so output is stable between runs.
List<AbiProblem> checkApkAbis(
  Iterable<String> entries, {
  String root = apkLibraryRoot,
}) {
  final libraries = nativeLibraries(entries, root: root);
  final present = libraries.keys.toSet();

  final unexpected = present.difference(expectedAbis).toList()..sort();
  final missing = expectedAbis.difference(present).toList()..sort();

  final missingLibraries = <AbiProblem>[];
  for (final abi in expectedAbis.intersection(present).toList()..sort()) {
    final absent = requiredLibraries.difference(libraries[abi]!).toList()
      ..sort();
    for (final library in absent) {
      missingLibraries.add(
        AbiProblem.missingLibrary(abi, library, root: root),
      );
    }
  }

  return [
    for (final abi in unexpected) AbiProblem.unexpectedAbi(abi, root: root),
    for (final abi in missing) AbiProblem.missingAbi(abi, root: root),
    ...missingLibraries,
  ];
}

/// Describes a [nativeLibraries] result as one line per ABI, for reporting.
///
/// ABIs and the libraries within each are sorted, for example
/// `armeabi-v7a: libapp.so, libflutter.so`.
List<String> describeNativeLibraries(Map<String, Set<String>> libraries) => [
  for (final abi in libraries.keys.toList()..sort())
    '$abi: ${(libraries[abi]!.toList()..sort()).join(', ')}',
];
