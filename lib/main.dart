import 'dart:async';
import 'package:flutter/material.dart';
import 'app/app.dart';
import 'bootstrap/bootstrap.dart';

void main() {
  runZonedGuarded(
    () async {
      // Initialize bindings inside the zone
      WidgetsFlutterBinding.ensureInitialized();

      try {
        await Bootstrap.initialize();
        runApp(const VahaanApp());
      } catch (error, stack) {
        // Bootstrap failed - show error screen
        Bootstrap.handleBootstrapError(error, stack);
      }
    },
    (error, stack) {
      // Runtime errors after bootstrap - just log them
      Bootstrap.handleRuntimeError(error, stack);
    },
  );
}
