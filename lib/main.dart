import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// #docregion platform_imports
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fleksa',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Fleksa(),
    );
  }
}

class Fleksa extends StatefulWidget {
  const Fleksa({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FleksaState createState() => _FleksaState();
}

class _FleksaState extends State<Fleksa> {
  bool isLoading = false;
  int progress = 0;
  @override
  void initState() {
    super.initState();

    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              progress = progress;
            });
            // debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
              progress = 0;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Page started loading: $url')),
            );
            // debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
              progress = 100;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Page finished loading: $url')),
            );
            // debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            // Display snackbar for page resource error.
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
      ''')),
            );
          },
//           onWebResourceError: (WebResourceError error) {
//             debugPrint('''
// Page resource error:
//   code: ${error.errorCode}
//   description: ${error.description}
//   errorType: ${error.errorType}
//   isForMainFrame: ${error.isForMainFrame}
//           ''');
//           },
          // onNavigationRequest: (NavigationRequest request) {
          //   if (request.url.startsWith('https://prodtestv3.fleksa.de/')) {
          //     debugPrint('blocking navigation to ${request.url}');
          //     return NavigationDecision.prevent;
          //   }
          //   debugPrint('allowing navigation to ${request.url}');
          //   return NavigationDecision.navigate;
          // },
          // onUrlChange: (UrlChange change) {
          //   debugPrint('url change to ${change.url}');
          // },

          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://prodtestv3.fleksa.de/')) {
              // Block navigation and display snackbar for blocked URL.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Blocking navigation to ${request.url}')),
              );
              return NavigationDecision.prevent;
            }
            // Allow navigation to other URLs.
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            // Display snackbar for URL change.
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('URL changed to ${change.url}')),
            );
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse('https://prodtestv3.fleksa.de/'));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(value: progress / 100),
                  const SizedBox(height: 10),
                  Text('$progress%'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar.
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('https://prodtestv3.fleksa.de/')) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    )
    ..loadRequest(Uri.parse('https://prodtestv3.fleksa.de/'));
}
