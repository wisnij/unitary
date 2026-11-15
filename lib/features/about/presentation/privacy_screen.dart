import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:material_ui/material_ui.dart';
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
            // flutter_markdown_plus still reads the Flutter SDK's own Theme,
            // which is a different class from the material_ui one.  The
            // bridge gives it this app's theme; without it the document is
            // drawn in light-theme colors.  Remove the bridge when
            // flutter_markdown_plus supports material_ui.
            // ignore: deprecated_member_use, the bridge is deprecated only to mark it as temporary
            return MaterialUiCompatibilityBridge(
              child: Markdown(
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
              ),
            );
          },
        ),
      ),
    );
  }
}
