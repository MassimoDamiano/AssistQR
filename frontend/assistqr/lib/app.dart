import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/classes/providers/class_provider.dart';
import 'features/subjects/providers/subject_provider.dart';

class AssistQrApp extends StatelessWidget {
  const AssistQrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<ClassProvider>(create: (_) => ClassProvider()),
        ChangeNotifierProvider<SubjectProvider>(
          create: (_) => SubjectProvider(),
        ),
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
