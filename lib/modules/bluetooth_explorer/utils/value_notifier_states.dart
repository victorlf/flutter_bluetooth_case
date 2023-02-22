abstract class BluetoothExplorerState {}

class InitialBEState extends BluetoothExplorerState {}

class LoadingBEState extends BluetoothExplorerState {
  bool isLoading;
  LoadingBEState(this.isLoading);
}

class SuccessBEState extends BluetoothExplorerState {
  String? data;
  SuccessBEState(this.data);
}

class NoDataBEState extends BluetoothExplorerState {}

class ErrorBEState extends BluetoothExplorerState {}
