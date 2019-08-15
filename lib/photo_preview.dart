import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PhotoPreviewPage extends StatelessWidget {
  const PhotoPreviewPage(this.photo);

  final String photo;

  @override
  Widget build(BuildContext context) {

    return Container(
      color: Color(0x99000000),
      padding: const EdgeInsets.all(16.0),
      alignment: Alignment.center,
      child: PhotoHero(
        photo: photo,
        width: 300.0,
        onTap: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class PhotoHero extends StatelessWidget {
  const PhotoHero({Key key, this.photo, this.onTap, this.width})
      : super(key: key);

  final String photo;
  final VoidCallback onTap;
  final double width;

  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Hero(
        tag: photo,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Image.file(
              File(photo),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
