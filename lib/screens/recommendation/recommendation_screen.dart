import 'package:flutter/material.dart';
import '../home/home_screen.dart';

class RecommendationScreen extends StatelessWidget {
  final String interest;
  final String skill;
  final String education;
  final String goal;

  const RecommendationScreen({
    super.key,
    required this.interest,
    required this.skill,
    required this.education,
    required this.goal,
  });

  Map<String, dynamic> getCareer() {
    // AI Rule Engine
    if (interest == "Technology" && skill == "Coding") {
      return {
        "career": "AI Engineer",
        "confidence": "96%",
        "salary": "₹8 – 20 LPA",
        "icon": Icons.psychology,
        "color": Colors.deepPurpleAccent,
        "description":
        "You enjoy technology and coding. AI Engineering is one of the strongest matches for your profile.",
        "skills": [
          "Python",
          "Machine Learning",
          "Flutter",
          "Data Structures"
        ]
      };
    }

    if (interest == "Technology" && skill == "Mathematics") {
      return {
        "career": "Data Scientist",
        "confidence": "94%",
        "salary": "₹7 – 18 LPA",
        "icon": Icons.analytics,
        "color": Colors.blue,
        "description":
        "Your mathematical thinking makes you suitable for data analysis and AI.",
        "skills": [
          "Python",
          "Statistics",
          "SQL",
          "Visualization"
        ]
      };
    }

    if (interest == "Design") {
      return {
        "career": "UI / UX Designer",
        "confidence": "92%",
        "salary": "₹5 – 12 LPA",
        "icon": Icons.palette,
        "color": Colors.pink,
        "description":
        "Your creativity makes designing beautiful digital products a great career choice.",
        "skills": ["Figma", "UI Design", "UX Research", "Prototyping"]
      };
    }

    if (interest == "Business") {
      return {
        "career": "Business Analyst",
        "confidence": "90%",
        "salary": "₹6 – 15 LPA",
        "icon": Icons.business_center,
        "color": Colors.orange,
        "description":
        "You communicate well and enjoy business thinking. Business Analysis is a strong option.",
        "skills": ["Excel", "Power BI", "SQL", "Communication"]
      };
    }

    return {
      "career": "Software Engineer",
      "confidence": "91%",
      "salary": "₹6 – 16 LPA",
      "icon": Icons.code,
      "color": Colors.green,
      "description":
      "A balanced technical profile makes Software Engineering a great starting career.",
      "skills": ["Flutter", "Java", "Git", "Firebase"]
    };
  }

  @override
  Widget build(BuildContext context) {
    final result = getCareer();

    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("AI Recommendation"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const SizedBox(height: 10),

            CircleAvatar(
              radius: 45,
              backgroundColor: (result["color"] as Color).withOpacity(.15),
              child: Icon(
                result["icon"] as IconData,
                size: 50,
                color: result["color"] as Color,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              "Best Career Match",
              style: TextStyle(
                color: Colors.white60,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              result["career"],
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF171F35),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  const Text(
                    "AI Confidence",
                    style: TextStyle(color: Colors.white60),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result["confidence"],
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Expected Salary",
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        result["salary"],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF171F35),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Why this career?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    result["description"],
                    style: const TextStyle(
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF171F35),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Recommended Skills",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...(result["skills"] as List<String>).map(
                        (skill) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.greenAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            skill,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HomeScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Continue to Dashboard",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}