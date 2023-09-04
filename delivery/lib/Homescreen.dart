import 'package:delivery/RestaurentDetailsPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('restaurants').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          final restaurants = snapshot.data?.docs;

          return ListView.builder(
            itemCount: restaurants!.length,
            itemBuilder: (context, index) {
              final restaurant =
                  restaurants[index].data() as Map<String, dynamic>;
              final restaurantName =
                  restaurant['Name']; // Replace 'name' with your field name

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  enableFeedback: true,
                  focusColor: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RestaurantDetailsPage(restaurants[index].id),
                      ),
                    );
                  },
                  isThreeLine: true,
                  subtitle: Text(restaurant['discription']),
                  title: Text(restaurantName),
                  enabled: restaurant['Opened'],
                  leading: Image.network(
                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSPkq7NvtTd8ohXvljuq0VB5mJQlC1M3RiHtxznS9PIGw&s"),
                  // Add more widgets to display other restaurant data
                ),
              );
            },
          );
        },
      ),
    );
  }
}
