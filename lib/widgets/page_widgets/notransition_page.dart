import 'package:go_router/go_router.dart';

class NoTransitionPage<T> extends CustomTransitionPage<T> {
  NoTransitionPage({
    required super.child,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },
        );
}
