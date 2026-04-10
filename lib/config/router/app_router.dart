import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Import Feature Screens
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/scaffold_with_navbar.dart';
import '../../features/home/presentation/splash_screen.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/transaction/presentation/checkout_screen.dart';
import '../../features/product/presentation/product_detail_screen.dart';
import '../../features/account/presentation/account_screen.dart';
import '../../features/product/presentation/search_screen.dart';
import '../../features/transaction/presentation/payment_waiting_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/product/presentation/category_product_screen.dart';
import '../../features/transaction/presentation/transaction_history_screen.dart';
import '../../features/transaction/presentation/transaction_detail_screen.dart'; 
import '../../features/notification/notification_screen.dart'; 

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorCartKey = GlobalKey<NavigatorState>(debugLabel: 'shellCart');
final _shellNavigatorNotifKey = GlobalKey<NavigatorState>(debugLabel: 'shellNotif');
final _shellNavigatorAccountKey = GlobalKey<NavigatorState>(debugLabel: 'shellAccount');

@riverpod
GoRouter goRouter(GoRouterRef ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) => ProductDetailScreen(productId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
      GoRoute(
        path: '/category/:id',
        builder: (context, state) => CategoryProductScreen(
          categoryId: int.parse(state.pathParameters['id']!),
          categoryName: state.extra as String? ?? "Kategori",
        ),
      ),
      
      // Rute Checkout & Payment biasanya diletakkan di root agar Full Screen
      GoRoute(path: '/transactions/checkout', builder: (context, state) => const CheckoutScreen()),
      GoRoute(
        path: '/transactions/payment',
        builder: (context, state) => PaymentWaitingScreen(order: state.extra),
      ),

      // Main App Shell dengan Navbar
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [GoRoute(path: '/home', builder: (context, state) => const HomeScreen())],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorCartKey,
            routes: [GoRoute(path: '/cart', builder: (context, state) => const CartScreen())],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorNotifKey,
            routes: [GoRoute(path: '/notifications', builder: (context, state) => const NotificationScreen())],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorAccountKey,
            routes: [
              GoRoute(
                path: '/account', 
                builder: (context, state) => const AccountScreen(),
                // PERBAIKAN: Masukkan rute riwayat sebagai rute anak (sub-route)
                routes: [
                  GoRoute(
                    path: 'transaction-history', 
                    builder: (context, state) => const TransactionHistoryScreen(),
                  ),
                  GoRoute(
                    path: 'transaction-detail/:id',
                    builder: (context, state) => TransactionDetailScreen(
                      transactionId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}