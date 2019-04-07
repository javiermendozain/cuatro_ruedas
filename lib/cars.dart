import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'ui.dart';
import 'constant.dart';
import 'dataCar.dart';

class Cars extends StatefulWidget {
  Cars({Key key, this.currentUID}) : super(key: key);
  final String currentUID;

  @override
  _CarsState createState() => _CarsState();
}

class _CarsState extends State<Cars> {
  String placa = '';
  String modelo = '';
  String color = '';
  String anno = '';
  String marca = '';
  bool isLoading = false;
  String idCar='';

  bool _validaInput() {
    if (placa != '') {
      if (modelo != '') {
        if (color != '') {
          if (anno != '') {
            if (marca != '') {
              setState(() {
                isLoading = true;
              });
              return true;
            } else {
              Fluttertoast.showToast(msg: 'Ingrese la marca ');
            }
          } else {
            Fluttertoast.showToast(msg: 'Ingrese el año ');
          }
        } else {
          Fluttertoast.showToast(msg: 'Ingrese el color');
        }
      } else {
        Fluttertoast.showToast(msg: 'Ingrese el modelo');
      }
    } else {
      Fluttertoast.showToast(msg: 'Ingrese la placa');
    }
    return false;
  }

  void handleUpdateData() async {
    if (_validaInput()) {
      idCar=DateTime.now().millisecondsSinceEpoch.toString()+modelo+placa;
      await Firestore.instance
          .collection(Car)
          .document(widget.currentUID+idCar)
          .setData({
        'id': widget.currentUID,
        'idCar':idCar,
        'color': color,
        'modelo': modelo,
        'anno': anno,
        'marca': marca,
        'placa': placa
      }).then((data) {
        setState(() {
          /**
          Navigator.pop(
            context,
          );*/

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => DataCars(
                      currentUID: widget.currentUID,
                      idCar: idCar,
                    ),
                fullscreenDialog: true,
              ));

          isLoading = false;
        });
      }).catchError((err) {
        setState(() {
          isLoading = false;
        });
        print('Error Guardar carros en Cars.dart: ' + err.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agrega tu carro'),
      ),
      body: body(),
    );
  }

  Widget body() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Column(
          children: <Widget>[
            InputTextCustomRound(
              context: context,
              textView: Text('Placa'),
              paddngTextView: const EdgeInsets.only(left: 40.0),
              colorBorderDecoration: Colors.blue,
              icon: null,
              marginContainer: const EdgeInsets.only(
                  bottom: 5.0, top: 5.0, left: 5.0, right: 5.0),
              textField: TextField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelStyle: Theme.of(context).textTheme.display1,
                ),
                onChanged: (text) {
                  placa = text;
                },
              ),
            ),
            InputTextCustomRound(
              context: context,
              textView: Text('Marca'),
              paddngTextView: const EdgeInsets.only(left: 40.0),
              colorBorderDecoration: Colors.blue,
              icon: null,
              marginContainer: const EdgeInsets.only(
                  bottom: 5.0, top: 5.0, left: 5.0, right: 5.0),
              textField: TextField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelStyle: Theme.of(context).textTheme.display1,
                ),
                onChanged: (text) {
                  marca = text;
                },
              ),
            ),
            InputTextCustomRound(
              context: context,
              textView: Text('Modelo'),
              paddngTextView: const EdgeInsets.only(left: 40.0),
              colorBorderDecoration: Colors.blue,
              icon: null,
              marginContainer: const EdgeInsets.only(
                  bottom: 5.0, top: 5.0, left: 5.0, right: 5.0),
              textField: TextField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelStyle: Theme.of(context).textTheme.display1,
                ),
                onChanged: (text) {
                  modelo = text;
                },
              ),
            ),
            InputTextCustomRound(
              context: context,
              textView: Text('Año'),
              paddngTextView: const EdgeInsets.only(left: 40.0),
              colorBorderDecoration: Colors.blue,
              icon: null,
              marginContainer: const EdgeInsets.only(
                  bottom: 5.0, top: 5.0, left: 5.0, right: 5.0),
              textField: TextField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelStyle: Theme.of(context).textTheme.display1,
                ),
                onChanged: (text) {
                  anno = text;
                },
              ),
            ),
            InputTextCustomRound(
              context: context,
              textView: Text('Color'),
              paddngTextView: const EdgeInsets.only(left: 40.0),
              colorBorderDecoration: Colors.blue,
              icon: null,
              marginContainer: const EdgeInsets.only(
                  bottom: 5.0, top: 5.0, left: 5.0, right: 5.0),
              textField: TextField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelStyle: Theme.of(context).textTheme.display1,
                ),
                onChanged: (text) {
                  color = text;
                },
              ),
            ),
            bottomActionCustom(
              context: context,
              textBottom: 'Siguiente',
              colorBackground: Colors.blue,
              iconButton: Icon(
                Icons.arrow_forward,
                color: Colors.blue,
              ),
              voidAction: handleUpdateData,
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
}
