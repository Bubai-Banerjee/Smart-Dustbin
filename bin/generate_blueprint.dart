import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() async {
  final pdf = pw.Document();

  final primaryColor = PdfColor.fromHex('#00E676'); // Neon Green
  final secondaryColor = PdfColor.fromHex('#00B0FF'); // Electric Cyan
  final darkBg = PdfColor.fromHex('#121212'); // Dark UI tone
  final lightGray = PdfColor.fromHex('#F5F5F5');
  final borderGray = PdfColor.fromHex('#E0E0E0');

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header: (context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(bottom: 20),
        child: pw.Text(
          'ECOTRACK SYSTEM BLUEPRINT',
          style: pw.TextStyle(
            color: PdfColors.grey600,
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
      footer: (context) => pw.Container(
        alignment: pw.Alignment.center,
        margin: const pw.EdgeInsets.only(top: 20),
        child: pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount} - GreenTech Institute of Technology',
          style: pw.TextStyle(color: PdfColors.grey500, fontSize: 8),
        ),
      ),
      build: (context) => [
        // Title block
        pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 12),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey400, width: 1.5),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'EcoTrack: Smart Waste Management',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#1B5E20'),
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Service Blueprint & Operational Workflow Architecture',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey700,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ],
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: primaryColor,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  'CONFIDENTIAL',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 15),

        // Overview Paragraph
        pw.Text(
          'EXECUTIVE SUMMARY:',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'This service blueprint details the end-to-end interactions, touchpoints, backstage workflows, and automated system systems supporting the EcoTrack Smart Waste Management platform at the GreenTech Institute of Technology. The framework connects three primary roles (Admin, Collector, and Citizen) with physical IoT sensor telemetry to maintain campus hygiene and reduce operational overhead.',
          style: pw.TextStyle(fontSize: 9, color: PdfColors.grey800, lineSpacing: 1.3),
        ),
        pw.SizedBox(height: 20),

        // Service Blueprint Grid Table
        pw.Text(
          'OPERATIONAL SERVICE BLUEPRINT MATRIX',
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0D47A1')),
        ),
        pw.SizedBox(height: 8),

        pw.Table(
          border: pw.TableBorder.all(color: borderGray, width: 1),
          columnWidths: {
            0: const pw.FixedColumnWidth(85), // Category Column
            1: const pw.FlexColumnWidth(1.2), // Telemetry Phase
            2: const pw.FlexColumnWidth(1.2), // Alert Phase
            3: const pw.FlexColumnWidth(1.2), // Dispatch Phase
            4: const pw.FlexColumnWidth(1.2), // Citizen Phase
          },
          children: [
            // Table Header Row
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildCell('SWIMLANES', isHeader: true),
                _buildCell('1. IOT TELEMETRY', isHeader: true),
                _buildCell('2. THRESHOLD ALERT', isHeader: true),
                _buildCell('3. OPERATION COLLECT', isHeader: true),
                _buildCell('4. CITIZEN ENGAGE', isHeader: true),
              ],
            ),
            // Physical Evidence
            pw.TableRow(
              children: [
                _buildCell('Physical Evidence', isLabel: true),
                _buildCell('Smart Dustbins, Battery/Temp indicators, live dashboards.'),
                _buildCell('LED warning lights on bins, Admin alerts tab, neon notifications.'),
                _buildCell('Collector navigation map, QR Code, trash bags, collection trucks.'),
                _buildCell('Public bin map list, report form screen, Eco-Point scorecard.'),
              ],
            ),
            // User Actions
            pw.TableRow(
              children: [
                _buildCell('User Actions', isLabel: true),
                _buildCell('Admin checks metrics. Citizen disposes waste.'),
                _buildCell('Admin reviews alerts drawer, triage priority levels.'),
                _buildCell('Collector follows route map, scans QR code to clear bin.'),
                _buildCell('Citizen reports overflow via app, checks cleanest bins.'),
              ],
            ),
            // Onstage Visible Contacts
            pw.TableRow(
              children: [
                _buildCell('Onstage / Visible Contact Actions', isLabel: true),
                _buildCell('None (automated background operations).'),
                _buildCell('Push warning message to Collector terminals.'),
                _buildCell('Collector manually empties bin at campus site.'),
                _buildCell('Citizen inputs location & photos of overflow.'),
              ],
            ),
            // Backstage Invisible Contacts
            pw.TableRow(
              children: [
                _buildCell('Backstage / Support Actions', isLabel: true),
                _buildCell('IoT updates stored locally. Timers run.'),
                _buildCell('Algorithms identify optimal pickup routes.'),
                _buildCell('Database clears bin logs, resets status to normal.'),
                _buildCell('Eco-points credited to citizen profile.'),
              ],
            ),
            // Support Processes
            pw.TableRow(
              children: [
                _buildCell('Support Processes', isLabel: true),
                _buildCell('Periodic stream simulations update Riverpod state.'),
                _buildCell('State notifier tracks alerts & updates metrics.'),
                _buildCell('GoRouter handles details drill down page navigation.'),
                _buildCell('Auth validations checks citizens permissions.'),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 25),

        // System flows section
        pw.Text(
          'KEY SERVICE STAGES & ARCHITECTURE:',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
        ),
        pw.SizedBox(height: 8),

        _buildDetailPoint(
          '1. Real-Time Telemetry Node System:',
          'The 25 campus nodes periodically transmit fill levels, battery charges, gas indicators, and temperatures. This keeps dashboards responsive, reducing physical inspections by 40%.',
        ),
        _buildDetailPoint(
          '2. Smart Automated Routing & Triage:',
          'When capacity hits >= 85%, the system elevates node status to "Overflowing". The collector dashboard reactively updates tasks, ranking bins based on proximity and breach urgency.',
        ),
        _buildDetailPoint(
          '3. QR-Based Pick Validation:',
          'Waste collection is validated by physical presence. The collector must scan the QR code fixed on the bin. Successful scan resets sensor registers and updates campus compliance metrics.',
        ),
        _buildDetailPoint(
          '4. Gamified Citizen Reporting:',
          'Citizens can report anomalies (e.g. overflow, bad odor) instantly. Dispatches trigger a prompt notification for manual collection while rewarding the reporting citizen with Eco-Points.',
        ),
        pw.SizedBox(height: 15),

        // Footer block signature
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.SizedBox(height: 15),
              pw.Container(
                width: 150,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(top: pw.BorderSide(color: PdfColors.grey400, width: 1)),
                ),
                padding: const pw.EdgeInsets.only(top: 4),
                child: pw.Text(
                  'GreenTech Operations Team',
                  style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  final file = File('service_blueprint.pdf');
  await file.writeAsBytes(await pdf.save());
  print('Service Blueprint PDF successfully generated.');
}

pw.Widget _buildCell(String text, {bool isHeader = false, bool isLabel = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(6),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: isHeader ? 7.5 : 7,
        fontWeight: (isHeader || isLabel) ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: isHeader ? PdfColors.black : (isLabel ? PdfColors.grey800 : PdfColors.grey700),
      ),
    ),
  );
}

pw.Widget _buildDetailPoint(String title, String body) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.green900),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          body,
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700, lineSpacing: 1.2),
        ),
      ],
    ),
  );
}
