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
  bool isListening = false; // Listening mode toggle
  String wakeWord = "Anavi"; // Default wake word
  int vibrationIntensity = 50; // Vibration intensity (0-100)
  int sensitivityLevel = 5; // Sensitivity level (1-10)
  int _selectedIndex = 0; // For sidebar navigation

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

  // Handle sidebar navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
            // Home Icon
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              selected: _selectedIndex == 0,
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context); // Close the drawer
              },
            ),
            // Device Features
            ListTile(
              leading: Icon(Icons.settings_input_component),
              title: Text("Device Features"),
              selected: _selectedIndex == 1,
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context); // Close the drawer
              },
            ),
            // Settings
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              selected: _selectedIndex == 2,
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context); // Close the drawer
              },
            ),
            Spacer(),
            // Logout Button
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
      body: _buildBody(), // Dynamically build the body based on selected index
    );
  }

  // Build the body based on the selected index
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0: // Home
        return _buildHomeScreen();
      case 1: // Device Features
        return _buildDeviceFeaturesScreen();
      case 2: // Settings
        return SettingsScreen();
      default:
        return _buildHomeScreen();
    }
  }

  // Home Screen (Status Page)
  Widget _buildHomeScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("NotiPhones",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 40),
          // Add your home screen content here
        ],
      ),
    );
  }

  // Device Features Screen
  Widget _buildDeviceFeaturesScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Device Features",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          // Listening Mode
          Card(
            child: ListTile(
              title: Text("Listening Mode"),
              trailing: Switch(
                value: isListening,
                onChanged: (value) {
                  setState(() {
                    isListening = value;
                  });
                },
              ),
            ),
          ),
          SizedBox(height: 10),
          // Set Wake Word
          Card(
            child: ListTile(
              title: Text("Set Wake Word"),
              subtitle: Text("Current: $wakeWord"),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showWakeWordDialog();
                },
              ),
            ),
          ),
          SizedBox(height: 10),
          // Vibration Settings
          Card(
            child: ListTile(
              title: Text("Vibration Settings"),
              subtitle: Text("Intensity: $vibrationIntensity%"),
              trailing: IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  _showVibrationSettingsDialog();
                },
              ),
            ),
          ),
          SizedBox(height: 10),
          // Sensitivity Settings
          Card(
            child: ListTile(
              title: Text("Sensitivity Settings"),
              subtitle: Text("Level: $sensitivityLevel"),
              trailing: IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  _showSensitivitySettingsDialog();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog to change the wake word
  void _showWakeWordDialog() {
    TextEditingController wakeWordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Set Wake Word"),
        content: TextField(
          controller: wakeWordController,
          decoration: InputDecoration(hintText: "Enter new wake word"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                wakeWord = wakeWordController.text;
              });
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  // Dialog to adjust vibration intensity
  void _showVibrationSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Vibration Intensity"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Adjust vibration intensity (0-100):"),
            Slider(
              value: vibrationIntensity.toDouble(),
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: (value) {
                setState(() {
                  vibrationIntensity = value.round();
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  // Dialog to adjust sensitivity level
  void _showSensitivitySettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Sensitivity Level"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Adjust sensitivity level (1-10):"),
            Slider(
              value: sensitivityLevel.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (value) {
                setState(() {
                  sensitivityLevel = value.round();
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
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
