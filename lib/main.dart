import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'package:permission_handler/permission_handler.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NotiPhones',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.dark,
      ),
      themeMode: themeProvider.themeMode,
      navigatorKey: navigatorKey,
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

class ScanDevicesScreen extends StatefulWidget {
  @override
  _ScanDevicesScreenState createState() => _ScanDevicesScreenState();
}

class _ScanDevicesScreenState extends State<ScanDevicesScreen> {
  List<BluetoothDevice> devices = [];
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() {
    setState(() {
      isScanning = true;
      devices.clear();
    });

    FlutterBluePlus.startScan(timeout: Duration(seconds: 4));

    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!devices.contains(result.device)) {
          setState(() {
            devices.add(result.device);
          });
        }
      }
    }).onDone(() {
      setState(() {
        isScanning = false;
      });
    });
  }

  void _stopScan() {
    FlutterBluePlus.stopScan();
    setState(() {
      isScanning = false;
    });
  }

  @override
  void dispose() {
    _stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan Devices')),
      body: Column(
        children: [
          if (isScanning) LinearProgressIndicator(),
          Expanded(
            child: devices.isEmpty
                ? Center(child: Text("No devices found."))
                : ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      BluetoothDevice device = devices[index];
                      return ListTile(
                        title: Text(device.name.isNotEmpty
                            ? device.name
                            : "Unknown Device"),
                        subtitle: Text(device.id.toString()),
                        onTap: () {
                          FlutterBluePlus.stopScan();
                          Navigator.pop(
                              context, device); // Return the selected device
                        },
                      );
                    },
                  ),
          ),
        ],
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

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  BluetoothDevice? connectedDevice;
  bool isBluetoothConnected = false;
  bool isScanning = false;
  List<BluetoothDevice> discoveredDevices = [];
  List<int>? receivedData;
  bool isListening = false; // Listening mode toggle
  String wakeWord = "Anavi"; // Default wake word
  int vibrationIntensity = 50; // Vibration intensity (0-100)
  int sensitivityLevel = 5; // Sensitivity level (1-10)
  int _selectedIndex = 0; // For sidebar navigation
  int microcontrollerBattery = 0; // Microcontroller battery percentage
  bool isLoading = false; // For refresh animation

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // App lifecycle observer
    _initBluetooth(); // Initialize BLE
    _fetchDeviceStatus(); // Fetch headphone + microcontroller battery info
    _loadSavedSettings(); // Load any app settings
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Stop scanning and disconnect devices only if scanning is active
      if (isScanning) {
        _stopScan();
      }
      _disconnectDevice(); // Disconnect Bluetooth devices
    } else if (state == AppLifecycleState.resumed) {
      // Only start scanning if explicitly needed
      if (!isBluetoothConnected && !isScanning) {
        _startScan(); // Resume scanning only if no device is connected
      }
    }
  }

  Future<void> _fetchDeviceStatus() async {
    setState(() {
      isLoading = true;
    });

    // Simulate a network/database call
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      isBluetoothConnected = false; // Simulate Bluetooth connected
      //microcontrollerBattery = 72; // Simulate microcontroller battery
      isLoading = false;
    });
  }

  void _initBluetooth() {
    // Check if Bluetooth is available
    FlutterBluePlus.isAvailable.then((available) {
      if (!available) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Bluetooth is not available on this device")),
        );
      }
    });

    // Listen for Bluetooth state changes
    FlutterBluePlus.state.listen((state) {
      if (state == BluetoothState.off) {
        setState(() {
          isBluetoothConnected = false;
        });
      }
    });
  }

  Future<void> _loadSavedSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      vibrationIntensity = prefs.getInt('vibrationIntensity') ?? 50;
      sensitivityLevel = prefs.getInt('sensitivityLevel') ?? 5;
    });
  }

  void _startScan() async {
    // Request permissions first
    if (await Permission.location.request().isGranted) {
      setState(() {
        isScanning = true;
        discoveredDevices.clear();
      });

      // Start scanning
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          print("Device found: ${result.device.name} - ${result.device.id.id}");

          // Just print and show everything for now
          if (!discoveredDevices.contains(result.device)) {
            setState(() {
              discoveredDevices.add(result.device);
            });
          }
        }
      });
    } else {
      print("Location permission denied");
    }
  }

  void _stopScan() {
    FlutterBluePlus.stopScan();
    setState(() {
      isScanning = false;
    });
  }

  void _connectToDevice(BluetoothDevice device) async {
    setState(() {
      isLoading = true;
    });

    try {
      await device.connect();
      setState(() {
        connectedDevice = device;
        isBluetoothConnected = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connected to ${device.name}")),
      );

      _listenToMicrocontroller();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to connect: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _disconnectDevice() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      setState(() {
        connectedDevice = null;
        isBluetoothConnected = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Disconnected from device")),
      );
    }
  }

  final String batteryNotifyCharacteristicUuid =
      "12345678-1234-5678-1234-56789abcdef4";
  final String listeningNotifyCharacteristicUuid =
      "12345678-1234-5678-1234-56789abcdef1";
  final String acknowledgmentNotifyCharacteristicUuid =
      "12345678-1234-5678-1234-56789abcdef2";
  final String wakeWordNotifyCharacteristicUuid =
      "12345678-1234-5678-1234-56789abcdef3";

  void _listenToMicrocontroller() async {
    if (connectedDevice == null) return;

    List<BluetoothService> services = await connectedDevice!.discoverServices();
    for (var service in services) {
      for (var characteristic in service.characteristics) {
        String charUuid = characteristic.uuid.toString().toLowerCase();

        if ((charUuid == batteryNotifyCharacteristicUuid.toLowerCase() ||
                charUuid == listeningNotifyCharacteristicUuid.toLowerCase() ||
                charUuid ==
                    acknowledgmentNotifyCharacteristicUuid.toLowerCase()) &&
            characteristic.properties.notify) {
          await characteristic.setNotifyValue(true);

          characteristic.value.listen((value) {
            if (value.isNotEmpty) {
              String receivedStr = String.fromCharCodes(value);
              print("Received: $receivedStr");

              // 🔋 Battery update
              if (charUuid == batteryNotifyCharacteristicUuid.toLowerCase()) {
                int rawValue = value[0];
                setState(() {
                  microcontrollerBattery = rawValue;
                });
                print("Battery level updated to: $rawValue%");
              }

              // 👂 Listening mode update
              else if (charUuid ==
                  listeningNotifyCharacteristicUuid.toLowerCase()) {
                if (receivedStr == "LISTENING_ENABLED") {
                  setState(() {
                    isListening = true;
                  });
                  print("Listening mode enabled");
                } else if (receivedStr == "LISTENING_DISABLED") {
                  setState(() {
                    isListening = false;
                  });
                  print("Listening mode disabled");
                }
              }

              // ✅ Acknowledgment received signal — TEST VERSION (no string check)
              else if (charUuid ==
                  acknowledgmentNotifyCharacteristicUuid.toLowerCase()) {
                print("Acknowledgment signal received");
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _showAcknowledgmentPopup();
                });
              } else if (charUuid ==
                  wakeWordNotifyCharacteristicUuid.toLowerCase()) {
                print("Wake word detected signal received");
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _showWakeWordPopup();
                });
              }
            }
          });
        }
      }
    }
  }

  void _sendCommandToMicrocontroller(String command) async {
    if (connectedDevice == null) return;

    Guid targetCharacteristicUUID =
        Guid('12345678-1234-5678-1234-56789abcdef5');

    List<BluetoothService> services = await connectedDevice!.discoverServices();

    for (var service in services) {
      for (var characteristic in service.characteristics) {
        if (characteristic.uuid == targetCharacteristicUUID &&
            characteristic.properties.write) {
          await characteristic.write(command.codeUnits);
          print("Sent command: $command");
          return;
        }
      }
    }

    print(
        "Write characteristic with UUID $targetCharacteristicUUID not found.");
  }

  void _showAcknowledgmentPopup() {
    print("Inside _showAcknowledgmentPopup");
    final context = navigatorKey.currentContext;
    if (context == null) {
      print("Context is null — cannot show popup");
      return;
    }

    print("Context is valid — showing popup...");

    showDialog(
      context: context,
      builder: (context) {
        print("Building AlertDialog");
        return AlertDialog(
          title: Text("Acknowledgment Received"),
          content: Text("The acknowledgment button was pressed."),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );

    Future.delayed(Duration(seconds: 3), () {
      print("5 seconds passed — trying to close the dialog");

      if (navigatorKey.currentContext != null) {
        Navigator.of(navigatorKey.currentContext!).pop();
        print("Dialog dismissed");
      } else {
        print("Could not dismiss — context was null");
      }
    });
  }

  void _showWakeWordPopup() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Wake Word Detected"),
          content: Text("The wake word was detected by the device."),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );

    Future.delayed(Duration(seconds: 3), () {
      if (navigatorKey.currentContext != null) {
        Navigator.of(navigatorKey.currentContext!).pop();
      }
    });
  }

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
              accountEmail: null,
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
            ListTile(
              leading: Icon(Icons.battery_charging_full),
              title: Text("Battery Life"),
              selected: _selectedIndex == 3,
              onTap: () {
                _onItemTapped(3);
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
      case 3:
        return BatteryLifeScreen();
      default:
        return _buildHomeScreen();
    }
  }

  Widget _buildHomeScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("NotiPhones",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 40),
          // Bluetooth Status
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
                ),
              ],
            ),
            child: Column(
              children: [
                Text("Bluetooth Status", style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isBluetoothConnected
                          ? Icons.bluetooth_connected
                          : Icons.bluetooth_disabled,
                      color: isBluetoothConnected ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 10),
                    Text(
                      isBluetoothConnected
                          ? "Device Connected"
                          : "Disconnected",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isBluetoothConnected ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                if (!isBluetoothConnected)
                  ElevatedButton(
                    onPressed: () async {
                      final selectedDevice = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ScanDevicesScreen()),
                      );

                      if (selectedDevice != null) {
                        _connectToDevice(selectedDevice);
                      }
                    },
                    child: Text("Scan Devices"),
                  )
                else
                  ElevatedButton(
                    onPressed: _disconnectDevice,
                    child: Text("Disconnect Device"),
                  ),
              ],
            ),
          ),

          SizedBox(height: 20),
          // Microcontroller Battery Status
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
                ),
              ],
            ),
            child: Column(
              children: [
                Text("Battery Status", style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Icon(Icons.memory, size: 40, color: Colors.teal[900]),
                        SizedBox(height: 5),
                        Text("Microcontroller"),
                        Text("$microcontrollerBattery%"),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          // Listening Mode Status
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
                ),
              ],
            ),
            child: Column(
              children: [
                Text("Listening Mode", style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isListening ? Icons.volume_up : Icons.volume_off,
                      color: isListening ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 10),
                    Text(
                      isListening ? "Listening" : "Off",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isListening ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          // Refresh Button
          isLoading
              ? CircularProgressIndicator(color: Colors.teal[900])
              : ElevatedButton(
                  onPressed: _fetchDeviceStatus,
                  child: Text("Refresh Status"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[900],
                    foregroundColor: Colors.white,
                  ),
                ),
        ],
      ),
    );
  }

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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isListening ? "On" : "Off",
                    style: TextStyle(
                      color: isListening ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10),
                  Switch(
                    value: isListening,
                    onChanged: (value) {
                      setState(() {
                        isListening = value;
                      });

                      // Send signal to microcontroller
                      _sendCommandToMicrocontroller(
                          value ? "enable" : "disable");

                      // Show confirmation message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(value
                              ? "Listening Mode Enabled"
                              : "Listening Mode Disabled"),
                        ),
                      );
                    },
                  ),
                ],
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
          SizedBox(height: 10),
          // Manual Vibration Button
          Card(
            child: ListTile(
              title: Text("Test Vibration"),
              trailing: IconButton(
                icon: Icon(Icons.vibration, color: Colors.teal[900]),
                onPressed: () {
                  _sendCommandToMicrocontroller(
                      "vibrate"); // Send vibration command
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Vibration triggered!")),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 10),
          // Acknowledge Button
          Card(
            child: ListTile(
              title: Text("Acknowledge Alert"),
              trailing: ElevatedButton(
                onPressed: () {
                  _sendCommandToMicrocontroller("acknowledgement");
                  _showAcknowledgeDialog(); // Open acknowledgment confirmation dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Red background
                  foregroundColor: Colors.white, // White text
                ),
                child: Text("Acknowledge"),
              ),
            ),
          ),
        ],
      ),
    );
  }

