import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
class HtmlWebView extends StatelessWidget {
  final String htmlContent;

  HtmlWebView({required this.htmlContent});

  @override
  Widget build(BuildContext context) {
    final String styledHtmlContent = '''
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body {
            color: #333; /* Set the text color */
            padding: 10px;
            font-size: 36px;
          }
        </style>
      </head>
      <body>
        $htmlContent
      </body>
      </html>
    ''';

    return WebView(
      initialUrl: 'about:blank',
      onWebViewCreated: (WebViewController controller) {
        controller.loadUrl(Uri.dataFromString(styledHtmlContent,
            mimeType: 'text/html', encoding: utf8).toString());
      },
      backgroundColor: Colors.white,
    );
  }
}
