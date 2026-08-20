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
      backgroundColor: Colors.transparent, // Transparent for custom styling
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF00150F), // Very dark teal/black background
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(color: Colors.tealAccent, width: 0.5),
                ),
              ),
              padding: EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                top: 12.0,
                bottom: MediaQuery.of(context).padding.bottom + 24.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Filter Alerts', 
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 24),
                  
                  // Zone Dropdown
                  DropdownButtonFormField<String?>(
                    dropdownColor: const Color(0xFF00251A), // Deep forest container
                    icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.tealAccent),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      labelText: 'Select Zone',
                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.tealAccent, width: 1.5)),
                    ),
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
                  const SizedBox(height: 16),

                  // Severity Dropdown
                  DropdownButtonFormField<String?>(
                    dropdownColor: const Color(0xFF00251A),
                    icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.tealAccent),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      labelText: 'Severity Level',
                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.tealAccent, width: 1.5)),
                    ),
                    value: tempSeverity,
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All Severities')),
                      DropdownMenuItem(value: 'CRITICAL', child: Text('Critical (Leopard/Tiger)')),
                      DropdownMenuItem(value: 'WARNING', child: Text('Warning (Boar/Monkey)')),
                    ],
                    onChanged: (val) => setModalState(() => tempSeverity = val),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _applyFilters(null, null), // Clear all
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.white.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Clear', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFF00796B), 
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shadowColor: Colors.tealAccent.withOpacity(0.3),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () => _applyFilters(tempZone, tempSeverity),
                          child: const Text('APPLY FILTERS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'ALERT HISTORY', 
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 18)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.filter_list_rounded, color: Colors.white, size: 28),
                if (_selectedZone != null || _selectedSeverity != null)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.tealAccent, // Vibrant dot for active filter
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF00251A), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.tealAccent.withOpacity(0.5),
                            blurRadius: 4,
                          )
                        ]
                      ),
                      constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                    ),
                  )
              ],
            ),
            onPressed: _openFilterSheet,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF004D40), // Deep Teal
              Color(0xFF00251A), // Dark Forest Green
              Color(0xFF0A0E11), // Premium Slate/Black
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.tealAccent, strokeWidth: 3),
                )
              : _alerts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 64, color: Colors.tealAccent.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'No alerts match your filters.',
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: Colors.tealAccent,
                      backgroundColor: const Color(0xFF0A0E11),
                      onRefresh: _fetchInitialData,
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 8, bottom: 20, left: 16, right: 16),
                        itemCount: _alerts.length + 1, // +1 for the loading indicator at the bottom
                        itemBuilder: (context, index) {
                          if (index < _alerts.length) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: AlertCard(alert: _alerts[index]),
                            );
                          } else {
                            // Bottom loading indicator for pagination
                            return _hasMoreData
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: Center(child: CircularProgressIndicator(color: Colors.tealAccent)),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 24),
                                    child: Center(
                                      child: Text(
                                        'End of History.',
                                        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
                                      )
                                    ),
                                  );
                          }
                        },
                      ),
                    ),
        ),
      ),
    );
  }
}