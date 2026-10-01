import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth/login_screen.dart';
import '../assessment/assessment_screen.dart';
import '../resume/resume_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool loading = true;
  bool retakingAssessment = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<void> loadProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
              (route) => false,
        );

        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (!mounted) return;

      setState(() {
        if (doc.exists) {
          userData = doc.data();
        }

        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Unable to load profile. Please try again.",
          ),
        ),
      );
    }
  }

  // ============================================================
  // RETAKE ASSESSMENT
  // ============================================================

  Future<void> retakeAssessment() async {
    if (retakingAssessment) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
            (route) => false,
      );

      return;
    }

    setState(() {
      retakingAssessment = true;
    });

    try {
      // Remove the old assessment result.
      //
      // This is important because LoginScreen checks
      // "career" and "matchScore" to decide whether
      // the assessment has already been completed.
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set(
        {
          "career": FieldValue.delete(),
          "matchScore": FieldValue.delete(),
          "roadmap": FieldValue.delete(),
          "assessmentCompleted": false,
          "updatedAt": FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      // Open a completely new assessment.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AssessmentScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Unable to start the assessment. Please try again.",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          retakingAssessment = false;
        });
      }
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
          (route) => false,
    );
  }

  // ============================================================
  // PROFILE TILE
  // ============================================================

  Widget tile(
      IconData icon,
      String title,
      VoidCallback onTap, {
        bool loading = false,
      }) {
    return Card(
      color: const Color(0xFF171F35),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.deepPurpleAccent,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        trailing: loading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.deepPurpleAccent,
          ),
        )
            : const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white54,
          size: 16,
        ),
        onTap: loading ? null : onTap,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("My Profile"),
        centerTitle: true,
      ),

      body: loading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(18),

        child: Column(
          children: [
            // ==================================================
            // PROFILE PHOTO
            // ==================================================

            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.deepPurple,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null
                  ? const Icon(
                Icons.person,
                color: Colors.white,
                size: 45,
              )
                  : null,
            ),

            const SizedBox(height: 14),

            // ==================================================
            // NAME
            // ==================================================

            Text(
              userData?["name"] ??
                  user?.displayName ??
                  "Student",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            // ==================================================
            // EMAIL
            // ==================================================

            Text(
              user?.email ?? "",
              style: const TextStyle(
                color: Colors.white60,
              ),
            ),

            const SizedBox(height: 8),

            // ==================================================
            // INTEREST
            // ==================================================

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                userData?["interest"] ?? "AI Engineer",
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // EDIT RESUME
            // ==================================================

            tile(
              Icons.description,
              "Edit Resume",
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ResumeScreen(),
                  ),
                );
              },
            ),

            // ==================================================
            // RETAKE ASSESSMENT
            // ==================================================

            tile(
              Icons.refresh,
              "Retake Assessment",
              retakeAssessment,
              loading: retakingAssessment,
            ),

            // ==================================================
            // LOGOUT
            // ==================================================

            tile(
              Icons.logout,
              "Logout",
              logout,
            ),

            const SizedBox(height: 25),

            const Text(
              "CareerPilot AI v1.0",
              style: TextStyle(
                color: Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}