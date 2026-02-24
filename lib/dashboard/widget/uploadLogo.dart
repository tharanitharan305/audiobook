import 'package:flutter/material.dart';
class UploadLogo extends StatelessWidget {
  const UploadLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).primaryColor.withOpacity(0.2)
      ),
      child: Center(
        child: Icon(Icons.file_upload_outlined,color: Theme.of(context).primaryColor,),
      ),
    );
  }
}
