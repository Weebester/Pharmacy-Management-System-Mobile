import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'api_call_manager.dart';
import 'assistant_card.dart';

class AssistantManage extends StatefulWidget {
  final List br;

  const AssistantManage({super.key, required this.br});

  @override
  AssistantManageState createState() => AssistantManageState();
}

class AssistantManageState extends State<AssistantManage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int _selectedBranchIndex = 0;

  List<Assistant> _assistants = [];

  @override
  void initState() {
    super.initState();
    fetchAssistants().then((temp) {
      setState(() {
        _assistants = temp;
      });
    });
  }

  void updateAssistList() {
    fetchAssistants().then((temp) {
      setState(() {
        _assistants = temp;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final apiCaller = context.read<APICaller>();

    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        title: const Text("Assistants Management"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Add new Assistant",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Confirm Action'),
                                  content: Text(
                                      'Are you sure you want to add this assistant?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        addAssistant(
                                          _nameController.text,
                                          _emailController.text,
                                          _passwordController.text,
                                          _selectedBranchIndex,
                                          apiCaller,
                                        ).then((M) {
                                          SchedulerBinding.instance
                                              .addPostFrameCallback((_) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(content: Text(M)),
                                            );
                                            Navigator.pop(context);
                                          });
                                        });
                                        updateAssistList();
                                      },
                                      child: Text('Confirm'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                        ),
                        child: const Text("Add"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  DropdownButtonFormField<int>(
                    value: _selectedBranchIndex,
                    decoration: InputDecoration(
                      labelText: 'Branch',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    items: List.generate(
                      widget.br.length,
                      (index) => DropdownMenuItem<int>(
                        value: index,
                        child: Text("Branch ${widget.br[index]}"),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedBranchIndex = value ?? 0;
                      });
                    },
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter your email'
                        : null,
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter your password'
                        : null,
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      hintText: 'Enter your Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter your Name'
                        : null,
                  ),
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        "Assistants List:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      )
                    ],
                  ),
                  ..._assistants.map((assistant) => AssistantCard(
                        assistant: assistant,
                        apiCaller: apiCaller,
                        updateList: updateAssistList,
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<List<Assistant>> fetchAssistants() async {
    String route = "$serverAddress/get_assistant";
    try {
      final apiCaller = context.read<APICaller>();
      final response = await apiCaller.get(route);

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = response.data;
        return jsonResponse
            .map((jsonObject) => Assistant.fromJson(jsonObject))
            .toList();
      } else {
        throw Exception('Failed to load assistant data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error fetching assistants: $e');
    }
  }

  Future<String> addAssistant(String name, String email, String password,
      int phIndex, APICaller apiCaller) async {
    String route = "$serverAddress/add_assistant";
    Map<String, dynamic> requestBody = {
      "name": name,
      "email": email,
      "passW": password,
      "index": phIndex
    };

    try {
      final response = await apiCaller.post(route, requestBody);

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return ('Failed to add assistant: ${response.data}');
      }
    } catch (e) {
      return ('Failed to add assistant');
    }
  }
}
