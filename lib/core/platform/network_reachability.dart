export 'network_reachability_stub.dart'
    if (dart.library.html) 'network_reachability_web.dart'
    if (dart.library.io) 'network_reachability_io.dart';
