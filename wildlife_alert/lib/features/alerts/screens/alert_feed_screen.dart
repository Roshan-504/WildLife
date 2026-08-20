import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../widgets/alert_card.dart';

class AlertFeedScreen extends StatefulWidget {
  const AlertFeedScreen({super.key});

  @override
  State<AlertFeedScreen> createState() => _AlertFeedScreenState();
}

class _AlertFeedScreenState extends State<AlertFeedScreen> {
  final ScrollController _scrollController = ScrollController();
  
  // Data State
  List<dynamic> _alerts = [];
  List<dynamic> _availableZones = [];
  
  // Pagination State
  int _currentPage = 1;
  bool _isLoading = true;
  bool _isFetchingMore = false;
  bool _hasMoreData = true;
  
  // Filter State
  String? _selectedZone;
  String? _selectedSeverity;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    
    // Listen for scrolling to trigger pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadMoreAlerts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // --- Data Fetching Logic ---

  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);
    
    // Fetch filter options and first page of alerts concurrently
    final results = await Future.wait([
      ApiService.fetchZones(),
      ApiService.fetchAlerts(
        zone: _selectedZone, 
        severity: _selectedSeverity, 
        page: 1,
      ),
    ]);

    setState(() {
      _availableZones = results[0];
      _alerts = results[1];
      _currentPage = 1;
      _hasMoreData = results[1].length == 10; // Assuming limit is 10 per page
      _isLoading = false;
    });
  }

  Future<void> _loadMoreAlerts() async {
    if (_isFetchingMore || !_hasMoreData) return;

    setState(() => _isFetchingMore = true);
    _currentPage++;

    final moreAlerts = await ApiService.fetchAlerts(
      zone: _selectedZone,
      severity: _selectedSeverity,
      page: _currentPage,
    );

    setState(() {
      _alerts.addAll(moreAlerts);
      _isFetchingMore = false;
      _hasMoreData = moreAlerts.length == 10; // True if full page returned
    });
  }

  Future<void> _applyFilters(String? zone, String? severity) async {
    setState(() {
      _selectedZone = zone;
      _selectedSeverity = severity;
    });
    Navigator.pop(context); // Close the bottom sheet
    await _fetchInitialData(); // Reload from page 1 with new filters
  }

  // --- UI Components ---

  void _openFilterSheet() {
    String? tempZone = _selectedZone;
    String? tempSeverity = _selectedSeverity;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Filter Alerts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  // Zone Dropdown
                  DropdownButtonFormField<String?>(
                    decoration: const InputDecoration(labelText: 'Select Zone', border: OutlineInputBorder()),
                    value: tempZone,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Zones')),
                      ..._availableZones.map((z) => DropdownMenuItem(
                            value: z['topic_id'] as String,
                            child: Text(z['name']),
                          )),
                    ],
                    onChanged: (val) => setModalState(() => tempZone = val),
                  ),
                  const SizedBox(height: 15),

                  // Severity Dropdown
                  DropdownButtonFormField<String?>(
                    decoration: const InputDecoration(labelText: 'Severity', border: OutlineInputBorder()),
                    value: tempSeverity,
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All Severities')),
                      DropdownMenuItem(value: 'CRITICAL', child: Text('Critical (Leopard/Tiger)')),
                      DropdownMenuItem(value: 'WARNING', child: Text('Warning (Boar/Monkey)')),
                    ],
                    onChanged: (val) => setModalState(() => tempSeverity = val),
                  ),
                  const SizedBox(height: 25),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _applyFilters(null, null), // Clear all
                          child: const Text('Clear Filters'),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
                          onPressed: () => _applyFilters(tempZone, tempSeverity),
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert History'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (_selectedZone != null || _selectedSeverity != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                    ),
                  )
              ],
            ),
            onPressed: _openFilterSheet,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _alerts.isEmpty
              ? const Center(child: Text('No alerts match your filters.'))
              : RefreshIndicator(
                  onRefresh: _fetchInitialData,
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _alerts.length + 1, // +1 for the loading indicator at the bottom
                    itemBuilder: (context, index) {
                      if (index < _alerts.length) {
                        return AlertCard(alert: _alerts[index]);
                      } else {
                        // Bottom loading indicator for pagination
                        return _hasMoreData
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            : const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(child: Text('No more alerts.')),
                              );
                      }
                    },
                  ),
                ),
    );
  }
}