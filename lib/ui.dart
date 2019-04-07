import 'dart:async';
import 'dart:math';

import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'constant.dart';

registrarCommunity({
  String currentID,
  BuildContext context,
}) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: BuildRestrarCommunity(
          currentID: currentID,
        ),
      );
    },
  );
}

class BuildRestrarCommunity extends StatefulWidget {
  final String currentID;

  BuildRestrarCommunity({Key key, this.currentID}) : super(key: key);

  @override
  _BuildRestrarCommunityState createState() => _BuildRestrarCommunityState();
}

class _BuildRestrarCommunityState extends State<BuildRestrarCommunity> {
  bool isLoading = false;
  String codCommunity = '';

  void _saveUserComunidad() async {
    await Firestore.instance
        .collection(UsersCommunitys)
        .document(widget.currentID)
        .setData({
      'id': widget.currentID,
      'community': codCommunity,
    }).then((data) async {
      setState(() {
        Navigator.pop(context);
        isLoading = false;
      });
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });
      print('Error Guardar comunidad en AlertDialog: ' + err.toString());
    });
  }

  void handleUpdateData() async {
    if (codCommunity != '') {
      setState(() {
        isLoading = true;
      });
      await Firestore.instance
          .collection(Communitys)
          .where("code", isEqualTo: codCommunity)
          .snapshots()
          .listen((data) {
        setState(() {
          if (data.documents.length != 0) {
            _saveUserComunidad();
          } else {
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: 'Comunidad no existe');
          }
        });
      });
    } else {
      Fluttertoast.showToast(msg: 'Ingrese el codigo');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _inputsCommunity(),
          (isLoading)
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [ColorLoader5()])
              : Container(),
          _bottomSend()
        ],
      ),
    );
  }

  Widget _inputsCommunity() {
    return Container(
        child: Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(1.0),
          child: ListTile(
            title: Center(
              child: Text(
                "Ingresa el código",
                style: TextStyle(color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.w800),
              ),
            ),
            subtitle: Center(
              child: Text(
                "de tu comunidad",
                style: TextStyle(color: Colors.grey, fontSize: 12.0),
              ),
            ),
          ),
        ),
        InputTextCustomRound(
          context: context,
          textView: Text('Codigo'),
          paddngTextView: const EdgeInsets.only(left: 40.0),
          colorBorderDecoration: Colors.blue,
          icon: Icon(
            Icons.attach_money,
            color: Theme.of(context).primaryIconTheme.color,
          ),
          marginContainer: const EdgeInsets.only(
              bottom: 5.0, top: 5.0, left: 5.0, right: 5.0),
          textField: TextField(
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              border: InputBorder.none,
              labelStyle: Theme.of(context).textTheme.display1,
            ),
            onChanged: (text) {
              codCommunity = text;
            },
          ),
        )
      ],
    ));
  }

  Widget _bottomSend() {
    return bottomActionCustom(
      context: context,
      textBottom: 'Guardar',
      colorBackground: Colors.blue,
      iconButton: Icon(
        Icons.arrow_forward,
        color: Colors.blue,
      ),
      voidAction: handleUpdateData,
    );
  }
}

/// construye dialog que confirma la salida
Future<Null> DialogConfirm4WillPopScope(
    {BuildContext context,
    Icon iconPrimary,
    Icon iconAccept,
    Icon iconDeny,
    Widget textAccept,
    Widget textDeny,
    Widget title,
    Widget subtitle,
    VoidCallback voidDeny,
    VoidCallback voidAccept}) async {
  await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding:
              EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(0.0),
              padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
              height: 100.0,
              child: Column(
                children: <Widget>[
                  Container(
                    child: (iconPrimary != null) ? iconPrimary : Container(),
                    margin: EdgeInsets.only(bottom: 10.0),
                  ),
                  title,
                  subtitle,
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: SimpleDialogOption(
                    onPressed: voidDeny,
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: iconDeny,
                          margin: EdgeInsets.only(right: 10.0),
                        ),
                        textDeny
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SimpleDialogOption(
                    onPressed: voidAccept,
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: iconAccept,
                          margin: EdgeInsets.only(right: 10.0),
                        ),
                        textAccept
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      });
}

