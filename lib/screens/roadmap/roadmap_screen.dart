import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool loading = true;
  bool saving = false;

  String career = "";

  List<Map<String, dynamic>> roadmap = [];

  // =========================================================
  // ROADMAP DATA
  // =========================================================

  List<Map<String, dynamic>> softwareRoadmap() => [
    {
      "title": "Learn C Programming",
      "weeks": "Week 1-2",
      "done": false,
    },
    {
      "title": "Data Structures",
      "weeks": "Week 3-4",
      "done": false,
    },
    {
      "title": "Flutter Development",
      "weeks": "Week 5-8",
      "done": false,
    },
    {
      "title": "Firebase Database",
      "weeks": "Week 9-10",
      "done": false,
    },
    {
      "title": "Build Portfolio Project",
      "weeks": "Week 11-12",
      "done": false,
    },
  ];

  List<Map<String, dynamic>> uiRoadmap() => [
    {
      "title": "Learn Figma",
      "weeks": "Week 1-2",
      "done": false,
    },
    {
      "title": "Color & Typography",
      "weeks": "Week 3",
      "done": false,
    },
    {
      "title": "Wireframing",
      "weeks": "Week 4-5",
      "done": false,
    },
    {
      "title": "Prototype UI",
      "weeks": "Week 6-8",
      "done": false,
    },
    {
      "title": "Build Design Portfolio",
      "weeks": "Week 9-10",
      "done": false,
    },
  ];

  List<Map<String, dynamic>> aiRoadmap() => [
    {
      "title": "Python Basics",
      "weeks": "Week 1",
      "done": false,
    },
    {
      "title": "NumPy & Pandas",
      "weeks": "Week 2-3",
      "done": false,
    },
    {
      "title": "Machine Learning",
      "weeks": "Week 4-6",
      "done": false,
    },
    {
      "title": "Deep Learning",
      "weeks": "Week 7-9",
      "done": false,
    },
    {
      "title": "TensorFlow Project",
      "weeks": "Week 10-12",
      "done": false,
    },
  ];

  List<Map<String, dynamic>> businessRoadmap() => [
    {
      "title": "Excel Advanced",
      "weeks": "Week 1",
      "done": false,
    },
    {
      "title": "SQL Basics",
      "weeks": "Week 2-3",
      "done": false,
    },
    {
      "title": "Power BI",
      "weeks": "Week 4-6",
      "done": false,
    },
    {
      "title": "Data Analytics",
      "weeks": "Week 7-8",
      "done": false,
    },
    {
      "title": "Business Case Study",
      "weeks": "Week 9-10",
      "done": false,
    },
  ];

  // =========================================================
  // INITIALIZATION
  // =========================================================

  @override
  void initState() {
    super.initState();
    loadRoadmap();
  }

  // =========================================================
  // LOAD ROADMAP
  // =========================================================

  Future<void> loadRoadmap() async {
    final user = auth.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
      return;
    }

    try {
      final userRef = firestore.collection("users").doc(user.uid);

      final userDoc = await userRef.get();

      final userData = userDoc.data();

      career = userData?["career"] ?? "Software Developer";

      // -------------------------------------------------------
      // If roadmap already exists, load it.
      // -------------------------------------------------------

      if (userData?["roadmap"] != null) {
        final savedRoadmap = userData!["roadmap"];

        if (savedRoadmap is List) {
          roadmap = savedRoadmap
              .map(
                (item) => Map<String, dynamic>.from(
              item as Map,
            ),
          )
              .toList();
        }
      }

      // -------------------------------------------------------
      // If no roadmap exists, create one based on career.
      // -------------------------------------------------------

      if (roadmap.isEmpty) {
        if (career == "Software Developer") {
          roadmap = softwareRoadmap();
        } else if (career == "UI/UX Designer") {
          roadmap = uiRoadmap();
        } else if (career == "AI Engineer") {
          roadmap = aiRoadmap();
        } else if (career == "Business Analyst") {
          roadmap = businessRoadmap();
        } else {
          roadmap = softwareRoadmap();
        }

        await saveRoadmap();
      } else {
        // Make sure older roadmap data also updates analytics.
        await updateAnalytics();
      }

      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading roadmap: $e");

      if (mounted) {
        setState(() {
          loading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Unable to load roadmap. Please try again.",
            ),
          ),
        );
      }
    }
  }

  // =========================================================
  // CALCULATE COMPLETED SKILLS
  // =========================================================

  int get completedSkills {
    return roadmap.where((item) {
      return item["done"] == true;
    }).length;
  }

  // =========================================================
  // CALCULATE ROADMAP PERCENTAGE
  // =========================================================

  int get roadmapPercentage {
    if (roadmap.isEmpty) {
      return 0;
    }

    return ((completedSkills / roadmap.length) * 100).round();
  }

  // =========================================================
  // SAVE ROADMAP
  // =========================================================

  Future<void> saveRoadmap() async {
    final user = auth.currentUser;

    if (user == null) return;

    try {
      setState(() {
        saving = true;
      });

      final userRef = firestore.collection("users").doc(user.uid);

      // Save roadmap itself.
      await userRef.set(
        {
          "roadmap": roadmap,
        },
        SetOptions(merge: true),
      );

      // Update analytics separately.
      await updateAnalytics();
    } catch (e) {
      debugPrint("Error saving roadmap: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Could not save roadmap progress.",
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  // =========================================================
  // UPDATE ANALYTICS
  // =========================================================

  Future<void> updateAnalytics() async {
    final user = auth.currentUser;

    if (user == null) return;

    final completed = completedSkills;
    final percentage = roadmapPercentage;

    await firestore.collection("analytics").doc(user.uid).set(
      {
        // Number of completed roadmap skills.
        "skillsCompleted": completed,

        // Percentage of completed roadmap.
        "roadmapProgress": percentage,

        // IMPORTANT:
        // Do NOT update "careerProgress" here.
        // Career Match comes from users.matchScore.
      },
      SetOptions(merge: true),
    );
  }

  // =========================================================
  // PROGRESS VALUE FOR PROGRESS BAR
  // =========================================================

  double get progress {
    if (roadmap.isEmpty) {
      return 0;
    }

    return completedSkills / roadmap.length;
  }

  // =========================================================
  // TOGGLE SKILL
  // =========================================================

  Future<void> toggleSkill(
      int index,
      bool value,
      ) async {
    if (index < 0 || index >= roadmap.length) {
      return;
    }

    setState(() {
      roadmap[index]["done"] = value;
    });

    await saveRoadmap();
  }

  // =========================================================
  // RESET PROGRESS
  // =========================================================

  Future<void> resetProgress() async {
    if (roadmap.isEmpty) return;

    setState(() {
      for (final item in roadmap) {
        item["done"] = false;
      }
    });

    await saveRoadmap();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Roadmap progress has been reset.",
          ),
        ),
      );
    }
  }

  // =========================================================
  // UI
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),

      // =======================================================
      // APP BAR
      // =======================================================

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Learning Roadmap",
        ),
        centerTitle: true,
      ),

      // =======================================================
      // BODY
      // =======================================================

      body: loading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================================================
            // CAREER TITLE
            // =================================================

            Text(
              "$career Roadmap",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "Personalized AI learning path",
              style: TextStyle(
                color: Colors.white60,
              ),
            ),

            const SizedBox(height: 22),

            // =================================================
            // PROGRESS CARD
            // =================================================

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF171F35),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        "Overall Progress",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),

                      const Spacer(),

                      Text(
                        "$roadmapPercentage%",
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.white12,
                    color: Colors.deepPurpleAccent,
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Icon(
                        Icons.school_outlined,
                        color: Colors.deepPurpleAccent,
                        size: 20,
                      ),

                      const SizedBox(width: 8),

                      Text(
                        "$completedSkills / ${roadmap.length} skills completed",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =================================================
            // SKILL CHECKLIST TITLE
            // =================================================

            const Text(
              "Skill Checklist",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // =================================================
            // SKILL LIST
            // =================================================

            Expanded(
              child: roadmap.isEmpty
                  ? const Center(
                child: Text(
                  "No roadmap available.",
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 16,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: roadmap.length,
                itemBuilder: (context, index) {
                  final item = roadmap[index];

                  final bool isDone =
                      item["done"] == true;

                  return Container(
                    margin: const EdgeInsets.only(
                      bottom: 12,
                    ),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF171F35),
                      borderRadius:
                      BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        // =================================
                        // CHECKBOX
                        // =================================

                        Checkbox(
                          value: isDone,
                          activeColor:
                          Colors.deepPurpleAccent,
                          onChanged: saving
                              ? null
                              : (value) async {
                            await toggleSkill(
                              index,
                              value ?? false,
                            );
                          },
                        ),

                        const SizedBox(width: 8),

                        // =================================
                        // SKILL INFORMATION
                        // =================================

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["title"] ?? "Skill",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  decoration: isDone
                                      ? TextDecoration
                                      .lineThrough
                                      : null,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                item["weeks"] ?? "",
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // =================================
                        // COMPLETED ICON
                        // =================================

                        if (isDone)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.greenAccent,
                            size: 22,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // =================================================
            // RESET BUTTON
            // =================================================

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  disabledBackgroundColor:
                  Colors.redAccent.withOpacity(0.5),
                ),
                onPressed: saving || roadmap.isEmpty
                    ? null
                    : resetProgress,
                child: saving
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  "Reset Progress",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}