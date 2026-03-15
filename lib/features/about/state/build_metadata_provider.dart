import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../about_constants.dart';

/// Provides the build metadata string compiled into the app via
/// `--dart-define=BUILD_METADATA=...`.  Empty string when not set.
final buildMetadataProvider = Provider<String>((_) => buildMetadata);
