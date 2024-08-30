import 'package:flutter/material.dart';
import 'package:note_intake_app/services/databse_helper.dart';

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

  void _reloadNotes() async {
    final note = await QueryHelper.getAllNotes();
    setState(() {
      _allNotes = note;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _reloadNotes();
  }

  Future _addNote() async {
    await QueryHelper.createNote(
        _noteTitleContorller.text, _noteDescriptionController.text);
    _reloadNotes();
  }

  Future<void> _updateNote(int id) async {
    await QueryHelper.updateNote(
        id, _noteTitleContorller.text, _noteDescriptionController.text);
    _reloadNotes();
  }

  void showBottomsheetContent(int? id) async {
    if (id != null) {
      final currentNote =
          _allNotes.firstWhere((element) => element['id'] == id);
      _noteTitleContorller.text = currentNote['title'];
      _noteDescriptionController.text = currentNote['description'];
    }

    showModalBottomSheet(
        elevation: 1,
        isScrollControlled: true,
        context: context,
        builder: (_) => SafeArea(
              child: SingleChildScrollView(
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
                                  onPressed: () async {
                                    if (id == null) {
                                      await _addNote();
                                    }
                                    if (id != null) {
                                      await _updateNote(id);
                                    }
                                    _noteTitleContorller.text = '';
                                    _noteDescriptionController.text = '';
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    id == null ? "Add Note" : "Update Note",
                                    style: const TextStyle(
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
      body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _allNotes.length,
                  itemBuilder: (context, index) => Card(
                        elevation: 5,
                        margin: const EdgeInsets.all(16),
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                    _allNotes[index]["title"],
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        showBottomsheetContent(
                                            _allNotes[index]['id']);
                                      },
                                      icon: const Icon(
                                        Icons.edit,
                                      ))
                                ],
                              ),
                            ],
                          ),
                          subtitle: Text(
                            _allNotes[index]["description"],
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ))),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showBottomsheetContent(null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
