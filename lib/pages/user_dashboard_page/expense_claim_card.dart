import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user.dart';
import '../expense_claim_details_page/claim_form.dart';



class ExpenseClaimDetailsPage extends StatefulWidget {
  final AppUser user;

  ExpenseClaimDetailsPage({required this.user});

  @override
  _ExpenseClaimDetailsPageState createState() => _ExpenseClaimDetailsPageState();
}

class _ExpenseClaimDetailsPageState extends State<ExpenseClaimDetailsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Claim Details', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClaimForm()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instanceFor(app: Firebase.app(),databaseId: 'aidatabase')
                    .collection('expenseClaims')
                    .where('userId', isEqualTo: _currentUser.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  var claims = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: claims.length,
                    itemBuilder: (context, index) {
                      var claim = claims[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: ListTile(
                          title: Text(
                              "Claim ID: ${claim.id} \nDate: ${claim['createdAt'].toDate().day}-${claim['createdAt'].toDate().month}-${claim['createdAt'].toDate().year}"),
                          subtitle: Text(
                              "Type: ${claim['claimType']} \nTotal Amount: RM ${claim['totalAmount'].toStringAsFixed(2)} \nStatus: ${claim['status']}"),
                          trailing: claim['transactionReference'] != null
                              ? Text("Reference: ${claim['transactionReference']}")
                              : null,
                        ),
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
}
