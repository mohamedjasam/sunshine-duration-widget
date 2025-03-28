import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sun Tracker',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        useMaterial3: true,
      ),
      home: const SunDashboard(),
    );
  }
}

class SunDashboard extends StatelessWidget {
  const SunDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Blurred background
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
              child: Image.asset(
                'assets/backk.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Dark overlay for better readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),

          // Centered SunCard
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SunCard(),
            ),
          ),
        ],
      ),
    );
  }
}

class SunCard extends StatefulWidget {
  const SunCard({super.key});

  @override
  _SunCardState createState() => _SunCardState();
}

class _SunCardState extends State<SunCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<Offset> _sunAnimation;

  double _sunHours = 0.0; // Dynamic sunshine hours fetched from API
  DateTime _lastUpdated = DateTime.now(); // Dynamic timestamp fetched from API
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchData();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _sunAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0),
      end: const Offset(-0.3, 0),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
  }

  Future<void> _fetchData() async {
    try {
      // Fetch data from the Django API
      final response = await http.get(Uri.parse('http://192.168.1.5:8000/api/sunshine/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // Update state with dynamic data from API
          _sunHours = data['total_hours'].toDouble();
          _lastUpdated = DateTime.parse(data['date']);
          _isLoading = false;
          _hasError = false;

          // Update progress animation dynamically based on fetched data
          _progressAnimation = Tween<double>(
            begin: 0,
            end: _sunHours / 12, // Normalize to max 12 hours
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeInOut,
            ),
          );

          // Start animations after data is loaded
          _animationController.forward(from: 0);
        });
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 340,
            maxHeight: 400,
          ),
          child: Stack(
            children: [
              // Landscape background for card
              Positioned.fill(
                child: Image.asset(
                  'assets/land.jpg',
                  fit: BoxFit.cover,
                ),
              ),

              // Dark overlay for better readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_hasError)
                      const Text(
                        'Failed to load data.\nPlease check your connection.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else
                      Column(
                        children: [
                          // Title
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                const Color(0xFF82723F),
                                const Color(0xFFE8CB71),
                              ],
                            ).createShader(bounds),
                            child: const Text(
                              "Today's Sunlight",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Sun animation
                          SlideTransition(
                            position: _sunAnimation,
                            child: Image.asset(
                              'assets/sunnn.png',
                              width: 90,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Sun hours
                          Text(
                            '${_sunHours.toStringAsFixed(1)} hrs',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: AnimatedBuilder(
                              animation: _progressAnimation,
                              builder: (context, child) {
                                return LinearProgressIndicator(
                                  value: _progressAnimation.value,
                                  backgroundColor: Colors.white24,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.amber.shade600),
                                  minHeight: 8,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Timestamp
                          Text(
                            'Updated at ${_formatTime(_lastUpdated)}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final amPm = dateTime.hour < 12 ? 'AM' : 'PM';
    final month = _getMonthAbbr(dateTime.month);
    return '${dateTime.day} $month ${dateTime.year}, ${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $amPm';
  }

  String _getMonthAbbr(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}