import 'dart:ui';

import 'package:legalease/shared/models/document_model.dart';
import 'package:legalease/features/document_scan/data/models/ocr_result_model.dart';

const String sampleContractText = '''
SERVICE AGREEMENT

This Service Agreement ("Agreement") is entered into as of the date of last signature below ("Effective Date") by and between Acme Corporation, a Delaware corporation with its principal place of business at 123 Business Avenue, Suite 100, New York, NY 10001 ("Company"), and the undersigned service provider ("Provider").

WHEREAS, Company desires to engage Provider to perform certain services as described herein; and

WHEREAS, Provider is willing to perform such services on the terms and conditions set forth in this Agreement;

NOW, THEREFORE, in consideration of the mutual covenants and agreements contained herein, and for other good and valuable consideration, the receipt and sufficiency of which are hereby acknowledged, the parties agree as follows:

ARTICLE 1 - SCOPE OF SERVICES
1.1 Provider shall provide the services described in Exhibit A attached hereto and incorporated by reference (the "Services"). Company may modify the scope of Services upon written notice to Provider, subject to mutual agreement on any changes to compensation.
1.2 Provider shall perform the Services in a professional and workmanlike manner consistent with industry standards. Provider represents that it has the necessary skill, experience, and qualifications to perform the Services.

ARTICLE 2 - COMPENSATION
2.1 In consideration for the Services, Company shall pay Provider the fees set forth in Exhibit B attached hereto. Payment shall be made within thirty (30) days of Provider's submission of a proper invoice.
2.2 Provider shall be responsible for all taxes, including income taxes, arising from compensation received under this Agreement. Company shall not withhold any taxes from payments to Provider.

ARTICLE 3 - TERM AND TERMINATION
3.1 This Agreement shall commence on the Effective Date and shall continue for a period of twelve (12) months unless earlier terminated as provided herein.
3.2 Either party may terminate this Agreement for convenience upon thirty (30) days written notice to the other party. Company may terminate this Agreement immediately upon written notice if Provider breaches any material provision of this Agreement.

ARTICLE 4 - CONFIDENTIALITY
4.1 Provider acknowledges that during the course of performing Services, Provider may have access to confidential and proprietary information of Company. Provider agrees to maintain the confidentiality of all such information and not to disclose or use such information except as necessary to perform the Services.
4.2 The obligations of confidentiality shall survive the termination of this Agreement for a period of five (5) years.

ARTICLE 5 - INDEMNIFICATION
5.1 Provider shall indemnify, defend, and hold harmless Company and its officers, directors, employees, and agents from any claims, damages, or expenses arising from Provider's performance of Services or breach of this Agreement.
5.2 Company shall not be liable for any indirect, incidental, special, or consequential damages arising out of this Agreement.

IN WITNESS WHEREOF, the parties have executed this Agreement as of the date first written above.
''';

const String sampleTermsAndConditions = '''
TERMS AND CONDITIONS

1. ACCEPTANCE OF TERMS
By accessing and using this service, you accept and agree to be bound by the terms and provisions of this agreement. If you do not agree to abide by these terms, please do not use this service.

2. USER REGISTRATION
You must be at least 18 years of age to use this service. You agree to provide accurate and complete information during registration and to update such information to keep it current. You are responsible for maintaining the confidentiality of your account credentials.

3. LICENSE AND USAGE
Subject to these terms, we grant you a limited, non-exclusive, non-transferable license to access and use our service for personal, non-commercial purposes. You may not copy, modify, distribute, or create derivative works from our service without prior written consent.

4. INTELLECTUAL PROPERTY
All content, features, and functionality of this service are owned by us and are protected by international copyright, trademark, and other intellectual property laws. You retain ownership of content you submit to the service.

5. LIMITATION OF LIABILITY
TO THE MAXIMUM EXTENT PERMITTED BY LAW, WE SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, OR CONSEQUENTIAL DAMAGES. OUR TOTAL LIABILITY SHALL NOT EXCEED THE AMOUNT YOU PAID FOR THE SERVICE IN THE PAST TWELVE MONTHS.

6. TERMINATION
We reserve the right to terminate or suspend your access to the service at any time, without notice, for conduct that we believe violates these terms or is harmful to other users, us, or third parties.

7. GOVERNING LAW
These terms shall be governed by and construed in accordance with the laws of the State of Delaware, without regard to its conflict of laws principles.
''';

