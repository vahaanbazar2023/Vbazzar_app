import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final _connectivity = Connectivity();
  late final StreamSubscription<List<ConnectivityResult>> _sub;

  final isConnected = true.obs;

  @override
  void onInit() {
    super.onInit();
    _sub = _connectivity.onConnectivityChanged.listen(_update);
    _check();
  }

  Future<void> _check() async {
    final result = await _connectivity.checkConnectivity();
    _update(result);
  }

  void _update(List<ConnectivityResult> results) {
    isConnected.value = !results.contains(ConnectivityResult.none);
  }

  @override
  void onClose() {
    _sub.cancel();
    super.onClose();
  }
}
