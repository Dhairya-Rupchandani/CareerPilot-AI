import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/star_background.dart';

import '../assessment/assessment_screen.dart';
import '../home/home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // SHOW MESSAGE
  // ============================================================

  void _showMessage(
      String message,
      Color color, {
        IconData icon = Icons.info_outline,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  void _showLoginSuccessMessage() {
    _showMessage(
      "Login successful!",
      Colors.green,
      icon: Icons.check_circle_outline,
    );
  }

  void _showSignupFirstMessage() {
    _showMessage(
      "Please sign up first.",
      Colors.orange,
      icon: Icons.person_add_alt_1,
    );
  }

  // ============================================================
  // GO TO NEXT SCREEN
  // ============================================================

  Future<void> _goToNextScreen() async {
    try {
      final bool completed =
      await FirestoreService().isAssessmentCompleted();

      if (!mounted) return;

      if (completed) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AssessmentScreen(),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        "Something went wrong. Please try again.",
        Colors.red,
        icon: Icons.error_outline,
      );
    }
  }

  // ============================================================
  // EMAIL LOGIN
  // ============================================================

  Future<void> _loginWithEmail() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (email.isEmpty) {
      _showMessage(
        "Please enter your email.",
        Colors.orange,
        icon: Icons.email_outlined,
      );
      return;
    }

    if (password.isEmpty) {
      _showMessage(
        "Please enter your password.",
        Colors.orange,
        icon: Icons.lock_outline,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showLoginSuccessMessage();

      await Future.delayed(
        const Duration(milliseconds: 900),
      );

      if (!mounted) return;

      await _goToNextScreen();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      switch (e.code) {
        case 'user-not-found':
          _showMessage(
            "Account not available. Please sign up first.",
            Colors.orange,
            icon: Icons.person_add_alt_1,
          );
          break;

        case 'invalid-credential':
          _showMessage(
            "Account not available. Please sign up first.",
            Colors.orange,
            icon: Icons.person_add_alt_1,
          );
          break;

        case 'wrong-password':
          _showMessage(
            "Incorrect password. Please try again.",
            Colors.red,
            icon: Icons.lock_outline,
          );
          break;

        case 'invalid-email':
          _showMessage(
            "Please enter a valid email address.",
            Colors.orange,
            icon: Icons.email_outlined,
          );
          break;

        case 'user-disabled':
          _showMessage(
            "This account has been disabled.",
            Colors.red,
            icon: Icons.block,
          );
          break;

        case 'too-many-requests':
          _showMessage(
            "Too many attempts. Please try again later.",
            Colors.red,
            icon: Icons.warning_amber_rounded,
          );
          break;

        case 'network-request-failed':
          _showMessage(
            "Network error. Please check your internet connection.",
            Colors.red,
            icon: Icons.wifi_off,
          );
          break;

        default:
          _showMessage(
            "Login failed. Please try again.",
            Colors.red,
            icon: Icons.error_outline,
          );
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        "Something went wrong. Please try again.",
        Colors.red,
        icon: Icons.error_outline,
      );
    }
  }

  // ============================================================
  // GOOGLE LOGIN
  // ============================================================

  Future<void> _loginWithGoogle() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final UserCredential? userCredential =
      await _authService.signInWithGoogle();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (userCredential == null) {
        return;
      }

      // Check if this Google account is being used
      // for the first time.
      final bool isNewUser =
          userCredential.additionalUserInfo?.isNewUser ?? false;

      // ========================================================
      // NEW GOOGLE USER
      // ========================================================

      if (isNewUser) {
        // This is LOGIN.
        // A new Google account must sign up first.
        await _authService.signOut();

        if (!mounted) return;

        _showSignupFirstMessage();

        return;
      }

      // ========================================================
      // EXISTING GOOGLE USER
      // ========================================================

      _showLoginSuccessMessage();

      await Future.delayed(
        const Duration(milliseconds: 900),
      );

      if (!mounted) return;

      await _goToNextScreen();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      switch (e.code) {
        case 'account-exists-with-different-credential':
          await _authService.signOut();

          if (!mounted) return;

          _showMessage(
            "Please login using your existing account.",
            Colors.orange,
            icon: Icons.person_outline,
          );
          break;

        case 'network-request-failed':
          _showMessage(
            "Network error. Please check your internet connection.",
            Colors.red,
            icon: Icons.wifi_off,
          );
          break;

        case 'user-disabled':
          _showMessage(
            "This account has been disabled.",
            Colors.red,
            icon: Icons.block,
          );
          break;

        default:
          _showMessage(
            "Google login failed. Please try again.",
            Colors.red,
            icon: Icons.error_outline,
          );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      final String errorText =
      e.toString().toLowerCase();

      // Google account picker cancelled.
      // Do not show any message.
      if (errorText.contains('cancel') ||
          errorText.contains('canceled') ||
          errorText.contains('cancelled')) {
        return;
      }

      _showMessage(
        "Google login failed. Please try again.",
        Colors.red,
        icon: Icons.error_outline,
      );
    }
  }

  // ============================================================
  // LOGIN UI
  // ============================================================

  Widget _buildLoginContent() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 30,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 450,
            ),
            child: Column(
              children: [
                // ==================================================
                // LOGO
                // ==================================================

                Image.asset(
                  'assets/images/careerpilot_logo.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 20),

                const Text(
                  "Welcome Back!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Login to continue your career journey",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 35),

                // ==================================================
                // EMAIL
                // ==================================================

                TextField(
                  controller: _emailController,
                  keyboardType:
                  TextInputType.emailAddress,
                  textInputAction:
                  TextInputAction.next,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: const TextStyle(
                      color: Colors.white70,
                    ),
                    hintText: "Enter your email",
                    hintStyle: const TextStyle(
                      color: Colors.white38,
                    ),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: Colors.white70,
                    ),
                    filled: true,
                    fillColor:
                    Colors.white.withOpacity(0.08),
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                      borderSide:
                      const BorderSide(
                        color: Colors.deepPurpleAccent,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ==================================================
                // PASSWORD
                // ==================================================

                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction:
                  TextInputAction.done,
                  onSubmitted: (_) {
                    if (!_isLoading) {
                      _loginWithEmail();
                    }
                  },
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: const TextStyle(
                      color: Colors.white70,
                    ),
                    hintText: "Enter your password",
                    hintStyle: const TextStyle(
                      color: Colors.white38,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Colors.white70,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword =
                          !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.white70,
                      ),
                    ),
                    filled: true,
                    fillColor:
                    Colors.white.withOpacity(0.08),
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                      borderSide:
                      const BorderSide(
                        color: Colors.deepPurpleAccent,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ==================================================
                // LOGIN BUTTON
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : _loginWithEmail,
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      Colors.deepPurpleAccent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                      Colors.deepPurpleAccent
                          .withOpacity(0.5),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // OR
                // ==================================================

                Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        color: Colors.white24,
                      ),
                    ),
                    const Padding(
                      padding:
                      EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                      child: Text(
                        "OR",
                        style: TextStyle(
                          color: Colors.white54,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        color: Colors.white24,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ==================================================
                // GOOGLE
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : _loginWithGoogle,
                    style:
                    OutlinedButton.styleFrom(
                      foregroundColor:
                      Colors.white,
                      side:
                      const BorderSide(
                        color: Colors.white24,
                      ),
                      backgroundColor:
                      Colors.white
                          .withOpacity(0.06),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration:
                          const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              "G",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Continue with Google",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ==================================================
                // SIGN UP
                // ==================================================

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const SignupScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color:
                          Colors.deepPurpleAccent,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: StarBackground(
        child: Stack(
          children: [
            _buildLoginContent(),

            // ======================================================
            // LOADING OVERLAY
            // ======================================================

            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.15),
                ),
              ),
          ],
        ),
      ),
    );
  }
}