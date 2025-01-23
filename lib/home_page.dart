import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:nutrition_app/auth/login_page.dart';
import 'package:nutrition_app/core/theme.dart';
import 'package:nutrition_app/product_scanner.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User user = FirebaseAuth.instance.currentUser!;
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    CollectionReference mealsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('meals');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 80,
          leading: Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 40),
            child: user.photoURL != null
                ? CircleAvatar(backgroundImage: NetworkImage(user.photoURL!))
                : CircleAvatar(
                    child: Icon(
                      Icons.person,
                      size: 30,
                    ),
                  ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Welcome",
                    style: TextStyle(fontSize: 18, color: Colors.grey)),
                Text(user.displayName ?? "User",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          actions: [
            MenuAnchor(
                menuChildren: [
                  MenuItemButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                          (route) => false);
                    },
                    child: Text(
                      'Logout',
                      style: TextStyle(fontSize: FontSizes.extraSmall),
                    ),
                    style: ButtonStyle(
                        padding: WidgetStateProperty.all<EdgeInsets>(
                            EdgeInsets.symmetric(horizontal: 15, vertical: 5)),
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.grey.shade200)),
                  ),
                ],
                builder: (context, controller, child) {
                  return IconButton(
                    padding: EdgeInsets.only(top: 40),
                    icon: Icon(Icons.more_vert_rounded),
                    onPressed: () {
                      if (!controller.isOpen) {
                        controller.open();
                      } else {
                        controller.close();
                      }
                    },
                  );
                }),
          ]),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ProductScannerPage()));
        },
        child: Icon(
          Icons.camera_alt,
          color: Colors.white,
        ),
        backgroundColor: Theme.of(context).focusColor,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            _buildDateSelector(),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: mealsRef
                    .where('date',
                        isEqualTo:
                            DateFormat('yyyy-MM-dd').format(selectedDate))
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Error loading meals"));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                        child: Text(
                      "No meals found",
                      style: Theme.of(context).textTheme.titleMedium,
                    ));
                  }

                  final meals = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: meals.length,
                    itemBuilder: (context, index) {
                      final id = meals[index].reference.id;
                      final meal = meals[index].data() as Map<String, dynamic>;

                      return _buildMealCard(
                        id,
                        meal['name'],
                        meal['calories'],
                        meal['protein'],
                        meal['fats'],
                        meal['carbs'],
                        meal['image'],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          DateTime date = DateTime.now().subtract(Duration(days: 3 - index));
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = date;
              });
            },
            child: _buildDateItem(
              DateFormat('MMM').format(date),
              DateFormat('dd').format(date),
              date.day == selectedDate.day,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateItem(String month, String day, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        width: 70,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isSelected
                ? Theme.of(context).focusColor
                : Colors.grey.shade100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(month,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(day,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(String id, String title, int calories, int protein,
      int fats, int carbs, String imageId) {
    var projectId = '6791cd0d00139cfb4f8b';
    var bucketId = '6791ce13001fc151d44b';

    final client = Client()
        .setEndpoint('https://cloud.appwrite.io/v1')
        .setProject(projectId);

    final storage = Storage(client);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            FutureBuilder(
                future: storage.getFileDownload(
                    bucketId: bucketId, fileId: imageId),
                builder: (context, snapshot) {
                  return snapshot.hasData && snapshot.data != null
                      ? Image.memory(snapshot.data!,
                          width: 60, height: 60, fit: BoxFit.cover)
                      : CircularProgressIndicator();
                }),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                Text("🔥 $calories kcal - 100g",
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
            Spacer(),
            MenuAnchor(
              menuChildren: [
                MenuItemButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('meals')
                        .doc(id)
                        .delete();
                  },
                  child: Text(
                    'Delete',
                    style: TextStyle(fontSize: FontSizes.extraSmall),
                  ),
                  style: ButtonStyle(
                      padding: WidgetStateProperty.all<EdgeInsets>(
                          EdgeInsets.symmetric(horizontal: 15, vertical: 5)),
                      backgroundColor:
                          WidgetStatePropertyAll(Colors.grey.shade200)),
                ),
              ],
              builder: (context, controller, child) {
                return IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {
                    if (!controller.isOpen) {
                      controller.open();
                    } else {
                      controller.close();
                    }
                  },
                );
              },
            )
          ]),
          Row(
            children: [
              Text("Protein: $protein g",
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(width: 10),
              Text("Fats: $fats g",
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(width: 10),
              Text("Carbs: $carbs g",
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }
}
