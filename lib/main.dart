import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(TemperatureConverterApp());
}

/// Main application widget that sets preferred orientations and launches the home screen
class TemperatureConverterApp extends StatelessWidget {
  const TemperatureConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme:  ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        scaffoldBackgroundColor: Colors.teal[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.teal,
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
          fillColor: Colors.white,
          filled: true,
        ),
      ),
      home: TemperatureConverter(),
    );
  }
}

/// Stateful widget that contains the temperature conversion logic and UI
class TemperatureConverter extends StatefulWidget {
  const TemperatureConverter({super.key});

    @override
  _TemperatureConverterState createState() => _TemperatureConverterState();
}

class _TemperatureConverterState extends State<TemperatureConverter>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController(); // Controller for input field
  bool isFtoC = true; // Determines conversion direction
  String result = ''; // Holds the conversion result
  List<String> history = []; // Holds the list of past conversions
  late AnimationController _animationController; // Controls animation timing
  late Animation<double> _scaleAnimation; // Defines the scale animation

  @override
  void initState() {
    super.initState();
    // Initialize animation controller for the result display
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  /// Converts the input temperature and updates the result and history
  void _convertTemperature() {
    final input = double.tryParse(_controller.text);
    if (input == null) return;

    double converted;
    String conversion;

    // Perform conversion based on selected direction
    if (isFtoC) {
      converted = (input - 32) * 5 / 9;
      conversion = 'F to C: $input => ${converted.toStringAsFixed(2)}';
    } else {
      converted = input * 9 / 5 + 32;
      conversion = 'C to F: $input => ${converted.toStringAsFixed(2)}';
    }

    // Update UI with the result and animate
    setState(() {
      result = converted.toStringAsFixed(2);
      history.insert(0, conversion);
      _animationController.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Builds the UI depending on orientation
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Temperature Convertor'), centerTitle: true,),
      body: SafeArea(child: OrientationBuilder(
        builder: (context, orientation) {
          final isPortrait = orientation == Orientation.portrait;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Conversion direction selector using radio buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio<bool>(
                      activeColor: Colors.teal,
                      value: true,
                      groupValue: isFtoC,
                      onChanged: (value) {
                        setState(() => isFtoC = value!);
                      },
                    ),
                    Text('Fahrenheit to Celsius'),
                    SizedBox(width: 20),
                    Radio<bool>(
                      activeColor: Colors.teal,
                      value: false,
                      groupValue: isFtoC,
                      onChanged: (value) {
                        setState(() => isFtoC = value!);
                      },
                    ),
                    Text('Celsius to Fahrenheit'),
                  ],
                ),
                // Input field for temperature
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Enter Temperature',
                    prefixIcon: Icon(Icons.thermostat_outlined),
                  ),
                ),
                SizedBox(height: 16),
                // Convert button
                ElevatedButton(
                  onPressed: _convertTemperature,
                  child: Text('Convert'),
                ),
                SizedBox(height: 16),
                // Animated display of the conversion result
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Text(
                    'Result: $result',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal[800]),
                  ),
                ),
                SizedBox(height: 16),
                // Display history of conversions
                Expanded(
                  child: ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) => Card(
                      elevation: 2,
                      child: ListTile(
                        leading: Icon(Icons.history, color: Colors.teal),
                        title: Text(history[index]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ));
  }
}
