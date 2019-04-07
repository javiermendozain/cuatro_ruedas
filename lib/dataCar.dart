import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_ibm_watson/flutter_ibm_watson.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'constant.dart';
import 'ui.dart';

enum TypeDocument { cc, soat, tPropiedad }

class DataCars extends StatefulWidget {
  DataCars({Key key, this.currentUID, this.idCar}) : super(key: key);
  final String currentUID;
  final String idCar;

  @override
  _DataCarsState createState() => _DataCarsState();
}

class _DataCarsState extends State<DataCars> {
  bool isLoading = false;
  File _ImageFileCC;
  File _ImageFileSOAT;
  File _ImageFileTPropiedad;
  bool _isLoading = false;
  bool _isLoadingPublicar = false;
  String _urlPictureTarjetaPropiedad = '';
  String _urlPictureSOAT = '';
  String _urlPictureCC = '';
  bool _validacc = false;
  bool _validatp = false;

  @override
  void initState() {
    super.initState();
  }

   visualRecognitionFile(File image) async {
    IamOptions options = await IamOptions(
            iamApiKey: "iR-AG_wLVdvuqE_cc1x0IWJNBZ7SqAB8DYK9KNqXwqJx",
            url: "https://gateway.watsonplatform.net/visual-recognition/api",)
        .build();

    VisualRecognition visualRecognition =
        VisualRecognition(iamOptions: options, language: Language.ENGLISH, );

    ClassifiedImages classifiedImages =
        await visualRecognition.classifyImageFile(image.path);

    return classifiedImages
        .getImages()[0]
        .getClassifiers()[0]
        .getClasses()[0]
        .className;
  }

  void handleUpdateData() async {
    if (_urlPictureCC != '' &&
        _urlPictureSOAT != '' &&
        _urlPictureTarjetaPropiedad != '' &&
        _validacc &&
        _validatp) {
      setState(() {
        _isLoadingPublicar = true;
      });
      _setData2base();
    } else {
      Fluttertoast.showToast(msg: 'Carga todos los documentos validos');
    }
  }

