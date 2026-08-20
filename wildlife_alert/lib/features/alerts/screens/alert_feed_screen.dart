import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import '../widgets/alert_card.dart';

class AlertFeedScreen extends StatefulWidget {
  const AlertFeedScreen({super.key});

  @override
  State<AlertFeedScreen> createState() => _AlertFeedScreenState();
}

class _AlertFeedScreenState extends State<AlertFeedScreen> {
  List<dynamic> _alerts = [];
  bool _isLoading = true;
  String _currentZone = '';

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  Future<void> _initLoad() async {
    final prefs = await SharedPreferences.getInstance();
    _currentZone = prefs.getString('current_zone') ?? '';
    await _fetchData();
  }

  Future<void> _fetchData() async {
    if (_currentZone.isEmpty) return;
    
    setState(() => _isLoading = true);
    final data = await ApiService.fetchAlerts(_currentZone);
    setState(() {
      _alerts = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Open Filter Bottom Sheet
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _alerts.isEmpty
              ? const Center(child: Text('No recent alerts in your zone.'))
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: ListView.builder(
                    itemCount: _alerts.length,
                    itemBuilder: (context, index) {
                      return AlertCard(alert: _alerts[index]);
                    },
                  ),
                ),
    );
  }
}