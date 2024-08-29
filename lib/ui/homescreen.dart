import 'package:flutter/material.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  List<Map<String, dynamic>> _allNotes = [];
  bool _isLoading = true;

  final TextEditingController _noteTitleContorller = TextEditingController();
  final TextEditingController _noteDescriptionController =
      TextEditingController();

  void showBottomsheetContent(int? id) async {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (_) => SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                        top: 15,
                        left: 15,
                        right: 15,
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextField(
                            controller: _noteTitleContorller,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "Note Title"),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          TextField(
                            controller: _noteDescriptionController,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Description",
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Center(
                            child: OutlinedButton(
                                onPressed: () {},
                                child: const Text(
                                  "Add Note",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300),
                                )),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Note"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text("notes"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showBottomsheetContent(null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
