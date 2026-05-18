import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/views/login/login_viewmodel.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';

class AuthWebViewScreen extends StatefulWidget {
  final String authUrl;
  final String redirectUri;
  final String clientId;
  final String email;

  AuthWebViewScreen({
    required this.authUrl,
    required this.redirectUri,
    required this.clientId,
    required this.email,
  });

  @override
  AuthWebViewScreenState createState() => AuthWebViewScreenState();
}

class AuthWebViewScreenState extends State<AuthWebViewScreen> {
  late WebViewController _controller;
  bool excecuted = true;

  @override
  void initState() {
    super.initState();
    clearCache();
    _controller =
        WebViewController()
          ..clearCache()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                Provider.of<LoginViewModel>(
                  context,
                  listen: false,
                ).setLoading(true);
              },
              onPageFinished: (String url) async {
                Provider.of<LoginViewModel>(
                  context,
                  listen: false,
                ).setLoading(false);
                print("cargando... $url");
                await _controller
                    .runJavaScript('''
                      (function() {
                        const emailInput = document.querySelector("input[name='email']");
                        const codeInput = document.querySelector("input[name='code']");
                        if ((emailInput != null || emailInput!= undefined) && codeInput == null){
                          emailInput.value = "${widget.email}";
                          const submitButton = document.querySelector("button[type='submit']");
                          if (submitButton) submitButton.click();
                        }
                      })();
                ''')
                    .catchError((error) {
                      print('Error al ejecutar JavaScript: $error');
                    });
              },
              onNavigationRequest: (NavigationRequest request) {
                if (request.url.startsWith(widget.redirectUri)) {
                  final uri = Uri.parse(request.url);
                  final code = uri.queryParameters['code'];
                  print('url load: ${request.url}');
                  if (request.url != widget.authUrl) {
                    excecuted = true;
                  }
                  if (code != null) {
                    Provider.of<LoginViewModel>(
                      context,
                      listen: false,
                    ).setAuthCode(code);
                  } else {
                    Provider.of<LoginViewModel>(
                      context,
                      listen: false,
                    ).setError('No se pudo capturar el código de autorización');
                  }
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
              onWebResourceError: (error) {
                Provider.of<LoginViewModel>(
                  context,
                  listen: false,
                ).setError('Error al cargar la página: ${error.description}');
              },
            ),
          )
          ..loadRequest(
            Uri.parse(widget.authUrl),
            headers: {"androidWebviewHardwareAcceleration": "false"},
          );
    print("url: ${widget.authUrl}");
  }

  void clearCache() async {
    final cookieManager = WebViewCookieManager();
    await cookieManager.clearCookies();
    print('WebView cache cleared');
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            viewModel.isLoading
                ? Center(
                  child: const CircularProgressIndicator(
                    color: Colors.grey,
                    strokeWidth: 1.5,
                  ),
                )
                : viewModel.errorMessage != null
                ? Center(
                  child: Text(
                    viewModel.errorMessage!,
                    style: TextStyle(color: CupertinoColors.destructiveRed),
                  ),
                )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

