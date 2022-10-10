import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class SignUpScreen extends StatefulWidget {
  // final VoidCallback onClickedSignIn;

  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose(){
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    showLoaderDialog(BuildContext context){
      AlertDialog alert=AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            Container(margin: EdgeInsets.only(left: 7),child:Text("Loading..." )),
          ],),
      );
      showDialog(barrierDismissible: false,
        context:context,
        builder:(BuildContext context){
          return alert;
        },
      );
    }
    Future signUp() async {
      showLoaderDialog(context);
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim());

      } on FirebaseAuthException catch (e) {
        print(e);
      }
      navigatorKey.currentState!.pop();
    }
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
                  'CADASTRE-SE',
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
                    labelText: 'Nome',
                    labelStyle: TextStyle(color: Colors.white)),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: emailController,
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
            Container(
              constraints: BoxConstraints(maxWidth: 55, maxHeight: 100),
              child: TextButton(
                child: const Text(
                  'Registre-se',
                  style: TextStyle(fontSize: 18, color: Color(0XFF7371FC)),
                ),
                onPressed: () {
                  print("${nameController.text},${emailController.text},${passwordController.text}");
                  signUp();
                },
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0)),
                    ),
                    backgroundColor: MaterialStateProperty.all(Colors.white)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: const Text(
                    'Já tem uma conta?',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Container(
                  // constraints: BoxConstraints(minHeight: 100),
                    child: TextButton(
                      child: const Text(
                        'Acesse aqui.',
                        style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline),
                      ),
                      onPressed: (){
                        // widget.onClickedSignIn;
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