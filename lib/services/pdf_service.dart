import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/note.dart';

class PdfService {
  PdfService._();

  static Future<void> exportNotes(List<Note> notes) async {
    final pdf = pw.Document();

    final now = DateTime.now();

    final totalFavorites =
        notes.where((e) => e.isFavorite).length;

    final totalPinned =
        notes.where((e) => e.isPinned).length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,

        margin: const pw.EdgeInsets.all(24),

        footer: (context) {
          return pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              "Page ${context.pageNumber}",
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey,
              ),
            ),
          );
        },

        build: (context) => [

          /// =========================
          /// HEADER
          /// =========================

          pw.Container(
            padding: const pw.EdgeInsets.all(20),

            decoration: pw.BoxDecoration(
              color: PdfColors.blue800,
              borderRadius: pw.BorderRadius.circular(8),
            ),

            child: pw.Column(
              crossAxisAlignment:
                  pw.CrossAxisAlignment.start,

              children: [

                pw.Text(
                  "NOTEFLOW",
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 6),

                pw.Text(
                  "Rapport des notes",
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          pw.Text(
            "Date d'export : ${DateFormat("dd/MM/yyyy HH:mm").format(now)}",
            style: const pw.TextStyle(
              fontSize: 12,
            ),
          ),

          pw.SizedBox(height: 20),

          /// =========================
          /// STATISTIQUES
          /// =========================

          pw.Table(
            border: pw.TableBorder.all(
              color: PdfColors.grey300,
            ),
            children: [

              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: PdfColors.blue50,
                ),
                children: [

                  _cell("Nombre de notes"),
                  _cell(notes.length.toString()),

                ],
              ),

              pw.TableRow(
                children: [

                  _cell("Favoris"),
                  _cell(totalFavorites.toString()),

                ],
              ),

              pw.TableRow(
                children: [

                  _cell("Epinglées"),
                  _cell(totalPinned.toString()),

                ],
              ),
            ],
          ),

          pw.SizedBox(height: 25),

          pw.Text(
            "Liste des notes",
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 10),

          ...notes.map((note) {

            return pw.Container(

              margin: const pw.EdgeInsets.only(
                bottom: 16,
              ),

              padding: const pw.EdgeInsets.all(14),

              decoration: pw.BoxDecoration(

                border: pw.Border.all(
                  color: PdfColors.grey300,
                ),

                borderRadius:
                    pw.BorderRadius.circular(8),

              ),

              child: pw.Column(

                crossAxisAlignment:
                    pw.CrossAxisAlignment.start,

                children: [

                  pw.Text(
                    note.title,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight:
                          pw.FontWeight.bold,
                    ),
                  ),

                  pw.SizedBox(height: 8),

                  pw.Text(
                    note.description,
                    style: const pw.TextStyle(
                      fontSize: 13,
                    ),
                  ),

                  pw.Divider(),

                  pw.Table(
                    columnWidths: {
                      0: const pw.FixedColumnWidth(80),
                    },

                    children: [

                      _row(
                        "Créée",
                        DateFormat(
                          "dd MMM yyyy  HH:mm",
                        ).format(note.createdAt),
                      ),

                      _row(
                        "Favori",
                        note.isFavorite
                            ? "Oui"
                            : "Non",
                      ),

                      _row(
                        "Epinglée",
                        note.isPinned
                            ? "Oui"
                            : "Non",
                      ),
                    ],
                  ),
                ],
              ),
            );

          }).toList(),
        ],
      ),
    );

    final directory =
        await getTemporaryDirectory();

    final file = File(
      "${directory.path}/noteflow_notes.pdf",
    );

    await file.writeAsBytes(
      await pdf.save(),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
    );
  }

  static pw.Widget _cell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text),
    );
  }

  static pw.TableRow _row(
    String label,
    String value,
  ) {
    return pw.TableRow(
      children: [

        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),

        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(value),
        ),
      ],
    );
  }
}