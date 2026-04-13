import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';

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
  late TabController _tabController;
  final GlobalKey _shareCardKey = GlobalKey();
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;
  bool _isSharing = false;
  GoogleMapController? _mapController;
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _cameraInitialized = false;
  bool _isFrontCamera = true;
  File? _capturedImage;
  bool _isCapturing = false;
  final ImagePicker _imagePicker = ImagePicker();
  final GlobalKey _winnerCardKey = GlobalKey();

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

  double _sw(double value, {double min = 0, double max = double.infinity}) {
    final factor = MediaQuery.of(context).size.width / 390.0;
    return (value * factor).clamp(min, max);
  }

  double _sh(double value, {double min = 0, double max = double.infinity}) {
    final factor = MediaQuery.of(context).size.height / 844.0;
    return (value * factor).clamp(min, max);
  }

  double get _screenW => MediaQuery.of(context).size.width;
  double get _screenH => MediaQuery.of(context).size.height;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
        CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));

    _fadeCtrl.forward();
    _slideCtrl.forward();

    _initCamera();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _mapController?.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) return;
      await _startCamera(_isFrontCamera);
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  Future<void> _startCamera(bool front) async {
    if (_cameras == null || _cameras!.isEmpty) return;

    CameraDescription? selected;
    for (final cam in _cameras!) {
      if (front && cam.lensDirection == CameraLensDirection.front) {
        selected = cam;
        break;
      }
      if (!front && cam.lensDirection == CameraLensDirection.back) {
        selected = cam;
        break;
      }
    }
    selected ??= _cameras!.first;

    await _cameraController?.dispose();
    _cameraController = CameraController(selected, ResolutionPreset.high);
    try {
      await _cameraController!.initialize();
      if (mounted) setState(() => _cameraInitialized = true);
    } catch (e) {
      debugPrint('Camera start error: $e');
    }
  }

  Future<void> _takeSelfie() async {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);
    try {
      final xFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 90,
      );
      if (xFile != null && mounted) {
        setState(() {
          _capturedImage = File(xFile.path);
          _cameraInitialized = false;
        });
        await _cameraController?.dispose();
        _cameraController = null;
      }
    } catch (e) {
      debugPrint('Selfie error: $e');
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    final xFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (xFile != null && mounted) {
      setState(() {
        _capturedImage = File(xFile.path);
        _cameraInitialized = false;
      });
      await _cameraController?.dispose();
      _cameraController = null;
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
      _cameraInitialized = false;
    });
    _initCamera();
  }

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
      return widget.routeCoordinates[widget.routeCoordinates.length ~/ 2];
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
    double minLat = coords.first.latitude, maxLat = coords.first.latitude;
    double minLng = coords.first.longitude, maxLng = coords.first.longitude;
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

  Future<File?> _getWinnerImageFile() async {
    try {
      final boundary = _winnerCardKey.currentContext?.findRenderObject()
      as RenderRepaintBoundary?;

      Uint8List? imageBytes;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
        imageBytes = byteData?.buffer.asUint8List();
      }

      final dir = await getTemporaryDirectory();
      if (imageBytes != null) {
        final file = File(
            '${dir.path}/winner_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(imageBytes);
        return file;
      }
      return _capturedImage;
    } catch (e) {
      debugPrint('Image capture error: $e');
      return _capturedImage;
    }
  }

  Future<void> _shareToWhatsApp() async {
    if (_capturedImage == null) return;
    try {
      final file = await _getWinnerImageFile();
      if (file == null) return;
      final text = '$_activityEmoji Just crushed a ${widget.activityType}!\n\n'
          '📍 Distance  : ${widget.distanceCovered.toStringAsFixed(2)} km\n'
          '⏱ Time      : ${widget.durationFormatted}\n'
          '🔥 Calories  : ${widget.caloriesBurned} Cal\n'
          '⚡ Avg Pace  : ${widget.avgPace} min/km\n\n'
          'Tracked with Fit First\n#FitFirst';
      await Share.shareXFiles([XFile(file.path, mimeType: 'image/png')],
          text: text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('WhatsApp share failed: $e')));
      }
    }
  }

  Future<void> _shareToInstagram() async {
    if (_capturedImage == null) return;
    try {
      final file = await _getWinnerImageFile();
      if (file == null) return;
      final xFile = XFile(file.path, mimeType: 'image/png');
      await Share.shareXFiles([xFile],
          text: '$_activityEmoji Just crushed a ${widget.activityType}!\n\n'
              '📍 ${widget.distanceCovered.toStringAsFixed(2)} km · '
              '⏱ ${widget.durationFormatted}\n\n'
              'Tracked with Fit First #FitFirst');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Share failed: $e')));
      }
    }
  }

  Future<void> _shareWinnerPhoto() async {
    if (_capturedImage == null) return;
    try {
      final file = await _getWinnerImageFile();
      if (file == null) return;
      final text =
          '$_activityEmoji Just crushed a ${widget.activityType}!\n\n'
          '📍 Distance  : ${widget.distanceCovered.toStringAsFixed(2)} km\n'
          '⏱ Time      : ${widget.durationFormatted}\n'
          '🔥 Calories  : ${widget.caloriesBurned} Cal\n'
          '⚡ Avg Pace  : ${widget.avgPace} min/km\n\n'
          'Tracked with Fit First\n#FitFirst';
      await Share.shareXFiles([XFile(file.path, mimeType: 'image/png')],
          text: text, subject: 'My ${widget.activityType} Win!');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Share failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTab1ActivitySummary(),
          _buildTab2WinnerCamera(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0A0A0A),
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.chevron_left_rounded,
            color: Colors.white, size: _sw(28, min: 24, max: 34)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text('Activity Summary',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: _sw(17, min: 15, max: 20),
              letterSpacing: 0.2)),
      centerTitle: true,
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: _accentColor,
        indicatorWeight: 2.5,
        labelColor: _accentColor,
        unselectedLabelColor: Colors.white38,
        labelStyle: TextStyle(
            fontSize: _sw(13, min: 11, max: 16), fontWeight: FontWeight.w600),
        tabs: [
          Tab(
            icon: Icon(Icons.bar_chart_rounded, size: _sw(20, min: 16, max: 26)),
            text: 'Summary',
          ),
          Tab(
            icon: Icon(Icons.emoji_events_rounded,
                size: _sw(20, min: 16, max: 26)),
            text: 'Winner Moment',
          ),
        ],
      ),
    );
  }

  Widget _buildTab1ActivitySummary() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(children: [
            RepaintBoundary(
                key: _shareCardKey, child: _buildShareableCard()),
          ]),
        ),
      ),
    );
  }

  Widget _buildShareableCard() {
    return Container(
      color: const Color(0xFF0A0A0A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMapSection(),
          SizedBox(height: _sh(10, min: 8, max: 16)),
          _buildActivityHeader(),
          SizedBox(height: _sh(10, min: 8, max: 16)),
          _buildStatsGrid(),
          SizedBox(height: _sh(10, min: 8, max: 16)),
          _buildBrandingStrip(),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    final mapH = (_screenH * 0.33).clamp(200.0, 380.0);
    return SizedBox(
      height: mapH,
      width: double.infinity,
      child: GoogleMap(
        onMapCreated: (controller) {
          _mapController = controller;
          controller.setMapStyle(_darkMapStyle);
          if (widget.routeCoordinates.length >= 2) {
            final bounds = _computeBounds(widget.routeCoordinates);
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                controller
                    .animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
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

  Widget _buildActivityHeader() {
    final hPad = _sw(20, min: 16, max: 32);
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, _sh(22, min: 16, max: 28), hPad, _sh(8, min: 6, max: 12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.activityType}  •  ${widget.distanceCovered.toStringAsFixed(2)} km',
            style: TextStyle(
              color: Colors.white,
              fontSize: _sw(26, min: 20, max: 34),
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
              height: 1.1,
            ),
          ),
          SizedBox(height: _sh(8, min: 6, max: 12)),
          Row(children: [
            Icon(Icons.timer_rounded,
                color: _accentColor, size: _sw(18, min: 14, max: 22)),
            SizedBox(width: _sw(6, min: 4, max: 10)),
            Text(
              widget.durationFormatted,
              style: TextStyle(
                  color: _accentColor,
                  fontSize: _sw(15, min: 12, max: 18),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3),
            ),
            SizedBox(width: _sw(16, min: 10, max: 24)),
            Icon(Icons.emoji_events_rounded,
                color: _accentColor, size: _sw(18, min: 14, max: 22)),
            SizedBox(width: _sw(6, min: 4, max: 10)),
            Text(
              'Goal Completed 🏆',
              style: TextStyle(
                  color: _accentColor,
                  fontSize: _sw(15, min: 12, max: 18),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final hPad = _sw(20, min: 16, max: 32);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: _sh(6, min: 4, max: 10)),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(_sw(16, min: 12, max: 22)),
          border: Border.all(color: Colors.white10, width: 0.5),
        ),
        child: Column(children: [
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
    final vPad = _sh(18, min: 12, max: 26);
    final valueFontSize = isLarge ? _sw(26, min: 18, max: 34) : _sw(20, min: 14, max: 28);
    final labelFontSize = isLarge ? _sw(12, min: 10, max: 15) : _sw(11, min: 9, max: 14);
    final iconSize = isLarge ? _sw(18, min: 13, max: 22) : _sw(14, min: 11, max: 18);

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: vPad, horizontal: _sw(4, min: 2, max: 8)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: valueFontSize,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: _sh(7, min: 4, max: 10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: iconColor, size: iconSize),
                SizedBox(width: _sw(4, min: 2, max: 6)),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: labelFontSize,
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

  Widget _dividerV() => Container(
      width: 0.5,
      height: _sh(68, min: 52, max: 90),
      color: Colors.white12);

  Widget _dividerH() => Container(height: 0.5, color: Colors.white12);

  Widget _buildBrandingStrip() {
    final hPad = _sw(20, min: 16, max: 32);
    final logoSize = _sw(50, min: 38, max: 68);
    return Container(
      margin: EdgeInsets.fromLTRB(hPad, _sh(12, min: 8, max: 18), hPad, _sh(20, min: 14, max: 28)),
      padding: EdgeInsets.symmetric(
          horizontal: _sw(16, min: 12, max: 24),
          vertical: _sh(16, min: 12, max: 22)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(_sw(14, min: 10, max: 20)),
        border: Border.all(color: Colors.white10, width: 0.6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(_sw(8, min: 6, max: 12)),
            child: Image.asset(
              'assets/images/Fit_First.png',
              height: logoSize,
              width: logoSize,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  Icon(_activityIcon, color: _accentColor, size: logoSize),
            ),
          ),
          SizedBox(width: _sw(14, min: 10, max: 20)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '· Fit First',
                  style: TextStyle(
                    color: _accentColor.withOpacity(0.9),
                    fontSize: _sw(15, min: 12, max: 18),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
                SizedBox(height: _sh(4, min: 2, max: 6)),
                Text(
                  'Track your fitness, challenge your limits, and stay active every day.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: _sw(12, min: 10, max: 15),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: _sw(10, min: 6, max: 16)),
          Text(
            _formattedDate,
            style: TextStyle(
                color: Colors.white38, fontSize: _sw(12, min: 10, max: 15)),
          ),
        ],
      ),
    );
  }

  Widget _buildTab2WinnerCamera() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildWinnerHeader(),
          SizedBox(height: _sh(12, min: 8, max: 18)),
          if (_capturedImage != null) ...[
            RepaintBoundary(
              key: _winnerCardKey,
              child: _buildImagePreview(),
            ),
          ] else ...[
            _buildCameraPreview(),
          ],
          SizedBox(height: _sh(20, min: 14, max: 28)),
          _buildWinnerStatsBadge(),
          SizedBox(height: _sh(20, min: 14, max: 28)),
          if (_capturedImage != null) ...[
            _buildAfterCaptureActions(),
          ] else ...[
            _buildCameraActions(),
          ],
          SizedBox(height: _sh(32, min: 20, max: 48)),
        ],
      ),
    );
  }

  Widget _buildWinnerHeader() {
    final hPad = _sw(20, min: 16, max: 32);
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, _sh(20, min: 14, max: 28), hPad, _sh(12, min: 8, max: 18)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: _sw(12, min: 8, max: 18),
                vertical: _sh(6, min: 4, max: 10)),
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(_sw(20, min: 14, max: 28)),
              border: Border.all(color: _accentColor.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events_rounded,
                    color: _accentColor, size: _sw(16, min: 13, max: 20)),
                SizedBox(width: _sw(6, min: 4, max: 10)),
                Text('Winner Moment',
                    style: TextStyle(
                        color: _accentColor,
                        fontSize: _sw(13, min: 11, max: 16),
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const Spacer(),
          Text(_formattedDate,
              style: TextStyle(
                  color: Colors.white38,
                  fontSize: _sw(12, min: 10, max: 15))),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    final previewH = (_screenH * 0.45).clamp(260.0, 480.0);
    final hPad = _sw(20, min: 16, max: 32);
    final circleOuter = _sw(140, min: 100, max: 200);
    final circleInner = _sw(100, min: 70, max: 145);
    final personIcon = _sw(52, min: 36, max: 75);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: hPad),
      height: previewH,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_sw(24, min: 18, max: 32)),
        border:
        Border.all(color: _accentColor.withOpacity(0.3), width: 1.5),
        color: const Color(0xFF141414),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_sw(22, min: 16, max: 30)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _accentColor.withOpacity(0.08),
                    const Color(0xFF141414),
                  ],
                ),
              ),
            ),
            Center(
              child: Container(
                width: circleOuter,
                height: circleOuter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: _accentColor.withOpacity(0.25), width: 2),
                ),
                child: Center(
                  child: Container(
                    width: circleInner,
                    height: circleInner,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _accentColor.withOpacity(0.08),
                      border: Border.all(
                          color: _accentColor.withOpacity(0.15), width: 1),
                    ),
                    child: Icon(Icons.person_rounded,
                        color: _accentColor.withOpacity(0.4),
                        size: personIcon),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: _sh(28, min: 18, max: 40),
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Icon(Icons.camera_alt_rounded,
                      color: _accentColor.withOpacity(0.5),
                      size: _sw(22, min: 16, max: 28)),
                  SizedBox(height: _sh(8, min: 5, max: 12)),
                  Text(
                    '"Take selfie" or "Upload from gallery" to share\nyour winner moment 🏆',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: _sw(13, min: 11, max: 16),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: _sh(14, min: 10, max: 20),
              left: _sw(14, min: 10, max: 20),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: _sw(10, min: 7, max: 15),
                    vertical: _sh(6, min: 4, max: 9)),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius:
                  BorderRadius.circular(_sw(20, min: 14, max: 28)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_events_rounded,
                        color: _accentColor, size: _sw(14, min: 11, max: 18)),
                    SizedBox(width: _sw(6, min: 4, max: 9)),
                    Text(
                      '${widget.distanceCovered.toStringAsFixed(2)} km · ${widget.durationFormatted}',
                      style: TextStyle(
                        color: _accentColor,
                        fontSize: _sw(11, min: 9, max: 14),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    final imgH = (_screenH * 0.53).clamp(300.0, 560.0);
    final hPad = _sw(20, min: 16, max: 32);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: hPad),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_sw(24, min: 18, max: 32)),
        border: Border.all(color: _accentColor.withOpacity(0.5), width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_sw(22, min: 16, max: 30)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: imgH,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(_capturedImage!, fit: BoxFit.cover),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: _sh(130, min: 90, max: 170),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black87, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: _sh(14, min: 10, max: 20),
                    left: _sw(14, min: 10, max: 20),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: _sw(10, min: 7, max: 15),
                          vertical: _sh(6, min: 4, max: 9)),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius:
                        BorderRadius.circular(_sw(20, min: 14, max: 28)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.emoji_events_rounded,
                              color: _accentColor,
                              size: _sw(16, min: 12, max: 20)),
                          SizedBox(width: _sw(6, min: 4, max: 9)),
                          Text(
                            '${widget.distanceCovered.toStringAsFixed(2)} km · ${widget.durationFormatted}',
                            style: TextStyle(
                              color: _accentColor,
                              fontSize: _sw(12, min: 10, max: 15),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: _sh(14, min: 10, max: 20),
                    right: _sw(14, min: 10, max: 20),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: _sw(10, min: 7, max: 15),
                          vertical: _sh(6, min: 4, max: 9)),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius:
                        BorderRadius.circular(_sw(20, min: 14, max: 28)),
                      ),
                      child: Text(
                        _formattedDate,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: _sw(12, min: 10, max: 15),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: _sh(14, min: 10, max: 20),
                    left: _sw(14, min: 10, max: 20),
                    right: _sw(14, min: 10, max: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _overlayStatItem(
                          icon: Icons.location_on_rounded,
                          value: widget.distanceCovered.toStringAsFixed(2),
                          unit: 'km',
                          color: const Color(0xFFF97316),
                        ),
                        _overlayDivider(),
                        _overlayStatItem(
                          icon: Icons.timer_rounded,
                          value: widget.durationFormatted,
                          unit: 'time',
                          color: const Color(0xFF4ADE80),
                        ),
                        _overlayDivider(),
                        _overlayStatItem(
                          icon: Icons.local_fire_department_rounded,
                          value: widget.caloriesBurned,
                          unit: 'cal',
                          color: const Color(0xFFFB923C),
                        ),
                        _overlayDivider(),
                        _overlayStatItem(
                          icon: Icons.speed_rounded,
                          value: widget.avgPace,
                          unit: 'min/km',
                          color: const Color(0xFF38BDF8),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Branding bottom bar
            Container(
              color: const Color(0xFF0A0A0A),
              padding: EdgeInsets.symmetric(
                  horizontal: _sw(16, min: 12, max: 24),
                  vertical: _sh(12, min: 8, max: 18)),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius:
                    BorderRadius.circular(_sw(8, min: 6, max: 12)),
                    child: Image.asset(
                      'assets/images/Fit_First.png',
                      height: _sw(36, min: 28, max: 50),
                      width: _sw(36, min: 28, max: 50),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(_activityIcon,
                          color: _accentColor,
                          size: _sw(36, min: 28, max: 50)),
                    ),
                  ),
                  SizedBox(width: _sw(10, min: 7, max: 16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '· Fit First',
                          style: TextStyle(
                            color: _accentColor,
                            fontSize: _sw(13, min: 11, max: 16),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        Text(
                          'Track your fitness, challenge your limits.',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: _sw(10, min: 8, max: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: _sw(10, min: 7, max: 15),
                        vertical: _sh(5, min: 3, max: 8)),
                    decoration: BoxDecoration(
                      color: _accentColor.withOpacity(0.15),
                      borderRadius:
                      BorderRadius.circular(_sw(20, min: 14, max: 28)),
                      border: Border.all(
                          color: _accentColor.withOpacity(0.3), width: 1),
                    ),
                    child: Text(
                      '$_activityEmoji ${widget.activityType}',
                      style: TextStyle(
                        color: _accentColor,
                        fontSize: _sw(11, min: 9, max: 14),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _overlayDivider() => Container(
      width: 0.5,
      height: _sh(36, min: 26, max: 50),
      color: Colors.white24);

  Widget _overlayStatItem({
    required IconData icon,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: _sw(14, min: 11, max: 18)),
        SizedBox(height: _sh(3, min: 2, max: 5)),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: _sw(13, min: 10, max: 16),
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            color: Colors.white60,
            fontSize: _sw(10, min: 8, max: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildWinnerStatsBadge() {
    final hPad = _sw(20, min: 16, max: 32);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: _sw(16, min: 10, max: 24),
            vertical: _sh(14, min: 10, max: 20)),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(_sw(16, min: 12, max: 22)),
          border: Border.all(color: Colors.white10, width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _winnerStat(
                value: widget.distanceCovered.toStringAsFixed(2),
                unit: 'km',
                icon: Icons.location_on_rounded,
                color: const Color(0xFFF97316)),
            _winnerStatDivider(),
            _winnerStat(
                value: widget.durationFormatted,
                unit: 'time',
                icon: Icons.timer_rounded,
                color: const Color(0xFF4ADE80)),
            _winnerStatDivider(),
            _winnerStat(
                value: widget.caloriesBurned,
                unit: 'cal',
                icon: Icons.local_fire_department_rounded,
                color: const Color(0xFFFB923C)),
            _winnerStatDivider(),
            _winnerStat(
                value: widget.avgPace,
                unit: 'min/km',
                icon: Icons.speed_rounded,
                color: const Color(0xFF38BDF8)),
          ],
        ),
      ),
    );
  }

  Widget _winnerStat({
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: _sw(16, min: 13, max: 20)),
        SizedBox(height: _sh(4, min: 2, max: 6)),
        Text(value,
            style: TextStyle(
                color: Colors.white,
                fontSize: _sw(14, min: 11, max: 18),
                fontWeight: FontWeight.bold)),
        Text(unit,
            style: TextStyle(
                color: Colors.white38,
                fontSize: _sw(10, min: 8, max: 13))),
      ],
    );
  }

  Widget _winnerStatDivider() => Container(
      width: 0.5,
      height: _sh(40, min: 30, max: 55),
      color: Colors.white12);

  Widget _buildCameraActions() {
    final hPad = _sw(20, min: 16, max: 32);
    final btnSize = _sw(72, min: 56, max: 96);
    final iconSize = _sw(32, min: 24, max: 44);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        children: [
          GestureDetector(
            onTap: _isCapturing ? null : _takeSelfie,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: btnSize,
              height: btnSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isCapturing ? Colors.white24 : _accentColor,
                boxShadow: [
                  BoxShadow(
                      color: _accentColor.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2)
                ],
              ),
              child: _isCapturing
                  ? Center(
                  child: SizedBox(
                      width: _sw(28, min: 20, max: 38),
                      height: _sw(28, min: 20, max: 38),
                      child: const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5)))
                  : Icon(Icons.camera_alt_rounded,
                  color: Colors.black, size: iconSize),
            ),
          ),
          SizedBox(height: _sh(8, min: 5, max: 12)),
          Text('Take Selfie',
              style: TextStyle(
                  color: _accentColor,
                  fontSize: _sw(12, min: 10, max: 15),
                  fontWeight: FontWeight.w600)),
          SizedBox(height: _sh(20, min: 14, max: 28)),
          GestureDetector(
            onTap: _pickFromGallery,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: _sh(14, min: 10, max: 20)),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius:
                BorderRadius.circular(_sw(14, min: 10, max: 20)),
                border: Border.all(
                    color: Colors.white.withOpacity(0.15), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_rounded,
                      color: Colors.white70,
                      size: _sw(20, min: 16, max: 26)),
                  SizedBox(width: _sw(10, min: 7, max: 16)),
                  Text('Upload from Gallery',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: _sw(14, min: 12, max: 17),
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAfterCaptureActions() {
    final hPad = _sw(20, min: 16, max: 32);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        children: [
          // Share main button
          GestureDetector(
            onTap: _shareWinnerPhoto,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: _sh(15, min: 11, max: 22)),
              decoration: BoxDecoration(
                color: _accentColor,
                borderRadius:
                BorderRadius.circular(_sw(14, min: 10, max: 20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Share Winner Moment',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: _sw(15, min: 12, max: 18),
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          SizedBox(height: _sh(12, min: 8, max: 18)),
          // Social row
          Row(
            children: [
              _socialShareBtn(
                icon: FontAwesomeIcons.whatsapp,
                label: 'WhatsApp',
                color: const Color(0xFF25D366),
                onTap: _shareToWhatsApp,
              ),
              SizedBox(width: _sw(12, min: 8, max: 18)),
              _socialShareBtn(
                icon: FontAwesomeIcons.instagram,
                label: 'Instagram',
                color: const Color(0xFFE1306C),
                onTap: _shareToInstagram,
              ),
              SizedBox(width: _sw(12, min: 8, max: 18)),
              _socialShareBtn(
                icon: FontAwesomeIcons.shareNodes,
                label: 'More',
                color: Colors.white54,
                onTap: _shareWinnerPhoto,
              ),
            ],
          ),
          SizedBox(height: _sh(16, min: 10, max: 24)),
          GestureDetector(
            onTap: _retakePhoto,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: _sh(14, min: 10, max: 20)),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius:
                BorderRadius.circular(_sw(14, min: 10, max: 20)),
                border: Border.all(
                    color: Colors.white.withOpacity(0.15), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh_rounded,
                      color: Colors.white54,
                      size: _sw(20, min: 16, max: 26)),
                  SizedBox(width: _sw(10, min: 7, max: 16)),
                  Text('Retake Photo',
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: _sw(14, min: 12, max: 17),
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialShareBtn({
    required FaIconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
          EdgeInsets.symmetric(vertical: _sh(12, min: 8, max: 18)),
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(_sw(12, min: 8, max: 18)),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Column(
            children: [
              FaIcon(icon, color: color, size: _sw(20, min: 16, max: 26)),
              SizedBox(height: _sh(6, min: 4, max: 10)),
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontSize: _sw(11, min: 9, max: 14),
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}