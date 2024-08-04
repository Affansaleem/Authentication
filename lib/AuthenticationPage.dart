import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _supportState = false;
  List<BiometricType>? _availableBiometrics;

  @override
  void initState() {
    super.initState();
    _checkDeviceSupport();
  }

  Future<void> _checkDeviceSupport() async {
    bool isSupported = await auth.isDeviceSupported();
    if (mounted) {
      setState(() {
        _supportState = isSupported;
      });
    }
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();
    if (mounted) {
      setState(() {
        _availableBiometrics = availableBiometrics;
      });
    }
  }

  Future<void> _authenticate() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: "For application security",
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "User authenticated successfully",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Authentication failed",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } on PlatformException catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "An error occurred",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Security"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_supportState)
              const Text("This device is supported")
            else
              const Text("This device is not supported"),
            const Divider(height: 100),
            ElevatedButton(
              onPressed: _getAvailableBiometrics,
              child: const Text('Get available biometrics'),
            ),
            const Divider(height: 100),
            ElevatedButton(
              onPressed: _authenticate,
              child: const Text('Authenticate'),
            ),
            if (_availableBiometrics != null)
              Text('Available biometrics: $_availableBiometrics'),
          ],
        ),
      ),
    );
  }
}
