import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'ui.dart';
import 'constant.dart';

import 'dart:async';




class _InputDropdown extends StatelessWidget {
  const _InputDropdown({
    Key key,
    this.child,
    this.labelText,
    this.valueText,
    this.valueStyle,
    this.onPressed }) : super(key: key);

  final String labelText;
  final String valueText;
  final TextStyle valueStyle;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: InputDecorator(
        decoration: InputDecoration(
          border:  InputBorder.none,
          labelText: labelText,
        ),
        baseStyle: valueStyle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(valueText, style: valueStyle),
            Icon(Icons.arrow_drop_down,
              color: Theme.of(context).brightness == Brightness.light ? Colors.grey.shade700 : Colors.white70,
            ),
          ],
        ),
      ),
    );
  }
}


class _DateTimePicker extends StatelessWidget {
  const _DateTimePicker({
    Key key,
    this.labelText,
    this.selectedTime,
    this.selectTime,
  }) : super(key: key);

  final String labelText;
  final TimeOfDay selectedTime;
  final ValueChanged<TimeOfDay> selectTime;


  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime)
      selectTime(picked);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle valueStyle = Theme.of(context).textTheme.title;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[

        const SizedBox(width: 12.0),
        Expanded(
          flex: 3,
          child: _InputDropdown(
            valueText: selectedTime.format(context),
            valueStyle: valueStyle,
            onPressed: () { _selectTime(context); },
          ),
        ),
      ],
    );
  }
}





class Travel extends StatefulWidget {
  Travel({Key key, this.currentUID}) : super(key: key);
  final String currentUID;

  @override
  _TravelState createState() => _TravelState();
}

class Commity {
  const Commity(
      {this.idCommunity = '',this.nombre});

  final String idCommunity;
  final String nombre;
}

class Vehiculos {
  const Vehiculos(
      {this.marca = '', this.modelo = '', this.idCar});

  final String marca;
  final String modelo;
  final String idCar;
}

class _TravelState extends State<Travel> {
  bool isLoading = false;
  String _origen = '';
  String _destino = '';
  String urlPhono='';
  String nickname='';
  int _cupos = 0;
  String _hora = '';
  Vehiculos _vehiculo;
  Commity _commity;
  List<DropdownMenuItem<Vehiculos>> _dropDownCar;
  List<DropdownMenuItem<Commity>> _dropDownCommnity;
  TimeOfDay _fromTime = const TimeOfDay(hour: 7, minute: 28);


  @override
  void initState() {
    super.initState();
    getDataCar();
    getDataCommnity();
    getDataUser();
  }

  bool validaInput() {
    if (_origen != '') {
      if (_destino != '') {
          if (_cupos != 0) {
            if (_commity != null) {
              if (_vehiculo != null) {
                  setState(() {
                    isLoading=true;
                  });
                return true;
              } else {
                Fluttertoast.showToast(msg: 'Seleccione un vehiculo');
              }

            } else {
              Fluttertoast.showToast(msg: 'Seleccione una comunidad');
            }
          } else {
            Fluttertoast.showToast(msg: 'Ingrese los cupos disponibles');
          }

      } else {
        Fluttertoast.showToast(msg: 'Ingrese el destino');
      }
    } else {
      Fluttertoast.showToast(msg: 'Ingrese el origen');
    }
    return false;
  }

  void getDataUser() async {
    await dbFirestore
        .collection(Users)
        .where('id',isEqualTo: widget.currentUID)
        .snapshots()
        .listen((data) {
      urlPhono=data.documents[0]['photoUrl'];
      nickname=data.documents[0]['nickname'];
    });


  }

  void getDataCar() async {
    _dropDownCar = List<DropdownMenuItem<Vehiculos>>();
    await dbFirestore
        .collection(Car)
        .where('id',isEqualTo: widget.currentUID)
        .where('estado',isEqualTo: true)
        .snapshots()
        .listen((data) {
      _dropDownCar.clear();
      for (int i = 0; i < data.documents.length; i++) {
        setState(() {
          _dropDownCar.add(DropdownMenuItem<Vehiculos>(
            child: Text(
                '${data.documents[i]['marca']}, ${data.documents[i]['modelo']} ${data.documents[i]['placa']}'),
            value: Vehiculos(
                marca: data.documents[i]['marca'],
                modelo: data.documents[i]['modelo'],
                idCar: data.documents[i]['idCar']),
          ));
        });
      }
    });
  }