const String samplePrivacyPolicy = '''
PRIVACY POLICY

Last Updated: January 1, 2024

1. PERSONAL DATA COLLECTION
We collect personal data and personal information you provide directly to us, including name, email address, phone number, and any other information you choose to provide. Our data collection also includes information automatically when you use our service.

2. DATA PROCESSING
We process your data to provide, maintain, and improve our service. This data processing is necessary for our legitimate interests in analyzing usage patterns and enhancing user experience.

3. INFORMATION SHARING WITH THIRD PARTIES
We do not sell your personal information. We may share your information with third party service providers who perform services on our behalf, including hosting, analytics, and customer service. We may also share information if required by law or to protect our rights.

4. DATA PROTECTION
We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. Our data protection practices comply with applicable regulations.

5. USER CONSENT
By using our service, you consent to our collection and use of your information as described in this policy.

6. COOKIES
We use cookies and similar tracking technologies to collect and track information about your activity on our service. You can instruct your browser to refuse all cookies.

7. GDPR COMPLIANCE
For users subject to GDPR, we process personal data based on consent and legitimate interest. You have the right to access, correct, delete, or port your personal data.

8. CCPA COMPLIANCE
For California residents, we comply with CCPA requirements regarding the collection and use of personal information.

9. CHANGES TO POLICY
We may update this privacy policy from time to time. We will notify you of any material changes.
''';

final List<RedFlag> sampleRedFlags = [
  RedFlag(
    id: 'red-flag-1',
    originalText: 'Provider shall indemnify, defend, and hold harmless Company and its officers, directors, employees, and agents from any claims, damages, or expenses arising from Provider\'s performance of Services or breach of this Agreement.',
    explanation: 'This is a broad indemnification clause that places significant liability on you. It requires you to cover the Company\'s legal costs and damages even in situations where you may not be fully at fault.',
    severity: 'high',
    startPosition: 2150,
    endPosition: 2380,
    confidenceScore: 0.92,
  ),
  RedFlag(
    id: 'red-flag-2',
    originalText: 'Company shall not be liable for any indirect, incidental, special, or consequential damages arising out of this Agreement.',
    explanation: 'This clause limits the Company\'s liability and prevents you from claiming damages for losses that are not direct, such as lost profits or opportunity costs.',
    severity: 'medium',
    startPosition: 2382,
    endPosition: 2505,
    confidenceScore: 0.85,
  ),
  RedFlag(
    id: 'red-flag-3',
    originalText: 'Company may terminate this Agreement immediately upon written notice if Provider breaches any material provision of this Agreement.',
    explanation: 'This allows the Company to terminate immediately for any breach of a "material" provision, which is vaguely defined and could lead to unexpected contract termination.',
    severity: 'medium',
    startPosition: 1450,
    endPosition: 1595,
    confidenceScore: 0.78,
  ),
  RedFlag(
    id: 'red-flag-4',
    originalText: 'TO THE MAXIMUM EXTENT PERMITTED BY LAW, WE SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, OR CONSEQUENTIAL DAMAGES.',
    explanation: 'This liability waiver appears in all caps for emphasis and completely disclaims responsibility for any damages beyond direct costs, significantly limiting your recourse.',
    severity: 'high',
    startPosition: 3200,
    endPosition: 3370,
    confidenceScore: 0.95,
  ),
];

