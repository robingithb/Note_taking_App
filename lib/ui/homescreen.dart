import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:note_intake_app/services/databse_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homescreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  const Homescreen({super.key, required this.onThemeChanged});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  bool _isDarkMode = false;
  Future<void> _loadPreferences() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    _isDarkMode = pref.getBool("isDarkMode") ?? false;
  }

  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
      widget.onThemeChanged(_isDarkMode);
    });
  }

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
    _loadPreferences();
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

  void _deleteNode(int id) async {
    await QueryHelper.deleteNote(id);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("The note has been deleted")));
    _reloadNotes();
  }

  void _deleteAllNotes() async {
    final noteCount = await QueryHelper.getNoteCount();
    if (noteCount > 0) {
      await QueryHelper.deleteAllNotes();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("All note has been deleted"),
      ));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("No notes to delete")));
    }
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
        actions: [
          IconButton(
              onPressed: () async {
                _deleteAllNotes();
              },
              icon: const Icon(Icons.delete_forever)),
          IconButton(
              onPressed: () {
                _exitApp();
              },
              icon: const Icon(Icons.exit_to_app)),
          Transform.scale(
            scale: 0.7,
            child: Switch(
                value: _isDarkMode,
                onChanged: (value) {
                  _toggleTheme(value);
                }),
          )
        ],
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
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        _deleteNode(_allNotes[index]['id']);
                                      },
                                      icon: const Icon(Icons.delete))
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

  void _exitApp() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Exit App"),
            content: const Text("Are you sure to exit???"),
            actions: [
              OutlinedButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  child: const Text("Exit")),
              OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"))
            ],
          );
        });
  }
}
