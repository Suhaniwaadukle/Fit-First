import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class TaskScreen extends StatefulWidget {
  final String activityType;
  final IconData activityIcon;
  final double distanceCovered;
  final String durationFormatted;
  final String caloriesBurned;
  final String avgPace;
  final int steps;
  final String elevationGain;
  final int overSpeedingCount;
  final List<LatLng> routeCoordinates;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final LatLng? startLatLng;

  const TaskScreen({
    super.key,
    this.activityType = '',
    this.activityIcon = Icons.directions_run,
    this.distanceCovered = 0.0,
    this.durationFormatted = '00:00:00',
    this.caloriesBurned = '0',
    this.avgPace = '0:00',
    this.steps = 0,
    this.elevationGain = '0.0',
    this.overSpeedingCount = 0,
    this.routeCoordinates = const [],
    this.markers = const {},
    this.polylines = const {},
    this.startLatLng,
  });

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with TickerProviderStateMixin {
  final GlobalKey _shareCardKey = GlobalKey();
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;
  bool _isSharing = false;
  GoogleMapController? _mapController;

  static const String _darkMapStyle =
      '[{"elementType":"geometry","stylers":[{"color":"#1d2c4d"}]},'
      '{"elementType":"labels.text.fill","stylers":[{"color":"#8ec3b9"}]},'
      '{"elementType":"labels.text.stroke","stylers":[{"color":"#1a3646"}]},'
      '{"featureType":"landscape.natural","elementType":"geometry","stylers":[{"color":"#023e58"}]},'
      '{"featureType":"poi","elementType":"geometry","stylers":[{"color":"#283d6a"}]},'
      '{"featureType":"poi.park","elementType":"geometry.fill","stylers":[{"color":"#023e58"}]},'
      '{"featureType":"road","elementType":"geometry","stylers":[{"color":"#304a7d"}]},'
      '{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#98a5be"}]},'
      '{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#2c6675"}]},'
      '{"featureType":"transit.line","elementType":"geometry.fill","stylers":[{"color":"#283d6a"}]},'
      '{"featureType":"water","elementType":"geometry","stylers":[{"color":"#0e1626"}]}]';

  // ─── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
            .animate(CurvedAnimation(
            parent: _slideCtrl, curve: Curves.easeOutCubic));

    _fadeCtrl.forward();
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  Color get _accentColor {
    switch (widget.activityType.toLowerCase()) {
      case 'running':
        return const Color(0xFF4ADE80);
      case 'cycling':
        return const Color(0xFF38BDF8);
      case 'walking':
        return const Color(0xFFFBBF24);
      case 'hiking':
        return const Color(0xFFF97316);
      default:
        return const Color(0xFF4ADE80);
    }
  }

  IconData get _activityIcon {
    switch (widget.activityType.toLowerCase()) {
      case 'running':
        return Icons.directions_run_rounded;
      case 'cycling':
        return Icons.directions_bike_rounded;
      case 'walking':
        return Icons.directions_walk_rounded;
      case 'hiking':
        return Icons.terrain_rounded;
      default:
        return widget.activityIcon;
    }
  }

  String get _activityEmoji {
    switch (widget.activityType.toLowerCase()) {
      case 'running':
        return '🏃';
      case 'cycling':
        return '🚴';
      case 'walking':
        return '🚶';
      case 'hiking':
        return '🥾';
      default:
        return '🏃';
    }
  }

  LatLng get _mapCenter {
    if (widget.startLatLng != null) return widget.startLatLng!;
    if (widget.routeCoordinates.isNotEmpty) {
      return widget
          .routeCoordinates[widget.routeCoordinates.length ~/ 2];
    }
    return const LatLng(23.2599, 77.4126);
  }

  String get _formattedDate {
    final n = DateTime.now();
    return '${n.day.toString().padLeft(2, '0')}/'
        '${n.month.toString().padLeft(2, '0')}/'
        '${n.year.toString().substring(2)}';
  }

  LatLngBounds _computeBounds(List<LatLng> coords) {
    double minLat = coords.first.latitude,
        maxLat = coords.first.latitude;
    double minLng = coords.first.longitude,
        maxLng = coords.first.longitude;
    for (final c in coords) {
      if (c.latitude < minLat) minLat = c.latitude;
      if (c.latitude > maxLat) maxLat = c.latitude;
      if (c.longitude < minLng) minLng = c.longitude;
      if (c.longitude > maxLng) maxLng = c.longitude;
    }
    return LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng));
  }

  // ─── Screenshot & Share ──────────────────────────────────────────────────────

  Future<Uint8List?> _captureCard() async {
    try {
      final boundary = _shareCardKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final bd =
      await image.toByteData(format: ui.ImageByteFormat.png);
      return bd?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Screenshot error: $e');
      return null;
    }
  }

  Future<void> _shareActivity({String? platform}) async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    try {
      final bytes = await _captureCard();
      if (bytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Could not capture screenshot')),
          );
        }
        return;
      }

      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/orka_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);

      final xFile = XFile(file.path, mimeType: 'image/png');
      final text = '''
$_activityEmoji Just finished a ${widget.activityType}!

Distance : ${widget.distanceCovered.toStringAsFixed(2)} km
Time     : ${widget.durationFormatted}
Calories : ${widget.caloriesBurned} Cal
Avg Pace : ${widget.avgPace} min/km

Tracked with Orka Sports – Fit First

#OrkaSports #FitFirst
''';

      await Share.shareXFiles(
        [xFile],
        text: platform == 'instagram' ? '' : text,
        subject: 'My ${widget.activityType} Activity',
        sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Share failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  void _showShareSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            const Text('Share Activity',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Share your achievement as a screenshot',
                style:
                TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 24),
            Row(children: [
              _shareOption(
                icon: Icons.chat_rounded,
                label: 'WhatsApp\nStatus',
                color: const Color(0xFF25D366),
                onTap: () {
                  Navigator.pop(context);
                  _shareActivity(platform: 'whatsapp');
                },
              ),
              const SizedBox(width: 16),
              _shareOption(
                icon: Icons.camera_alt_rounded,
                label: 'Instagram\nStory',
                color: const Color(0xFFE1306C),
                onTap: () {
                  Navigator.pop(context);
                  _shareActivity(platform: 'instagram');
                },
              ),
              const SizedBox(width: 16),
              _shareOption(
                icon: Icons.more_horiz_rounded,
                label: 'More\nOptions',
                color: const Color(0xFF636366),
                onTap: () {
                  Navigator.pop(context);
                  _shareActivity();
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _shareOption(
      {required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border:
              Border.all(color: color.withOpacity(0.3), width: 1)),
          child: Column(children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.3)),
          ]),
        ),
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(children: [
              RepaintBoundary(
                  key: _shareCardKey,
                  child: _buildShareableCard()),
              const SizedBox(height: 16),
              _buildShareStrip(),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ),
    );
  }

  // ─── AppBar ──────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0A0A0A),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.chevron_left_rounded,
            color: Colors.white, size: 28),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('Activity Summary',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 17,
              letterSpacing: 0.2)),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.more_horiz_rounded,
              color: Colors.white, size: 24),
          onPressed: _showShareSheet,
        ),
        IconButton(
          icon: _isSharing
              ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.ios_share_rounded,
              color: Colors.white, size: 22),
          onPressed: _isSharing ? null : _showShareSheet,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ─── Shareable Card ──────────────────────────────────────────────────────────

  Widget _buildShareableCard() {
    return Container(
      color: const Color(0xFF0A0A0A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMapSection(),
          const SizedBox(height: 10),
          _buildActivityHeader(),
          const SizedBox(height: 10),
          _buildStatsGrid(),
          const SizedBox(height: 10),
          _buildBrandingStrip(),
        ],
      ),
    );
  }

  // ─── Map ─────────────────────────────────────────────────────────────────────

  Widget _buildMapSection() {
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: GoogleMap(
        onMapCreated: (controller) {
          _mapController = controller;
          controller.setMapStyle(_darkMapStyle);

          if (widget.routeCoordinates.length >= 2) {
            final bounds =
            _computeBounds(widget.routeCoordinates);
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                controller.animateCamera(
                    CameraUpdate.newLatLngBounds(bounds, 60));
              }
            });
          }
        },
        initialCameraPosition: CameraPosition(
          target: widget.routeCoordinates.isNotEmpty
              ? widget.routeCoordinates.first
              : _mapCenter,
          zoom: 16,
        ),
        markers: widget.markers,
        polylines: widget.polylines.isNotEmpty
            ? widget.polylines
            : (widget.routeCoordinates.length >= 2
            ? {
          Polyline(
            polylineId: const PolylineId('route'),
            points: widget.routeCoordinates,
            color: Colors.green,
            width: 6,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          )
        }
            : {}),
        zoomControlsEnabled: false,
        myLocationButtonEnabled: false,
      ),
    );
  }

  // ─── Activity Header ─────────────────────────────────────────────────────────

  Widget _buildActivityHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Activity type + distance title
          Text(
            '${widget.activityType}  •  ${widget.distanceCovered.toStringAsFixed(2)} km',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),

          // Duration badge
          Row(children: [
            Icon(Icons.timer_rounded, color: _accentColor, size: 18),
            const SizedBox(width: 6),
            Text(
              widget.durationFormatted,
              style: TextStyle(
                  color: _accentColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3),
            ),
            const SizedBox(width: 16),
            Icon(Icons.emoji_events_rounded,
                color: _accentColor, size: 18),
            const SizedBox(width: 6),
            Text(
              'Goal Completed 🏆',
              style: TextStyle(
                  color: _accentColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10, width: 0.5),
        ),
        child: Column(children: [
          // Row 1 — Distance | Duration | Calories
          Row(children: [
            _statCell(
              value: widget.distanceCovered.toStringAsFixed(2),
              label: 'km',
              icon: Icons.location_on_rounded,
              iconColor: const Color(0xFFF97316),
            ),
            _dividerV(),
            _statCell(
              value: widget.durationFormatted,
              label: 'Duration',
              icon: Icons.timer_rounded,
              iconColor: const Color(0xFF4ADE80),
              isLarge: true,
            ),
            _dividerV(),
            _statCell(
              value: widget.caloriesBurned,
              label: 'Cal',
              icon: Icons.local_fire_department_rounded,
              iconColor: const Color(0xFFFB923C),
            ),
          ]),
          _dividerH(),
          // Row 2 — Pace | Elevation | Overspeed
          Row(children: [
            _statCell(
              value: widget.avgPace,
              label: 'min/km',
              icon: Icons.speed_rounded,
              iconColor: const Color(0xFF38BDF8),
            ),
            _dividerV(),
            _statCell(
              value: '${widget.elevationGain} m',
              label: 'Elevation',
              icon: Icons.landscape_rounded,
              iconColor: const Color(0xFFA78BFA),
              isLarge: true,
            ),
            _dividerV(),
            _statCell(
              value: widget.overSpeedingCount.toString(),
              label: 'Overspeed',
              icon: Icons.warning_amber_rounded,
              iconColor: const Color(0xFFFBBF24),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _statCell({
    required String value,
    required String label,
    required IconData icon,
    required Color iconColor,
    bool isLarge = false,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: isLarge ? 26 : 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 7),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: iconColor, size: isLarge ? 18 : 14),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: isLarge ? 12 : 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dividerV() =>
      Container(width: 0.5, height: 68, color: Colors.white12);
  Widget _dividerH() =>
      Container(height: 0.5, color: Colors.white12);

  Widget _buildBrandingStrip() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      padding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10, width: 0.6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/Fit_First.png',
              height: 50,
              width: 50,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  Icon(_activityIcon, color: _accentColor, size: 48),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '· Fit First',
                  style: TextStyle(
                    color: _accentColor.withOpacity(0.9),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Track your fitness, challenge your limits, and stay active every day.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _formattedDate,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildShareStrip() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Share your achievement',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Row(children: [
            _shareBtn(
              label: 'WhatsApp',
              icon: FontAwesomeIcons.whatsapp,
              color: const Color(0xFF25D366),
              onTap: () => _shareActivity(platform: 'whatsapp'),
            ),
            const SizedBox(width: 12),
            _shareBtn(
              label: 'Instagram',
              icon: FontAwesomeIcons.instagram,
              color: const Color(0xFFE1306C),
              onTap: () => _shareActivity(platform: 'instagram'),
            ),
            const SizedBox(width: 12),
            _shareBtn(
              label: 'More',
              icon: FontAwesomeIcons.shareNodes,
              color: Colors.white54,
              onTap: () => _shareActivity(),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _shareBtn({
    required String label,
    required FaIconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: Colors.white.withOpacity(0.15), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}