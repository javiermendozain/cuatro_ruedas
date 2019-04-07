import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'ui.dart';
import 'constant.dart';
import 'chatPeer2Peer.dart';

class ListChats extends StatefulWidget {
  ListChats({Key key, this.currentUserID}) : super(key: key);
  final String currentUserID;

  @override
  State<StatefulWidget> createState() => HomeContacts();
}

class HomeContacts extends State<ListChats> {
  ///Control del UI loading
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        elevation: 0.0,
      ),
      body: Stack(
        children: <Widget>[
          // List
          Container(
            child: StreamBuilder(
              stream: dbFirestore
                  .collection(ListChat)
                  .document(widget.currentUserID)
                  .collection(widget.currentUserID)
                  .where('id',isEqualTo: widget.currentUserID)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return ColorLoader5();
                } else {
                  return ListView.builder(
                    padding: EdgeInsets.only(left: 10.0,right: 10.0,top: 1.0),
                    itemBuilder: (context, index) =>
                        BuildProfile(context, snapshot.data.documents[index]),
                    itemCount: snapshot.data.documents.length,
                  );
                }
              },
            ),
          ),
          // Loading
          Positioned(
            child: isLoading
                ? Container(
                    child: ColorLoader5(),
                    color: Colors.white.withOpacity(0.8),
                  )
                : Container(),
          )
        ],
      ),
    );
  }

  Widget BuildProfile(BuildContext context, DocumentSnapshot doc){
    return Container(
      child: StreamBuilder(
        stream: dbFirestore
            .collection(Users)
            .document(doc['peerId'])
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return ColorLoader5();
          } else {
            return buildItem(context, snapshot.data);
          }
        },
      ),
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
      return Container(
        child: FlatButton(
          child: Row(
            children: <Widget>[
              Material(
                child: CachedNetworkImage(
                  placeholder: Container(
                    width: 50.0,
                    height: 50.0,
                    child: ColorLoader3(
                      dotRadius: 4.0,
                      radius: 15.0,
                    ),
                  ),
                  errorWidget: Material(
                    child: Image.asset(
                      'assets/user_no_found.png',
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                    clipBehavior: Clip.hardEdge,
                  ),
                  imageUrl: document['photoUrl']??'',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                clipBehavior: Clip.hardEdge,
              ),
              Flexible(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                              child: Container(
                                margin: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                                child: RichText(
                                  text: TextSpan(
                                    text:
                                    '${document['nickname'] ?? ''}',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ))
                          ,

                        ],
                      ),
                    ],
                  ),
                  margin: EdgeInsets.only(left: 10.0),
                ),
              ),
            ],
          ),
          onPressed: () {
             Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (context) => new ChatScreen(
                          peerId: document['id'],
                          currentUID: widget.currentUserID,
                          peerName:
                              '${document['nickname'] ?? ''}',
                          peerAvatar: document['photoUrl'] ?? '',
                        )));
          },
          color: Colors.grey.withOpacity(0.2),
          padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        margin: EdgeInsets.only(bottom: 4.0, left: 5.0, right: 5.0),
      );

  }
}
