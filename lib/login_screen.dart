import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synology_image_viewer/file_grid_screen.dart';
import 'package:synology_image_viewer/synology_api.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Login")), body: LoginForm());
  }
}

class LoginForm extends StatefulWidget {
  @override
  State createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  var account = "";
  var ipAddress = "";
  var password = "";

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getStoredLoginInfo(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Row(
                  children: [
                    Text(
                      "Synology IP Address",
                      style: _bigLabelStyle(),
                    )
                  ],
                ),
                TextFormField(
                  style: _formInputTextStyle(),
                  initialValue: ipAddress,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Enter an IP Address';
                    }
                  },
                  onSaved: (value) => ipAddress = value,
                ),
                Row(children: [
                  Padding(
                    child: Text(
                      "Username",
                      style: _bigLabelStyle(),
                    ),
                    padding: const EdgeInsets.only(top: 16),
                  )
                ]),
                TextFormField(
                  style: _formInputTextStyle(),
                  initialValue: account,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Enter a Username';
                    }
                  },
                  onSaved: (value) => account = value,
                ),
                Row(children: [
                  Padding(
                    child: Text(
                      "Password",
                      style: _bigLabelStyle(),
                    ),
                    padding: const EdgeInsets.only(top: 16),
                  )
                ]),
                TextFormField(
                  style: _formInputTextStyle(),
                  obscureText: true,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Enter a Password';
                    }
                  },
                  onSaved: (value) => password = value,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: RaisedButton(
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setString("account", account);
                        prefs.setString("ip", ipAddress);
                        Scaffold.of(context).showSnackBar(SnackBar(content: Text("Logging In")));
                        var synologyApi = SynologyApi();
                        await synologyApi.login(ipAddress, account, password);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => FileGridScreen("/Share")));
                      }
                    },
                    child: Text("Log In"),
                  ),
                ),
              ]),
            ),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  TextStyle _formInputTextStyle() {
    return TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18);
  }

  TextStyle _bigLabelStyle() => TextStyle(fontSize: 18);

  _getInitialValue(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.get(key);
  }

  getStoredLoginInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    account = prefs.getString("account");
    ipAddress = prefs.getString("ip");

    return account == null ? "" : account;
  }
}