  Future _getImage(TypeDocument typeDocument) async {
    setState(() {
      _isLoading = true;
    });
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        switch (typeDocument) {
          case TypeDocument.cc:
            _ImageFileCC = image;
            break;
          case TypeDocument.soat:
            _ImageFileSOAT = image;
            break;
          case TypeDocument.tPropiedad:
            _ImageFileTPropiedad = image;
            break;
        }

        _isLoading = false;
      });
    }

    switch (typeDocument) {
      case TypeDocument.cc:
        _uploadFile(typeDocument, _ImageFileCC);
        break;
      case TypeDocument.soat:
        _uploadFile(typeDocument, _ImageFileSOAT);
        break;
      case TypeDocument.tPropiedad:
        _uploadFile(typeDocument, _ImageFileTPropiedad);

        break;
    }
  }

  Future _uploadFile(TypeDocument typeDocument, File imagen) async {
    /// Cambiar fileName para un nombre que sea unico
    String fileName =
        '${DateTime.now().millisecondsSinceEpoch.toString()}|${widget.currentUID}';
    StorageReference reference = await FirebaseStorage.instance
        .ref()
        .child(widget.currentUID)
        .child(fileName);
    StorageUploadTask uploadTask = await reference.putFile(imagen);
    StorageTaskSnapshot storageTaskSnapshot;
    await uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          setState(() async {
            switch (typeDocument) {
              case TypeDocument.cc:
                _urlPictureCC = downloadUrl;
                String cc= await visualRecognitionFile(_ImageFileCC);
                _validacc = (cc == 'cc')? true: false;
                break;
              case TypeDocument.soat:
                _urlPictureSOAT = downloadUrl;
                break;
              case TypeDocument.tPropiedad:
                _urlPictureTarjetaPropiedad = downloadUrl;
                String tp= await visualRecognitionFile(_ImageFileTPropiedad);
                _validatp = ( tp==  'licenciar') ? true: false;
                break;
            }
            _isLoading = false;
          });
        }, onError: (err) {
          setState(() {
            _isLoading = false;
          });
          Fluttertoast.showToast(msg: 'Intente nuevamente');
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        Fluttertoast.showToast(msg: 'This file is not an image');
      }
    }, onError: (err) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  void _setData2base() async {
    await Firestore.instance
        .collection(Car)
        .where("idCar", isEqualTo: widget.idCar)
        .snapshots()
        .listen((data) {
      if (data.documents.length != 0) {
        data.documents[0].reference.updateData({
          'urlTarjetaPropiedad': _urlPictureTarjetaPropiedad,
          'urlCC': _urlPictureCC,
          'urlSOAT': _urlPictureSOAT,
          'estado': true
        }).whenComplete(() {
          setState(() {
            _isLoadingPublicar = false;
            _isLoading = false;
            _urlPictureTarjetaPropiedad = '';
            _urlPictureSOAT = '';
            _urlPictureCC = '';
            _ImageFileCC = null;
            _ImageFileSOAT = null;
            _ImageFileTPropiedad = null;
          });
          Navigator.pop(
            context,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Datos complementarios'),
      ),
      body: body(),
    );
  }

  Widget body() {
    return WillPopScope(
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 5.0, top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Licencia de conducir'),
                  SizedBox(width: 5.0,),
                  Icon(Icons.check_circle, color: (_validatp)?Colors.green :Colors.red,)
                ],
              ),
            ),
            _builPictureTarjetaPropiedad(),
            Padding(
              padding: EdgeInsets.only(bottom: 5.0, top: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Cedula de ciudadania'),
                  SizedBox(width: 5.0,),
                  Icon(Icons.check_circle, color: (_validacc)?Colors.green :Colors.red,)
                ],
              ),
            ),
            _builPictureCC(),
            Padding(
              padding: EdgeInsets.only(bottom: 5.0, top: 5.0),
              child: Text('SOAT'),
            ),
            _builPictureSOAT(),
            Padding(
              padding:
                  const EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
              child: bottomActionCustom(
                context: context,
                textBottom: 'Guardar',
                colorBackground: Colors.blue,
                iconButton: Icon(
                  Icons.arrow_forward,
                  color: Colors.blue,
                ),
                voidAction: handleUpdateData,
              ),
            ),
            (isLoading)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [ColorLoader5()])
                : Container()
          ],
        ),
      ),
    );
  }

  Widget _builPictureTarjetaPropiedad() {
    return Expanded(
      flex: 2,
      child: GestureDetector(
        onTap: () {
          _getImage(TypeDocument.tPropiedad);
        },
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            (_ImageFileTPropiedad == null)
                ? (_urlPictureTarjetaPropiedad != ''
                    ? Material(
                        elevation: 2.0,
                        clipBehavior: Clip.hardEdge,
                        child: CachedNetworkImage(
                          placeholder: ColorLoader3(
                            dotRadius: 4.0,
                            radius: 15.0,
                          ),
                          imageUrl: _urlPictureTarjetaPropiedad,
                          fit: BoxFit.cover,
                        ))
                    : Material(
                        color: Colors.transparent,
                        child: Image.asset(
                          'assets/tp.jpeg',
                          fit: BoxFit.fitWidth,
                          width: 200.0,
                          height: 200.0,
                        ),
                      ))
                : Stack(alignment: Alignment.center, children: [
                    Material(
                      elevation: 2.0,
                      child: Image.file(
                        _ImageFileTPropiedad,
                        fit: BoxFit.cover,
                      ),
                      clipBehavior: Clip.hardEdge,
                    ),
                    (_isLoading)
                        ? ColorLoader3(
                            dotRadius: 4.0,
                            radius: 15.0,
                          )
                        : Container(),
                  ]),
          ],
        ),
      ),
    );
  }

  Widget _builPictureCC() {
    return Expanded(
      flex: 2,
      child: GestureDetector(
        onTap: () {
          _getImage(TypeDocument.cc);
        },
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            (_ImageFileCC == null)
                ? (_urlPictureCC != ''
                    ? Material(
                        elevation: 2.0,
                        clipBehavior: Clip.hardEdge,
                        child: CachedNetworkImage(
                          placeholder: ColorLoader3(
                            dotRadius: 4.0,
                            radius: 15.0,
                          ),
                          imageUrl: _urlPictureCC,
                          fit: BoxFit.cover,
                        ))
                    : Material(
                        color: Colors.transparent,
                        child: Image.asset(
                          'assets/cc.jpeg',
                          fit: BoxFit.fitWidth,
                          width: 200.0,
                          height: 200.0,
                        ),
                      ))
                : Stack(alignment: Alignment.center, children: [
                    Material(
                      elevation: 2.0,
                      child: Image.file(
                        _ImageFileCC,
                        fit: BoxFit.cover,
                      ),
                      clipBehavior: Clip.hardEdge,
                    ),
                    (_isLoading)
                        ? ColorLoader3(
                            dotRadius: 4.0,
                            radius: 15.0,
                          )
                        : Container(),
                  ]),
          ],
        ),
      ),
    );
  }

  Widget _builPictureSOAT() {
    return Expanded(
      flex: 2,
      child: GestureDetector(
        onTap: () {
          _getImage(TypeDocument.soat);
        },
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            (_ImageFileSOAT == null)
                ? (_urlPictureSOAT != ''
                    ? Material(
                        elevation: 2.0,
                        clipBehavior: Clip.hardEdge,
                        child: CachedNetworkImage(
                          placeholder: ColorLoader3(
                            dotRadius: 4.0,
                            radius: 15.0,
                          ),
                          imageUrl: _urlPictureSOAT,
                          fit: BoxFit.cover,
                        ))
                    : Material(
                        color: Colors.transparent,
                        child: Image.asset(
                          'assets/soat.jpeg',
                          fit: BoxFit.fitWidth,
                          width: 200.0,
                          height: 200.0,
                        ),
                      ))
                : Stack(alignment: Alignment.center, children: [
                    Material(
                      elevation: 2.0,
                      child: Image.file(
                        _ImageFileSOAT,
                        fit: BoxFit.cover,
                      ),
                      clipBehavior: Clip.hardEdge,
                    ),
                    (_isLoading)
                        ? ColorLoader3(
                            dotRadius: 4.0,
                            radius: 15.0,
                          )
                        : Container(),
                  ]),
          ],
        ),
      ),
    );
  }
}
