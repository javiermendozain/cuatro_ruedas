import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'constant.dart';
import 'ui.dart';


final themeColor = new Color(0xfff5a623);
final primaryColor = new Color(0xff203152);
final greyColor = new Color(0xffaeaeae);
final greyColor2 = new Color(0xffE8E8E8);

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final String currentUID;
  final String peerName;

  ChatScreen(
      {Key key,
      @required this.peerId,
      @required this.peerAvatar,
      this.currentUID,
      this.peerName})
      : super(key: key);

  @override
  State createState() =>
      new ChatScreenState(peerId: peerId, peerAvatar: peerAvatar);
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState({Key key, @required this.peerId, @required this.peerAvatar});

  String peerId;
  String peerAvatar;
  String id;

  ///var listMessage;
  String groupChatId;
  bool isPictureLoagin = false;
  File imageFile;
  bool isShowSticker;
  String imageUrl;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    focusNode.addListener(onFocusChange);

    groupChatId = '';
    isShowSticker = false;
    imageUrl = '';

    readLocal();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  readLocal() async {
    setState(() {
      id = widget.currentUID;
      groupChatId = id;
    });
  }

  Future getImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      setState(() {
        uploadFile();
        isPictureLoagin = true;
      });
    }
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  Future uploadFile() async {
    String fileName =
        '${DateTime.now().millisecondsSinceEpoch.toString()}|${id}';
    StorageReference reference =
        await FirebaseStorage.instance.ref().child(id).child(fileName);
    StorageUploadTask uploadTask = await reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    await storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isPictureLoagin = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (err) {
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }

  void onSendMessage(String content, int type) async {
    if (type == 2) {
      setState(() {
        isShowSticker = false;
      });
    }

    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();
      await Firestore.instance
          .collection(Messages)
          .document(id)
          .collection(id)
          .document(DateTime.now().millisecondsSinceEpoch.toString())
          .setData({
        'idFrom': id,
        'idTo': peerId,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': content,
        'type': type
      });

      await Firestore.instance
          .collection(ListChat)
          .document(id)
          .collection(id)
          .where('id', isEqualTo: id)
          .where('peerId', isEqualTo: peerId)
          .snapshots()
          .listen((data) async {
        if (data.documents.length == 0) {
          if (id != peerId) {
            await Firestore.instance
                .collection(ListChat)
                .document(peerId)
                .collection(peerId)
                .document()
                .setData({
              'id': peerId,
              'peerId': id,
              'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            });
          }

          await Firestore.instance
              .collection(ListChat)
              .document(id)
              .collection(id)
              .document()
              .setData({
            'id': id,
            'peerId': peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          });
        }
      });
      if (id != peerId) {
        await Firestore.instance
            .collection(Messages)
            .document(peerId)
            .collection(peerId)
            .document(DateTime.now().millisecondsSinceEpoch.toString())
            .setData({
          'idFrom': id,
          'idTo': peerId,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'content': content,
          'type': type
        });
      }
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 10), curve: Curves.easeOut);
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      Navigator.pop(context);
    }
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0.0,
          title: GestureDetector(
            onTap: () {

            },
            child: Wrap(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Material(
                      child: CachedNetworkImage(
                        placeholder: Container(
                          width: 40.0,
                          height: 40.0,
                          child: ColorLoader3(
                            dotRadius: 4.0,
                            radius: 15.0,
                          ),
                        ),
                        errorWidget: Material(
                          child: Image.asset(
                            'assets/user_no_found.png',
                            width: 40.0,
                            height: 40.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                          clipBehavior: Clip.hardEdge,
                        ),
                        imageUrl: widget.peerAvatar ?? '',
                        width: 40.0,
                        height: 40.0,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      clipBehavior: Clip.hardEdge,
                    ),
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.only(left: 8.0),
                      child: RichText(
                        text: TextSpan(
                          text: widget.peerName ?? '',
                        ),
                      ),
                    ))
                  ],
                ),
              ],
            ),
          )),
      body: WillPopScope(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                /// List of messages
                buildListMessage(),

                /// Loading Picture
                (isPictureLoagin
                    ? Padding(
                        padding: EdgeInsets.only(bottom: 1.5),
                        child: ColorLoader5(
                          dotOneColor: Colors.redAccent,
                          dotTwoColor: Colors.white,
                          dotThreeColor: Colors.yellowAccent,
                          dotIcon: Icon(Icons.adjust),
                          dotType: DotType.circle,
                          duration: Duration(seconds: 1),
                        ))
                    : Container()),

                /// Sticker
                (isShowSticker ? buildSticker() : Container()),

                /// Input content
                buildInput(),
              ],
            ),
          ],
        ),
        onWillPop: onBackPress,
      ),
    );
  }

  Widget buildSticker() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi1', 2),
                child: new Image.asset(
                  'assets/images/mimi1.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi2', 2),
                child: new Image.asset(
                  'assets/images/mimi2.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi3', 2),
                child: new Image.asset(
                  'assets/images/mimi3.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi4', 2),
                child: new Image.asset(
                  'assets/images/mimi4.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi5', 2),
                child: new Image.asset(
                  'assets/images/mimi5.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi6', 2),
                child: new Image.asset(
                  'assets/images/mimi6.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi7', 2),
                child: new Image.asset(
                  'assets/images/mimi7.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi8', 2),
                child: new Image.asset(
                  'assets/images/mimi8.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi9', 2),
                child: new Image.asset(
                  'assets/images/mimi9.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: new BoxDecoration(
          border:
              new Border(top: new BorderSide(color: greyColor2, width: 0.5)),
          color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }

  Widget buildInput() {
    final backgroundColor = Colors.indigo[50];
    return Container(
      child: Row(
        children: <Widget>[

          /// Edit text
          Flexible(
            child: Material(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      /// keyboardType: TextInputType.multiline,
                      style: TextStyle(color: primaryColor, fontSize: 15.0),
                      controller: textEditingController,
                      decoration: InputDecoration.collapsed(
                        hintText: 'Escribe tu mensaje...',
                        hintStyle: TextStyle(color: greyColor),
                      ),
                      focusNode: focusNode,
                    ),
                  ),
                ]),
              ),
            ),
          ),

          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: primaryColor,
              ),
            ),
            color: backgroundColor,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(
          border:
              new Border(top: new BorderSide(color: greyColor2, width: 0.5)),
          color: backgroundColor),
    );
  }

  bool idFrom2idTo(String idFrom, String idTo) =>
      (idTo == peerId && idFrom == id) ? true : false;

  bool idTo2idFrom(String idFrom, String idTo) =>
      (idTo == id && idFrom == peerId) ? true : false;

  Widget buildItem(int index, DocumentSnapshot document) {
    if (idFrom2idTo(document['idFrom'], document['idTo']) ||
        idTo2idFrom(document['idFrom'], document['idTo'])) {
      if (document['idFrom'] == id) {
        /// Right (my message)
        return Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                document['type'] == 0

                    /// Text
                    ? Stack(alignment: Alignment.bottomRight, children: <
                        Widget>[
                        Container(
                          margin: EdgeInsets.only(right: 0.5),
                          height: 6.5,
                          width: 6.5,
                          child: Material(
                            color: greyColor2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(3.25),
                                  topRight: Radius.circular(3.25),
                                  bottomLeft: Radius.circular(3.25),
                                  bottomRight: Radius.circular(3.25)),
                            ),
                            /** Otros estilos de bordes
                          BeveledRectangleBorder(borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15.0),),),

                          StadiumBorder(side: BorderSide(width: 2.0))
                       */
                          ),
                        ),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                document['content'],
                                style: TextStyle(color: primaryColor),
                              ),

                              /// Time
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Text(
                                      DateFormat('dd MMM kk:mm').format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              int.parse(
                                                  document['timestamp']))),
                                      style: TextStyle(
                                          color: primaryColor,
                                          fontSize: 8.0,
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ],
                                ),
                                margin: EdgeInsets.only(top: 4.0),
                              )
                            ],
                          ),
                          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                          width: 200.0,
                          decoration: BoxDecoration(
                              color: greyColor2,
                              borderRadius: BorderRadius.circular(8.0)),
                          margin: EdgeInsets.only(right: 10.0, top: 2.0),
                        )
                      ])
                    : document['type'] == 1

                        /// Image
                        ? Stack(alignment: Alignment.bottomRight, children: [
                            Container(
                              child: Material(
                                child: CachedNetworkImage(
                                  placeholder: ColorLoader3(
                                    dotRadius: 4.0,
                                    radius: 15.0,
                                  ),
                                  errorWidget: Material(
                                    child: Image.asset(
                                      'assets/images/img_not_available.jpeg',
                                      width: 200.0,
                                      height: 200.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                                  imageUrl: document['content'] ?? '',
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                              margin: EdgeInsets.only(right: 10.0, top: 2.0),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    DateFormat('dd MMM kk:mm').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            int.parse(document['timestamp']))),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8.0,
                                        fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ),
                              margin:
                                  EdgeInsets.only(right: 15.0, bottom: 10.0),
                            )
                          ])

                        /// Sticker
                        : Container(
                            child: new Image.asset(
                              'assets/images/${document['content']}.gif',
                              width: 100.0,
                              height: 100.0,
                              fit: BoxFit.cover,
                            ),
                            margin: EdgeInsets.only(right: 10.0),
                          ),
              ],
              mainAxisAlignment: MainAxisAlignment.end,
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.end,
        );
      } else {
        /// Left (peer message)
        return Container(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  /// Text
                  document['type'] == 0
                      ? Stack(alignment: Alignment.bottomLeft, children: <
                          Widget>[
                          Container(
                            margin: EdgeInsets.only(right: 0.5),
                            height: 6.5,
                            width: 6.5,
                            child: Material(
                              color: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(3.25),
                                    topRight: Radius.circular(3.25),
                                    bottomLeft: Radius.circular(3.25),
                                    bottomRight: Radius.circular(3.25)),
                              ),
                              /** Otros estilos de bordes
                            BeveledRectangleBorder(borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15.0),),),

                            StadiumBorder(side: BorderSide(width: 2.0))
                         */
                            ),
                          ),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  document['content'],
                                  style: TextStyle(color: Colors.white),
                                ),

                                /// Time
                                Container(
                                  child: Text(
                                    DateFormat('dd MMM kk:mm').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            int.parse(document['timestamp']))),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8.0,
                                        fontStyle: FontStyle.italic),
                                  ),
                                  margin: EdgeInsets.only(top: 4.0),
                                )
                              ],
                            ),
                            padding:
                                EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                            width: 200.0,
                            decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(8.0)),
                            margin: EdgeInsets.only(left: 10.0, top: 2.0),
                          )
                        ])

                      ///Imagen
                      : document['type'] == 1
                          ? Stack(alignment: Alignment.bottomLeft, children: [
                              Container(
                                child: Material(
                                  child: CachedNetworkImage(
                                    placeholder: ColorLoader3(
                                      dotRadius: 4.0,
                                      radius: 15.0,
                                    ),
                                    errorWidget: Material(
                                      child: Image.asset(
                                        'assets/images/img_not_available.jpeg',
                                        width: 200.0,
                                        height: 200.0,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                    ),
                                    imageUrl: document['content'] ?? '',
                                    width: 200.0,
                                    height: 200.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                margin: EdgeInsets.only(left: 5.0, top: 2.0),
                              ),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      DateFormat('dd MMM kk:mm').format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              int.parse(
                                                  document['timestamp']))),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 8.0,
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ],
                                ),
                                margin:
                                    EdgeInsets.only(left: 15.0, bottom: 10.0),
                              ),
                            ])

                          /// emoji-git
                          : Container(
                              child: new Image.asset(
                                'assets/images/${document['content']}.gif',
                                width: 100.0,
                                height: 100.0,
                                fit: BoxFit.cover,
                              ),
                              margin: EdgeInsets.only(left: 5.0),
                            ),
                ],
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        );
      }
    } else {
      return Container();
    }
  }

  Widget buildListMessage() {
    return Flexible(
      child: StreamBuilder(
        stream: dbFirestore
            .collection(Messages)
            .document(groupChatId)
            .collection(groupChatId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (BuildContext context, snapshot) {
          if (!snapshot.hasData) {
            return ColorLoader5();
          } else {
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) =>
                  buildItem(index, snapshot.data.documents[index]),
              itemCount: snapshot.data.documents.length,
              reverse: true,
              controller: listScrollController,
            );
          }
        },
      ),
    );
  }
}
