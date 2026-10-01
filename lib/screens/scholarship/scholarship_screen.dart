import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ScholarshipScreen extends StatefulWidget {
  const ScholarshipScreen({super.key});

  @override
  State<ScholarshipScreen> createState() => _ScholarshipScreenState();
}

class _ScholarshipScreenState extends State<ScholarshipScreen> {
  final TextEditingController searchController = TextEditingController();

  String education = "";
  String career = "";
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadStudentData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadStudentData() async {
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
          education = (data?["education"] ?? "").toString();
          career = (data?["career"] ?? "").toString();
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

  List<Map<String, String>> getRecommendedScholarships() {
    final List<Map<String, String>> result = [];

    final educationLower = education.toLowerCase();
    final careerLower = career.toLowerCase();

    final isDiploma =
        educationLower.contains("diploma") ||
            educationLower.contains("polytechnic");

    final isDegree =
        educationLower.contains("degree") ||
            educationLower.contains("engineering") ||
            educationLower.contains("bachelor");

    // ---------------------------------------------------------
    // AICTE SWANATH
    // ---------------------------------------------------------
    if (isDiploma) {
      result.add({
        "title": "AICTE - Swanath Scholarship Scheme",
        "type": "Technical Diploma",
        "provider": "AICTE",
        "eligibility":
        "For eligible students pursuing technical diploma programmes.",
        "deadline": "31 Oct 2026",
        "website":
        "https://scholarships.gov.in/All-Scholarships",
        "reason": "Matches your diploma/technical education",
      });
    } else if (isDegree) {
      result.add({
        "title": "AICTE - Swanath Scholarship Scheme",
        "type": "Technical Degree",
        "provider": "AICTE",
        "eligibility":
        "For eligible students pursuing technical degree programmes.",
        "deadline": "31 Oct 2026",
        "website":
        "https://scholarships.gov.in/All-Scholarships",
        "reason": "Matches your technical degree education",
      });
    }

    // ---------------------------------------------------------
    // AICTE PRAGATI
    // ---------------------------------------------------------
    // Eligibility includes girl students, so this is shown as
    // an opportunity to check rather than claiming the student
    // is automatically eligible.
    if (isDiploma) {
      result.add({
        "title": "AICTE - Pragati Scholarship Scheme",
        "type": "Technical Diploma",
        "provider": "AICTE",
        "eligibility":
        "For eligible girl students pursuing technical diploma programmes.",
        "deadline": "31 Oct 2026",
        "website":
        "https://scholarships.gov.in/All-Scholarships",
        "reason": "Relevant to technical diploma students",
      });
    } else if (isDegree) {
      result.add({
        "title": "AICTE - Pragati Scholarship Scheme",
        "type": "Technical Degree",
        "provider": "AICTE",
        "eligibility":
        "For eligible girl students pursuing technical degree programmes.",
        "deadline": "31 Oct 2026",
        "website":
        "https://scholarships.gov.in/All-Scholarships",
        "reason": "Relevant to technical degree students",
      });
    }

    // ---------------------------------------------------------
    // AICTE SAKSHAM
    // ---------------------------------------------------------
    if (isDiploma) {
      result.add({
        "title": "AICTE - Saksham Scholarship Scheme",
        "type": "Technical Diploma",
        "provider": "AICTE",
        "eligibility":
        "For eligible specially abled students pursuing technical diploma programmes.",
        "deadline": "31 Oct 2026",
        "website":
        "https://scholarships.gov.in/All-Scholarships",
        "reason": "Relevant to technical diploma students",
      });
    } else if (isDegree) {
      result.add({
        "title": "AICTE - Saksham Scholarship Scheme",
        "type": "Technical Degree",
        "provider": "AICTE",
        "eligibility":
        "For eligible specially abled students pursuing technical degree programmes.",
        "deadline": "31 Oct 2026",
        "website":
        "https://scholarships.gov.in/All-Scholarships",
        "reason": "Relevant to technical degree students",
      });
    }

    // ---------------------------------------------------------
    // RELIANCE FOUNDATION
    // ---------------------------------------------------------
    // This is relevant mainly when the student is in first year
    // of an undergraduate degree. Exact eligibility must be
    // checked on the official website.
    if (isDegree) {
      result.add({
        "title": "Reliance Foundation Undergraduate Scholarship",
        "type": "Undergraduate",
        "provider": "Reliance Foundation",
        "eligibility":
        "For eligible first-year regular full-time undergraduate students.",
        "deadline": "Check official website",
        "website":
        "https://www.scholarships.reliancefoundation.org/UG_Scholarship",
        "reason": "Relevant to undergraduate degree students",
      });
    }

    // ---------------------------------------------------------
    // MYSY - GUJARAT
    // ---------------------------------------------------------
    result.add({
      "title": "MYSY Scholarship",
      "type": "Gujarat Government",
      "provider": "Government of Gujarat",
      "eligibility":
      "Eligibility depends on the applicable Gujarat MYSY criteria.",
      "deadline": "Check official website",
      "website": "https://mysy.gujarat.gov.in/",
      "reason": "Gujarat-based scholarship opportunity",
    });

    // ---------------------------------------------------------
    // PM-USP CSSS
    // ---------------------------------------------------------
    if (isDegree) {
      result.add({
        "title":
        "PM-USP Central Sector Scheme of Scholarship for College and University Students",
        "type": "Merit Based",
        "provider": "Government of India",
        "eligibility":
        "For eligible college and university students meeting the scheme criteria.",
        "deadline": "31 Oct 2026",
        "website":
        "https://scholarships.gov.in/All-Scholarships",
        "reason": "Relevant to college/university students",
      });
    }

    return result;
  }

  Future<void> openWebsite(String website) async {
    final Uri url = Uri.parse(website);

    try {
      final bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Could not open the scholarship website."),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not open the scholarship website."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allScholarships = getRecommendedScholarships();

    final query = searchController.text.toLowerCase().trim();

    final filteredScholarships = allScholarships.where((s) {
      return s["title"]!.toLowerCase().contains(query) ||
          s["provider"]!.toLowerCase().contains(query) ||
          s["type"]!.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Scholarship Finder"),
        centerTitle: true,
      ),

      body: loading
          ? const Center(
        child: CircularProgressIndicator(
          color: Colors.deepPurpleAccent,
        ),
      )
          : Column(
        children: [
          // -------------------------------------------------
          // RECOMMENDATION HEADER
          // -------------------------------------------------
          if (career.isNotEmpty || education.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF171F35),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Colors.deepPurpleAccent,
                      size: 28,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Scholarships for You",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          if (career.isNotEmpty)
                            Text(
                              "Career: $career",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),

                          if (education.isNotEmpty)
                            Text(
                              "Education: $education",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // -------------------------------------------------
          // SEARCH
          // -------------------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: searchController,
              onChanged: (_) {
                setState(() {});
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search Scholarship...",
                hintStyle:
                const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.white70,
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  onPressed: () {
                    searchController.clear();
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.clear,
                    color: Colors.white70,
                  ),
                )
                    : null,
                filled: true,
                fillColor: const Color(0xFF171F35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // -------------------------------------------------
          // SCHOLARSHIP LIST
          // -------------------------------------------------
          Expanded(
            child: filteredScholarships.isEmpty
                ? const Center(
              child: Text(
                "No scholarships found.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                20,
              ),
              itemCount: filteredScholarships.length,
              itemBuilder: (context, index) {
                final s = filteredScholarships[index];

                return Container(
                  margin:
                  const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF171F35),
                    borderRadius:
                    BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      // TITLE
                      Text(
                        s["title"]!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // MATCH REASON
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent
                              .withValues(alpha: 0.15),
                          borderRadius:
                          BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Recommended: ${s["reason"]}",
                          style: const TextStyle(
                            color:
                            Colors.deepPurpleAccent,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // PROVIDER
                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.account_balance,
                            color:
                            Colors.deepPurpleAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              s["provider"]!,
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // TYPE
                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.school,
                            color: Colors.blueAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              s["type"]!,
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // ELIGIBILITY
                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.people,
                            color: Colors.orangeAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              s["eligibility"]!,
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // DEADLINE
                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.redAccent,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Application deadline: ${s["deadline"]}",
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // VISIT WEBSITE
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            openWebsite(
                              s["website"]!,
                            );
                          },
                          icon: const Icon(
                            Icons.open_in_new,
                            size: 18,
                          ),
                          label: const Text(
                            "Visit Official Website",
                          ),
                          style:
                          ElevatedButton.styleFrom(
                            backgroundColor:
                            Colors.deepPurpleAccent,
                            foregroundColor: Colors.white,
                            padding:
                            const EdgeInsets.symmetric(
                              vertical: 13,
                            ),
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                        ),
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