Widget bottomActionCustom(
    {BuildContext context,
    String textBottom,
    Color colorBackground,
    Icon iconButton,
    VoidCallback voidAction,
    double height = 40.0}) {
  return Container(
    margin: const EdgeInsets.only(top: 20.0),
    padding: const EdgeInsets.only(left: 5.0, right: 5.0),
    child: new Row(
      children: <Widget>[
        new Expanded(
          child: Container(
            height: height,
            child: FlatButton(
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
              splashColor: colorBackground,
              color: colorBackground,
              child: new Row(
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      textBottom,
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
                            borderRadius: new BorderRadius.circular(28.0)),
                        splashColor: Colors.white,
                        color: Colors.white,
                        child: iconButton,
                        onPressed: voidAction,
                      ),
                    ),
                  )
                ],
              ),
              onPressed: voidAction,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget InputTextCustomRound(
    {BuildContext context,
    Widget textView,
    Widget textField,
    EdgeInsets paddngTextView,
    Color colorBorderDecoration,
    Color colorSeparator = Colors.transparent,
    double widthBorderDecoration = 1.0,
    double borderRadiuscircular = 40.0,
    EdgeInsets marginContainer,
    Icon icon,
    double widthSeparator = 1.0,
    double heightSeparator = 30.0,
    double height = 40.0}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.max,
    children: <Widget>[
      Padding(
        padding: paddngTextView,
        child: textView,
      ),
      Container(
        height: height,
        decoration: BoxDecoration(
          border: Border.all(
            color: colorBorderDecoration,
            width: widthBorderDecoration,
          ),
          borderRadius: BorderRadius.circular(borderRadiuscircular),
        ),
        margin: marginContainer,
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
              child: icon ?? Container(),
            ),
            Container(
              height: heightSeparator,
              width: widthSeparator,
              color: colorSeparator,
              margin: const EdgeInsets.only(right: 5.0),
            ),
            Expanded(
              child: textField,
            )
          ],
        ),
      ),
    ],
  );
}

enum DotType { square, circle, diamond, icon }

class ColorLoader5 extends StatefulWidget {
  final Color dotOneColor;
  final Color dotTwoColor;
  final Color dotThreeColor;
  final Duration duration;
  final DotType dotType;
  final Icon dotIcon;

  ColorLoader5(
      {this.dotOneColor = Colors.redAccent,
      this.dotTwoColor = Colors.green,
      this.dotThreeColor = Colors.blueAccent,
      this.duration = const Duration(milliseconds: 1000),
      this.dotType = DotType.circle,
      this.dotIcon = const Icon(Icons.blur_on)});

  @override
  _ColorLoader5State createState() => _ColorLoader5State();
}

