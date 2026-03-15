import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../settings/state/package_info_provider.dart';
import '../about_constants.dart';
import '../state/build_metadata_provider.dart';
import 'license_screen.dart';

/// About screen with version, build, license, and project link.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  void _copyToClipboard(BuildContext context, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $value'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveBuildMetadata = ref.watch(buildMetadataProvider);
    final version = ref
        .watch(packageInfoProvider)
        .when(
          data: (info) => info.version,
          loading: () => '…',
          error: (_, _) => 'unknown',
        );

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Version'),
            subtitle: Text(version),
            onLongPress: () => _copyToClipboard(context, version),
          ),
          if (effectiveBuildMetadata.isNotEmpty)
            ListTile(
              title: const Text('Build'),
              subtitle: Text(effectiveBuildMetadata),
              onLongPress: () =>
                  _copyToClipboard(context, effectiveBuildMetadata),
            ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('License terms'),
            subtitle: const Text('GNU AGPL 3.0'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const LicenseScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.open_in_new),
            title: const Text('Project home'),
            subtitle: const Text(projectHomeUrl),
            onTap: () async {
              final uri = Uri.parse(projectHomeUrl);
              try {
                await launchUrl(uri, mode: LaunchMode.platformDefault);
              } catch (_) {
                // Silently ignore launch failures (e.g. no browser available).
              }
            },
          ),
        ],
      ),
    );
  }
}
