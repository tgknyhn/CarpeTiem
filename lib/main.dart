import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:qr_code/auth/auth.dart';
import 'pages/login.dart';
import 'pages/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  bool doesUserExist = await userCheck();
  runApp(MyApp(doesUserExist: doesUserExist));
}

Future<bool> userCheck() async {
  if (await Auth().currentUser() != null) {
    return true;
  } else {
    return false;
  }
}

class MyApp extends StatelessWidget {
  final bool doesUserExist;
  const MyApp({Key? key, required this.doesUserExist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    if (doesUserExist) {
      return const MaterialApp(home: Home(), debugShowCheckedModeBanner: false);
    } else {
      return const MaterialApp(home: LoginPage(), debugShowCheckedModeBanner: false);
    }
  }
}
