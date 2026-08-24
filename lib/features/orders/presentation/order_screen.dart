import 'package:flutter/material.dart';

class OrderScreen extends StatelessWidget{
  const OrderScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: Center(
        child: Text('This is the order screen'),
      ),
    );
  }
}