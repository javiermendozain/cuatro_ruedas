
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';


import 'autenticacion.dart';
import 'login.dart';
import 'home.dart';

void main() => runApp(MyApp());


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(
        auth: Auth(),
      ),
    );
  }
}

enum nextScreen {
  login,
  home,
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.auth}) : super(key: key);
  final BaseAuth auth;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  nextScreen screen = nextScreen.login;
  String currentUID = '';
  SharedPreferences prefs;

  initState(){
    super.initState();
    _loaderLocalDataUser();
  }

  void _loaderLocalDataUser()async{
    prefs = await SharedPreferences.getInstance();
    String user= await prefs.getString('id');
    if(user!=null){
      setState(() {
        currentUID = user;
        screen =  nextScreen.home ;
      });
    }else{
     /*
      await widget.auth.currentUser().then((userId) {
        setState(() {
          currentUID = userId;
          screen = userId != null ? nextScreen.home : nextScreen.login;
        });

      });*/
    }
  }


  @override
  Widget build(BuildContext context) {
    switch (screen) {
      case nextScreen.login:
        return login(
          auth: widget.auth,
          onIniciarSesion: () => _actualizaEstadoSesion(nextScreen.home),
        );
      case nextScreen.home:
        return home(
            currentUID: currentUID,
            auth: widget.auth,
            onCerrarSesion: () => _actualizaEstadoSesion(nextScreen.login));
    }
  }


  /// Actualiza la variable screen despues de iniciar sesion, para ingresar a home
  void _actualizaEstadoSesion(nextScreen _screen) async {
    await widget.auth.currentUser().then((userId) {
      setState(() {
        currentUID = userId??'';
        screen = _screen;
      });
    });


  }
}
