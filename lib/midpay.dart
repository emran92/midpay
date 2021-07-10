import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

typedef Future<void> MidtransCallback(TransactionFinished transactionFinished);

class Midpay {
  MidtransCallback? finishCallback;
  static Midpay _instance = Midpay._internal();
  static const MethodChannel _channel = const MethodChannel('midpay');

  Midpay._internal() {
    _channel.setMethodCallHandler(_channelHandler);
  }

  factory Midpay() {
    return _instance;
  }

  ///channel handler
  Future<dynamic> _channelHandler(MethodCall methodCall) async {
    if (methodCall.method == "onTransactionFinished") {
      if (finishCallback != null) {
        await finishCallback!(TransactionFinished(
          methodCall.arguments['transactionCanceled'],
          methodCall.arguments['status'],
          methodCall.arguments['source'],
          methodCall.arguments['statusMessage'],
          methodCall.arguments['response'],
        ));
      }
    }
    return Future.value(null);
  }

  ///set finish calback
  void setFinishCallback(MidtransCallback callback) {
    finishCallback = callback;
  }

  ///initialize
  Future<void> init(String clientId, String url,
      {Environment environment = Environment.sanbox}) async {
    String env = 'sandbox';
    if (environment == Environment.production) {
      env = 'production';
    }
    await _channel.invokeMethod("init", {
      "client_key": clientId,
      "base_url": url,
      "env": env,
    });
    return Future.value(null);
  }

  ///make payment
  Future<void> makePayment(MidtransTransaction transaction) async {
    await _channel.invokeMethod("payment", jsonEncode(transaction.toJson()));
    return Future.value(null);
  }

  ///make payment token
  Future<void> makePaymentToken(String token) async {
    await _channel.invokeMethod("paymentToken", token);
    return Future.value(null);
  }

}

/// MidtransCustomer Model
class MidtransCustomer {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;

  MidtransCustomer(this.firstName, this.lastName, this.email, this.phone);

  MidtransCustomer.fromJson(Map<String, dynamic> json)
      : firstName = json["first_name"],
        lastName = json["last_name"],
        email = json["email"],
        phone = json["phone"];

  Map<String, dynamic> toJson() {
    return {
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "phone": phone,
    };
  }
}

///MidtransItem Model
class MidtransItem {
  final String? id;
  final int? price;
  final int? quantity;
  final String? name;

  MidtransItem(this.id, this.price, this.quantity, this.name);

  MidtransItem.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        price = json["price"],
        quantity = json["quantity"],
        name = json["name"];

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "price": price,
      "quantity": quantity,
      "name": name,
    };
  }
}

///MidtransTransaction Model
class MidtransTransaction {
  final int total;
  final MidtransCustomer customer;
  final List<MidtransItem> items;
  final bool skipCustomer;
  final String? customField1;
  final String? customField2;
  final String? customField3;

  MidtransTransaction(
    this.total,
    this.customer,
    this.items, {
    this.customField1,
    this.customField2,
    this.customField3,
    this.skipCustomer = false,
  });

  Map<String, dynamic> toJson() {
    return {
      "total": total,
      "skip_customer": skipCustomer,
      "items": items.map((v) => v.toJson()).toList(),
      "customer": customer.toJson(),
      "custom_field_1": customField1,
      "custom_field_2": customField2,
      "custom_field_3": customField3,
    };
  }
}

///TransactionFinished Model
class TransactionFinished {
  final bool? transactionCanceled;
  final String? status;
  final String? source;
  final String? statusMessage;
  final String? response;

  TransactionFinished(
    this.transactionCanceled,
    this.status,
    this.source,
    this.statusMessage,
    this.response,
  );
}

/// Environment enumeration
enum Environment {
  sanbox,
  production,
}
