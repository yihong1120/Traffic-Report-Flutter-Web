import 'package:flutter/material.dart';

class PasswordChangeDonePage extends StatefulWidget {
  const PasswordChangeDonePage({Key? key}) : super(key: key);

  @override
  _PasswordChangeDonePageState createState() => _PasswordChangeDonePageState();
}

class _PasswordChangeDonePageState extends State<PasswordChangeDonePage> {
  int _countdown = 10;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(Duration(seconds: 1), () {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
        _startCountdown();
      } else {
        _redirectToAccountPage();
      }
    });
  }

  void _redirectToAccountPage() {
    // Replace with the route name of your account page
    Navigator.of(context).pushReplacementNamed('/account');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Password Change Successful'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Your password has been changed successfully!',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'You will be redirected to your account page in $_countdown seconds.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: _redirectToAccountPage,
              child: Text('Click here if you are not redirected'),
            ),
          ],
        ),
      ),
    );
  }
}