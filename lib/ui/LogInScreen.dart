// import 'package:app_oculos_zan/ui/ForgotPassword.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/HomePage.dart';

import 'ForgotPassword.dart';
import '../../main.dart';

class LogInScreen extends StatefulWidget {
  final VoidCallback onClickedSignUp;

  const LogInScreen({
    Key? key,
    required this.onClickedSignUp,
  }) : super(key: key);

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  //Paleta de cores
  int blue_white = 0xFF4D7FAE;
  int blue_median = 0xFF22496D;
  int blue_strong = 0xFF7371FC;

  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // showLoaderDialog(BuildContext context){
    //   AlertDialog alert=AlertDialog(
    //     content: Row(
    //       children: [
    //         CircularProgressIndicator(),
    //         Container(margin: EdgeInsets.only(left: 7),child:Text("Loading..." )),
    //       ],),
    //   );
    //   showDialog(barrierDismissible: false,
    //     context:context,
    //     builder:(BuildContext context){
    //       return alert;
    //     },
    //   );
    // }
    // Future signin() async {
    //   showLoaderDialog(context);
    //   try {
    //     await FirebaseAuth.instance.signInWithEmailAndPassword(
    //         email: nameController.text.trim(),
    //         password: passwordController.text.trim());
    //   } on FirebaseAuthException catch (e) {
    //     print(e.message);
    //   }
    //   navigatorKey.currentState!.pop();
    // }
    return Scaffold(
      backgroundColor: Color(0xFF7371FC),
      extendBodyBehindAppBar: true,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
            Container(
                height: 100,
                width: 50,
                margin: EdgeInsets.fromLTRB(0, 16, 0, 8),
                child: Image.asset(
                  'assets/images/avatar-2.png',
                  height: 200,
                  width: 200,
                  color: Color(0XFF9393f5),
                )),
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                margin: EdgeInsets.fromLTRB(0, 0, 0, 8),
                child: Text(
                  'BEM VINDO DE VOLTA',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                )),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.white)),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 30),
              child: TextField(
                obscureText: true,
                controller: passwordController,
                decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.white)),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: 50, minHeight: 0, maxWidth: 25, minWidth: 0),
              child: ElevatedButton(
                child: const Text(
                  'Conecte-se',
                  style: TextStyle(fontSize: 18, color: Color(0XFF7371FC)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0)),
                    ),
                    backgroundColor: MaterialStateProperty.all(Colors.white)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => ForgotPasswordScreen()));
              },
              child: Text(
                'Esqueceu a senha?',
                style: TextStyle(color: Colors.white),
              ),
              style: TextButton.styleFrom(
                  padding: const EdgeInsets.fromLTRB(0, 24, 0, 16)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: const Text(
                    'Não tem uma conta?',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Container(
                    // constraints: BoxConstraints(minHeight: 100),
                    child: TextButton(
                  child: const Text(
                    'Registre-se',
                    style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline),
                  ),
                  // onPressed: widget.onClickedSignUp,
                      onPressed: (){

                      },
                ))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
