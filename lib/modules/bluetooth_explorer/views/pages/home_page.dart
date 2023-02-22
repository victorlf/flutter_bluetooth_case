import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_case/modules/bluetooth_explorer/stores/home_store.dart';
import 'package:flutter_bluetooth_case/modules/bluetooth_explorer/utils/value_notifier_states.dart';
import 'package:flutter_bluetooth_case/modules/bluetooth_explorer/views/widgets/device_item.dart';
import 'package:flutter_bluetooth_case/modules/bluetooth_explorer/views/widgets/result_text.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final homeStore = HomeStore();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('Bluetooth Explorer')),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          top: 10.0,
          right: 20.0,
          bottom: 30.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ValueListenableBuilder(
                  valueListenable: homeStore,
                  builder: (_, state, __) {
                    if (state is InitialBEState) {
                      return const ResultText(
                        content:
                            'Press the button below to explorer  nearby devices',
                      );
                    }
                    // else if (state is LoadingBEState) {
                    //   return ResultText(
                    //     content: 'Loading',
                    //     textColor: Colors.yellow.shade900,
                    //   );
                    // }
                    else if (state is LoadingBEState) {
                      if (homeStore.bleIsReady!) {
                        final devices = homeStore.devices;
                        if (devices.isEmpty) {
                          return const ResultText(content: 'Any device found');
                        }
                        return ListView.builder(
                            itemCount: homeStore.devices.length,
                            itemBuilder: (context, index) {
                              final device = devices[index];
                              return DeviceItem(
                                onPressed: () => homeStore.connect(device),
                                content:
                                    '${device.name} :: ${device.serviceUuids} :: ${device.rssi}',
                              );
                            });
                      } else {
                        return ResultText(
                          content: 'Turn on Bluetooth',
                          textColor: Colors.yellow.shade900,
                        );
                      }
                    } else if (state is SuccessBEState) {
                      final device = homeStore.connectedDevice!;
                      return Column(
                        children: [
                          ResultText(
                            content: '${device.name} :: ${device.rssi}',
                          ),
                          ResultText(
                            content:
                                state.data ?? 'Point the reader to a bar code',
                            textColor: Colors.blue,
                          ),
                        ],
                      );
                    }

                    return const ResultText(
                      content: 'Error to load initial page',
                      textColor: Colors.red,
                    );
                  }),
            ),
            ValueListenableBuilder(
                valueListenable: homeStore,
                builder: (_, state, __) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // ElevatedButton(
                      //   onPressed: () => homeStore.initiate(),
                      //   style: ElevatedButton.styleFrom(
                      //       fixedSize: Size(width / 4, 30.0)),
                      //   child: const Text('Initial'),
                      // ),
                      Visibility(
                        visible: state is InitialBEState,
                        child: ElevatedButton(
                          onPressed: homeStore.scan,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              fixedSize: Size(width / 4, 30.0)),
                          child: const Text('Scan'),
                        ),
                      ),
                      Visibility(
                        visible: state is LoadingBEState,
                        child: ElevatedButton(
                          onPressed: homeStore.cancelScan,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow.shade900,
                              fixedSize: Size(width / 4, 30.0)),
                          child: const Text('Stop Scan'),
                        ),
                      ),
                      Visibility(
                        visible: state is SuccessBEState,
                        child: ElevatedButton(
                          onPressed: homeStore.disconnect,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              fixedSize: Size(width / 4 + 10, 30.0)),
                          child: const Text('Disconnect'),
                        ),
                      ),
                      // ElevatedButton(
                      //   onPressed: () => homeStore.success(),
                      //   style: ElevatedButton.styleFrom(
                      //       backgroundColor: Colors.green,
                      //       fixedSize: Size(width / 4, 30.0)),
                      //   child: const Text('Success'),
                      // ),
                    ],
                  );
                })
          ],
        ),
      ),
    );
  }
}
