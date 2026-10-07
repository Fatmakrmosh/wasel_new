import 'package:go_router/go_router.dart';

import '../../core/network/supabase_service.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/language/language_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/account_type_screen.dart';
import '../../features/home/home_screen.dart';

import '../../features/rides/city/city_ride_screen.dart';
import '../../features/rides/offers/driver_offers_screen.dart';
import '../../features/rides/chat/ride_chat_screen.dart';
import '../../features/rides/city/ride_status_screen.dart';
import '../../features/rides/history/my_rides_screen.dart';
import '../../features/rides/intercity/intercity_screen.dart';
import '../../features/rides/bus/bus_screen.dart';

import '../../features/parcels/send_parcel_screen.dart';
import '../../features/parcels/track_parcel_screen.dart';

import '../../features/notifications/notifications_screen.dart';
import '../../features/account/account_screen.dart';

import '../../features/driver/driver_registration_screen.dart';
import '../../features/driver/vehicle_registration_screen.dart';
import '../../features/driver/driver_home_screen.dart';

import '../../features/company/company_registration_screen.dart';
import '../../features/company/company_home_screen.dart';

import '../../features/admin/admin_gate_screen.dart';
import '../../features/admin/admin_users_screen.dart';
import '../../features/admin/admin_permissions_screen.dart';
import '../../features/admin/admin_rides_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final loggedIn = SupabaseService.client?.auth.currentSession != null;
    final publicRoute = ["/splash","/onboarding","/language","/login","/register"];
    final isPublic = publicRoute.contains(state.uri.path);

    if (!loggedIn && !isPublic) {
      return '/login?reason=auth';
    }

    if (loggedIn && (state.uri.path == '/login' || state.uri.path == '/register')) {
      return '/home';
    }

    return null;
  },
  routes: [
    // =========================
    // البداية والمصادقة
    // =========================

    GoRoute(
      path: '/splash',
      builder: (_, _) => const SplashScreen(),
    ),

    GoRoute(
      path: '/onboarding',
      builder: (_, _) => const OnboardingScreen(),
    ),

    GoRoute(
      path: '/language',
      builder: (_, _) => const LanguageScreen(),
    ),

    GoRoute(
      path: '/login',
      builder: (_, state) => LoginScreen(
        message: state.uri.queryParameters['reason'] == 'auth'
            ? 'يرجى تسجيل الدخول أولاً للوصول إلى هذه الصفحة.'
            : null,
      ),
    ),

    GoRoute(
      path: '/register',
      builder: (_, _) => const RegisterScreen(),
    ),

    GoRoute(
      path: '/account-type',
      builder: (_, _) => const AccountTypeScreen(),
    ),

    // =========================
    // الراكب - الرئيسية
    // =========================

    GoRoute(
      path: '/home',
      builder: (_, _) => const HomeScreen(),
    ),

    GoRoute(
      path: '/account',
      builder: (_, _) => const AccountScreen(),
    ),

    GoRoute(
      path: '/notifications',
      builder: (_, _) => const NotificationsScreen(),
    ),

    // =========================
    // رحلات المدينة
    // =========================

    GoRoute(
      path: '/city-ride',
      builder: (_, _) => const CityRideScreen(),
    ),

    GoRoute(
      path: '/driver-offers',
      builder: (_, _) => const DriverOffersScreen(),
    ),

    GoRoute(
      path: '/ride-chat',
      builder: (_, _) => const RideChatScreen(),
    ),

    GoRoute(
      path: '/ride-status',
      builder: (_, _) => const RideStatusScreen(),
    ),

    GoRoute(
      path: '/my-rides',
      builder: (_, _) => const MyRidesScreen(),
    ),

    // =========================
    // الرحلات بين المدن
    // =========================

    GoRoute(
      path: '/intercity',
      builder: (_, _) => const IntercityScreen(),
    ),

    GoRoute(
      path: '/bus',
      builder: (_, _) => const BusScreen(),
    ),

    // =========================
    // الطرود
    // =========================

    GoRoute(
      path: '/send-parcel',
      builder: (_, _) => const SendParcelScreen(),
    ),

    GoRoute(
      path: '/track-parcel',
      builder: (_, _) => const TrackParcelScreen(),
    ),

    // =========================
    // السائق
    // =========================

    GoRoute(
      path: '/driver-register',
      builder: (_, _) => const DriverRegistrationScreen(),
    ),

    GoRoute(
      path: '/vehicle-register',
      builder: (_, _) => const VehicleRegistrationScreen(),
    ),

    GoRoute(
      path: '/driver-home',
      builder: (_, _) => const DriverHomeScreen(),
    ),

    // =========================
    // شركة النقل
    // =========================

    GoRoute(
      path: '/company-register',
      builder: (_, _) => const CompanyRegistrationScreen(),
    ),

    GoRoute(
      path: '/company-home',
      builder: (_, _) => const CompanyHomeScreen(),
    ),

    // =========================
    // الإدارة
    // =========================

    GoRoute(
      path: '/admin',
      builder: (_, _) => const AdminGateScreen(),
    ),

    GoRoute(
      path: '/admin/users',
      builder: (_, state) => AdminUsersScreen(
        initialFilter: state.uri.queryParameters['filter'] ?? 'all',
      ),
    ),

    GoRoute(
      path: '/admin/permissions',
      builder: (_, _) => const AdminPermissionsScreen(),
    ),

    GoRoute(
      path: '/admin/rides',
      builder: (_, _) => const AdminRidesScreen(),
    ),
  ],
);