class _ColorLoader5State extends State<ColorLoader5>
    with SingleTickerProviderStateMixin {
  Animation<double> animation_1;
  Animation<double> animation_2;
  Animation<double> animation_3;
  AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(duration: widget.duration, vsync: this);

    animation_1 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 0.70, curve: Curves.linear),
      ),
    );

    animation_2 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.1, 0.80, curve: Curves.linear),
      ),
    );

    animation_3 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.2, 0.90, curve: Curves.linear),
      ),
    );

    controller.addListener(() {
      setState(() {
        //print(animation_1.value);
      });
    });

    controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    //print(animation_1.value <= 0.4 ? 2.5 * animation_1.value : (animation_1.value > 0.40 && animation_1.value <= 0.60) ? 1.0 : 2.5 - (2.5 * animation_1.value));
    return Container(
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Opacity(
            opacity: (animation_1.value <= 0.4
                ? 2.5 * animation_1.value
                : (animation_1.value > 0.40 && animation_1.value <= 0.60)
                    ? 1.0
                    : 2.5 - (2.5 * animation_1.value)),
            child: new Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Dot(
                radius: 10.0,
                color: widget.dotOneColor,
                type: widget.dotType,
                icon: widget.dotIcon,
              ),
            ),
          ),
          Opacity(
            opacity: (animation_2.value <= 0.4
                ? 2.5 * animation_2.value
                : (animation_2.value > 0.40 && animation_2.value <= 0.60)
                    ? 1.0
                    : 2.5 - (2.5 * animation_2.value)),
            child: new Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Dot(
                radius: 10.0,
                color: widget.dotTwoColor,
                type: widget.dotType,
                icon: widget.dotIcon,
              ),
            ),
          ),
          Opacity(
            opacity: (animation_3.value <= 0.4
                ? 2.5 * animation_3.value
                : (animation_3.value > 0.40 && animation_3.value <= 0.60)
                    ? 1.0
                    : 2.5 - (2.5 * animation_3.value)),
            child: new Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Dot(
                radius: 10.0,
                color: widget.dotThreeColor,
                type: widget.dotType,
                icon: widget.dotIcon,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class FormatterPrice extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
          TextEditingValue oldValue, TextEditingValue newValue) =>
      newValue.copyWith(
          text: NumberFormat.simpleCurrency(
        decimalDigits: 0,
      ).format(double.parse(newValue.text)));
}

class Dot extends StatelessWidget {
  final double radius;
  final Color color;
  final DotType type;
  final Icon icon;

  Dot({this.radius, this.color, this.type, this.icon});

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: type == DotType.icon
          ? Icon(
              icon.icon,
              color: color,
              size: 1.3 * radius,
            )
          : new Transform.rotate(
              angle: type == DotType.diamond ? pi / 4 : 0.0,
              child: Container(
                width: radius,
                height: radius,
                decoration: BoxDecoration(
                    color: color,
                    shape: type == DotType.circle
                        ? BoxShape.circle
                        : BoxShape.rectangle),
              ),
            ),
    );
  }
}

class ColorLoader4 extends StatefulWidget {
  final Color dotOneColor;
  final Color dotTwoColor;
  final Color dotThreeColor;
  final Duration duration;
  final DotType dotType;
  final Icon dotIcon;

  ColorLoader4(
      {this.dotOneColor = Colors.redAccent,
      this.dotTwoColor = Colors.green,
      this.dotThreeColor = Colors.blueAccent,
      this.duration = const Duration(milliseconds: 1000),
      this.dotType = DotType.circle,
      this.dotIcon = const Icon(Icons.blur_on)});

  @override
  _ColorLoader4State createState() => _ColorLoader4State();
}

