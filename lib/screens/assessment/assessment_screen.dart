import '../recommendation/recommendation_screen.dart';
import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../home/home_screen.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final PageController _controller = PageController();

  int page = 0;

  String? interest;
  String? skill;
  String? education;
  String? goal;

  final List<String> interests = [
    "Technology",
    "Business",
    "Healthcare",
    "Design",
    "Science",
    "Arts",
  ];

  final List<String> skills = [
    "Coding",
    "Communication",
    "Creativity",
    "Leadership",
    "Mathematics",
    "Problem Solving",
  ];

  final List<String> educations = [
    "10th",
    "12th",
    "Diploma",
    "Undergraduate",
  ];

  final List<String> goals = [
    "High Salary",
    "Government Job",
    "Higher Studies",
    "Entrepreneurship",
  ];

  bool get canContinue {
    switch (page) {
      case 0:
        return interest != null;
      case 1:
        return skill != null;
      case 2:
        return education != null;
      case 3:
        return goal != null;
      default:
        return false;
    }
  }

  Future<void> next() async {
    if (page < 3) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      return;
    }

    try {
      await FirestoreService().saveAssessment(
        interest: interest!,
        skill: skill!,
        education: education!,
        goal: goal!,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RecommendationScreen(
            interest: interest!,
            skill: skill!,
            education: education!,
            goal: goal!,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget optionCard({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected
              ? Colors.deepPurpleAccent
              : const Color(0xFF171F35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? Colors.deepPurpleAccent
                : Colors.white12,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.check_circle
                  : Icons.circle_outlined,
              color: Colors.white,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget questionPage({
    required String title,
    required String subtitle,
    required List<String> items,
    required String? selected,
    required Function(String) onSelect,
  }) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 28),
          Expanded(
            child: ListView(
              children: items
                  .map(
                    (e) => optionCard(
                  title: e,
                  selected: selected == e,
                  onTap: () {
                    setState(() {
                      onSelect(e);
                    });
                  },
                ),
              )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text("AI Career Assessment"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      "Question ${page + 1} of 4",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const Spacer(),
                    Text(
                      "${(page + 1) * 25}%",
                      style: const TextStyle(
                        color: Colors.deepPurpleAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (page + 1) / 4,
                  minHeight: 8,
                  backgroundColor: Colors.white12,
                  color: Colors.deepPurpleAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          Expanded(
            child: PageView(
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() => page = index);
              },
              children: [
                questionPage(
                  title: "What interests you most?",
                  subtitle: "Choose one field",
                  items: interests,
                  selected: interest,
                  onSelect: (v) => interest = v,
                ),
                questionPage(
                  title: "What is your strongest skill?",
                  subtitle: "Choose one skill",
                  items: skills,
                  selected: skill,
                  onSelect: (v) => skill = v,
                ),
                questionPage(
                  title: "What is your education level?",
                  subtitle: "Current qualification",
                  items: educations,
                  selected: education,
                  onSelect: (v) => education = v,
                ),
                questionPage(
                  title: "What is your career goal?",
                  subtitle: "Choose your priority",
                  items: goals,
                  selected: goal,
                  onSelect: (v) => goal = v,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: canContinue ? next : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  disabledBackgroundColor: Colors.white12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  page == 3
                      ? "Finish Assessment"
                      : "Continue",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}