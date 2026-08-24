abstract class AppRoutes {
  //Prevent instantiation
  const AppRoutes._();

  //Root
  static const menu = AppRouteInfo(name: 'menu', path: '/menu');
  static const order = AppRouteInfo(name: 'order', path: '/order');
  

}

/// Helper class to keep names and paths coupled cleanly
class AppRouteInfo {
  final String name;
  final String path;

  const AppRouteInfo({
    required this.name,
    required this.path,
  });
}