class _ColorLoader4State extends State<ColorLoader4>
    with SingleTickerProviderStateMixin {
  Animation<double> animation_1;
  Animation<double> animation_2;
  Animation<double> animation_3;
  AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(duration: widget.duration, vsync: this);

    animation_1 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 0.80, curve: Curves.ease),
      ),
    );

    animation_2 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.1, 0.9, curve: Curves.ease),
      ),
    );

    animation_3 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.2, 1.0, curve: Curves.ease),
      ),
    );

    controller.addListener(() {
      setState(() {
        //print(animation_1.value);
      });
    });

    controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Transform.translate(
            offset: Offset(
              0.0,
              -30 *
                  (animation_1.value <= 0.50
                      ? animation_1.value
                      : 1.0 - animation_1.value),
            ),
            child: new Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Dot(
                radius: 10.0,
                color: widget.dotOneColor,
                type: widget.dotType,
                icon: widget.dotIcon,
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(
              0.0,
              -30 *
                  (animation_2.value <= 0.50
                      ? animation_2.value
                      : 1.0 - animation_2.value),
            ),
            child: new Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Dot(
                radius: 10.0,
                color: widget.dotTwoColor,
                type: widget.dotType,
                icon: widget.dotIcon,
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(
              0.0,
              -30 *
                  (animation_3.value <= 0.50
                      ? animation_3.value
                      : 1.0 - animation_3.value),
            ),
            child: new Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Dot(
                radius: 10.0,
                color: widget.dotThreeColor,
                type: widget.dotType,
                icon: widget.dotIcon,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class ColorLoader3 extends StatefulWidget {
  final double radius;
  final double dotRadius;

  ColorLoader3({
    this.radius = 30.0,
    this.dotRadius = 3.0,
  });

  @override
  _ColorLoader3State createState() => _ColorLoader3State();
}

class _ColorLoader3State extends State<ColorLoader3>
    with SingleTickerProviderStateMixin {
  Animation<double> animation_rotation;
  Animation<double> animation_radius_in;
  Animation<double> animation_radius_out;
  AnimationController controller;

  double radius;
  double dotRadius;

  @override
  void initState() {
    super.initState();

    radius = widget.radius;
    dotRadius = widget.dotRadius;

    print(dotRadius);

    controller = AnimationController(
        lowerBound: 0.0,
        upperBound: 1.0,
        duration: const Duration(milliseconds: 3000),
        vsync: this);

    animation_rotation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 1.0, curve: Curves.linear),
      ),
    );

    animation_radius_in = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.75, 1.0, curve: Curves.elasticIn),
      ),
    );

    animation_radius_out = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 0.25, curve: Curves.elasticOut),
      ),
    );

    controller.addListener(() {
      setState(() {
        if (controller.value >= 0.75 && controller.value <= 1.0)
          radius = widget.radius * animation_radius_in.value;
        else if (controller.value >= 0.0 && controller.value <= 0.25)
          radius = widget.radius * animation_radius_out.value;
      });
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {}
    });

    controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.0,
      height: 100.0,
      //color: Colors.black12,
      child: new Center(
        child: new RotationTransition(
          turns: animation_rotation,
          child: new Container(
            //color: Colors.limeAccent,
            child: new Center(
              child: Stack(
                children: <Widget>[
                  new Transform.translate(
                    offset: Offset(0.0, 0.0),
                    child: Dot(
                      radius: radius,
                      color: Colors.black12,
                    ),
                  ),
                  new Transform.translate(
                    child: Dot(
                      radius: dotRadius,
                      color: Colors.amber,
                    ),
                    offset: Offset(
                      radius * cos(0.0),
                      radius * sin(0.0),
                    ),
                  ),
                  new Transform.translate(
                    child: Dot(
                      radius: dotRadius,
                      color: Colors.deepOrangeAccent,
                    ),
                    offset: Offset(
                      radius * cos(0.0 + 1 * pi / 4),
                      radius * sin(0.0 + 1 * pi / 4),
                    ),
                  ),
                  new Transform.translate(
                    child: Dot(
                      radius: dotRadius,
                      color: Colors.pinkAccent,
                    ),
                    offset: Offset(
                      radius * cos(0.0 + 2 * pi / 4),
                      radius * sin(0.0 + 2 * pi / 4),
                    ),
                  ),
                  new Transform.translate(
                    child: Dot(
                      radius: dotRadius,
                      color: Colors.purple,
                    ),
                    offset: Offset(
                      radius * cos(0.0 + 3 * pi / 4),
                      radius * sin(0.0 + 3 * pi / 4),
                    ),
                  ),
                  new Transform.translate(
                    child: Dot(
                      radius: dotRadius,
                      color: Colors.yellow,
                    ),
                    offset: Offset(
                      radius * cos(0.0 + 4 * pi / 4),
                      radius * sin(0.0 + 4 * pi / 4),
                    ),
                  ),
                  new Transform.translate(
                    child: Dot(
                      radius: dotRadius,
                      color: Colors.lightGreen,
                    ),
                    offset: Offset(
                      radius * cos(0.0 + 5 * pi / 4),
                      radius * sin(0.0 + 5 * pi / 4),
                    ),
                  ),
                  new Transform.translate(
                    child: Dot(
                      radius: dotRadius,
                      color: Colors.orangeAccent,
                    ),
                    offset: Offset(
                      radius * cos(0.0 + 6 * pi / 4),
                      radius * sin(0.0 + 6 * pi / 4),
                    ),
                  ),
                  new Transform.translate(
                    child: Dot(
                      radius: dotRadius,
                      color: Colors.blueAccent,
                    ),
                    offset: Offset(
                      radius * cos(0.0 + 7 * pi / 4),
                      radius * sin(0.0 + 7 * pi / 4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class ColorLoader2 extends StatefulWidget {
  final Color color1;
  final Color color2;
  final Color color3;

  ColorLoader2(
      {this.color1 = Colors.deepOrangeAccent,
      this.color2 = Colors.yellow,
      this.color3 = Colors.lightGreen});

  @override
  _ColorLoader2State createState() => _ColorLoader2State();
}

class _ColorLoader2State extends State<ColorLoader2>
    with TickerProviderStateMixin {
  Animation<double> animation1;
  Animation<double> animation2;
  Animation<double> animation3;
  AnimationController controller1;
  AnimationController controller2;
  AnimationController controller3;

  @override
  void initState() {
    super.initState();

    controller1 = AnimationController(
        duration: const Duration(milliseconds: 1200), vsync: this);

    controller2 = AnimationController(
        duration: const Duration(milliseconds: 900), vsync: this);

    controller3 = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    animation1 = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: controller1, curve: Interval(0.0, 1.0, curve: Curves.linear)));

    animation2 = Tween<double>(begin: -1.0, end: 0.0).animate(CurvedAnimation(
        parent: controller2, curve: Interval(0.0, 1.0, curve: Curves.easeIn)));

    animation3 = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: controller3,
        curve: Interval(0.0, 1.0, curve: Curves.decelerate)));

    controller1.repeat();
    controller2.repeat();
    controller3.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          new RotationTransition(
            turns: animation1,
            child: CustomPaint(
              painter: Arc1Painter(widget.color1),
              child: Container(
                width: 50.0,
                height: 50.0,
              ),
            ),
          ),
          new RotationTransition(
            turns: animation2,
            child: CustomPaint(
              painter: Arc2Painter(widget.color2),
              child: Container(
                width: 50.0,
                height: 50.0,
              ),
            ),
          ),
          new RotationTransition(
            turns: animation3,
            child: CustomPaint(
              painter: Arc3Painter(widget.color3),
              child: Container(
                width: 50.0,
                height: 50.0,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    controller3.dispose();
    super.dispose();
  }
}

class Arc1Painter extends CustomPainter {
  final Color color;

  Arc1Painter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint p1 = new Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Rect rect1 = new Rect.fromLTWH(0.0, 0.0, size.width, size.height);

    canvas.drawArc(rect1, 0.0, 0.5 * pi, false, p1);
    canvas.drawArc(rect1, 0.6 * pi, 0.8 * pi, false, p1);
    canvas.drawArc(rect1, 1.5 * pi, 0.4 * pi, false, p1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Arc2Painter extends CustomPainter {
  final Color color;

  Arc2Painter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint p2 = new Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Rect rect2 = new Rect.fromLTWH(
        0.0 + (0.2 * size.width) / 2,
        0.0 + (0.2 * size.height) / 2,
        size.width - 0.2 * size.width,
        size.height - 0.2 * size.height);

    canvas.drawArc(rect2, 0.0, 0.5 * pi, false, p2);
    canvas.drawArc(rect2, 0.8 * pi, 0.6 * pi, false, p2);
    canvas.drawArc(rect2, 1.6 * pi, 0.2 * pi, false, p2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Arc3Painter extends CustomPainter {
  final Color color;

  Arc3Painter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint p3 = new Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Rect rect3 = new Rect.fromLTWH(
        0.0 + (0.4 * size.width) / 2,
        0.0 + (0.4 * size.height) / 2,
        size.width - 0.4 * size.width,
        size.height - 0.4 * size.height);

    canvas.drawArc(rect3, 0.0, 0.9 * pi, false, p3);
    canvas.drawArc(rect3, 1.1 * pi, 0.8 * pi, false, p3);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
