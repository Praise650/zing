import 'dart:async';

import 'package:flutter/foundation.dart';

/// Lets go_router re-run its redirect whenever [stream] emits.
class StreamRefreshListenable extends ChangeNotifier {
  StreamRefreshListenable(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
