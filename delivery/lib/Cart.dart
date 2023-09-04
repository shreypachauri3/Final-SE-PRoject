import 'package:delivery/Ordered.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartScreen extends StatelessWidget {
  final String userId;

  CartScreen(this.userId);

  @override
  Widget build(BuildContext context) {
    Future<void> deleteCartItem(String documentId) async {
      try {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection('Cart')
            .doc(documentId)
            .delete();
        print('Item deleted successfully');
      } catch (e) {
        print('Error deleting item: $e');
      }
    }

    Future<void> moveCartToOrdered() async {
      try {
        final CollectionReference cartCollection = FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('Cart');
        final CollectionReference orderedCollection = FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('Ordered');
        // Get all documents from the "Cart" collection
        QuerySnapshot cartItems = await cartCollection.get();

        // Loop through each cart item and move it to the "Ordered" collection with the "ordered" flag
        for (QueryDocumentSnapshot cartItem in cartItems.docs) {
          Map<String, dynamic> cartData =
              cartItem.data() as Map<String, dynamic>;
          cartData['ordered'] = true; // Add the "ordered" flag

          // Add the modified cart item to the "Ordered" collection
          await orderedCollection.add(cartData);

          // Delete the cart item from the "Cart" collection
          await cartItem.reference.delete();
        }

        print('Cart items moved to "Ordered" successfully');
      } catch (e) {
        print('Error moving cart items to "Ordered": $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart'),
        actions: [
          IconButton(
              onPressed: moveCartToOrdered, icon: Icon(Icons.shop_rounded))
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection('Cart')
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
              child: Text('Cart is empty.'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot cartItem = snapshot.data!.docs[index];
                    Map<String, dynamic> data =
                        cartItem.data() as Map<String, dynamic>;

                    // Extract cart item data
                    String name = data['Name'];
                    double price = data['Price'];

                    return ListTile(
                      title: Text(name),
                      subtitle: Text('Price: \$${price.toStringAsFixed(2)}'),
                      trailing: IconButton(
                        onPressed: () {
                          deleteCartItem(cartItem.id);
                        },
                        icon: Icon(Icons.delete),
                        color: Colors.red.shade700,
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    moveCartToOrdered();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderedItemsScreen(
                              FirebaseAuth.instance.currentUser!.uid),
                        ));
                  },
                  child: Text("Place Order"))
            ],
          );
        },
      ),
    );
  }
}
