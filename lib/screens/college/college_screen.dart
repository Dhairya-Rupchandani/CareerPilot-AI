import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CollegeScreen extends StatefulWidget {
  const CollegeScreen({super.key});

  @override
  State<CollegeScreen> createState() => _CollegeScreenState();
}

class _CollegeScreenState extends State<CollegeScreen> {
  String career = "";
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadCareer();
  }

  Future<void> loadCareer() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() {
          loading = false;
        });
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();

        setState(() {
          career = data?["career"] ?? "";
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  List<Map<String, String>> getRecommendedColleges() {
    final normalizedCareer = career.toLowerCase();

    // Software Developer / Computer / IT
    if (normalizedCareer.contains("software") ||
        normalizedCareer.contains("computer") ||
        normalizedCareer.contains("developer") ||
        normalizedCareer.contains("technology")) {
      return [
        {
          "name": "L.D. College of Engineering",
          "course": "Computer Engineering",
          "city": "Ahmedabad",
          "rating": "4.8",
          "query": "L.D. College of Engineering Ahmedabad Gujarat",
        },
        {
          "name": "Vishwakarma Government Engineering College",
          "course": "Information Technology / Computer Engineering",
          "city": "Ahmedabad",
          "rating": "4.7",
          "query":
          "Vishwakarma Government Engineering College Ahmedabad Gujarat",
        },
        {
          "name": "Government Engineering College",
          "course": "Computer Engineering",
          "city": "Gandhinagar",
          "rating": "4.5",
          "query": "Government Engineering College Gandhinagar Gujarat",
        },
        {
          "name": "Nirma University",
          "course": "Computer Science and Engineering",
          "city": "Ahmedabad",
          "rating": "4.6",
          "query": "Nirma University Ahmedabad Gujarat",
        },
      ];
    }

    // AI Engineer
    if (normalizedCareer.contains("ai") ||
        normalizedCareer.contains("artificial intelligence") ||
        normalizedCareer.contains("machine learning")) {
      return [
        {
          "name": "Nirma University",
          "course": "Computer Science / AI related programs",
          "city": "Ahmedabad",
          "rating": "4.6",
          "query": "Nirma University Ahmedabad Gujarat",
        },
        {
          "name": "L.D. College of Engineering",
          "course": "Computer Engineering / AI related studies",
          "city": "Ahmedabad",
          "rating": "4.8",
          "query": "L.D. College of Engineering Ahmedabad Gujarat",
        },
        {
          "name": "Vishwakarma Government Engineering College",
          "course": "Computer Engineering / IT",
          "city": "Ahmedabad",
          "rating": "4.7",
          "query":
          "Vishwakarma Government Engineering College Ahmedabad Gujarat",
        },
      ];
    }

    // UI/UX Designer
    if (normalizedCareer.contains("ui") ||
        normalizedCareer.contains("ux") ||
        normalizedCareer.contains("design")) {
      return [
        {
          "name": "CEPT University",
          "course": "Design related programs",
          "city": "Ahmedabad",
          "rating": "4.6",
          "query": "CEPT University Ahmedabad Gujarat",
        },
        {
          "name": "National Institute of Design",
          "course": "Design",
          "city": "Ahmedabad",
          "rating": "4.7",
          "query": "National Institute of Design Ahmedabad Gujarat",
        },
      ];
    }

    // Business Analyst
    if (normalizedCareer.contains("business") ||
        normalizedCareer.contains("analyst")) {
      return [
        {
          "name": "Nirma University",
          "course": "Management / Business related programs",
          "city": "Ahmedabad",
          "rating": "4.6",
          "query": "Nirma University Ahmedabad Gujarat",
        },
        {
          "name": "Gujarat University",
          "course": "Business / Management related programs",
          "city": "Ahmedabad",
          "rating": "4.4",
          "query": "Gujarat University Ahmedabad Gujarat",
        },
      ];
    }

    // Data Scientist
    if (normalizedCareer.contains("data scientist") ||
        normalizedCareer.contains("data")) {
      return [
        {
          "name": "Nirma University",
          "course": "Computer Science / Data related programs",
          "city": "Ahmedabad",
          "rating": "4.6",
          "query": "Nirma University Ahmedabad Gujarat",
        },
        {
          "name": "Dhirubhai Ambani Institute of Information and Communication Technology",
          "course": "Information Technology / Data related studies",
          "city": "Gandhinagar",
          "rating": "4.7",
          "query":
          "Dhirubhai Ambani Institute of Information and Communication Technology Gandhinagar Gujarat",
        },
      ];
    }

    // Healthcare
    if (normalizedCareer.contains("health") ||
        normalizedCareer.contains("medical")) {
      return [
        {
          "name": "B.J. Medical College",
          "course": "Medical",
          "city": "Ahmedabad",
          "rating": "4.5",
          "query": "B.J. Medical College Ahmedabad Gujarat",
        },
      ];
    }

    // Default recommendations
    return [
      {
        "name": "L.D. College of Engineering",
        "course": "Engineering",
        "city": "Ahmedabad",
        "rating": "4.8",
        "query": "L.D. College of Engineering Ahmedabad Gujarat",
      },
      {
        "name": "Vishwakarma Government Engineering College",
        "course": "Engineering / IT",
        "city": "Ahmedabad",
        "rating": "4.7",
        "query":
        "Vishwakarma Government Engineering College Ahmedabad Gujarat",
      },
      {
        "name": "Nirma University",
        "course": "Engineering / Technology",
        "city": "Ahmedabad",
        "rating": "4.6",
        "query": "Nirma University Ahmedabad Gujarat",
      },
    ];
  }

  Future<void> openGoogleMaps(String query) async {
    final encodedQuery = Uri.encodeComponent(query);

    final Uri mapsUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$encodedQuery",
    );

    try {
      final launched = await launchUrl(
        mapsUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Could not open Google Maps."),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not open Google Maps."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colleges = getRecommendedColleges();

    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      appBar: AppBar(
        title: const Text("Recommended Colleges"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: loading
          ? const Center(
        child: CircularProgressIndicator(
          color: Colors.deepPurpleAccent,
        ),
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (career.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF171F35),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Colors.deepPurpleAccent,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Based on your career recommendation",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            career,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              itemCount: colleges.length,
              itemBuilder: (context, index) {
                final college = colleges[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF171F35),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        college["name"]!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.school,
                            color: Colors.deepPurpleAccent,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              college["course"]!,
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.redAccent,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            college["city"]!,
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 18,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            college["rating"]!,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                openGoogleMaps(
                                  college["query"]!,
                                );
                              },
                              icon: const Icon(
                                Icons.location_on,
                                size: 18,
                              ),
                              label: const Text("Open Location"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                Colors.deepPurpleAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}