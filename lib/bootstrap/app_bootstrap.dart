import 'package:flutter/material.dart';

import '../presentation/app.dart';
import '../presentation/common/app_dependencies.dart';
import '../presentation/common/app_scope.dart';
import '../presentation/design/design.dart';
import 'composition_root.dart';

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late final Future<AppDependencies> _dependencies = CompositionRoot.create();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppDependencies>(
      future: _dependencies,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return AppScope(
            dependencies: snapshot.data!,
            child: const CalorieTrackApp(),
          );
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          home: const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }
}
