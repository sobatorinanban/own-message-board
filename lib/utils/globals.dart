import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

String? wssUri;
String? conversationId;
String? memberId;
String? slackWebSocketUrl;



Future<void> webLaunchUrl(Uri url) async {
  if (await canLaunchUrl(url)) {
    launchUrl(url,
        mode: LaunchMode.platformDefault,
        webOnlyWindowName: '_blank'
    );
  } else {
    throw Exception('Could not launch url.');
  }
}