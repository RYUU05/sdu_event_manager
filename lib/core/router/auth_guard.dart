import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_router.gr.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    // Если пользователь залогинен — пускаем дальше
    if (FirebaseAuth.instance.currentUser != null) {
      resolver.next(true);
    } else {
      // Если нет — отправляем на логин и ПРЕРЫВАЕМ текущую навигацию
      router.push(const LoginRoute());
      resolver.next(false);
    }
  }
}