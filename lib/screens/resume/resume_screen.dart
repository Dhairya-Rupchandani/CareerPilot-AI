import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class ResumeScreen extends StatefulWidget {
  const ResumeScreen({super.key});

  @override
  State<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen> {
  final _formKey = GlobalKey<FormState>();

  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final college = TextEditingController();
  final education = TextEditingController();
  final skills = TextEditingController();
  final project = TextEditingController();
  final languages = TextEditingController();
  final career = TextEditingController();

  bool loading = false;

  File? profileImage;
  String? imagePath;

  final picker = ImagePicker();

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();

    loadResume();

    name.addListener(() => setState(() {}));
    phone.addListener(() => setState(() {}));
    email.addListener(() => setState(() {}));
    college.addListener(() => setState(() {}));
    education.addListener(() => setState(() {}));
    skills.addListener(() => setState(() {}));
    project.addListener(() => setState(() {}));
    languages.addListener(() => setState(() {}));
    career.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    email.dispose();
    college.dispose();
    education.dispose();
    skills.dispose();
    project.dispose();
    languages.dispose();
    career.dispose();

    super.dispose();
  }

  bool get isValid {
    return name.text.trim().isNotEmpty &&
        phone.text.length == 10 &&
        email.text.trim().endsWith("@gmail.com") &&
        college.text.trim().isNotEmpty &&
        education.text.trim().isNotEmpty &&
        skills.text.trim().isNotEmpty &&
        project.text.trim().isNotEmpty &&
        languages.text.trim().isNotEmpty &&
        career.text.trim().isNotEmpty;
  }

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        profileImage = File(image.path);
        imagePath = image.path;
      });
    }
  }

  Future<void> loadResume() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("resume")
          .doc("details")
          .get();

      if (!doc.exists) return;

      final d = doc.data()!;

      name.text = d["name"] ?? "";
      phone.text = d["phone"] ?? "";
      email.text = d["email"] ?? "";
      college.text = d["college"] ?? "";
      education.text = d["education"] ?? "";
      skills.text = d["skills"] ?? "";
      project.text = d["project"] ?? "";
      languages.text = d["languages"] ?? "";
      career.text = d["career"] ?? "";

      if (d["photo"] != null && d["photo"] != "") {
        imagePath = d["photo"];

        final file = File(imagePath!);

        if (await file.exists()) {
          profileImage = file;
        }
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not load saved resume."),
        ),
      );
    }
  }

  Future<void> saveResume() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload profile photo"),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;

      // ---------------------------------------------------------
      // 1. SAVE RESUME DETAILS
      // ---------------------------------------------------------
      await firestore
          .collection("users")
          .doc(uid)
          .collection("resume")
          .doc("details")
          .set({
        "name": name.text.trim(),
        "phone": phone.text.trim(),
        "email": email.text.trim(),
        "college": college.text.trim(),
        "education": education.text.trim(),
        "career": career.text.trim(),
        "skills": skills.text.trim(),
        "project": project.text.trim(),
        "languages": languages.text.trim(),
        "photo": imagePath,
        "updatedAt": FieldValue.serverTimestamp(),
      });

      // ---------------------------------------------------------
      // 2. UPDATE ANALYTICS
      // ---------------------------------------------------------
      await firestore
          .collection("analytics")
          .doc(uid)
          .set({
        "resumeCompletion": 100,
      }, SetOptions(merge: true));

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Resume saved successfully! Completion: 100%",
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Go back after saving.
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to save resume: $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget textField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboard = TextInputType.text,
    List<TextInputFormatter>? formatter,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        inputFormatters: formatter,
        validator: validator,
        maxLines: maxLines,
        style: const TextStyle(
          color: Colors.white,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.white70,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.deepPurpleAccent,
          ),
          filled: true,
          fillColor: const Color(0xFF171F35),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
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
        title: const Text("Resume Builder"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),

        child: Form(
          key: _formKey,

          child: Column(
            children: [
              // -------------------------------------------------
              // PROFILE PHOTO
              // -------------------------------------------------
              GestureDetector(
                onTap: pickImage,

                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.deepPurple,

                  backgroundImage: profileImage != null
                      ? FileImage(profileImage!)
                      : null,

                  child: profileImage == null
                      ? const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 35,
                  )
                      : null,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Tap to Upload Photo",
                style: TextStyle(
                  color: Colors.white60,
                ),
              ),

              const SizedBox(height: 20),

              // -------------------------------------------------
              // NAME
              // -------------------------------------------------
              textField(
                label: "Full Name",
                icon: Icons.person,
                controller: name,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Enter your name";
                  }

                  return null;
                },
              ),

              // -------------------------------------------------
              // CAREER
              // -------------------------------------------------
              textField(
                label: "Career Title",
                icon: Icons.work,
                controller: career,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Enter career title";
                  }

                  return null;
                },
              ),

              // -------------------------------------------------
              // PHONE
              // -------------------------------------------------
              textField(
                label: "Phone Number",
                icon: Icons.phone,
                controller: phone,
                keyboard: TextInputType.number,
                formatter: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (v) {
                  if (v == null || v.length != 10) {
                    return "Enter valid 10 digit phone";
                  }

                  return null;
                },
              ),

              // -------------------------------------------------
              // EMAIL
              // -------------------------------------------------
              textField(
                label: "Gmail Address",
                icon: Icons.email,
                controller: email,
                keyboard: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Enter Gmail";
                  }

                  if (!v.trim().endsWith("@gmail.com")) {
                    return "Only @gmail.com accepted";
                  }

                  return null;
                },
              ),

              // -------------------------------------------------
              // COLLEGE
              // -------------------------------------------------
              textField(
                label: "College",
                icon: Icons.school,
                controller: college,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Enter college";
                  }

                  return null;
                },
              ),

              // -------------------------------------------------
              // EDUCATION
              // -------------------------------------------------
              textField(
                label: "Education",
                icon: Icons.menu_book,
                controller: education,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Enter education";
                  }

                  return null;
                },
              ),

              // -------------------------------------------------
              // SKILLS
              // -------------------------------------------------
              textField(
                label: "Skills",
                icon: Icons.build,
                controller: skills,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Enter skills";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              // -------------------------------------------------
              // PROJECT
              // -------------------------------------------------
              textField(
                label: "Projects",
                icon: Icons.code,
                controller: project,
                maxLines: 2,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Enter project";
                  }

                  return null;
                },
              ),

              // -------------------------------------------------
              // LANGUAGES
              // -------------------------------------------------
              textField(
                label: "Languages",
                icon: Icons.language,
                controller: languages,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Enter languages";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              // -------------------------------------------------
              // SAVE BUTTON
              // -------------------------------------------------
              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton.icon(
                  onPressed: isValid && !loading
                      ? saveResume
                      : null,

                  icon: loading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.save),

                  label: Text(
                    loading
                        ? "Saving..."
                        : "Update Resume",
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    Colors.deepPurpleAccent,

                    disabledBackgroundColor:
                    Colors.grey.shade700,

                    foregroundColor: Colors.white,

                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}