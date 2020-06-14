import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';

class JsonRPC {

  final String url;
  final Client client;

  JsonRPC(this.url, this.client);

  Future<Response> getStdSignMsg(
    Map<String, dynamic> msg,
  ) async {
    const encodeApi = "/sign_msg/encode";

    final response = await client.post(
      url + encodeApi,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(msg),
    );

    return response;
  }
}