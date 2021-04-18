import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foodie/views/order_page.dart';
import 'package:url_launcher/url_launcher.dart';

class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {

  final CollectionReference _usersRef =
  FirebaseFirestore.instance.collection("GUsers");
  final CollectionReference _dishRef =
  FirebaseFirestore.instance.collection("dishes");
  final CollectionReference _drinkRef =
  FirebaseFirestore.instance.collection('drinks');

  User _user = FirebaseAuth.instance.currentUser;

  final SnackBar _snackBar =
  SnackBar(content: Text("Item removed from cart"));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backwardsCompatibility: false,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.red[700]),
        title: Text(
          'Your Cart',
          style: TextStyle(
            color: Colors.red[700],
          ),
        ),
        elevation: 1.0,
        backgroundColor: Colors.white,
        bottom: PreferredSize(
            child: BottomAppBar(
              notchMargin: 4.0,
            ),
            preferredSize: Size.fromHeight(6.0)),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      ),
        body: Stack(
          children: [
            FutureBuilder<QuerySnapshot>(
              future: _usersRef.doc(_user.uid).collection("Cart").get(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Scaffold(
                    body: Center(
                      child: Text("Error: ${snapshot.error}"),
                    ),
                  );
                }
                //Collection Data ready to display
                if (snapshot.connectionState == ConnectionState.done) {
                  return
                    ListView(
                    children: snapshot.data.docs.map((document) {
                      return Card(
                          margin: EdgeInsets.only(
                              left: 14.0, top: 14.0, right: 14.0, bottom: 10.0),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0)),
                          elevation: 3.0,
                          child: FutureBuilder(
                              future: _dishRef.doc(document.id).get(),
                              builder: (context, dishSnap) {
                                if (dishSnap.hasError) {
                                  return Container(
                                    child: Center(
                                      child: Text("${dishSnap.error}"),
                                    ),
                                  );
                                }
                                if (dishSnap.connectionState ==
                                    ConnectionState.done) {
                                  Map _dishMap = dishSnap.data.data();
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                      horizontal: 20.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 90,
                                          height: 90,
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          OrderPage(
                                                            dishesId:
                                                            document.id,
                                                          )));
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                              BorderRadius.circular(8.0),
                                              child: Image.network(
                                                "${_dishMap['images'][0]}",
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child, loadingProgress) {
                                                  if (loadingProgress == null) return child;
                                                  return Center(
                                                    child: CircularProgressIndicator(),
                                                  );
                                                },
                                                errorBuilder: (context, error, stacktrace) => Center(
                                                    child: Text("Ooops !Check Your Internet Connection")),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(
                                            left: 12.0,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${_dishMap['dish']}",
                                                style: TextStyle(
                                                    fontSize: 17.0,
                                                    color: Colors.black
                                                        .withOpacity(0.8),
                                                    fontWeight:
                                                    FontWeight.w400),
                                              ),
                                              Padding(
                                                padding:
                                                const EdgeInsets.symmetric(
                                                  vertical: 5.0,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(FontAwesomeIcons.rupeeSign,
                                                      size: 18.0,color: Colors.black,
                                                    ),
                                                    SizedBox(
                                                      width: 5.0,
                                                    ),
                                                    Text(
                                                    "${_dishMap['price']}",
                                                    style: TextStyle(
                                                        fontSize: 16.0,
                                                        color: Theme.of(context)
                                                            .accentColor,
                                                        fontWeight:
                                                        FontWeight.w400),
                                                  ),
                                               ] ),
                                              ),
                                              Row(
                                                children:[
                                                  Icon(FontAwesomeIcons.solidStar,
                                                    size: 18.0,color: Colors.yellow[600],
                                                  ),
                                                  SizedBox(
                                                    width: 5.0,
                                                  ),
                                                  Text(
                                                  "${_dishMap['rating']}",
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      color: Colors.black
                                                          .withOpacity(0.8),
                                                      fontWeight:
                                                      FontWeight.w400),
                                                ),
                                             ] ),
                                              Row(children: [
                                                TextButton(
                                                  onPressed: () {
                                                    launch(("tel: 8839640035"));
                                                  },
                                                  child: Text(
                                                    "Order Now",
                                                    style: TextStyle(
                                                        fontSize: 16.0,
                                                        color:
                                                        Colors.lightBlue),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 25.0,
                                                ),
                                                IconButton(
                                                    icon: Icon(
                                                      Icons.delete_rounded,
                                                      color: Colors.black
                                                          .withOpacity(0.7),
                                                    ),
                                                    onPressed: () {
                                                      showDialog<void>(
                                                          context: context,
                                                          barrierDismissible:
                                                          false,
                                                          builder: (BuildContext
                                                          context) {
                                                            return AlertDialog(
                                                              title: Text(
                                                                  "Delete?"),
                                                              content:
                                                              SingleChildScrollView(
                                                                child: ListBody(
                                                                  children: [
                                                                    Text(
                                                                        "Are you sure you want to remove this item from Cart?")
                                                                  ],
                                                                ),
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child: Text(
                                                                      "No",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                          17.0),
                                                                    )),
                                                                TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      setState(
                                                                              () {
                                                                            FirebaseFirestore
                                                                                .instance
                                                                                .collection(
                                                                                "GUsers")
                                                                                .doc(_user
                                                                                .uid)
                                                                                .collection(
                                                                                "Cart")
                                                                                .doc(document
                                                                                .id)
                                                                                .delete()
                                                                                .then((value) =>
                                                                                Navigator.pop(context))
                                                                                .whenComplete(() => ScaffoldMessenger.of(context).showSnackBar(_snackBar));
                                                                          });
                                                                    },
                                                                    child: Text(
                                                                      "Yes",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                          16.0),
                                                                    )),
                                                              ],
                                                            );
                                                          });
                                                    })
                                              ])
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return Container(
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                );
                              })) ;
                    }).toList(),
                  );
                }
                return Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
          ],
        )
    );
  }
}
