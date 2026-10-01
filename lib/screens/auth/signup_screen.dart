import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/star_background.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController =
  TextEditingController();

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  final AuthService _authService = AuthService();

  bool _hidePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // SIGNUP SUCCESS MESSAGE
  // ============================================================

  void _showSignupSuccessMessage() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Sign up successful! Please login to continue.",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ACCOUNT ALREADY EXISTS MESSAGE
  // ============================================================

  void _showAccountAlreadyExistsMessage() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.info_rounded,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Account already exists. Please login to continue.",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // NORMAL EMAIL + PASSWORD SIGN UP
  // ============================================================

  Future<void> _signup() async {
    if (_isLoading || _isGoogleLoading) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    try {
      // --------------------------------------------------------
      // CREATE FIREBASE ACCOUNT
      // --------------------------------------------------------

      final UserCredential credential =
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // --------------------------------------------------------
      // SAVE USER NAME
      // --------------------------------------------------------

      await credential.user?.updateDisplayName(name);

      // --------------------------------------------------------
      // CREATE FIRESTORE USER DOCUMENT
      // --------------------------------------------------------

      await FirestoreService().createUserIfNotExist();

      if (!mounted) return;

      // --------------------------------------------------------
      // SUCCESS
      // --------------------------------------------------------

      _showSignupSuccessMessage();

      // --------------------------------------------------------
      // SIGN OUT
      // User must login separately after signup.
      // --------------------------------------------------------

      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      // Allow the success message to be visible.
      await Future.delayed(
        const Duration(milliseconds: 1200),
      );

      if (!mounted) return;

      // Go back to Login screen.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      switch (e.code) {
      // ------------------------------------------------------
      // ACCOUNT ALREADY EXISTS
      // ------------------------------------------------------

        case 'email-already-in-use':
          _showAccountAlreadyExistsMessage();
          break;

      // ------------------------------------------------------
      // INVALID EMAIL
      // ------------------------------------------------------

        case 'invalid-email':
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Please enter a valid email address.",
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
          break;

      // ------------------------------------------------------
      // WEAK PASSWORD
      // ------------------------------------------------------

        case 'weak-password':
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Password is too weak. Use at least 6 characters.",
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
          break;

      // ------------------------------------------------------
      // OPERATION NOT ALLOWED
      // ------------------------------------------------------

        case 'operation-not-allowed':
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Email/password signup is not enabled in Firebase.",
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
          break;

      // ------------------------------------------------------
      // NETWORK ERROR
      // ------------------------------------------------------

        case 'network-request-failed':
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Network error. Please check your internet connection.",
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
          break;

      // ------------------------------------------------------
      // OTHER FIREBASE ERROR
      // ------------------------------------------------------

        default:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Signup failed. Please try again.",
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Something went wrong. Please try again.",
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // GOOGLE SIGN UP
  // ============================================================

  Future<void> _continueWithGoogle() async {
    if (_isGoogleLoading || _isLoading) return;

    setState(() {
      _isGoogleLoading = true;
    });

    try {
      // --------------------------------------------------------
      // GOOGLE AUTHENTICATION
      // --------------------------------------------------------

      final UserCredential? userCredential =
      await _authService.signInWithGoogle();

      if (!mounted) return;

      if (userCredential == null) {
        return;
      }

      // --------------------------------------------------------
      // CHECK WHETHER GOOGLE ACCOUNT IS NEW
      // --------------------------------------------------------

      final bool isNewUser =
          userCredential.additionalUserInfo?.isNewUser ?? false;

      // ========================================================
      // NEW GOOGLE USER
      // ========================================================

      if (isNewUser) {
        // Make sure Firestore profile exists.
        await FirestoreService().createUserIfNotExist();

        if (!mounted) return;

        _showSignupSuccessMessage();

        // User must login separately.
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        await Future.delayed(
          const Duration(milliseconds: 1200),
        );

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );

        return;
      }

      // ========================================================
      // EXISTING GOOGLE USER
      // ========================================================

      // Sign out because this is the Signup screen.
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      _showAccountAlreadyExistsMessage();

      await Future.delayed(
        const Duration(milliseconds: 1200),
      );

      if (!mounted) return;

      // Go to Login screen.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      // --------------------------------------------------------
      // GOOGLE ACCOUNT ALREADY EXISTS WITH DIFFERENT PROVIDER
      // --------------------------------------------------------

      if (e.code ==
          'account-exists-with-different-credential') {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        _showAccountAlreadyExistsMessage();

        await Future.delayed(
          const Duration(milliseconds: 1200),
        );

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );

        return;
      }

      // --------------------------------------------------------
      // OTHER FIREBASE GOOGLE ERROR
      // --------------------------------------------------------

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Google signup failed. Please try again.",
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      final String errorText =
      e.toString().toLowerCase();

      // --------------------------------------------------------
      // GOOGLE ACCOUNT PICKER CANCELLED
      // --------------------------------------------------------
      // Do NOT show any message.
      // Do NOT navigate anywhere.

      if (errorText.contains('cancel') ||
          errorText.contains('canceled') ||
          errorText.contains('cancelled')) {
        return;
      }

      // --------------------------------------------------------
      // OTHER GOOGLE ERROR
      // --------------------------------------------------------

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Google signup failed. Please try again.",
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      validator: validator,
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.5),
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.white70,
        ),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.deepPurpleAccent,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.redAccent,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.5,
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
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: StarBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 420,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // ==================================================
                      // LOGO
                      // ==================================================

                      Image.asset(
                        "assets/images/careerpilot_logo.png",
                        height: 110,
                      ),

                      const SizedBox(height: 16),

                      // ==================================================
                      // TITLE
                      // ==================================================

                      const Text(
                        "Create Account",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Join CareerPilot AI and discover your future",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ==================================================
                      // NAME
                      // ==================================================

                      buildField(
                        controller: _nameController,
                        hint: "Full Name",
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return "Enter your name";
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      // ==================================================
                      // EMAIL
                      // ==================================================

                      buildField(
                        controller: _emailController,
                        hint: "Email",
                        icon: Icons.email_outlined,
                        keyboard:
                        TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return "Enter email";
                          }

                          if (!value.contains("@")) {
                            return "Invalid email";
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      // ==================================================
                      // PASSWORD
                      // ==================================================

                      buildField(
                        controller: _passwordController,
                        hint: "Password",
                        icon: Icons.lock_outline,
                        obscure: _hidePassword,
                        suffix: IconButton(
                          onPressed: () {
                            setState(() {
                              _hidePassword =
                              !_hidePassword;
                            });
                          },
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white70,
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return "Enter password";
                          }

                          if (value.length < 6) {
                            return "Minimum 6 characters";
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 22),

                      // ==================================================
                      // SIGN UP BUTTON
                      // ==================================================

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed:
                          (_isLoading ||
                              _isGoogleLoading)
                              ? null
                              : _signup,
                          style:
                          ElevatedButton.styleFrom(
                            backgroundColor:
                            Colors.deepPurpleAccent,
                            disabledBackgroundColor:
                            Colors.deepPurpleAccent
                                .withOpacity(.5),
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(14),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                            CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                              : const Text(
                            "SIGN UP",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight:
                              FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // ==================================================
                      // OR
                      // ==================================================

                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.white
                                  .withOpacity(0.25),
                            ),
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            child: Text(
                              "OR",
                              style: TextStyle(
                                color: Colors.white
                                    .withOpacity(0.6),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.white
                                  .withOpacity(0.25),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // ==================================================
                      // GOOGLE SIGN UP
                      // ==================================================

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed:
                          (_isLoading ||
                              _isGoogleLoading)
                              ? null
                              : _continueWithGoogle,
                          style:
                          OutlinedButton.styleFrom(
                            backgroundColor:
                            Colors.white
                                .withOpacity(0.06),
                            side: BorderSide(
                              color: Colors.white
                                  .withOpacity(0.25),
                            ),
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(14),
                            ),
                          ),
                          child: _isGoogleLoading
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                            CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                              : Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration:
                                const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                alignment:
                                Alignment.center,
                                child: const Text(
                                  "G",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight:
                                    FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Continue with Google",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight:
                                  FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ==================================================
                      // LOGIN
                      // ==================================================

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: TextStyle(
                              color: Colors.white
                                  .withOpacity(0.65),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (_isLoading ||
                                  _isGoogleLoading) {
                                return;
                              }

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const LoginScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Login",
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

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}