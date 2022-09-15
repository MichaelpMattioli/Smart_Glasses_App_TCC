import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class ForgotPasswordScreen extends StatefulWidget {

  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();


  @override
  void dispose(){
    nameController.dispose();
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
    Future signin() async {
      showLoaderDialog(context);
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: nameController.text.trim());
        Navigator.of(context).pop();
      } on FirebaseAuthException catch (e) {
        print(e.message);
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
                  'RECUPERAÇÃO DE CONTA',
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
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: 50, minHeight: 0, maxWidth: 25, minWidth: 0),
              child: ElevatedButton(
                child: const Text(
                  'Enviar',
                  style: TextStyle(fontSize: 18, color: Color(0XFF7371FC)),
                ),
                onPressed: () {},
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