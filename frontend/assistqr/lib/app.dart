import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';

class AssistQrApp extends StatelessWidget {
  const AssistQrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'AssistQR',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const LoginScreen(),
      ),
    );
  }
}
