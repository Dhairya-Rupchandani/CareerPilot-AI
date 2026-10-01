  import 'package:flutter/material.dart';
  import 'package:firebase_auth/firebase_auth.dart';

  import '../../services/firestore_service.dart';
  import '../ai/ai_chat_screen.dart';
  import '../analytics/analytics_screen.dart';
  import '../college/college_screen.dart';
  import '../profile/profile_screen.dart';
  import '../resume/resume_preview_screen.dart';
  import '../roadmap/roadmap_screen.dart';
  import '../scholarship/scholarship_screen.dart';

  class HomeScreen extends StatefulWidget {
    const HomeScreen({super.key});

    @override
    State<HomeScreen> createState() => _HomeScreenState();
  }

  class _HomeScreenState extends State<HomeScreen> {
    final FirestoreService firestore = FirestoreService();

    Map<String, dynamic>? userData;
    bool loading = true;

    @override
    void initState() {
      super.initState();
      loadUser();
    }

    // ============================================================
    // LOAD USER DATA
    // ============================================================

    Future<void> loadUser() async {
      try {
        final data = await firestore.getUserData();

        if (!mounted) return;

        setState(() {
          userData = data;
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
              "Unable to load dashboard. Please try again.",
            ),
          ),
        );
      }
    }

    // ============================================================
    // OPEN RESUME BUILDER
    // ============================================================

    void openResumeBuilder() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ResumePreviewScreen(),
        ),
      );
    }

    // ============================================================
    // BUILD
    // ============================================================

    @override
    Widget build(BuildContext context) {
      final user = FirebaseAuth.instance.currentUser;

      final name =
          userData?["name"] ??
              user?.displayName ??
              "Student";

      final career =
          userData?["career"] ??
              "Not Generated";

      final score =
          userData?["matchScore"] ??
              0;

      final skill =
          userData?["skill"] ??
              "-";

      final goal =
          userData?["goal"] ??
              "-";

      return Scaffold(
        backgroundColor: const Color(0xFF0B1020),

        // ============================================================
        // APP BAR
        // ============================================================

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("CareerPilot AI"),
          actions: [
            IconButton(
              onPressed: loadUser,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),

        // ============================================================
        // BODY
        // ============================================================

        body: loading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : RefreshIndicator(
          onRefresh: loadUser,
          child: SingleChildScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                // ==================================================
                // GREETING
                // ==================================================

                Text(
                  "Hello, $name 👋",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Welcome back to CareerPilot AI",
                  style: TextStyle(
                    color: Colors.white60,
                  ),
                ),

                const SizedBox(height: 22),

                // ==================================================
                // AI CAREER CARD
                // ==================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(22),
                    gradient:
                    const LinearGradient(
                      colors: [
                        Color(0xFF6A5CFF),
                        Color(0xFF8C73FF),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      const Text(
                        "AI Recommended Career",
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        career.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [

                          const Icon(
                            Icons.verified,
                            color: Colors.white,
                          ),

                          const SizedBox(width: 8),

                          Text(
                            "$score% Match Score",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ==================================================
                // QUICK FEATURES
                // ==================================================

                const Text(
                  "Quick Features",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                GridView.count(
                  shrinkWrap: true,
                  physics:
                  const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.05,
                  children: [

                    // ==============================
                    // AI CHAT
                    // ==============================

                    FeatureCard(
                      icon: Icons.smart_toy,
                      title: "AI Chat",
                      color: Colors.deepPurple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const AIChatScreen(),
                          ),
                        );
                      },
                    ),

                    // ==============================
                    // ROADMAP
                    // ==============================

                    FeatureCard(
                      icon: Icons.route,
                      title: "Roadmap",
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const RoadmapScreen(),
                          ),
                        );
                      },
                    ),

                    // ==============================
                    // COLLEGES
                    // ==============================

                    FeatureCard(
                      icon: Icons.school,
                      title: "Colleges",
                      color: Colors.teal,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const CollegeScreen(),
                          ),
                        );
                      },
                    ),

                    // ==============================
                    // SCHOLARSHIP
                    // ==============================

                    FeatureCard(
                      icon: Icons.workspace_premium,
                      title: "Scholarship",
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const ScholarshipScreen(),
                          ),
                        );
                      },
                    ),

                    // ==============================
                    // ANALYTICS
                    // ==============================

                    FeatureCard(
                      icon: Icons.bar_chart,
                      title: "Analytics",
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const AnalyticsScreen(),
                          ),
                        );
                      },
                    ),

                    // ==============================
                    // RESUME
                    // ==============================

                    FeatureCard(
                      icon: Icons.description,
                      title: "Resume",
                      color: Colors.pink,
                      onTap: openResumeBuilder,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ==================================================
                // YOUR DETAILS
                // ==================================================

                const Text(
                  "Your Details",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF171F35),
                    borderRadius:
                    BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [

                      detailRow(
                        "Career",
                        career.toString(),
                      ),

                      const Divider(
                        color: Colors.white24,
                      ),

                      detailRow(
                        "Skill",
                        skill.toString(),
                      ),

                      const Divider(
                        color: Colors.white24,
                      ),

                      detailRow(
                        "Goal",
                        goal.toString(),
                      ),

                      const Divider(
                        color: Colors.white24,
                      ),

                      detailRow(
                        "Score",
                        "$score%",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),

        // ============================================================
        // BOTTOM NAVIGATION
        // ============================================================

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          type: BottomNavigationBarType.fixed,

          backgroundColor:
          const Color(0xFF131A2D),

          selectedItemColor:
          Colors.deepPurpleAccent,

          unselectedItemColor:
          Colors.white54,

          onTap: (index) {
            switch (index) {

            // ==========================
            // HOME
            // ==========================

              case 0:
                break;

            // ==========================
            // AI
            // ==========================

              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const AIChatScreen(),
                  ),
                );
                break;

            // ==========================
            // RESUME
            // ==========================

              case 2:
                openResumeBuilder();
                break;

            // ==========================
            // PROFILE
            // ==========================

              case 3:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const ProfileScreen(),
                  ),
                );
                break;
            }
          },

          items: const [

            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: "AI",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.description),
              label: "Resume",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
        ),
      );
    }

    // ============================================================
    // DETAIL ROW
    // ============================================================

    Widget detailRow(
        String title,
        String value,
        ) {
      return Row(
        children: [

          Text(
            title,
            style: const TextStyle(
              color: Colors.white60,
            ),
          ),

          const Spacer(),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    }
  }

  // ================================================================
  // FEATURE CARD
  // ================================================================

  class FeatureCard extends StatelessWidget {
    final IconData icon;
    final String title;
    final Color color;
    final VoidCallback onTap;

    const FeatureCard({
      super.key,
      required this.icon,
      required this.title,
      required this.color,
      required this.onTap,
    });

    @override
    Widget build(BuildContext context) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),

        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF171F35),
            borderRadius:
            BorderRadius.circular(18),
          ),

          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [

              CircleAvatar(
                radius: 26,
                backgroundColor:
                color.withOpacity(.15),

                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }