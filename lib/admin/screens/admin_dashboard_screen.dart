import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/admin_auth_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AdminAuthService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console'),
        actions: [
          IconButton(
            onPressed: auth.signOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: DefaultTabController(
        length: 5,
        child: Column(
          children: [
            const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Users'),
                Tab(text: 'Packages'),
                Tab(text: 'Payments'),
                Tab(text: 'Trials & Promos'),
                Tab(text: 'Analytics'),
              ],
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  _UsersTab(),
                  _PackagesTab(),
                  _PaymentsTab(),
                  _TrialsTab(),
                  _AnalyticsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: db.collection('landlords').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? [];
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search by name or email'),
                      onChanged: (q) {
                        // TODO: implement client-side filter or Firestore queries
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(onPressed: (){}, icon: const Icon(Icons.person_add), label: const Text('Grant Trial')),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Plan')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Registered')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: [
                    for (final d in docs)
                      DataRow(cells: [
                        DataCell(Text(d.data()['name'] ?? '—')),
                        DataCell(Text(d.data()['email'] ?? '—')),
                        DataCell(Text(d.data()['plan'] ?? 'free')),
                        DataCell(Text((d.data()['active'] ?? true) ? 'Active' : 'Suspended')),
                        DataCell(Text((d.data()['createdAt'] as Timestamp?)?.toDate().toString() ?? '—')),
                        DataCell(Row(
                          children: [
                            IconButton(tooltip: 'Suspend', icon: const Icon(Icons.block), onPressed: () async {
                              await db.collection('landlords').doc(d.id).update({'active': false});
                            }),
                            IconButton(tooltip: 'Reactivate', icon: const Icon(Icons.check_circle), onPressed: () async {
                              await db.collection('landlords').doc(d.id).update({'active': true});
                            }),
                            IconButton(tooltip: 'Reset password email', icon: const Icon(Icons.password), onPressed: () async {
                              final email = d.data()['email'];
                              if (email != null && email is String) {
                                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                              }
                            }),
                          ],
                        )),
                      ])
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PackagesTab extends StatelessWidget {
  const _PackagesTab();

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              FilledButton.icon(onPressed: () async {
                await db.collection('packages').add({
                  'name': 'Standard',
                  'price': 9.99,
                  'duration': 'monthly',
                  'features': ['Basic features'],
                  'active': true,
                  'createdAt': FieldValue.serverTimestamp(),
                });
              }, icon: const Icon(Icons.add), label: const Text('Add Package')),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: db.collection('packages').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final d = docs[i];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(d.data()['name'] ?? 'Package'),
                      subtitle: Text('USD ${d.data()['price']} • ${d.data()['duration']}'),
                      trailing: Switch(
                        value: (d.data()['active'] ?? true) as bool,
                        onChanged: (v) => db.collection('packages').doc(d.id).update({'active': v}),
                      ),
                      onTap: () async {
                        // TODO: open edit dialog
                      },
                      onLongPress: () async {
                        await db.collection('packages').doc(d.id).delete();
                      },
                    ),
                  );
                },
              );
            },
          ),
        )
      ],
    );
  }
}

class _PaymentsTab extends StatelessWidget {
  const _PaymentsTab();

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: db.collection('payments').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        return ListView(
          children: [
            DataTable(
              columns: const [
                DataColumn(label: Text('User')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Gateway')),
                DataColumn(label: Text('Txn Id')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Actions')),
              ],
              rows: [
                for (final d in docs)
                  DataRow(cells: [
                    DataCell(Text(d.data()['userEmail'] ?? '—')),
                    DataCell(Text(d.data()['amount']?.toString() ?? '—')),
                    DataCell(Text(d.data()['status'] ?? '—')),
                    DataCell(Text(d.data()['gateway'] ?? '—')),
                    DataCell(Text(d.data()['txnId'] ?? '—')),
                    DataCell(Text((d.data()['createdAt'] as Timestamp?)?.toDate().toString() ?? '—')),
                    DataCell(Row(children: [
                      IconButton(tooltip: 'Mark verified', icon: const Icon(Icons.verified), onPressed: () async {
                        await db.collection('payments').doc(d.id).update({'status': 'verified'});
                      }),
                      IconButton(tooltip: 'Refund', icon: const Icon(Icons.undo), onPressed: () async {
                        // TODO: integrate gateway refund API
                      }),
                    ])),
                  ])
              ],
            ),
          ],
        );
      },
    );
  }
}

class _TrialsTab extends StatelessWidget {
  const _TrialsTab();

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              FilledButton.icon(onPressed: () async {
                // TODO: implement promo creation dialog
              }, icon: const Icon(Icons.local_offer), label: const Text('Create Promo Code')),
              const SizedBox(width: 8),
              FilledButton.icon(onPressed: () async {
                // TODO: implement trial grant workflow
              }, icon: const Icon(Icons.timer), label: const Text('Grant Trial')),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: db.collection('promos').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final d = docs[i];
                  return ListTile(
                    leading: const Icon(Icons.local_offer),
                    title: Text(d.data()['code'] ?? 'CODE'),
                    subtitle: Text('Valid till: ${d.data()['validUntil']?.toDate() ?? '—'}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await db.collection('promos').doc(d.id).delete();
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;
    return FutureBuilder<List<int>>(
      future: _loadCounts(db),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final data = snapshot.data!;
        return GridView.count(
          crossAxisCount: 3,
          children: [
            _MetricCard(title: 'Total Landlords', value: data[0].toString()),
            _MetricCard(title: 'Active Subscriptions', value: data[1].toString()),
            _MetricCard(title: 'Payments (30d)', value: data[2].toString()),
          ],
        );
      },
    );
  }

  Future<List<int>> _loadCounts(FirebaseFirestore db) async {
    final landlords = await db.collection('landlords').count().get();
    final activeSubs = await db.collection('subscriptions').where('active', isEqualTo: true).count().get();
    final payments = await db.collection('payments').where('createdAt', isGreaterThan: DateTime.now().subtract(const Duration(days: 30))).count().get();
    return [landlords.count, activeSubs.count, payments.count];
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  const _MetricCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 8),
            Text(title),
          ],
        ),
      ),
    );
  }
}
