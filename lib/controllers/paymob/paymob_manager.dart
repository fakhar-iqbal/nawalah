import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:nawalah/util/local_storage/shared_preferences_helper.dart';

import 'constants.dart';

class PaymobManager{

  Future<String> getPaymentKey(int amount,String currency)async{
    try {

      String authanticationToken= await _getAuthanticationToken();


      int orderId= await _getOrderId(
        authanticationToken: authanticationToken,
        amount: (100*amount).toString(),
        currency: currency,
      );

      String paymentKey= await _getPaymentKey(
        authanticationToken: authanticationToken,
        amount: (100*amount).toString(),
        currency: currency,
        orderId: orderId.toString(),
      );
      return paymentKey;
    } catch (e) {
      print("Exc==========================================");
      print(e.toString());
      throw Exception();
    }
  }

  Future<String>_getAuthanticationToken()async{

    final Response response=await Dio().post(
        "https://pakistan.paymob.com/api/auth/tokens",
        data: {
          "api_key":Constants.api_key,
        }
    );

    return response.data["token"];
  }



  Future<int>_getOrderId({
    required String authanticationToken,
    required String amount,
    required String currency,
  })async{
    final Response response=await Dio().post(
        "https://pakistan.paymob.com/api/ecommerce/orders",
        data: {
          "auth_token":  authanticationToken,
          "amount_cents":amount, //  >>(STRING)<<
          "currency": "PKR",//Not Req
          "delivery_needed": "false",
          "items": [],
        }
    );
    return response.data["id"];  //INTGER
  }

  Future<String> _getPaymentKey({
    required String authanticationToken,
    required String orderId,
    required String amount,
    required String currency,
  }) async{

    String? email = SharedPreferencesHelper.getCustomerEmail();
    String? name = await SharedPreferencesHelper.getUsername();

    final Response response=await Dio().post(
        "https://pakistan.paymob.com/api/acceptance/payment_keys",
        data: {
          //ALL OF THEM ARE REQIERD
          "expiration": 3600,

          "auth_token": authanticationToken,//From First Api
          "order_id":orderId,//From Second Api  >>(STRING)<<
          "integration_id": Constants.integId,//Integration Id Of The Payment Method

          "amount_cents": amount,
          "currency": currency,

        "billing_data": {
        "apartment": "NA",
        "email": email,
        "floor": "NA",
        "first_name": "nA",
        "street": "NA",
        "building": "NA",
        "phone_number": "NA",
        "shipping_method": "NA",
        "postal_code": "NA",
        "city": "NA",
        "country": "NA",
        "last_name": "Nicolas",
        "state": "Utah"
        },
    }
    );
    return response.data["token"];
  }

}