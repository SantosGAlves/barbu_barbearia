import 'package:flutter/material.dart';
import 'screens/auth/login_page.dart';
import 'screens/home/home_page.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/register_page.dart';
import 'screens/bookings/booking_page.dart';
// 1. Importe sua Splash Screen aqui (ajuste o caminho se necessário)
import 'screens/splash/splash_tela.dart'; 

void main() => runApp(const BarbeariaPremiumApp());

class BarbeariaPremiumApp extends StatelessWidget {
  const BarbeariaPremiumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      
      // 2. Mude o initialRoute para a splash
      initialRoute: '/', 
      
      routes: {
        // 3. Adicione a rota da Splash
        '/': (context) => const SplashScreen(), 
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const ResponsiveWrapper(child: MainNavigation()),
        '/booking': (context) => const BookingPage(),
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