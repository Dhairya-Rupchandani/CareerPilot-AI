import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import 'resume_screen.dart';

class ResumePreviewScreen extends StatefulWidget {
  const ResumePreviewScreen({super.key});

  @override
  State<ResumePreviewScreen> createState() =>
      _ResumePreviewScreenState();
}

class _ResumePreviewScreenState
    extends State<ResumePreviewScreen> {
  Map<String, dynamic>? data;
  bool loading = true;

  // =========================================================
  // PROFESSIONAL SVG ICONS
  // =========================================================

  // Skills - professional tools icon
  final String skillsIcon = '''
<svg xmlns="http://www.w3.org/2000/svg"
     width="24"
     height="24"
     viewBox="0 0 24 24"
     fill="none"
     stroke="#24354D"
     stroke-width="1.8"
     stroke-linecap="round"
     stroke-linejoin="round">

  <path d="M14.7 6.3a5 5 0 0 0-6.4 6.4L3.5 17.5a2.12 2.12 0 0 0 3 3l4.8-4.8a5 5 0 0 0 6.4-6.4l-2.9 2.9-3-3 2.9-2.9z"/>

</svg>
''';

  // Languages - professional globe icon
  final String languagesIcon = '''
<svg xmlns="http://www.w3.org/2000/svg"
     width="24"
     height="24"
     viewBox="0 0 24 24"
     fill="none"
     stroke="#24354D"
     stroke-width="1.8"
     stroke-linecap="round"
     stroke-linejoin="round">

  <circle cx="12" cy="12" r="9"/>

  <line x1="3" y1="12" x2="21" y2="12"/>

  <path d="M12 3
           C9.5 5.5 8 8.5 8 12
           C8 15.5 9.5 18.5 12 21"/>

  <path d="M12 3
           C14.5 5.5 16 8.5 16 12
           C16 15.5 14.5 18.5 12 21"/>

</svg>
''';

  @override
  void initState() {
    super.initState();
    loadResume();
  }

  // =========================================================
  // LOAD RESUME
  // =========================================================

  Future<void> loadResume() async {
    try {
      final uid =
          FirebaseAuth.instance.currentUser!.uid;

      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("resume")
          .doc("details")
          .get();

      if (doc.exists) {
        data = doc.data();
      }

      if (!mounted) return;

      setState(() {
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
            "Could not load resume.",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================================================
  // GENERATE PDF
  // =========================================================

  Future<void> generatePDF() async {
    if (data == null) return;

    final pdf = pw.Document();

    // ---------------------------------------------------------
    // PROFILE IMAGE
    // ---------------------------------------------------------

    Uint8List? imageBytes;

    if (data!["photo"] != null &&
        data!["photo"] != "") {
      final file = File(
        data!["photo"],
      );

      if (await file.exists()) {
        imageBytes =
        await file.readAsBytes();
      }
    }

    final image = imageBytes != null
        ? pw.MemoryImage(imageBytes)
        : null;

    // ---------------------------------------------------------
    // SVG ICONS
    // ---------------------------------------------------------

    final skillsSvg =
    pw.SvgImage(
      svg: skillsIcon,
      width: 15,
      height: 15,
    );

    final languagesSvg =
    pw.SvgImage(
      svg: languagesIcon,
      width: 15,
      height: 15,
    );

    // ---------------------------------------------------------
    // CREATE PDF PAGE
    // ---------------------------------------------------------

    pdf.addPage(
      pw.Page(
        pageFormat:
        PdfPageFormat.a4,

        margin:
        pw.EdgeInsets.zero,

        build: (context) {
          return pw.Row(
            crossAxisAlignment:
            pw.CrossAxisAlignment
                .stretch,

            children: [

              // =================================================
              // LEFT SIDEBAR
              // =================================================

              pw.Container(
                width: 170,

                color:
                PdfColor.fromHex(
                  "#E9E9E9",
                ),

                padding:
                const pw.EdgeInsets.all(
                  18,
                ),

                child: pw.Column(
                  crossAxisAlignment:
                  pw.CrossAxisAlignment
                      .start,

                  children: [

                    // -------------------------------------------------
                    // PROFILE PHOTO
                    // -------------------------------------------------

                    pw.Center(
                      child: image != null
                          ? pw.Container(
                        width: 110,
                        height: 110,

                        decoration:
                        pw.BoxDecoration(
                          shape:
                          pw.BoxShape
                              .circle,

                          image:
                          pw.DecorationImage(
                            image: image,
                            fit: pw.BoxFit
                                .cover,
                          ),

                          border:
                          pw.Border.all(
                            color:
                            PdfColors
                                .white,
                            width: 3,
                          ),
                        ),
                      )
                          : pw.Container(
                        width: 110,
                        height: 110,

                        decoration:
                        const pw.BoxDecoration(
                          shape:
                          pw.BoxShape
                              .circle,

                          color:
                          PdfColors
                              .grey300,
                        ),

                        child:
                        pw.Center(
                          child:
                          pw.Text(
                            "PHOTO",

                            style:
                            const pw
                                .TextStyle(
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ),

                    pw.SizedBox(
                      height: 22,
                    ),

                    // -------------------------------------------------
                    // CONTACT
                    // -------------------------------------------------

                    sectionTitle(
                      "CONTACT",
                    ),

                    contactItem(
                      "Phone",
                      data!["phone"] ??
                          "",
                    ),

                    contactItem(
                      "Email",
                      data!["email"] ??
                          "",
                    ),

                    contactItem(
                      "College",
                      data!["college"] ??
                          "",
                    ),

                    pw.SizedBox(
                      height: 18,
                    ),

                    // -------------------------------------------------
                    // SKILLS
                    // -------------------------------------------------

                    sectionTitleWithSvgIcon(
                      icon: skillsSvg,
                      title: "SKILLS",
                    ),

                    bullet(
                      data!["skills"] ??
                          "",
                    ),

                    pw.SizedBox(
                      height: 18,
                    ),

                    // -------------------------------------------------
                    // LANGUAGES
                    // -------------------------------------------------

                    sectionTitleWithSvgIcon(
                      icon: languagesSvg,
                      title: "LANGUAGES",
                    ),

                    bullet(
                      data!["languages"] ??
                          "",
                    ),

                    pw.Spacer(),

                    // -------------------------------------------------
                    // FOOTER
                    // -------------------------------------------------

                    pw.Text(
                      "CareerPilot AI",

                      style:
                      pw.TextStyle(
                        fontWeight:
                        pw.FontWeight
                            .bold,

                        color:
                        PdfColors
                            .grey700,
                      ),
                    ),
                  ],
                ),
              ),

              // =================================================
              // RIGHT CONTENT
              // =================================================

              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment:
                  pw.CrossAxisAlignment
                      .start,

                  children: [

                    // -------------------------------------------------
                    // HEADER
                    // -------------------------------------------------

                    pw.Container(
                      width:
                      double.infinity,

                      color:
                      PdfColor.fromHex(
                        "#24354D",
                      ),

                      padding:
                      const pw.EdgeInsets.all(
                        24,
                      ),

                      child:
                      pw.Column(
                        crossAxisAlignment:
                        pw.CrossAxisAlignment
                            .start,

                        children: [

                          pw.Text(
                            (data!["name"] ??
                                "")
                                .toUpperCase(),

                            style:
                            pw.TextStyle(
                              color:
                              PdfColors
                                  .white,

                              fontSize: 24,

                              fontWeight:
                              pw.FontWeight
                                  .bold,
                            ),
                          ),

                          pw.SizedBox(
                            height: 4,
                          ),

                          pw.Text(
                            data!["career"] ??
                                "",

                            style:
                            const pw
                                .TextStyle(
                              color:
                              PdfColors
                                  .white,

                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // -------------------------------------------------
                    // MAIN CONTENT
                    // -------------------------------------------------

                    pw.Padding(
                      padding:
                      const pw.EdgeInsets
                          .all(20),

                      child:
                      pw.Column(
                        crossAxisAlignment:
                        pw.CrossAxisAlignment
                            .start,

                        children: [

                          // PROFILE
                          heading(
                            "PROFILE",
                          ),

                          pw.Text(
                            "Motivated student seeking "
                                "opportunities to build "
                                "practical skills in technology, "
                                "problem solving and software "
                                "development.",

                            style:
                            const pw
                                .TextStyle(
                              fontSize: 11,
                            ),
                          ),

                          pw.SizedBox(
                            height: 18,
                          ),

                          // EDUCATION
                          heading(
                            "EDUCATION",
                          ),

                          pw.Text(
                            data![
                            "education"] ??
                                "",

                            style:
                            pw.TextStyle(
                              fontWeight:
                              pw.FontWeight
                                  .bold,

                              fontSize: 13,
                            ),
                          ),

                          pw.Text(
                            data![
                            "college"] ??
                                "",

                            style:
                            const pw
                                .TextStyle(
                              fontSize: 11,
                            ),
                          ),

                          pw.SizedBox(
                            height: 18,
                          ),

                          // PROJECT
                          heading(
                            "PROJECT",
                          ),

                          pw.Text(
                            data![
                            "project"] ??
                                "",

                            style:
                            const pw
                                .TextStyle(
                              fontSize: 11,
                            ),
                          ),

                          pw.SizedBox(
                            height: 18,
                          ),

                          // TECHNICAL SKILLS
                          heading(
                            "TECHNICAL SKILLS",
                          ),

                          pw.Text(
                            data![
                            "skills"] ??
                                "",

                            style:
                            const pw
                                .TextStyle(
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // =========================================================
    // OPEN PDF
    // =========================================================

    await Printing.layoutPdf(
      onLayout: (format) async {
        return pdf.save();
      },
    );
  }

  // =========================================================
  // PDF SECTION TITLE
  // =========================================================

  pw.Widget sectionTitle(
      String text,
      ) {
    return pw.Padding(
      padding:
      const pw.EdgeInsets.only(
        bottom: 8,
      ),

      child: pw.Text(
        text,

        style:
        pw.TextStyle(
          fontWeight:
          pw.FontWeight.bold,

          fontSize: 14,
        ),
      ),
    );
  }

  // =========================================================
  // PDF SECTION TITLE WITH SVG ICON
  // =========================================================

  pw.Widget sectionTitleWithSvgIcon({
    required pw.Widget icon,
    required String title,
  }) {
    return pw.Padding(
      padding:
      const pw.EdgeInsets.only(
        bottom: 8,
      ),

      child: pw.Row(
        crossAxisAlignment:
        pw.CrossAxisAlignment
            .center,

        children: [

          // SVG ICON
          pw.Container(
            width: 18,
            height: 18,

            alignment:
            pw.Alignment.center,

            child: icon,
          ),

          pw.SizedBox(
            width: 7,
          ),

          // TITLE
          pw.Text(
            title,

            style:
            pw.TextStyle(
              fontWeight:
              pw.FontWeight
                  .bold,

              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // PDF HEADING
  // =========================================================

  pw.Widget heading(
      String text,
      ) {
    return pw.Column(
      crossAxisAlignment:
      pw.CrossAxisAlignment
          .start,

      children: [

        pw.Text(
          text,

          style:
          pw.TextStyle(
            fontWeight:
            pw.FontWeight
                .bold,

            fontSize: 15,
          ),
        ),

        pw.Divider(),
      ],
    );
  }

  // =========================================================
  // PDF CONTACT ITEM
  // =========================================================

  pw.Widget contactItem(
      String title,
      String value,
      ) {
    return pw.Padding(
      padding:
      const pw.EdgeInsets.only(
        bottom: 6,
      ),

      child: pw.Text(
        "$title\n$value",

        style:
        const pw.TextStyle(
          fontSize: 10,
        ),
      ),
    );
  }

  // =========================================================
  // PDF BULLET
  // =========================================================

  pw.Widget bullet(
      String text,
      ) {
    return pw.Row(
      crossAxisAlignment:
      pw.CrossAxisAlignment
          .start,

      children: [

        pw.Text(
          "• ",

          style:
          const pw.TextStyle(
            fontSize: 10,
          ),
        ),

        pw.Expanded(
          child: pw.Text(
            text,

            style:
            const pw.TextStyle(
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // FLUTTER PREVIEW INFO
  // =========================================================

  Widget info(
      String title,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 10,
      ),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment
            .start,

        children: [

          Text(
            "$title : ",

            style:
            const TextStyle(
              fontWeight:
              FontWeight.bold,
            ),
          ),

          Expanded(
            child:
            Text(value),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      const Color(0xFF0B1020),

      // -------------------------------------------------------
      // APP BAR
      // -------------------------------------------------------

      appBar: AppBar(
        backgroundColor:
        Colors.transparent,

        elevation: 0,

        title:
        const Text(
          "Resume Preview",
        ),
      ),

      // -------------------------------------------------------
      // BODY
      // -------------------------------------------------------

      body: loading

          ? const Center(
        child:
        CircularProgressIndicator(),
      )

          : data == null

          ? const Center(
        child: Text(
          "Resume not found",

          style:
          TextStyle(
            color:
            Colors.white,
          ),
        ),
      )

          : SingleChildScrollView(
        padding:
        const EdgeInsets.all(
          16,
        ),

        child:
        Column(
          children: [

            // =================================================
            // RESUME PREVIEW CARD
            // =================================================

            Container(
              width:
              double.infinity,

              decoration:
              BoxDecoration(
                color:
                Colors.white,

                borderRadius:
                BorderRadius
                    .circular(
                  18,
                ),
              ),

              child:
              Column(
                children: [

                  // -------------------------------------------------
                  // HEADER
                  // -------------------------------------------------

                  Container(
                    width:
                    double.infinity,

                    padding:
                    const EdgeInsets
                        .all(20),

                    decoration:
                    const BoxDecoration(
                      color:
                      Color(
                        0xFF24354D,
                      ),

                      borderRadius:
                      BorderRadius
                          .only(
                        topLeft:
                        Radius
                            .circular(
                          18,
                        ),

                        topRight:
                        Radius
                            .circular(
                          18,
                        ),
                      ),
                    ),

                    child:
                    Row(
                      children: [

                        CircleAvatar(
                          radius: 38,

                          backgroundColor:
                          Colors
                              .white,

                          backgroundImage:
                          data![
                          "photo"] !=
                              null &&
                              data![
                              "photo"] !=
                                  ""
                              ? FileImage(
                            File(
                              data![
                              "photo"],
                            ),
                          )
                              : null,

                          child:
                          data![
                          "photo"] ==
                              null ||
                              data![
                              "photo"] ==
                                  ""
                              ? const Icon(
                            Icons
                                .person,
                            size:
                            35,
                          )
                              : null,
                        ),

                        const SizedBox(
                          width: 15,
                        ),

                        Expanded(
                          child:
                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                            children: [

                              Text(
                                data![
                                "name"] ??
                                    "",

                                style:
                                const TextStyle(
                                  color:
                                  Colors
                                      .white,

                                  fontSize:
                                  22,

                                  fontWeight:
                                  FontWeight
                                      .bold,
                                ),
                              ),

                              Text(
                                data![
                                "career"] ??
                                    "",

                                style:
                                const TextStyle(
                                  color:
                                  Colors
                                      .white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // -------------------------------------------------
                  // DETAILS
                  // -------------------------------------------------

                  Padding(
                    padding:
                    const EdgeInsets
                        .all(18),

                    child:
                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [

                        const Text(
                          "CONTACT",

                          style:
                          TextStyle(
                            fontSize:
                            17,

                            fontWeight:
                            FontWeight
                                .bold,
                          ),
                        ),

                        const Divider(),

                        info(
                          "Phone",
                          data![
                          "phone"] ??
                              "",
                        ),

                        info(
                          "Email",
                          data![
                          "email"] ??
                              "",
                        ),

                        info(
                          "College",
                          data![
                          "college"] ??
                              "",
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        const Text(
                          "EDUCATION",

                          style:
                          TextStyle(
                            fontSize:
                            17,

                            fontWeight:
                            FontWeight
                                .bold,
                          ),
                        ),

                        const Divider(),

                        Text(
                          data![
                          "education"] ??
                              "",
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        const Text(
                          "SKILLS",

                          style:
                          TextStyle(
                            fontSize:
                            17,

                            fontWeight:
                            FontWeight
                                .bold,
                          ),
                        ),

                        const Divider(),

                        Text(
                          data![
                          "skills"] ??
                              "",
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        const Text(
                          "PROJECT",

                          style:
                          TextStyle(
                            fontSize:
                            17,

                            fontWeight:
                            FontWeight
                                .bold,
                          ),
                        ),

                        const Divider(),

                        Text(
                          data![
                          "project"] ??
                              "",
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        const Text(
                          "LANGUAGES",

                          style:
                          TextStyle(
                            fontSize:
                            17,

                            fontWeight:
                            FontWeight
                                .bold,
                          ),
                        ),

                        const Divider(),

                        Text(
                          data![
                          "languages"] ??
                              "",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // =================================================
            // EDIT BUTTON
            // =================================================

            SizedBox(
              width:
              double.infinity,

              height: 55,

              child:
              ElevatedButton.icon(
                style:
                ElevatedButton
                    .styleFrom(
                  backgroundColor:
                  Colors.orange,
                ),

                icon:
                const Icon(
                  Icons.edit,
                ),

                label:
                const Text(
                  "Edit Resume",
                ),

                onPressed:
                    () async {
                  await Navigator
                      .push(
                    context,

                    MaterialPageRoute(
                      builder: (_) =>
                      const ResumeScreen(),
                    ),
                  );

                  loadResume();
                },
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // =================================================
            // DOWNLOAD PDF BUTTON
            // =================================================

            SizedBox(
              width:
              double.infinity,

              height: 55,

              child:
              ElevatedButton.icon(
                style:
                ElevatedButton
                    .styleFrom(
                  backgroundColor:
                  Colors
                      .deepPurple,
                ),

                icon:
                const Icon(
                  Icons
                      .picture_as_pdf,
                ),

                label:
                const Text(
                  "Download PDF",
                ),

                onPressed:
                generatePDF,
              ),
            ),

            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}