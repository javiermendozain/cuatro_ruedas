import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'autenticacion.dart';
import 'chatPeer2Peer.dart';
import 'ui.dart';
import 'constant.dart';
import 'cars.dart';
import 'Travel.dart';
import 'list_chats.dart';

class DrawerItem {
  String title;
  IconData icon;

  DrawerItem(this.title, this.icon);
}

class Choice {
  const Choice({this.title, this.icon, this.id});

  final int id;
  final String title;
  final IconData icon;
}

class home extends StatefulWidget {
  home({Key key, this.auth, this.onCerrarSesion, this.currentUID})
      : super(key: key);
  final BaseAuth auth;
  final VoidCallback onCerrarSesion;
  final String currentUID;

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String tvCiudad = '';
  String community = '';
  bool gridView = true;
  bool isPremium = false;
  SharedPreferences prefs;
  List<Choice> choices = const <Choice>[
    const Choice(title: 'Cerrar sesion', icon: Icons.exit_to_app, id: 1),
  ];
  Timer _timer;
  bool isOnOff = false;

  @override
  void initState() {
    super.initState();
    checkCars();
    getDataCommunityUser();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  void checkCars() async {
    await Firestore.instance
        .collection(Car)
        .where("id", isEqualTo: widget.currentUID)
        .snapshots()
        .listen((data) {
      setState(() {
        if (data.documents.length == 0) {
          DialogConfirm4WillPopScope(
              context: context,
              iconPrimary: Icon(
                Icons.directions_car,
                size: 30.0,
                color: Colors.blue,
              ),
              title: Wrap(
                children: <Widget>[
                  Text(
                    '¿Tienes vehiculo?',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              subtitle: Wrap(
                children: <Widget>[
                  Text(
                    '¡ Registralo !',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              iconAccept: null,
              iconDeny: null,
              textAccept: Text(
                'Si',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              textDeny: Text(
                'No',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              voidAccept: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => Cars(
                            currentUID: widget.currentUID,
                          ),
                      fullscreenDialog: true,
                    ));
              },
              voidDeny: () {
                Navigator.pop(
                  context,
                );
              });
        }
      });
    });
    checkCommunity();
  }

  void getDataCommunityUser() async {
    await dbFirestore
        .collection(UsersCommunitys)
        .where('id', isEqualTo: widget.currentUID)
        .snapshots()
        .listen((data) {
      setState(() {
        community = data.documents[0]['community'];
      });
    });
  }

  void checkCommunity() async {
    await Firestore.instance
        .collection(UsersCommunitys)
        .where("id", isEqualTo: widget.currentUID)
        .snapshots()
        .listen((data) {
      setState(() {
        if (data.documents.length == 0) {
          registrarCommunity(currentID: widget.currentUID, context: context);
        }
      });
    });
  }

  void _cerrarSesion() async {
    await widget.auth.signOut();
    await widget.onCerrarSesion();
    prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  void onItemMenuPress(Choice choice) {
    if (choice.id == 1) {
      _cerrarSesion();
    }
  }

  ///  Valida la salida del aplicativo
  Future<bool> _presionarAtras() async {
    await DialogConfirm4WillPopScope(
        context: context,
        iconPrimary: Icon(
          Icons.exit_to_app,
          size: 30.0,
          color: Theme.of(context).primaryIconTheme.color,
        ),
        title: Wrap(
          children: <Widget>[
            Text(
              '¿Deseas salir?',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        subtitle: Wrap(
          children: <Widget>[
            Text(
              '¡Vuelve pronto!',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ],
        ),
        iconAccept: Icon(
          Icons.check_circle,
          color: Theme.of(context).primaryIconTheme.color,
        ),
        iconDeny: Icon(
          Icons.cancel,
          color: Theme.of(context).primaryIconTheme.color,
        ),
        textAccept: Text(
          'Si',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        textDeny: Text(
          'No',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        voidAccept: () {
          Navigator.pop(context, exit(0));
        },
        voidDeny: () {
          Navigator.pop(
            context,
          );
        });

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: const Text('Rueda 4'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.power_settings_new,
              color: (isOnOff) ? Colors.green : Colors.red,
            ),
            onPressed: () {
              setState(() {
                isOnOff = !isOnOff;
              });
            },
          ),
          PopupMenuButton<Choice>(
            onSelected: onItemMenuPress,
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                    value: choice,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          choice.icon,
                        ),
                        Container(
                          width: 10.0,
                        ),
                        Text(
                          choice.title,
                        ),
                      ],
                    ));
              }).toList();
            },
          ),
        ],
      ),
      key: _scaffoldKey,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: _floatingAtionbutton(),
      bottomNavigationBar: _bottomNavigationBar(),
      body: _home(context),
    );
  }

  /// Construye home (primera vista GirdcardView)
  Widget _home(BuildContext context) {
    return WillPopScope(
      onWillPop: _presionarAtras,
      child: Stack(
        children: [
          Container(
            child: StreamBuilder(
              stream: dbFirestore
                  .collection(Travels)
                  .where('community', isEqualTo: community)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return ColorLoader5();
                } else {
                  return ListView.builder(
                    padding: EdgeInsets.only(top: 1.0, bottom: 1.0),
                    itemBuilder: (context, index) =>
                        buildTravel(snapshot.data.documents[index]),
                    itemCount: snapshot.data.documents.length,
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }

  /// Construye el perfil dentro de cada card
  Widget buildTravel( DocumentSnapshot document,) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                child: Row(
                  children: <Widget>[
                    Material(
                      elevation: 2.0,
                      child: CachedNetworkImage(
                        placeholder: Container(
                          width: 25.0,
                          height: 25.0,
                          child: ColorLoader3(
                            dotRadius: 4.0,
                            radius: 15.0,
                          ),
                        ),
                        errorWidget: Material(
                          child: Image.asset(
                            'assets/images/user_no_found.png',
                            width: 30.0,
                            height: 30.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                          clipBehavior: Clip.hardEdge,
                        ),
                        imageUrl: document['photoUrl'] ?? '',
                        width: 30.0,
                        height: 30.0,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      clipBehavior: Clip.hardEdge,
                    ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: 4.0),
                            child: RichText(
                          text: TextSpan(
                            text: '${document['nickname'] ?? ''} ',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.all(8.0),
                            icon: Icon(
                              Icons.chat,
                              color: Colors.black38,
                            ),
                            onPressed: () {

                              Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) => new ChatScreen(
                                        peerId: document['id'],
                                        currentUID: widget.currentUID,
                                        peerName:
                                        '${document['nickname']}',
                                        peerAvatar: document['photoUrl'],
                                      )));
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Icon(
                  Icons.location_on,
                  color: Colors.blue,
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: document['origen'],
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.blue,
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: document['destino'],
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Icon(
                  Icons.watch_later,
                  color: Colors.blue,
                ),
                SizedBox(
                  width: 2.0,
                ),
                Text(document['hora']),
                SizedBox(
                  width: 15.0,
                ),
                Text('Cupos:  '),
                Text(document['cupos'].toString())
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construye del boton flotante
  Widget _floatingAtionbutton() {
    return FloatingActionButton(
      elevation: 4.0,
      child: Icon(
        Icons.add_a_photo,
        color: Theme.of(context).primaryIconTheme.color,
      ),
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => Travel(
                    currentUID: widget.currentUID,
                  ),
              fullscreenDialog: true,
            ));
      },
    );
  }

  /// Construye de la barra de  navegacion inferior
  _bottomNavigationBar() {
    return BottomAppBar(
      elevation: 4.0,
      shape: CircularNotchedRectangle(),
      notchMargin: 4.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.directions_car,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => Cars(
                          currentUID: widget.currentUID,
                        ),
                    fullscreenDialog: true,
                  ));
            },
          ),
          IconButton(
            icon: Icon(
              Icons.people,
            ),
            onPressed: () {
              registrarCommunity(
                  currentID: widget.currentUID, context: context);

            },
          ),


          IconButton(
            padding: EdgeInsets.all(8.0),
            icon: Icon(
              Icons.chat,
              color: Colors.black,
            ),
            onPressed: () {

              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => ListChats(
                        currentUserID: widget.currentUID,
                      )
                  ));
            },
          ),



        ],
      ),
    );
  }
}
