import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(TemperatureConverterApp());
}

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        scaffoldBackgroundColor: Colors.teal[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.teal,
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

class TemperatureConverter extends StatefulWidget {
  const TemperatureConverter({super.key});

  @override
  _TemperatureConverterState createState() => _TemperatureConverterState();
}

class _TemperatureConverterState extends State<TemperatureConverter>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  bool isFtoC = true;
  String result = '';
  List<String> history = [];
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  void _convertTemperature() {
    final input = double.tryParse(_controller.text);
    if (input == null) return;

    double converted;
    String conversion;

    if (isFtoC) {
      converted = (input - 32) * 5 / 9;
      conversion = 'F to C: $input => ${converted.toStringAsFixed(2)}';
    } else {
      converted = input * 9 / 5 + 32;
      conversion = 'C to F: $input => ${converted.toStringAsFixed(2)}';
    }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Temperature Converter'), centerTitle: true),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        Expanded(child: Text('Celsius to Fahrenheit')),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _controller,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Enter Temperature',
                        prefixIcon: Icon(Icons.thermostat_outlined),
                      ),
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: _convertTemperature,
                        child: Text(
                          'Convert',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Center(
                        child: Text(
                          'Result: $result',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[800],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: Text(
                        'History:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: history.length,
                      itemBuilder:
                          (context, index) => Card(
                            elevation: 2,
                            child: ListTile(
                              leading: Icon(Icons.history, color: Colors.teal),
                              title: Text(history[index]),
                            ),
                          ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