  void getDataCommnity() async {
    _dropDownCommnity = List<DropdownMenuItem<Commity>>();

    await dbFirestore
        .collection(UsersCommunitys)
        .where('id',isEqualTo: widget.currentUID)
        .snapshots()
        .listen((data) async{
          if(data.documents.length!=0){
            _dropDownCommnity.clear();
            for (int i = 0; i < data.documents.length; i++) {
            await dbFirestore
                .collection(Communitys)
                .where('code',isEqualTo: data.documents[i]['community'])
                .snapshots()
                .listen((data) {

              for (int j = 0; j < data.documents.length; j++) {
                setState(() {
                  _dropDownCommnity.add(DropdownMenuItem<Commity>(
                    child: Text(
                        '${data.documents[j]['name']}'),
                    value: Commity(
                      idCommunity: data.documents[j]['code'],
                    nombre:data.documents[j]['name'],),
                  ));
                });
              }
            });}
          }
    });
  }

  void handleUpdateData() async {
    if (validaInput()) {
      await Firestore.instance
          .collection(Travels)
          .document()
          .setData({
        'id': widget.currentUID,
        'nickname':nickname,
        'photoUrl':urlPhono,
        'origen':_origen,
        'destino':_destino,
        'cupos':_cupos,
        'hora':_fromTime.format(context).toString(),
        'vehiculo':_vehiculo.idCar,
        'community':_commity.idCommunity

          }).then((data) {
        setState(() {
          Navigator.pop(
            context,
          );
          isLoading = false;
        });
      }).catchError((err) {
        setState(() {
          isLoading = false;
        });
        print('Error Guardar  en TRavel.dart: ' + err.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Programa tú viaje'),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Column(
          children: <Widget>[
            InputTextCustomRound(
              context: context,
              textView: Text('Origen'),
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
                  _origen = text;
                },
              ),
            ),
            InputTextCustomRound(
              context: context,
              textView: Text('Destino'),
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
                  _destino = text;
                },
              ),
            ),
            InputTextCustomRound(
              context: context,
              textView: Text('Hora'),
              paddngTextView: const EdgeInsets.only(left: 40.0),
              colorBorderDecoration: Colors.blue,
              icon: null,
              marginContainer: const EdgeInsets.only(
                  bottom: 5.0, top: 5.0, left: 5.0, right: 5.0),
              textField: _DateTimePicker(
                labelText: '',
                selectedTime: _fromTime,
                selectTime: (TimeOfDay time) {
                  setState(() {
                    _fromTime = time;
                  });
                },
              ),
            ),
            InputTextCustomRound(
              context: context,
              textView: Text('Cupos'),
              paddngTextView: const EdgeInsets.only(left: 40.0),
              colorBorderDecoration: Colors.blue,
              icon: null,
              marginContainer: const EdgeInsets.only(
                  bottom: 5.0, top: 5.0, left: 5.0, right: 5.0),
              textField: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelStyle: Theme.of(context).textTheme.display1,
                ),
                onChanged: (text) {
                  _cupos = int.parse(text);
                },
              ),
            ),
            InputTextCustomRound(
              context: context,
              textView: Text('Vehiculo'),
              paddngTextView: const EdgeInsets.only(left: 40.0),
              colorBorderDecoration: Colors.blue,
              icon: null,
              marginContainer: const EdgeInsets.only(
                  bottom: 5.0, top: 5.0, left: 5.0, right: 5.0),
              textField:  Container(
                margin: EdgeInsets.only(right: 5.0),
                child: DropdownButton(
                  elevation: 2,
                  items: _dropDownCar,
                  onChanged: (Vehiculos value) {
                    setState(() {
                      _vehiculo = value;
                    });
                  },
                  hint: Text(
                      (_vehiculo != null) ? '${_vehiculo.marca}, ${_vehiculo.modelo}': 'Seleciona...',
                      style: TextStyle(color: Colors.black)),
                ),
              )

            ),
            InputTextCustomRound(
                context: context,
                textView: Text('Comunidad'),
                paddngTextView: const EdgeInsets.only(left: 40.0),
                colorBorderDecoration: Colors.blue,
                icon: null,
                marginContainer: const EdgeInsets.only(
                    bottom: 5.0, top: 5.0, left: 5.0, right: 5.0),
                textField:  Container(
                  margin: EdgeInsets.only(right: 5.0),
                  child: DropdownButton(
                    elevation: 2,
                    items: _dropDownCommnity,
                    onChanged: (Commity value) {
                      setState(() {
                        _commity = value;
                      });
                    },
                    hint: Text(
                        (_commity != null) ? '${_commity.nombre}': 'Seleciona...',
                        style: TextStyle(color: Colors.black)),
                  ),
                )
            ),
            bottomActionCustom(
              context: context,
              textBottom: 'Publicar',
              colorBackground: Colors.blue,
              iconButton: Icon(
                Icons.arrow_forward,
                color: Colors.blue,
              ),
              voidAction: handleUpdateData,
            ),
            SizedBox(height: 10.0,)            ,
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
