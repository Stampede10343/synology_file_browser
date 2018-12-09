import 'dart:convert';

import 'package:http/http.dart' as httpClient;

class SynologyApi {
  static final SynologyApi _api = new SynologyApi._internal();
  String _authCookie;
  String _url;

  final _thumbnailUrlParams = "&size=small&api=SYNO.FileStation.Thumb&method=get&version=2";

  factory SynologyApi() {
    return _api;
  }

  // Singleton Constructor
  SynologyApi._internal();

  login(url, account, password) async {
    final response = await httpClient.post(
      'http://$url:5000/webapi/auth.cgi',
      body: "api=SYNO.API.Auth&method=login&account=$account&passwd=$password&session=FileStation&version=2",
    );

    _url = "http://$url:5000";
    _authCookie = response.headers["set-cookie"];
    print(_authCookie);
  }

  Future<List<dynamic>> getResultsForPath(path) async {
    final encodedPath = Uri.encodeComponent("\"$path\"");
    final response = await httpClient.post(
      "$_url/webapi/entry.cgi",
      headers: getAuthHeaders(),
      body:
          "folder_path=$encodedPath&additional=%5B%22size%22%2C%22time%22%5D&offset=0&limit=1000&sort_by=%22name%22&sort_direction=%22asc%22&filetype=%22all%22&api=%22SYNO.FileStation.List%22&method=%22list%22&version=2",
    );
    print("Results body: ${response.body}");
    return json.decode(response.body)["data"]["files"];
  }

  Map<String, String> getAuthHeaders() {
    return Map.fromEntries([MapEntry("Cookie", _authCookie)]);
  }

  String getThumbnailUrl(path) {
    final encodedPath = Uri.encodeComponent('$path');
    return "$_url/webapi/entry.cgi?path=$encodedPath&size=small&api=SYNO.FileStation.Thumb&method=get&version=2";
  }

  String getImageUrl(String path) {
    final encodedPath = Uri.encodeComponent('$path');
    return "$_url/webapi/entry.cgi?path=$encodedPath&size=xlarge&api=SYNO.FileStation.Thumb&method=get&version=2";
  }
}
