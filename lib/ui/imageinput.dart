import 'package:expange/colors.dart';
import 'package:expange/utils/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageInput extends StatefulWidget {
  final String imageURL;
  final Function setImage;

  ImageInput(this.imageURL, this.setImage);

  @override
  _ImageInput createState() => _ImageInput();
}

class _ImageInput extends State<ImageInput> {
  File _fileImage;

  Widget _buildButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.add_a_photo),
        SizedBox(width: 10.0),
        Text('Update Image', style: labelTextStyle())
      ],
    );
  }

  void _getImage(BuildContext context, ImageSource source) {
    ImagePicker.pickImage(source: source, maxWidth: 400.0).then(
      (File image) {
        setState(() {
          _fileImage = image;
        });
        if (widget.setImage != null) {
          widget.setImage(image: _fileImage);
        }
        Navigator.of(context).pop();
      },
    );
  }

  void _openImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 150.0,
          color: Color(0xFF707070),
          child: Container(
            decoration: BoxDecoration(
              color: kSurfaceColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(10.0),
                topRight: const Radius.circular(10.0),
              ),
            ),
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Pick an Image',
                  style: smallBoldTextStyle(),
                ),
                SizedBox(height: 10.0),
                FlatButton(
                  onPressed: () {
                    _getImage(context, ImageSource.camera);
                  },
                  child: Wrap(
                    spacing: 10.0,
                    children: <Widget>[
                      Icon(Icons.add_a_photo),
                      Text('Open Camera', style: labelTextStyle())
                    ],
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    _getImage(context, ImageSource.gallery);
                  },
                  child: Wrap(
                    spacing: 10.0,
                    children: <Widget>[
                      Icon(Icons.add_photo_alternate),
                      Text('Open Gallery', style: labelTextStyle())
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageDisplay() {
    Widget displayContent =
        Text('Please Select an Image', style: smallBoldTextStyle());
    if (widget.imageURL != null && _fileImage == null) {
      displayContent = Image.network(
        widget.imageURL,
        fit: BoxFit.cover,
        height: 300.0,
        width: (MediaQuery.of(context).size.width - 10.0),
        alignment: Alignment.topCenter,
      );
    } else if (_fileImage != null) {
      displayContent = Image.file(_fileImage,
          fit: BoxFit.cover,
          height: 300.0,
          width: (MediaQuery.of(context).size.width - 10.0),
          alignment: Alignment.topCenter);
    }
    return displayContent;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildImageDisplay(),
          SizedBox(height: 10.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: OutlineButton(
              borderSide:
                  BorderSide(color: Theme.of(context).accentColor, width: 2.0),
              onPressed: () {
                _openImagePicker(context);
              },
              child: _buildButton(),
            ),
          )
        ],
      ),
    );
  }
}
