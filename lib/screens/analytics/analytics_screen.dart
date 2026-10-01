import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _analyticsStream;
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _userStream;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final uid = user.uid;

      _analyticsStream = FirebaseFirestore.instance
          .collection("analytics")
          .doc(uid)
          .snapshots();

      _userStream = FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .snapshots();
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refresh() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get(const GetOptions(source: Source.server));

      await FirebaseFirestore.instance
          .collection("analytics")
          .doc(user.uid)
          .get(const GetOptions(source: Source.server));
    } catch (_) {
      // Realtime streams will continue working.
    }

    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // CONVERT VALUE TO INT
  // ============================================================

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.round();
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  // ============================================================
  // LIMIT PERCENTAGE BETWEEN 0 AND 100
  // ============================================================

  int _clampPercentage(int value) {
    if (value < 0) return 0;
    if (value > 100) return 100;

    return value;
  }

  // ============================================================
  // CALCULATE SKILL PERCENTAGE
  // ============================================================

  int _calculateSkillsPercentage({
    required int skillsCompleted,
    required int roadmapTotal,
  }) {
    if (roadmapTotal <= 0) {
      return 0;
    }

    final percentage =
    ((skillsCompleted / roadmapTotal) * 100).round();

    return _clampPercentage(percentage);
  }

  // ============================================================
  // CALCULATE OVERALL CAREER PROGRESS
  // ============================================================

  int _calculateOverallProgress({
    required int resume,
    required int roadmap,
    required int skillsPercentage,
  }) {
    /*
      Overall Career Progress represents actual completion.

      Career Match is NOT included here because:
      Career Match = assessment/recommendation score.

      Actual progress:
      - Resume
      - Roadmap
      - Skills

      If all three are 100%:
      Overall Career Progress = 100%
    */

    final int total =
        resume + roadmap + skillsPercentage;

    final int overall =
    (total / 3).round();

    return _clampPercentage(overall);
  }

  // ============================================================
  // MAIN ANALYTICS CONTENT
  // ============================================================

  Widget _buildRealtimeContent(
      Map<String, dynamic> userData,
      Map<String, dynamic> analyticsData,
      ) {
    // ============================================================
    // FIREBASE DATA
    // ============================================================

    final int chatCount = _toInt(
      analyticsData["chatCount"],
    );

    final int resume = _clampPercentage(
      _toInt(analyticsData["resumeCompletion"]),
    );

    final int roadmap = _clampPercentage(
      _toInt(analyticsData["roadmapProgress"]),
    );

    final int skillsCompleted = _toInt(
      analyticsData["skillsCompleted"],
    );

    // ------------------------------------------------------------
    // NUMBER OF SKILLS
    // ------------------------------------------------------------

    int roadmapTotal = 0;

    final dynamic roadmapData = userData["roadmap"];

    if (roadmapData is List) {
      roadmapTotal = roadmapData.length;
    }

    // ------------------------------------------------------------
    // SKILL PERCENTAGE
    // ------------------------------------------------------------

    final int skillsPercentage =
    _calculateSkillsPercentage(
      skillsCompleted: skillsCompleted,
      roadmapTotal: roadmapTotal,
    );

    // ------------------------------------------------------------
    // CAREER MATCH
    // ------------------------------------------------------------

    final int careerMatch = _clampPercentage(
      _toInt(userData["matchScore"]),
    );

    // ============================================================
    // OVERALL PROGRESS
    // ============================================================

    final int overallProgress =
    _calculateOverallProgress(
      resume: resume,
      roadmap: roadmap,
      skillsPercentage: skillsPercentage,
    );

    // ============================================================
    // ASSESSMENT STATUS
    // ============================================================

    final bool assessmentCompleted =
        userData.containsKey("career") &&
            userData.containsKey("matchScore");

    // ============================================================
    // ACHIEVEMENTS
    // ============================================================

    final bool resumeCompleted = resume >= 100;

    final bool aiExplorer =
        chatCount >= 5;

    final bool roadmapStarted =
        skillsCompleted > 0;

    final bool skillsCompletedAchievement =
        roadmapTotal > 0 &&
            skillsCompleted >= roadmapTotal;

    // ============================================================
    // UI
    // ============================================================

    return RefreshIndicator(
      onRefresh: _refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // ======================================================
            // OVERALL PROGRESS
            // ======================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(22),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6A5CFF),
                    Color(0xFF8C73FF),
                  ],
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    "Overall Career Progress",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: 130,
                    height: 130,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value:
                          overallProgress / 100,
                          strokeWidth: 10,
                          backgroundColor:
                          Colors.white24,
                          valueColor:
                          const AlwaysStoppedAnimation<
                              Color>(
                            Colors.white,
                          ),
                        ),

                        Center(
                          child: Text(
                            "$overallProgress%",
                            style:
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_done,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Live Firebase Analytics",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // ======================================================
            // PROGRESS BREAKDOWN
            // ======================================================

            const Text(
              "Progress Breakdown",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            _ProgressBar(
              title: "Career Match",
              value: careerMatch,
              icon: Icons.work_outline,
            ),

            const SizedBox(height: 14),

            _ProgressBar(
              title: "Resume Completion",
              value: resume,
              icon:
              Icons.description_outlined,
            ),

            const SizedBox(height: 14),

            _ProgressBar(
              title: "Roadmap Progress",
              value: roadmap,
              icon: Icons.route_outlined,
            ),

            const SizedBox(height: 14),

            _ProgressBar(
              title: "Skills Completed",
              value: skillsPercentage,
              icon: Icons.psychology_outlined,
            ),

            const SizedBox(height: 26),

            // ======================================================
            // LIVE STATISTICS
            // ======================================================

            const Text(
              "Live Statistics",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: StatBox(
                    title: "Career Match",
                    value: "$careerMatch%",
                    icon:
                    Icons.track_changes,
                    color:
                    Colors.deepPurpleAccent,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: StatBox(
                    title: "Resume",
                    value: "$resume%",
                    icon:
                    Icons.description,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: StatBox(
                    title: "Roadmap",
                    value: "$roadmap%",
                    icon: Icons.route,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: StatBox(
                    title: "AI Chats",
                    value: "$chatCount",
                    icon: Icons.smart_toy,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: StatBox(
                    title: "Skills",
                    value:
                    "$skillsCompleted/$roadmapTotal",
                    icon:
                    Icons.psychology,
                    color: Colors.purple,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: StatBox(
                    title: "Overall",
                    value:
                    "$overallProgress%",
                    icon: Icons.insights,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),

            // ======================================================
            // CAREER INFORMATION
            // ======================================================

            const Text(
              "Career Information",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color:
                const Color(0xFF171F35),
                borderRadius:
                BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Recommended Career",
                    style: TextStyle(
                      color: Colors.white60,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    userData["career"]
                        ?.toString() ??
                        "Assessment not completed",
                    style:
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    assessmentCompleted
                        ? "Career recommendation is based on your completed assessment."
                        : "Complete your assessment to get your career recommendation.",
                    style:
                    const TextStyle(
                      color: Colors.white60,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // ======================================================
            // ACHIEVEMENTS
            // ======================================================

            const Text(
              "Achievements",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            AchievementTile(
              title:
              "Assessment Completed",
              completed:
              assessmentCompleted,
              icon:
              Icons.check_circle,
              color: Colors.green,
            ),

            AchievementTile(
              title:
              "Resume Generated",
              completed:
              resumeCompleted,
              icon:
              Icons.workspace_premium,
              color: Colors.amber,
            ),

            AchievementTile(
              title: "AI Explorer",
              completed:
              aiExplorer,
              icon:
              Icons.smart_toy,
              color:
              Colors.deepPurple,
            ),

            AchievementTile(
              title:
              "Roadmap Started",
              completed:
              roadmapStarted,
              icon:
              Icons.route,
              color: Colors.blue,
            ),

            AchievementTile(
              title:
              "Skills Mastered",
              completed:
              skillsCompletedAchievement,
              icon:
              Icons.psychology,
              color: Colors.purple,
            ),

            const SizedBox(height: 30),

            // ======================================================
            // REALTIME INFORMATION
            // ======================================================

            const Center(
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.circle,
                    size: 9,
                    color: Colors.green,
                  ),
                  SizedBox(width: 7),
                  Text(
                    "Analytics updating in realtime",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null ||
        _analyticsStream == null ||
        _userStream == null) {
      return Scaffold(
        backgroundColor:
        const Color(0xFF0B1020),
        appBar: AppBar(
          backgroundColor:
          Colors.transparent,
          elevation: 0,
          title: const Text(
            "Progress Analytics",
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            "Please login to view analytics.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
      const Color(0xFF0B1020),

      appBar: AppBar(
        backgroundColor:
        Colors.transparent,
        elevation: 0,
        title: const Text(
          "Progress Analytics",
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon:
            const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),

      body: StreamBuilder<
          DocumentSnapshot<
              Map<String, dynamic>>>(
        stream: _userStream,

        builder:
            (context, userSnapshot) {
          if (userSnapshot
              .connectionState ==
              ConnectionState.waiting &&
              !userSnapshot.hasData) {
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          return StreamBuilder<
              DocumentSnapshot<
                  Map<String, dynamic>>>(
            stream: _analyticsStream,

            builder: (
                context,
                analyticsSnapshot,
                ) {
              if (analyticsSnapshot
                  .connectionState ==
                  ConnectionState.waiting &&
                  !analyticsSnapshot.hasData) {
                return const Center(
                  child:
                  CircularProgressIndicator(),
                );
              }

              final Map<String, dynamic>
              userData =
                  userSnapshot.data?.data() ??
                      {};

              final Map<String, dynamic>
              analyticsData =
                  analyticsSnapshot.data
                      ?.data() ??
                      {};

              return _buildRealtimeContent(
                userData,
                analyticsData,
              );
            },
          );
        },
      ),
    );
  }
}

// ================================================================
// PROGRESS BAR
// ================================================================

class _ProgressBar
    extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;

  const _ProgressBar({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
        const Color(0xFF171F35),
        borderRadius:
        BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                color:
                Colors.deepPurpleAccent,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style:
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ),

              Text(
                "$value%",
                style:
                const TextStyle(
                  color: Colors.white,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius:
            BorderRadius.circular(10),
            child:
            LinearProgressIndicator(
              value: value / 100,
              minHeight: 8,
              backgroundColor:
              Colors.white12,
              valueColor:
              const AlwaysStoppedAnimation<
                  Color>(
                Colors.deepPurpleAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// STAT BOX
// ================================================================

class StatBox
    extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatBox({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
        const Color(0xFF171F35),
        borderRadius:
        BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor:
            color.withOpacity(.15),
            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style:
            const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            textAlign:
            TextAlign.center,
            style:
            const TextStyle(
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// ACHIEVEMENT TILE
// ================================================================

class AchievementTile
    extends StatelessWidget {
  final String title;
  final bool completed;
  final IconData icon;
  final Color color;

  const AchievementTile({
    super.key,
    required this.title,
    required this.completed,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
        const Color(0xFF171F35),
        borderRadius:
        BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
            color.withOpacity(.15),
            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              title,
              style:
              const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),

          Icon(
            completed
                ? Icons.check_circle
                : Icons.lock,
            color: completed
                ? Colors.green
                : Colors.grey,
          ),
        ],
      ),
    );
  }
}