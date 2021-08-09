import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class NoInternetWidget extends StatefulWidget {
  ConnectivityResult connectionStatus;
  NoInternetWidget(this.connectionStatus);
  @override
  _NoInternetState createState() => _NoInternetState(connectionStatus);
}

class _NoInternetState extends State<NoInternetWidget> {
  ConnectivityResult connectionStatus;
  _NoInternetState(this.connectionStatus);
  bool retryPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_sharp,
              size: 100,
              color: Colors.white,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "No Connection to Internet",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                fontFamily: "Lobster",
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              child: Text(
                "please check your internet connection and try again",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Lobster",
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            retryPressed == true
                ? Container(
                    margin: EdgeInsets.only(top: 10),
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.black,
                    ),
                  )
                : Container(
                    width: 100,
                    height: 40,
                    margin: EdgeInsets.only(top: 30),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          retryPressed = true;
                        });
                        if (connectionStatus == ConnectivityResult.none) {
                          Timer(Duration(seconds: 2), () {
                            setState(() {
                              retryPressed = false;
                            });
                          });
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(
                        "Retry",
                        style: TextStyle(
                          fontFamily: "Lobster",
                          fontWeight: FontWeight.w400,
                          fontSize: 24,
                          letterSpacing: 1.5,
                        ),
                      ),
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22.0),
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
