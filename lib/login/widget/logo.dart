import 'package:flutter/material.dart';
class logo extends StatelessWidget {
  const logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(     color: Theme.of(context).primaryColor,borderRadius: BorderRadius.circular(10)),
        width: 50,
      height: 50,
      child: Center(
        child: Icon(Icons.headphones_outlined,color: Theme.of(context).colorScheme.onPrimary,size: 35,),
      ),
    );
  }
}
