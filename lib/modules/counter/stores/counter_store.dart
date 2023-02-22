import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CounterStore extends ValueNotifier<int> {
  CounterStore() : super(5);

  void increment() {
    value++;
  }
}
