import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/auth/login_page.dart';
import 'screens/home/home_page.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/register_page.dart';
import 'screens/bookings/booking_page.dart';
import 'screens/splash/splash_tela.dart';
import 'screens/home/loyalty_page.dart';
import 'screens/home/products_page.dart';
import 'screens/profile/profile_page.dart';
import 'services/notification_service.dart';

// A FUNÇÃO MAIN AGORA É ASYNC (ASSÍNCRONA)
void main() async {
  // 1. Garante que o Flutter esteja pronto antes de chamar pacotes nativos
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Inicializa o Firebase com as opções geradas para o seu projeto
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Inicializa o serviço de notificações locais
  await NotificationService.init();

  // 4. Roda o aplicativo
  runApp(const BarbeariaPremiumApp());
}

class BarbeariaPremiumApp extends StatelessWidget {
  const BarbeariaPremiumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      
      initialRoute: '/', 
      
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const ResponsiveWrapper(child: MainNavigation()),
        '/booking': (context) => const BookingPage(),
        '/loyalty': (context) => const ResponsiveWrapper(child: LoyaltyPage()),
        '/products': (context) => const ResponsiveWrapper(child: ProductsPage()),
        '/profile': (context) => const ResponsiveWrapper(child: ProfilePage()),
      },
    );
  }
}

// Seu Wrapper de consistência (mantido)
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  const ResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SizedBox(
          width: 450, 
          child: child,
        ),
      ),
    );
  }
}