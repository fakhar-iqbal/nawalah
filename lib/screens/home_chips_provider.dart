import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../widgets/home_chips_row.dart';

// class HomeChipsProvider with ChangeNotifier {
//   final HomeChipsController _controller = Get.find<HomeChipsController>();
//
//   int get activeChip => _controller.activeChip.value;
//
//   void setActiveChip(int index) {
//     _controller.activeChip.value = index;
//     notifyListeners();
//   }
// }

class HomeChipsProvider with ChangeNotifier {
  final HomeChipsController _controller = Get.find<HomeChipsController>();

  int get activeChip => _controller.activeChip.value;

  void setActiveChip(int index) {
    _controller.activeChip.value = index;
    notifyListeners();
  }
}