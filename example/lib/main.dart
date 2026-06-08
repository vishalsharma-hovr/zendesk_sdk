import 'package:flutter/material.dart';

import 'zendesk_controller.dart';
import 'zendesk_demo_page.dart';

void main() {
  runApp(
    MaterialApp(
      home: ZendeskDemoPage(
        controller: ZendeskController.defaults(),
      ),
    ),
  );
}
