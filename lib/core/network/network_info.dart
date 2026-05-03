abstract interface class NetworkInfo {
  Future<bool> get isConnected;
}

class AlwaysConnectedNetworkInfo implements NetworkInfo {
  const AlwaysConnectedNetworkInfo({this.connected = true});

  final bool connected;

  @override
  Future<bool> get isConnected async => connected;
}
