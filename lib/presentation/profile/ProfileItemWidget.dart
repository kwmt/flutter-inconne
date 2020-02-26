import 'package:flutter/material.dart';

class ProfileItemWidget extends StatelessWidget {
  const ProfileItemWidget({Key key, this.title, this.value, this.onTap})
      : super(key: key);

  final String title;
  final String value;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: themeData.dividerColor))),
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.subhead,
          child: SafeArea(
            top: false,
            bottom: false,
            child: Container(
              padding: EdgeInsets.only(left: 16.0, right: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      width: 72.0,
                      child: Text(title)),
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        value,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}
