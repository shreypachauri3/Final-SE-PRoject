import 'package:delivery/Cart.dart';
import 'package:delivery/Models/item.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RestaurantDetailsPage extends StatelessWidget {
  final String restaurantId;

  RestaurantDetailsPage(this.restaurantId);

  @override
  Widget build(BuildContext context) {
    Future<void> createOrAppendData(
        String name, double price, String url) async {
      try {
        CollectionReference userCollection =
            FirebaseFirestore.instance.collection('Users');

        // Get a reference to the user's document in the subcollection
        DocumentReference userDocument = userCollection
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('Cart')
            .doc();

        // Check if the document exists
        DocumentSnapshot snapshot = await userDocument.get();

        if (!snapshot.exists) {
          // If the document doesn't exist, create it with the new data
          await userDocument
              .set({'Name': name, 'Price': price, 'Photo': url, 'qty': 1});
        } else {
          // If the document exists, generate a new document ID and add the data
          int currentQty =
              (snapshot.data() as Map<String, dynamic>)['qty'] ?? 0;

          // Increment the qty by 1
          int updatedQty = currentQty + 1;

          // Update the document with the new qty value
          await userDocument.update({'qty': updatedQty});
          print('Quantity updated successfully');

          // Set the data in the new document with a new ID
          await userDocument.set(
              {'Name': name, 'Price': price, 'Photo': url, 'qty': updatedQty});
        }

        print('Data created or appended successfully');
      } catch (e) {
        print('Error creating or appending data: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant Details'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('restaurants')
            .doc(restaurantId)
            .collection('Food_items')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          final menuItems = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return MenuItem(
                name: data['Name'] as String,
                price: data['Price'] as double,
                Photo: data['Photo']);
          }).toList();

          return ListView.builder(
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final menuItem = menuItems[index];
              return Column(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CartScreen(
                                  FirebaseAuth.instance.currentUser!.uid),
                            ));
                      },
                      child: Text("Go to your Cart")),
                  Container(
                    height: 220,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(8),
                      title: Text(menuItem.name),
                      subtitle:
                          Text('Price: \$${menuItem.price.toStringAsFixed(2)}'),
                      leading: Image.network(menuItem.Photo),
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              createOrAppendData(menuItem.name, menuItem.price,
                                  menuItem.Photo);
                            },
                            child: Text('Add to Cart'),
                          ),
                          SizedBox(width: 8), // Add spacing between the buttons
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