// Function to show acknowledge dialog
  void _showAcknowledgeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Acknowledge Alert"),
        content: Text("Are you sure you want to acknowledge this alert?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              // Simulate acknowledging the alert
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Acknowledgement received!"),
                  duration: Duration(seconds: 1),
                ),
              );
              Navigator.pop(context); // Close the dialog
            },
            child: Text("Acknowledge"),
          ),
        ],
      ),
    );
  }

// Function to trigger manual vibration
  // void _triggerManualVibration() {
  // Simulate vibration (you can replace this with actual vibration logic later)
  // ScaffoldMessenger.of(context).showSnackBar(
  // SnackBar(
  // content: Text("Vibration triggered!"),
  //duration: Duration(seconds: 1),
  // ),
  //);
  // }

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

  // Save vibration intensity to SharedPreferences
  Future<void> _saveVibrationIntensity(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('vibrationIntensity', value);
  }

// Save sensitivity level to SharedPreferences
  Future<void> _saveSensitivityLevel(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sensitivityLevel', value);
  }

  void _showVibrationSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        int tempIntensity =
            vibrationIntensity; // Temporary value for user adjustment
        return AlertDialog(
          title: Text("Vibration Settings"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Adjust vibration intensity:"),
              Slider(
                value: tempIntensity.toDouble(),
                min: 35, // ✅ Adjusted minimum value
                max: 100, // ✅ Adjusted maximum value
                divisions:
                    65, // ✅ Correct division count (so movement is smooth)
                label: "$tempIntensity%",
                onChanged: (value) {
                  setState(() {
                    tempIntensity = value.toInt();
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cancel dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                // ✅ Save new intensity value
                setState(() {
                  vibrationIntensity = tempIntensity;
                });

                // ✅ Save intensity to SharedPreferences for persistence
                await _saveVibrationIntensity(tempIntensity);

                // ✅ Send vibration intensity as a string to the microcontroller
                _sendCommandToMicrocontroller(
                    "VIBRATION_INTENSITY:$vibrationIntensity");

                // ✅ Notify user of update
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text("Vibration intensity set to $vibrationIntensity%"),
                    duration: Duration(seconds: 2),
                  ),
                );

                Navigator.pop(context); // Close dialog
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showSensitivitySettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        int tempSensitivity =
            sensitivityLevel; // Temporary value for user adjustment
        return AlertDialog(
          title: Text("Sensitivity Settings"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Adjust sensitivity level:"),
              Slider(
                value: tempSensitivity.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: "$tempSensitivity",
                onChanged: (value) {
                  setState(() {
                    tempSensitivity = value.toInt();
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cancel dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                // Save the new sensitivity level to the app state
                setState(() {
                  sensitivityLevel = tempSensitivity;
                });

                // Save the sensitivity level to SharedPreferences
                await _saveSensitivityLevel(tempSensitivity);

                // Send updated sensitivity level to microcontroller
                _sendCommandToMicrocontroller(
                    "SENSITIVITY_LEVEL:$sensitivityLevel");

                // Notify the user
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Sensitivity level set to $sensitivityLevel"),
                    duration: Duration(seconds: 2),
                  ),
                );

                Navigator.pop(context); // Close dialog
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isNotificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSettingTile(
              title: "Dark Mode",
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
            ),
            _buildSettingTile(
              title: "Enable Notifications",
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

  Widget _buildSettingTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 16)),
        Row(
          children: [
            Text(
              value ? "On" : "Off",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: value ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 4),
            Switch(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ],
    );
  }
}

class BatteryLifeScreen extends StatefulWidget {
  @override
  _BatteryLifeScreenState createState() => _BatteryLifeScreenState();
}

class _BatteryLifeScreenState extends State<BatteryLifeScreen>
    with WidgetsBindingObserver {
  bool _isInBackground = false; // Track whether the app is in the background

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _isInBackground = state == AppLifecycleState.paused;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Battery Life"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Battery Conservation",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Real-Time Indicator
            Row(
              children: [
                Icon(
                  _isInBackground ? Icons.battery_saver : Icons.battery_std,
                  color: _isInBackground ? Colors.green : Colors.grey,
                ),
                SizedBox(width: 10),
                Text(
                  _isInBackground
                      ? "Battery is being conserved (App in background)"
                      : "Battery conservation is inactive (App in foreground)",
                  style: TextStyle(
                    fontSize: 16,
                    color: _isInBackground ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "To conserve battery, this app minimizes background activity when not in use. Here's how:",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            _buildFeatureTile(
              icon: Icons.bluetooth,
              title: "Bluetooth Optimization",
              description:
                  "Bluetooth scans and connections are paused when the app is in the background.",
            ),
            _buildFeatureTile(
              icon: Icons.notifications_off,
              title: "Notifications",
              description:
                  "Notifications are only sent when necessary to reduce battery usage.",
            ),
            _buildFeatureTile(
              icon: Icons.timer,
              title: "Background Activity",
              description:
                  "Background tasks are minimized to ensure the app doesn't drain your battery.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal[900]),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
      ),
    );
  }
}
