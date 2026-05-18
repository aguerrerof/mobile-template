import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ModalValidation3DSView extends StatefulWidget {
  final String urlString;

  const ModalValidation3DSView({super.key, required this.urlString});

  @override
  State<ModalValidation3DSView> createState() => _ModalValidation3DSViewState();
}

class _ModalValidation3DSViewState extends State<ModalValidation3DSView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..addJavaScriptChannel(
            'Print',
            onMessageReceived: (message) {
              debugPrint(message.message);
              Map<String, dynamic> response = jsonDecode(message.message);
              Navigator.of(context).pop(response);
            },
          )
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (url) {
                debugPrint('Página iniciada: $url');
              },
              onPageFinished: (url) {
                debugPrint('Página cargada: $url');
              },
              onNavigationRequest: (request) {
                debugPrint('Navegación hacia: ${request.url}');
                final uri = Uri.tryParse(request.url);
                if (uri != null &&
                    uri.scheme.toLowerCase() == "projectproject" &&
                    uri.host.toLowerCase() == "callbackcreditcard") {
                  Navigator.of(context).pop(uri.queryParameters);
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.urlString));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MyColors.backgroundColor,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(40.0),
          child: AppBar(
            automaticallyImplyLeading: false,
            title: const Text(
              'project',
              style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
            ),
            backgroundColor: MyColors.btnColor,
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.close_sharp),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
            centerTitle: false,
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: WebViewWidget(controller: _controller),
          ),
        ),
      ),
    );
  }
}

