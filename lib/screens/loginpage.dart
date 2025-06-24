import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaxiorderv1/data/dbhelper.dart';
import 'package:vaxiorderv1/data/sharedpreferences.dart';
import 'package:vaxiorderv1/services/getusers.dart';
import 'package:vaxiorderv1/utils/encryption.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final LocalDatabase _dbHelper = LocalDatabase();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedUsername();
    _loadInitialData();
  }

  Future<void> _loadSavedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');
    final savedPassword = prefs.getString('password');
    if (savedUsername != null) {
      _usernameController.text = savedUsername;
      _passwordController.text = savedPassword ?? '';
    }
  }

  Future<void> _loadInitialData() async {
    await fetchAndStoreUsers(); // Fetch from API and store in SQLite
    setState(() {
      _isLoading = false;
    });
  }

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showError('Please enter username and password.');
      return;
    }

    final user = await _dbHelper.getUserByUserName(username);

    if (user == null) {
      _showError('User not found.');
      return;
    }

    final isValid = validatePassword(password, user.userpass ?? '');

    if (isValid) {
      await LoginPreferences.saveLogin(username, password);
      Navigator.pushReplacementNamed(context, '/home');
      //_showSuccess('Login successful!');
    } else {
      _showError('Invalid password.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /*void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _login, child: const Text('Login')),
            ],
          ),
        ),
      ),
    );
  }
}
