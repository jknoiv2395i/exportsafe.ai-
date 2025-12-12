import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';

class ViewLCScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const ViewLCScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LC Document Preview"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: PdfPreview(
        build: (format) => _generatePdf(format, data),
        actions: [
          PdfPreviewAction(
            icon: const Icon(Icons.download),
            onPressed: (context, build, pageFormat) async {
             // Default already handles print/save, but this is an extra explicit action if needed
             // Printing package has built-in save/share
            },
          ),
        ],
        canDebug: false,
        canChangeOrientation: false,
        canChangePageFormat: false,
      ),
    );
  }



  Future<Uint8List> _generatePdf(PdfPageFormat format, Map<String, dynamic> data) async {
    final pdf = pw.Document();
    
    // Helpers to safely get nested data
    String get(String key) => data[key]?.toString() ?? "";
    Map<String, dynamic> getMap(String key) => (data[key] is Map) ? data[key] : {};
    
    final applicant = getMap('applicant');
    final beneficiary = getMap('beneficiary');
    final issuingBank = getMap('issuing_bank');
    final shipment = getMap('shipment_details');
    
    // Define styles
    final font = pw.Font.times();
    final boldFont = pw.Font.timesBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
               // Header
               pw.Center(
                 child: pw.Text(
                   "LETTER OF CREDIT INSTRUCTIONS",
                   style: pw.TextStyle(
                     font: boldFont,
                     fontSize: 18,
                     fontWeight: pw.FontWeight.bold,
                     decoration: pw.TextDecoration.underline,
                   ),
                 ),
               ),
               pw.SizedBox(height: 24),

               // Date
               pw.Text(
                 "Date: ${get('issue_date')}",
                 style: pw.TextStyle(font: font, fontSize: 12),
               ),
               pw.SizedBox(height: 24),

               // To / From Row (Issuing Bank -> Applicant)
               pw.Row(
                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                 crossAxisAlignment: pw.CrossAxisAlignment.start,
                 children: [
                   pw.Expanded(
                     child: pw.Column(
                       crossAxisAlignment: pw.CrossAxisAlignment.start,
                       children: [
                         pw.Text("To (Issuing Bank):", style: pw.TextStyle(font: boldFont, fontWeight: pw.FontWeight.bold)),
                         pw.SizedBox(height: 4),
                         pw.Container(
                           padding: const pw.EdgeInsets.all(4),
                           child: pw.Text(
                             "${issuingBank['name'] ?? 'Pending Bank Selection'}\n${issuingBank['address'] ?? ''}\nSWIFT: ${issuingBank['swift_code'] ?? 'N/A'}",
                             style: pw.TextStyle(font: font),
                           ),
                         ),
                       ],
                     ),
                   ),
                   pw.SizedBox(width: 40),
                   pw.Expanded(
                     child: pw.Column(
                       crossAxisAlignment: pw.CrossAxisAlignment.start,
                       children: [
                         pw.Text("From (Applicant):", style: pw.TextStyle(font: boldFont, fontWeight: pw.FontWeight.bold)),
                         pw.SizedBox(height: 4),
                         pw.Container(
                           padding: const pw.EdgeInsets.all(4),
                           child: pw.Text(
                             "${applicant['name'] ?? 'Pending Applicant'}\n${applicant['address'] ?? ''}",
                             style: pw.TextStyle(font: font),
                           ),
                         ),
                       ],
                     ),
                   ),
                 ],
               ),
               pw.SizedBox(height: 24),

               // RE: Section
               pw.Row(
                 children: [
                   pw.Text("RE:  ", style: pw.TextStyle(font: boldFont, fontWeight: pw.FontWeight.bold)),
                   _buildPdfFieldRow("Ref:", get('lc_number'), font, boldFont),
                 ]
               ),
               pw.SizedBox(height: 24),

               pw.Text("Gentlemen:", style: pw.TextStyle(font: font)),
               pw.SizedBox(height: 8),
               
               // Intro Body
               pw.Text(
                 "Please issue an irrevocable Letter of Credit (Subject to UCP 600) with the following details:",
                 textAlign: pw.TextAlign.justify,
                 style: pw.TextStyle(font: font, fontSize: 11),
               ),
               pw.SizedBox(height: 16),

               // Core UCP 600 Details
               _buildPdfNumberedItem("1.", "Expiry: ${get('expiry_date')} in ${get('expiry_place')}", font),
               _buildPdfNumberedItem("2.", "Beneficiary: ${beneficiary['name'] ?? 'N/A'}\nAddress: ${beneficiary['address'] ?? ''}", font),
               _buildPdfNumberedItem("3.", "Amount: ${get('currency')} ${get('amount')}", font),
               _buildPdfNumberedItem("4.", "Available with Any Bank by Negotiation.", font),
               
               // Shipment Section
               pw.SizedBox(height: 8),
               pw.Text("Shipment Details:", style: pw.TextStyle(font: boldFont, fontWeight: pw.FontWeight.bold, fontSize: 11)),
               pw.Padding(
                 padding: const pw.EdgeInsets.only(left: 10),
                 child: pw.Column(
                   crossAxisAlignment: pw.CrossAxisAlignment.start,
                   children: [
                     pw.Text("- From: ${shipment['port_of_loading'] ?? 'Any Port'}", style: pw.TextStyle(font: font, fontSize: 10)),
                     pw.Text("- To: ${shipment['port_of_discharge'] ?? 'Any Port'}", style: pw.TextStyle(font: font, fontSize: 10)),
                     pw.Text("- Latest Shipment: ${shipment['latest_shipment_date'] ?? 'N/A'}", style: pw.TextStyle(font: font, fontSize: 10)),
                     pw.Text("- Partial Shipment: ${shipment['partial_shipment'] ?? 'Allowed'}", style: pw.TextStyle(font: font, fontSize: 10)),
                     pw.Text("- Transshipment: ${shipment['transshipment'] ?? 'Allowed'}", style: pw.TextStyle(font: font, fontSize: 10)),
                     pw.Text("- Incoterm: ${get('incoterms')}", style: pw.TextStyle(font: font, fontSize: 10)),
                   ]
                 )
               ),

               // Goods
               pw.SizedBox(height: 8),
               pw.Text("Description of Goods:", style: pw.TextStyle(font: boldFont, fontWeight: pw.FontWeight.bold, fontSize: 11)),
               pw.Container(
                 width: double.infinity,
                 color: PdfColors.grey100,
                 padding: const pw.EdgeInsets.all(4),
                 child: pw.Text(get('description_of_goods'), style: pw.TextStyle(font: font, fontSize: 10)),
               ),

               // Documents
               pw.SizedBox(height: 8),
               pw.Text("Required Documents:", style: pw.TextStyle(font: boldFont, fontWeight: pw.FontWeight.bold, fontSize: 11)),
               ...((data['required_documents'] as List<dynamic>? ?? []).map((doc) => 
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 10, bottom: 2),
                    child: pw.Bullet(text: doc.toString(), style: pw.TextStyle(font: font, fontSize: 10))
                  )
               )),

               // Additional Conditions
               pw.SizedBox(height: 8),
               pw.Text("Additional Conditions:", style: pw.TextStyle(font: boldFont, fontWeight: pw.FontWeight.bold, fontSize: 11)),
               ...((data['additional_conditions'] as List<dynamic>? ?? []).map((cond) => 
                  pw.Padding(
                     padding: const pw.EdgeInsets.only(left: 10, bottom: 2),
                     child: pw.Bullet(text: cond.toString(), style: pw.TextStyle(font: font, fontSize: 10))
                  )
               )),
               
               pw.Spacer(),

               // Signatures
               pw.Divider(),
               pw.SizedBox(height: 30),
               pw.Row(
                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                 children: [
                   pw.Column(
                     crossAxisAlignment: pw.CrossAxisAlignment.start,
                     children: [
                       pw.Container(width: 150, height: 1, color: PdfColors.black),
                       pw.SizedBox(height: 4),
                       pw.Text("Authorized Signature", style: pw.TextStyle(font: font, fontSize: 10)),
                     ],
                   ),
                    pw.Column(
                     crossAxisAlignment: pw.CrossAxisAlignment.start,
                     children: [
                       pw.Container(width: 150, height: 1, color: PdfColors.black),
                       pw.SizedBox(height: 4),
                       pw.Text("Date", style: pw.TextStyle(font: font, fontSize: 10)),
                     ],
                   ),
                 ]
               )
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
  
  pw.Widget _buildPdfNumberedItem(String number, String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(number, style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 10), textAlign: pw.TextAlign.justify)
          ),
        ],
      )
    );
  }

  pw.Widget _buildPdfCheckboxRow(String label, String value, pw.Font font, pw.Font boldFont) {
     return pw.Padding(
       padding: const pw.EdgeInsets.only(bottom: 2),
       child: pw.Row(
         children: [
           pw.Container(
             width: 10, height: 10, 
             decoration: pw.BoxDecoration(border: pw.Border.all())
           ),
           pw.SizedBox(width: 6),
           pw.Text("$label: ", style: pw.TextStyle(font: font, fontSize: 10)),
           pw.Text(value, style: pw.TextStyle(font: boldFont, fontSize: 10, fontWeight: pw.FontWeight.bold)),
         ]
       )
     );
  }

  pw.Widget _buildPdfFieldRow(String label, String value, pw.Font font, pw.Font boldFont) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 60, child: pw.Text(label, style: pw.TextStyle(font: font, fontSize: 10))),
          pw.Expanded(
            child: pw.Container(
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
              ),
              child: pw.Text(value, style: pw.TextStyle(font: boldFont, fontWeight: pw.FontWeight.bold, fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }


}
