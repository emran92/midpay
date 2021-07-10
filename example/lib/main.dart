import 'dart:async';

import 'package:flutter/material.dart';
import 'package:midpay/midpay.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final midpay = Midpay();


  //test payment
  _testPayment() {
    //for android auto sandbox when debug and production when release
    midpay.init("CLIENT KEY", "BASE_URL", environment: Environment.sanbox);
    midpay.setFinishCallback(_callback);
    var midtransCustomer = MidtransCustomer(
        'Zaki', 'Mubarok', 'kakzaki@gmail.com', '085704703691');
    List<MidtransItem> listitems = List();
    var midtransItems = MidtransItem('IDXXX', 50000, 2, 'Charger');
    listitems.add(midtransItems);
    var midtransTransaction = MidtransTransaction(
        100000, midtransCustomer, listitems,
        skipCustomer: true);
    midpay
        .makePayment(midtransTransaction)
        .catchError((err) => print("ERROR $err"));
  }

  //calback
  Future<void> _callback(TransactionFinished finished) async {
    print("Finish $finished");
    return Future.value(null);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Midpay Plugin example app'),
        ),
        body: new Center(
          child: RaisedButton(
            child: Text("Payment"),
            onPressed: () => _testPayment(),
          ),
        ),
      ),
    );
  }
}
