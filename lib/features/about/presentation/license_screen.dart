import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Full-screen view displaying the GNU AGPL 3.0 license text.
class LicenseScreen extends StatelessWidget {
  const LicenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('License terms')),
      body: FutureBuilder<String>(
        future: DefaultAssetBundle.of(context).loadString('LICENSE.md'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load license text.'));
          }
          return Markdown(
            data: snapshot.data ?? '',
            onTapLink: (text, href, title) async {
              if (href == null) {
                return;
              }
              final uri = Uri.tryParse(href);
              if (uri == null) {
                return;
              }
              try {
                await launchUrl(uri, mode: LaunchMode.platformDefault);
              } catch (_) {
                // Silently ignore launch failures.
              }
            },
          );
        },
      ),
    );
  }
}
