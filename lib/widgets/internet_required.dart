import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InternetRequired extends StatefulWidget {
  final Widget child;

  const InternetRequired({
    super.key,
    required this.child,
  });

  @override
  State<InternetRequired> createState() =>
      _InternetRequiredState();
}

class _InternetRequiredState
    extends State<InternetRequired>
    with WidgetsBindingObserver {
  final InternetConnection _internetConnection =
  InternetConnection();

  StreamSubscription<InternetStatus>? _subscription;

  bool _hasInternet = true;
  bool _checking = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _checkInternet();

    _subscription =
        _internetConnection.onStatusChange.listen(
              (InternetStatus status) {
            if (!mounted) return;

            setState(() {
              _hasInternet =
                  status == InternetStatus.connected;

              _checking = false;
            });
          },
        );
  }

  // ============================================================
  // CHECK INTERNET
  // ============================================================

  Future<void> _checkInternet() async {
    try {
      final bool connected =
      await _internetConnection.hasInternetAccess;

      if (!mounted) return;

      setState(() {
        _hasInternet = connected;
        _checking = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _hasInternet = false;
        _checking = false;
      });
    }
  }

  // ============================================================
  // CHECK AGAIN WHEN APP RETURNS TO FOREGROUND
  // ============================================================

  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state,
      ) {
    if (state == AppLifecycleState.resumed) {
      _checkInternet();
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _subscription?.cancel();

    super.dispose();
  }

  // ============================================================
  // OFFLINE SCREEN
  // ============================================================

  Widget _buildOfflineScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                // ==================================================
                // WIFI OFF ICON
                // ==================================================

                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xFF171F35),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white12,
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.wifi_off_rounded,
                    color: Colors.white,
                    size: 55,
                  ),
                ),

                const SizedBox(height: 30),

                // ==================================================
                // TITLE
                // ==================================================

                const Text(
                  "Internet Connection Required",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                // ==================================================
                // MESSAGE
                // ==================================================

                const Text(
                  "The internet connection is not established.\n\n"
                      "Please connect to the internet to continue "
                      "using CareerPilot AI.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 30),

                // ==================================================
                // CHECKING INDICATOR
                // ==================================================

                const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.deepPurpleAccent,
                ),

                const SizedBox(height: 16),

                const Text(
                  "Waiting for internet connection...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // While the first Internet check is running,
    // show the connection screen instead of allowing
    // the user to enter the app.
    if (_checking) {
      return _buildOfflineScreen();
    }

    // No Internet = completely block the app.
    if (!_hasInternet) {
      return _buildOfflineScreen();
    }

    // Internet available = normal application.
    return widget.child;
  }
}