import 'package:get/get.dart';
import 'package:lunar/pages/auth_page.dart';
import 'package:lunar/pages/calendar/binding/calendar_binding.dart';
import 'package:lunar/pages/calendar/view/calendar_view.dart';
import 'package:lunar/pages/history/binding/history_binding.dart';
import 'package:lunar/pages/history/view/history_view.dart';
import 'package:lunar/pages/home/binding/home_binding.dart';
import 'package:lunar/pages/home/view/home_view.dart';
import 'package:lunar/pages/notification/binding/notification_binding.dart';
import 'package:lunar/pages/notification/view/notification_view.dart';
import 'package:lunar/pages/profile/binding/profile_binding.dart';
import 'package:lunar/pages/profile/view/profile_view.dart';
import 'package:lunar/pages/signin/binding/signin_binding.dart';
import 'package:lunar/pages/signin/view/signin_view.dart';
import 'package:lunar/pages/signup/binding/signup_binding.dart';
import 'package:lunar/pages/signup/view/signup_view.dart';
import 'package:lunar/pages/content/binding/content_binding.dart';
import 'package:lunar/pages/content/view/content_view.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.signin,
      page: () => SignInView(),
      binding: SignInBinding(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => SignUpView(),
      binding: SignUpBinding(),
    ),
    GetPage(
      name: AppRoutes.calendar,
      page: () => const CalendarView(),
      binding: CalendarBinding(),
    ),
    GetPage(
      name: AppRoutes.content,
      page: () => const ContentView(),
      binding: ContentBinding(),
    ),
    GetPage(
      name: AppRoutes.history,
      page: () => const HistoryView(),
      binding: HistoryBinding(),
    ),
    GetPage(
      name: AppRoutes.notification,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.auth,
      page: () => const AuthPage(),
    ),
  ];
}
