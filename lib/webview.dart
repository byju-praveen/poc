import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ExtractArgumentsScreen extends StatelessWidget {
  const ExtractArgumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: WebViewWidget(
        controller: WebViewController()
          ..loadFile(
              'file:///data/user/0/com.example.poc/cache/folder/unzipfile/interaction-1577-assets/index.html')
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          // ..runJavaScript('window.appEvent("resume")')
          ..setNavigationDelegate(NavigationDelegate(
            onProgress: (int progress) {},
            onPageStarted: (String url) {},
            onPageFinished: (String url) {},
            onWebResourceError: (WebResourceError error) {},
            onNavigationRequest: (NavigationRequest request) {
              return NavigationDecision.navigate;
            },
          ))
          ..addJavaScriptChannel('sendExploreUIEvent',
              onMessageReceived: (JavaScriptMessage message) {
            print(
                "${message.message}::FLUTTER::WebViewController:requestString:  ::");
          }),
      ),
    );
  }
}
