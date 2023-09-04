import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderedItemsScreen extends StatelessWidget {
  final String userId;

  OrderedItemsScreen(this.userId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ordered Items'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection('Ordered')
            .where('ordered', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No ordered items.'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot orderedItem = snapshot.data!.docs[index];
              Map<String, dynamic> data =
                  orderedItem.data() as Map<String, dynamic>;

              // Display ordered item data
              String name = data['Name'];
              double price = data['Price'];
              int qty = data['qty'];

              return ListTile(
                title: Text(name),
                subtitle: Text('Price: \$${price.toStringAsFixed(2)}'),
                trailing: Text('Qty: $qty'),
              );
            },
          );
        },
      ),
    );
  }
}
