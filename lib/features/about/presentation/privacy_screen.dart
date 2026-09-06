import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Full-screen view displaying the bundled privacy policy.
///
/// The document travels with the build rather than being fetched, so it
/// describes the behaviour of the app the user is actually running and stays
/// readable offline.  It names the canonical hosted copy, which
/// [Markdown.onTapLink] turns into a working link for readers who want the
/// current version.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy policy')),
      body: SafeArea(
        child: FutureBuilder<String>(
          future: DefaultAssetBundle.of(context).loadString('PRIVACY.md'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text('Failed to load privacy policy.'),
              );
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
      ),
    );
  }
}
