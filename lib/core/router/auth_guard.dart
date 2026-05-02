import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_router.gr.dart';

/// Guards routes that require an authenticated user.
/// Redirects to LoginPage if not signed in.
class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (FirebaseAuth.instance.currentUser != null) {
      resolver.next(true);
    } else {
      resolver.redirect(
        const LoginRoute(),
        opaque: false,
      );
    }
  }
}
