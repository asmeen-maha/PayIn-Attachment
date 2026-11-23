import 'package:flutter/material.dart';

import 'core/constants/app_info.dart';
import 'core/theme/app_theme.dart';
import 'features/pay_advance/pay_advance_page.dart';

class PayInApp extends StatelessWidget {
  const PayInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppInfo.title,
      theme: AppTheme.light,
      home: const PayAdvancePage(),
    );
  }
}
