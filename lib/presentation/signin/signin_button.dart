import 'package:flutter/material.dart';

Widget signInButton(title, uri,
    [color = const Color.fromRGBO(68, 68, 76, .8)]) {
  return Container(
    padding: const EdgeInsets.all(16.0),
    child: Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            uri,
            width: 25.0,
          ),
          Padding(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Roboto',
                color: color,
              ),
            ),
            padding: EdgeInsets.only(left: 15.0),
          ),
        ],
      ),
    ),
  );
}
