import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class Fleksa extends StatefulWidget {
  const Fleksa({Key? key}) : super(key: key);

  @override
  _FleksaState createState() => _FleksaState();
}

class _FleksaState extends State<Fleksa> {
  late final WebViewController _controller;

  bool _isLoading = true;
  int _progress = 0;

  late Future<void> _pageLoadedFuture;

  @override
  void initState() {
    super.initState();

    _pageLoadedFuture = _loadPage();
  }

  Future<void> _loadPage() async {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params);

    await _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await _controller.setBackgroundColor(const Color(0x00000000));
    await _controller.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (String url) {
          setState(() {
            _isLoading = true;
            _progress = 0;
          });
        },
        onPageFinished: (String url) {
          setState(() {
            _isLoading = false;
            _progress = 100;
          });
        },
        onProgress: (int progress) {
          setState(() {
            _progress = progress;
          });
        },
        onWebResourceError: (WebResourceError error) {
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
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('https://prodtestv3.fleksa.de/')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Blocking navigation to ${request.url}'),
              ),
            );
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onUrlChange: (UrlChange change) {
          debugPrint('URL changed to ${change.url}');
        },
      ),
    );

    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    await _controller.loadRequest(Uri.parse('https://prodtestv3.fleksa.de/'));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: FutureBuilder<void>(
          future: _pageLoadedFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 10,
                      backgroundColor: Colors.redAccent,
                      value: _progress / 100,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 10),
                    Text('$_progress%'),
                  ],
                ),
              );
            } else {
              return WebViewWidget(controller: _controller);
            }
          },
        ),
      ),
    );
  }
}
