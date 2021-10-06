import 'package:auth_app/auth_class.dart';
import 'package:auth_app/driver.dart';
import 'package:auth_app/views/user_view.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage /*extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);*/
    extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<QuerySnapshot>(
            stream: _db
                .collection("users")
                .orderBy("timestamp", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Text("Loading..."),
                );
              } else {
                return ListView(
                    //scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: snapshot.data!.docs.map((e) {
                      return Card(
                          child: ListTile(
                              leading: Image.network(e.get("picture_url")),
                              title: Text(e.get("first_name")),
                              subtitle: Text(
                                  "Joined: ${e.get("timestamp").toDate()}"),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (con) => UserPage(uid: e.id)));
                              }));
                    }).toList());
              }
            }),
        appBar: AppBar(
          title: const Text("All Users"),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      _buildLogoutDialog(context),
                );
              },
              tooltip: 'Log Out',
              icon: const Icon(Icons.logout),
            ),
          ],
        ));
  }

  Widget _buildLogoutDialog(BuildContext context) {
    return AlertDialog(
        title: const Text("Do you want to log out?"),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              OutlinedButton(
                onPressed: () {
                  _signOut(context);
                },
                child: const Text('Log out'),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              )
            ]));
  }

  void _signOut(BuildContext context) async {
    ScaffoldMessenger.of(context).clearSnackBars();
    await FireAuthClass.logout();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('User logged out.')));
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (con) => AppDriver()));
  }
}
