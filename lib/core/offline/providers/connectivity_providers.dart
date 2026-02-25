import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectionStatus {
  online,
  offline,
  unknown,
}

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Stream<ConnectionStatus> get statusStream {
    return _connectivity.onConnectivityChanged.map((results) => _mapResultList(results));
  }

  Future<ConnectionStatus> get status async {
    final result = await _connectivity.checkConnectivity();
    return _mapResultList(result);
  }

  ConnectionStatus _mapResultList(List<ConnectivityResult> result) {
    if (result.contains(ConnectivityResult.none)) {
      return ConnectionStatus.offline;
    }
    if (result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.ethernet)) {
      return ConnectionStatus.online;
    }
    return ConnectionStatus.unknown;
  }

  void dispose() {
    _subscription?.cancel();
  }
}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  return service;
});

final connectionStatusProvider = StreamProvider<ConnectionStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.statusStream;
});

final isOnlineProvider = Provider<bool>((ref) {
  final status = ref.watch(connectionStatusProvider);
  return status.valueOrNull == ConnectionStatus.online;
});

final isOfflineProvider = Provider<bool>((ref) {
  final status = ref.watch(connectionStatusProvider);
  return status.valueOrNull == ConnectionStatus.offline;
});