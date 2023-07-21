import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';

class InAppWebViewWidget extends StatefulWidget {
  final String path;
  const InAppWebViewWidget({super.key, required this.path});

  @override
  State<InAppWebViewWidget> createState() => _InAppWebViewState();
}

class _InAppWebViewState extends State<InAppWebViewWidget> {
  late final InAppWebViewController _controller;

  @override
  void initState() {
    super.initState();
    // final uri =
    //     Uri.directory("file:///android_asset${widget.path}", windows: false);
    // final headers = {'Access-Control-Allow-Origin': '*'};
    // // loadAsset();
    // controller = WebViewController();
    // // ..loadFlutterAsset("assets/testEngineScripts/index.html");

    // controller
    //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
    //   ..loadFile(widget.path)
    //   ..setBackgroundColor(const Color(0x00000000))
    //   // ..runJavaScript(
    //   //     ''' console.log('here2'); function dsBridgeWrapper(){}dsBridgeWrapper.prototype.call=function(e,n){var s={type:e,message:n};console.log("--------- Post Message Sent ----------",s),window.flutterChannel&&window.flutterChannel.postMessage&&window.flutterChannel.postMessage(JSON.stringify(s))},window._dsbridge=new dsBridgeWrapper; ''')
    //   ..setNavigationDelegate(NavigationDelegate(
    //     onProgress: (int progress) {},
    //     onPageStarted: (String url) {},
    //     onPageFinished: (String url) {
    //       debugPrint('Page finished loading: $url');
    //       controller.runJavaScript(
    //           ''' console.log('here2'); function dsBridgeWrapper(){}dsBridgeWrapper.prototype.call=function(e,n){var s={type:e,message:n};console.log("--------- Post Message Sent ----------",s),window.flutterChannel&&window.flutterChannel.postMessage&&window.flutterChannel.postMessage(JSON.stringify(s))},window._dsbridge=new dsBridgeWrapper; ''');
    //     },
    //     onWebResourceError: (WebResourceError error) {},
    //     onNavigationRequest: (NavigationRequest request) {
    //       return NavigationDecision.navigate;
    //     },
    //   ))
    //   ..addJavaScriptChannel('sendExploreUIEvent',
    //       onMessageReceived: (JavaScriptMessage message) {
    //     print(
    //         "${message.message}::FLUTTER::WebViewController:requestString:  ::");
    //   })
    //   ..addJavaScriptChannel('flutterChannel',
    //       onMessageReceived: (JavaScriptMessage message) {
    //     print(
    //         "${message.message}::FLUTTER::WebViewController:requestString:  ::");
    //   })
    //   ..runJavaScript(''' window._dsf._hasJavascriptMethod("",""); ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: InAppWebView(
        onLoadStop: (controller, url) {
          _controller.evaluateJavascript(
              source:
                  ''' console.log('here2'); function dsBridgeWrapper(){}dsBridgeWrapper.prototype.call=function(e,n){var s={type:e,message:n};console.log("--------- Post Message Sent ----------",s),window.flutter_inappwebview&&window.flutter_inappwebview.callHandler&&window.flutter_inappwebview.callHandler('myHandlerName',JSON.stringify(s))},window._dsbridge=new dsBridgeWrapper; ''');
        },
        initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
                javaScriptEnabled: true,
                useShouldOverrideUrlLoading: true,
                useOnLoadResource: true,
                allowUniversalAccessFromFileURLs: true)),
        // initialFile: "assets/testEngineScripts/index.html",
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          var uri = navigationAction.request.url;
          if (uri?.scheme == "file") {
            // Handle 'file://' URLs separately
            return NavigationActionPolicy.ALLOW;
          }
          return NavigationActionPolicy.ALLOW;
        },
        onWebViewCreated: (controller) {
          _controller = controller;
          _loadLocalHTMLFile();
          _registerJavaScriptBridge();
        },
      ),
    );
  }

  loadAsset() async {
    print("loading from inapp web view");

    _controller.loadUrl(
        urlRequest: URLRequest(
      url: Uri.parse('about:blank'),
    ));
  }

  void _registerJavaScriptBridge() {
    // Add a JavaScript channel and define its name
    _controller.addJavaScriptHandler(
      handlerName: 'myHandlerName',
      callback: (args) {
        // Handle messages from JavaScript
        print('Received message from JavaScript: $args');
      },
    );
  }

  void _loadLocalHTMLFile() async {
    try {
      // Replace 'path/to/your/local/file.html' with your actual file path
      final appDir = await getApplicationDocumentsDirectory();

      final file = File(widget.path);
      final content = await file.readAsString();
      print(content);
      // Load the HTML content using the web view controller
      _controller.loadData(
          data: content,
          mimeType: 'text/html',
          encoding: 'utf-8',
          baseUrl: Uri.file(widget.path),
          allowingReadAccessTo: Uri.file('${widget.path}/res'));
    } catch (e) {
      print('Error loading local HTML file: $e');
    }
  }
}
