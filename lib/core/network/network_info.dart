import '../exports.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

class NetworkInfoImpl implements NetworkInfo {
  final InternetConnection connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected => connectionChecker.hasInternetAccess;

  @override
  Stream<bool> get onConnectivityChanged => connectionChecker.onStatusChange
      .map((status) => status == InternetStatus.connected);
}
