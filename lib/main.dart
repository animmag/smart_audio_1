import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NotiPhones',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.light,
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = "";
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  Future<void> _login() async {
    String? savedUsername = await secureStorage.read(key: "username");
    String? savedPassword = await secureStorage.read(key: "password");

    String username = usernameController.text;
    String password = passwordController.text;

    if (username == savedUsername && password == savedPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(username: username)),
      );
    } else {
      setState(() {
        errorMessage = "Invalid username or password";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[700],
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          width: 350,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'NotiPhones',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[900]),
              ),
              SizedBox(height: 20),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none),
                  prefixIcon: Icon(Icons.person, color: Colors.teal[900]),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none),
                  prefixIcon: Icon(Icons.lock, color: Colors.teal[900]),
                ),
                obscureText: true,
              ),
              SizedBox(height: 10),
              if (errorMessage.isNotEmpty)
                Text(errorMessage,
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[900],
                    foregroundColor: Colors.white),
                child: Text('Login', style: TextStyle(fontSize: 18)),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupScreen()),
                  );
                },
                child: Text("Create New Account",
                    style: TextStyle(color: Colors.teal[900])),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  String message = "";

  Future<void> _createAccount() async {
    String username = usernameController.text;
    String password = passwordController.text;

    if (username.isNotEmpty && password.isNotEmpty) {
      await secureStorage.write(key: "username", value: username);
      await secureStorage.write(key: "password", value: password);
      setState(() {
        message = "Account created successfully!";
      });
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    } else {
      setState(() {
        message = "Please enter a valid username and password";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[700],
      appBar: AppBar(title: Text("Create Account")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none),
                  prefixIcon: Icon(Icons.person, color: Colors.teal[900]),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none),
                  prefixIcon: Icon(Icons.lock, color: Colors.teal[900]),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createAccount,
                child: Text("Sign Up"),
              ),
              if (message.isNotEmpty)
                Text(message, style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String username;

  HomeScreen({required this.username});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  bool isListening = false;
  bool isDarkMode = false;
  bool notificationsEnabled = true;

  void _logout(BuildContext context) async {
    bool confirmLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text("Yes"),
          ),
        ],
      ),
    );

    if (confirmLogout) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  void _toggleNotifications() {
    setState(() {
      notificationsEnabled = !notificationsEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("NotiPhones Home"),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(widget.username),
              accountEmail: null, // Email removed
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.teal,
                child: Text(widget.username[0].toUpperCase(),
                    style: TextStyle(fontSize: 40, color: Colors.white)),
              ),
            ),
            ListTile(
              title: Text("Listening Mode"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text("Settings"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
            Spacer(),
            ListTile(
              title: ElevatedButton(
                onPressed: () => _logout(context),
                child: Text("Logout"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[900],
                    foregroundColor: Colors.white),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("NotiPhones",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 40),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.teal[100],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                children: [
                  Text("Listening Mode", style: TextStyle(fontSize: 18)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Status: "),
                      Icon(
                        isListening ? Icons.volume_up : Icons.volume_off,
                        color: isListening ? Colors.green : Colors.red,
                      ),
                      Switch(
                        value: isListening,
                        onChanged: (value) {
                          setState(() {
                            isListening = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _isNotificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text("Dark Mode"),
              value: _isDarkMode,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
              },
            ),
            SwitchListTile(
              title: Text("Enable Notifications"),
              value: _isNotificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _isNotificationsEnabled = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
