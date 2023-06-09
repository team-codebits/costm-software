import 'package:flutter/material.dart';
import 'package:costm_software/views/add_player_view.dart';
import 'package:costm_software/models/tournament_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class AddTournamentPage extends StatefulWidget {
  const AddTournamentPage({Key? key}) : super(key: key);

  @override
  State<AddTournamentPage> createState() => _AddTournamentPageState();
}

class _AddTournamentPageState extends State<AddTournamentPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController organizerController = TextEditingController();
  final TextEditingController timeControlController = TextEditingController();
  final TextEditingController roundsController = TextEditingController();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  List<Tournament> tournamentList = [];

  Future<bool> saveTournament() async {
    if (nameController.text.isEmpty ||
        organizerController.text.isEmpty ||
        timeControlController.text.isEmpty ||
        roundsController.text.isEmpty) {
      return false;
    }

    final Tournament tournament = Tournament(
      name: nameController.text,
      organizer: organizerController.text,
      timeControl: timeControlController.text,
      roundsNumber: int.tryParse(roundsController.text),
    );

    // Retrieve existing tournament list from secure storage
    final String? tournamentListJson =
        await secureStorage.read(key: 'tournamentList');
    if (tournamentListJson != null) {
      final List<dynamic> tournamentListData = jsonDecode(tournamentListJson);
      tournamentList =
          tournamentListData.map((t) => Tournament.fromJson(t)).toList();
    }

    // Add new tournament to the list
    tournamentList.add(tournament);

    // Write updated tournament list back to secure storage
    final List<Map<String, dynamic>> tournamentListJsonData =
        tournamentList.map((t) => t.toJson()).toList();
    await secureStorage.write(
      key: 'tournamentList',
      value: jsonEncode(tournamentListJsonData),
    );

    nameController.clear();
    organizerController.clear();
    timeControlController.clear();
    roundsController.clear();

    return true;
  }

  void showSaveConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tournament saved'),
        content: const Text('The tournament has been successfully saved.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: const Text('Add tournament'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final savedSuccessfully = await saveTournament();
          if (savedSuccessfully) {
            showSaveConfirmationDialog();
          } else {
            // ignore: use_build_context_synchronously
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Empty fields'),
                content: const Text('Please fill in all fields.'),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        },
        label: const Text('SAVE TOURNAMENT'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: nameController,
                maxLines: 1,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: organizerController,
                maxLines: 1,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Organizer',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: timeControlController,
                maxLines: 1,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Time control',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: roundsController,
                maxLines: 1,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Number of rounds',
                ),
              ),
            ),
            const Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Player's list:",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                ElevatedButton.icon(
                  label: const Text('Add player'),
                  icon: const Icon(Icons.group_add),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => const AddPlayerPage())));
                  },
                )
              ],
            ),
          ],
        ),
      ));
}
