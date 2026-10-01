import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  // ================= USER =================

  Future<void> createUserIfNotExist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = _db.collection("users").doc(user.uid);
    final doc = await ref.get();

    if (!doc.exists) {
      await ref.set({
        "name": user.displayName ?? "",
        "email": user.email ?? "",
        "photo": user.photoURL ?? "",
        "createdAt": FieldValue.serverTimestamp(),
      });
    }

    await _createAnalyticsIfNeeded();
  }

  Future<bool> isAssessmentCompleted() async {
    final doc = await _db.collection("users").doc(uid).get();

    if (!doc.exists) return false;

    final data = doc.data();

    return data != null &&
        data.containsKey("career") &&
        data.containsKey("matchScore");
  }

  // ================= AI CAREER ENGINE =================

  Map<String, dynamic> _generateCareer({
    required String interest,
    required String skill,
    required String education,
    required String goal,
  }) {
    String career = "";
    int score = 0;

    // DESIGN INTEREST
    if (interest == "Design") {
      career = "UI/UX Designer";
      score = 92;
    }

    // TECHNOLOGY
    else if (interest == "Technology") {
      if (skill == "Coding") {
        career = "Software Developer";
        score = 95;
      } else {
        career = "AI Engineer";
        score = 90;
      }
    }

    // BUSINESS
    else if (interest == "Business") {
      career = "Business Analyst";
      score = 86;
    }

    // HEALTHCARE
    else if (interest == "Healthcare") {
      career = "Healthcare Specialist";
      score = 84;
    }

    // SCIENCE
    else if (interest == "Science") {
      career = "Data Scientist";
      score = 89;
    }

    // ARTS
    else if (interest == "Arts") {
      career = "Graphic Designer";
      score = 88;
    }

    else {
      career = "Software Developer";
      score = 78;
    }

    return {
      "career": career,
      "score": score,
    };
  }

  // ================= SAVE ASSESSMENT =================

  Future<void> saveAssessment({
    required String interest,
    required String skill,
    required String education,
    required String goal,
  }) async {
    final result = _generateCareer(
      interest: interest,
      skill: skill,
      education: education,
      goal: goal,
    );

    await _db.collection("users").doc(uid).set({
      "interest": interest,
      "skill": skill,
      "education": education,
      "goal": goal,
      "career": result["career"],
      "matchScore": result["score"],
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _db.collection("analytics").doc(uid).set({
      "careerProgress": result["score"],
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final doc = await _db.collection("users").doc(uid).get();
    return doc.data();
  }

  // ================= RESUME =================

  Future<void> saveResume(Map<String, dynamic> data) async {
    await _db.collection("users").doc(uid).set({
      "resume": data,
    }, SetOptions(merge: true));

    await _db.collection("analytics").doc(uid).set({
      "resumeCompletion": 100,
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getResume() async {
    final doc = await _db.collection("users").doc(uid).get();
    return doc.data()?["resume"];
  }

  // ================= ANALYTICS =================

  Future<void> _createAnalyticsIfNeeded() async {
    final ref = _db.collection("analytics").doc(uid);
    final doc = await ref.get();

    if (!doc.exists) {
      await ref.set({
        "chatCount": 0,
        "resumeCompletion": 0,
        "roadmapProgress": 25,
        "skillsCompleted": 0,
        "careerProgress": 25,
      });
    }
  }

  Future<void> incrementChat() async {
    await _createAnalyticsIfNeeded();

    await _db.collection("analytics").doc(uid).update({
      "chatCount": FieldValue.increment(1),
    });
  }

  Future<Map<String, dynamic>> getAnalytics() async {
    await _createAnalyticsIfNeeded();

    final doc = await _db.collection("analytics").doc(uid).get();

    return doc.data() ?? {};
  }
}