final OcrResultModel sampleOcrResult = OcrResultModel(
  text: sampleContractText.substring(0, 800),
  blocks: [
    OcrTextBlock(
      text: 'SERVICE AGREEMENT',
      boundingBox: const Rect.fromLTRB(100.0, 50.0, 400.0, 80.0),
      lines: ['SERVICE AGREEMENT'],
      confidence: 0.98,
    ),
    OcrTextBlock(
      text: 'This Service Agreement ("Agreement") is entered into as of the date of last signature below',
      boundingBox: const Rect.fromLTRB(50.0, 100.0, 550.0, 140.0),
      lines: [
        'This Service Agreement ("Agreement") is entered into as of',
        'the date of last signature below',
      ],
      confidence: 0.95,
    ),
    OcrTextBlock(
      text: 'WHEREAS, Company desires to engage Provider to perform certain services',
      boundingBox: const Rect.fromLTRB(50.0, 160.0, 500.0, 190.0),
      lines: ['WHEREAS, Company desires to engage Provider to perform certain services'],
      confidence: 0.91,
    ),
  ],
  imageSize: const Size(612.0, 792.0),
  processingTime: const Duration(milliseconds: 1250),
  confidence: 0.94,
  filePath: '/test/fixtures/sample_contract.pdf',
  pageIndex: 0,
);

final MultiPageOcrResult sampleMultiPageOcrResult = MultiPageOcrResult(
  pages: [
    sampleOcrResult,
    OcrResultModel(
      text: '''
ARTICLE 3 - TERM AND TERMINATION

3.1 This Agreement shall commence on the Effective Date and shall continue for a period of twelve (12) months unless earlier terminated as provided herein.

3.2 Either party may terminate this Agreement for convenience upon thirty (30) days written notice to the other party.
''',
      blocks: [
        OcrTextBlock(
          text: 'ARTICLE 3 - TERM AND TERMINATION',
          boundingBox: const Rect.fromLTRB(100.0, 50.0, 450.0, 75.0),
          lines: ['ARTICLE 3 - TERM AND TERMINATION'],
          confidence: 0.97,
        ),
        OcrTextBlock(
          text: '3.1 This Agreement shall commence on the Effective Date and shall continue for a period of twelve (12) months unless earlier terminated as provided herein.',
          boundingBox: const Rect.fromLTRB(50.0, 100.0, 550.0, 150.0),
          lines: [
            '3.1 This Agreement shall commence on the Effective Date',
            'and shall continue for a period of twelve (12) months',
            'unless earlier terminated as provided herein.',
          ],
          confidence: 0.93,
        ),
      ],
      imageSize: const Size(612.0, 792.0),
      processingTime: const Duration(milliseconds: 980),
      confidence: 0.92,
      filePath: '/test/fixtures/sample_contract.pdf',
      pageIndex: 1,
    ),
    OcrResultModel(
      text: '''
ARTICLE 5 - INDEMNIFICATION

5.1 Provider shall indemnify, defend, and hold harmless Company and its officers, directors, employees, and agents from any claims.

IN WITNESS WHEREOF, the parties have executed this Agreement.
''',
      blocks: [
        OcrTextBlock(
          text: 'ARTICLE 5 - INDEMNIFICATION',
          boundingBox: const Rect.fromLTRB(100.0, 50.0, 420.0, 75.0),
          lines: ['ARTICLE 5 - INDEMNIFICATION'],
          confidence: 0.96,
        ),
        OcrTextBlock(
          text: '5.1 Provider shall indemnify, defend, and hold harmless Company',
          boundingBox: const Rect.fromLTRB(50.0, 100.0, 500.0, 130.0),
          lines: ['5.1 Provider shall indemnify, defend, and hold harmless Company'],
          confidence: 0.89,
        ),
      ],
      imageSize: const Size(612.0, 792.0),
      processingTime: const Duration(milliseconds: 1100),
      confidence: 0.90,
      filePath: '/test/fixtures/sample_contract.pdf',
      pageIndex: 2,
    ),
  ],
  totalProcessingTime: const Duration(milliseconds: 3330),
  averageConfidence: 0.92,
);