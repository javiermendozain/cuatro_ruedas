
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'autenticacion.dart';
import 'constant.dart';
import 'ui.dart';

const margin = 5.0;
enum typeAccount { facebook, google, email }


class login extends StatefulWidget {
  login({Key key, this.title, this.auth, this.onIniciarSesion})
      : super(key: key);
  final String title;
  final BaseAuth auth;
  final VoidCallback onIniciarSesion;

  @override
  State<StatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<login> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  GoogleSignInAccount googleUser;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final formkey = GlobalKey<FormState>();
  String _correo;
  String _contrasena;
  bool isLoggedIn = false;
  DocumentReference _cityRefCiudad;
  Color pagSelector = Colors.red;
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
  }


  void _onLoginStatusChanged(bool isLoggedIn) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
      if (isLoggedIn) {
        pagSelector = Colors.transparent;
      }
    });
  }

  void saveSharedPreferences(String currentID)async{
    prefs = await SharedPreferences.getInstance();
    await prefs.setString('id', currentID);
  }

  void isAccountCreated(typeAccount typeaccount) async {

    String uid = await widget.auth.currentUser();
    await Firestore.instance
        .collection(Users)
        .document(uid)
        .snapshots()
        .listen((data) {
      if (data.data != null) {
        /// Goto home and Stop loading
        saveSharedPreferences(uid);
        widget.onIniciarSesion();
      } else if (data.data == null && typeaccount == typeAccount.google) {
        saveAccountUserOnFirestore();
      }
    });
  }

  void saveAccountUserOnFirestore() async {
    String uid = await widget.auth.currentUser();
    await dbFirestore.collection(Users).document(uid).setData({
      'nickname': googleUser.displayName ?? '',
      'id': uid ?? '',
      'estado': false,
      'correo': googleUser.email ?? '',
      'photoUrl': googleUser.photoUrl ?? '',
    }).whenComplete((() {
      /// Go to Home and stop loading
      saveSharedPreferences(uid);
      widget.onIniciarSesion();
    })).catchError((error) {
      _onLoginStatusChanged(false);
      Fluttertoast.showToast(msg: 'Intenta nuevamente');
    });
  }

  void loginFirebase(
      {
      GoogleSignInAuthentication googleAuth,
      typeAccount typeaccount}) async {

    /// Login Google
     if (typeaccount == typeAccount.google) {
      String user = await widget.auth.signInWithGoogle(
        googleAuth.accessToken,
        googleAuth.idToken,
      );
      if (user != null) {

        isAccountCreated(typeaccount);
      } else {
        Fluttertoast.showToast(msg: 'Intenta nuevamente');
      }
    }
  }


  void handleSignInGoogle() async {
    /// para iniciar sesion con google es necesario configurar la clave SHA1
    /// en Firebase
    _onLoginStatusChanged(true);
    googleUser = await googleSignIn.signIn().catchError(() {
      _onLoginStatusChanged(false);
    }).whenComplete(() {
      _onLoginStatusChanged(false);
    });
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    loginFirebase(
        googleAuth: googleAuth,
        typeaccount: typeAccount.google);
    await googleSignIn.disconnect();
    await  googleSignIn.signOut();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:   Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        Container(
          child: _tabLogin()
        ),

      ],
    )
    );
  }


  Widget _tabLogin() {
    return Container(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                    key: formkey,
                    child: Column(
                      children: [
                        _buildInputs_Bottom(),
                      ],
                    ))),
          ),
        ));
  }

  ///Construye los input {correo, contraseña}
  Widget _buildInputs_Bottom() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom:10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.fitWidth,
                  width: 200.0,
                  height: 200.0,
                ),
              ],
            ),
          ),
          Bottoms(),
          SizedBox(height: 5.0,),
          (isLoggedIn)
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [ColorLoader5()])
              : Container()
        ]);
  }

  Widget Bottoms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[

        /// login google
        Container(
          margin: const EdgeInsets.only(top: 10.0),
          padding: const EdgeInsets.only(left: margin, right: margin),
          child: new Row(
            children: <Widget>[
              new Expanded(
                child: Container(
                  height: 40.0,
                  child: FlatButton(
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    splashColor: Colors.green,
                    color: Colors.green,
                    child: new Row(
                      children: <Widget>[
                        new Padding(
                          padding: const EdgeInsets.only(left: 18.0),
                          child: Text(
                            "Inicia con Google",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        new Expanded(
                          child: Container(),
                        ),
                        new Transform.translate(
                          offset: Offset(15.0, 0.0),
                          child: new Container(
                            padding: const EdgeInsets.all(5.0),
                            child: FlatButton(
                              shape: new RoundedRectangleBorder(
                                  borderRadius:
                                      new BorderRadius.circular(28.0)),
                              splashColor: Colors.white,
                              color: Colors.white,
                              child: Image.asset(
                                'assets/google.png',
                                width: 20.0,
                                height: 20.0,
                              ),
                              onPressed: handleSignInGoogle,
                            ),
                          ),
                        )
                      ],
                    ),
                    onPressed: handleSignInGoogle,
                  ),
                ),
              ),
            ],
          ),
        ),

        /// login Twitter
        Container(
          margin: const EdgeInsets.only(top: 10.0),
          padding: const EdgeInsets.only(left: margin, right: margin),
          child: new Row(
            children: <Widget>[
              new Expanded(
                child: Container(
                  height: 40.0,
                  child: FlatButton(
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    splashColor: Colors.red,
                    color: Colors.red,
                    child: new Row(
                      children: <Widget>[
                        new Padding(
                          padding: const EdgeInsets.only(left: 18.0),
                          child: Text(
                            "Inicia con Twitter",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        new Expanded(
                          child: Container(),
                        ),
                        new Transform.translate(
                          offset: Offset(15.0, 0.0),
                          child: new Container(
                            padding: const EdgeInsets.all(5.0),
                            child: FlatButton(
                              shape: new RoundedRectangleBorder(
                                  borderRadius:
                                  new BorderRadius.circular(28.0)),
                              splashColor: Colors.white,
                              color: Colors.white,
                              child: Image.asset(
                                'assets/twitter.png',
                                width: 20.0,
                                height: 20.0,
                              ),
                              onPressed: (){
                                  Fluttertoast.showToast(msg: 'presionado, pendiente');
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                    onPressed: (){
                      Fluttertoast.showToast(msg: 'presionado, pendiente');
                    },
                  ),
                ),
              ),
            ],
          ),
        ),


      ],
    );
  }
}
