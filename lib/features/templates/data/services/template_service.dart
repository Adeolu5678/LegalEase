import 'package:legalease/features/templates/data/models/legal_template.dart';

class TemplateService {
  final List<LegalTemplate> _templates = _initializeTemplates();

  List<LegalTemplate> get allTemplates => _templates;

  static List<LegalTemplate> _initializeTemplates() {
    return [
      LegalTemplate(
        id: 'nda_basic',
        name: 'Non-Disclosure Agreement (NDA)',
        description: 'A basic non-disclosure agreement for protecting confidential information between two parties.',
        category: TemplateCategory.contracts,
        isPremium: false,
        createdAt: DateTime.now(),
        tags: ['confidentiality', 'business', 'legal'],
        fields: [
          const TemplateFieldDefinition(id: 'disclosing_party', label: 'Disclosing Party Name', required: true),
          const TemplateFieldDefinition(id: 'disclosing_address', label: 'Disclosing Party Address', type: TemplateField.address, required: true),
          const TemplateFieldDefinition(id: 'receiving_party', label: 'Receiving Party Name', required: true),
          const TemplateFieldDefinition(id: 'receiving_address', label: 'Receiving Party Address', type: TemplateField.address, required: true),
          const TemplateFieldDefinition(id: 'effective_date', label: 'Effective Date', type: TemplateField.date, required: true),
          const TemplateFieldDefinition(id: 'duration', label: 'Duration (years)', type: TemplateField.number, defaultValue: '5'),
          const TemplateFieldDefinition(id: 'governing_state', label: 'Governing State', required: true),
        ],
        content: '''
NON-DISCLOSURE AGREEMENT

This Non-Disclosure Agreement (the "Agreement") is entered into as of {{effective_date}} (the "Effective Date") by and between:

DISCLOSING PARTY:
{{disclosing_party}}
{{disclosing_address}}

and

RECEIVING PARTY:
{{receiving_party}}
{{receiving_address}}

1. DEFINITION OF CONFIDENTIAL INFORMATION
For purposes of this Agreement, "Confidential Information" shall include all information or data that has or could have commercial value or other utility in the business in which Disclosing Party is engaged.

2. EXCLUSIONS FROM CONFIDENTIAL INFORMATION
Receiving Party's obligations under this Agreement do not extend to information that is: (a) publicly known at the time of disclosure or subsequently becomes publicly known through no fault of the Receiving Party; (b) discovered or created by the Receiving Party before disclosure by Disclosing Party; (c) learned by the Receiving Party through legitimate means other than from the Disclosing Party; or (d) is disclosed by Receiving Party with Disclosing Party's prior written approval.

3. OBLIGATIONS OF RECEIVING PARTY
Receiving Party shall hold and maintain the Confidential Information in strict confidence for the sole and exclusive benefit of the Disclosing Party. Receiving Party shall carefully restrict access to Confidential Information to its employees, contractors, and third parties as is reasonably required.

4. TIME PERIODS
The nondisclosure provisions of this Agreement shall survive the termination of this Agreement and Receiving Party's duty to hold Confidential Information in confidence shall remain in effect until the Confidential Information no longer qualifies as a trade secret or until Disclosing Party sends Receiving Party written notice releasing Receiving Party from this Agreement, whichever occurs first.

5. RELATIONSHIPS
Nothing contained in this Agreement shall be deemed to constitute either party a partner, joint venturer or employee of the other party for any purpose.

6. SEVERABILITY
If a court finds any provision of this Agreement invalid or unenforceable, the remainder of this Agreement shall be interpreted so as best to effect the intent of the parties.

7. INTEGRATION
This Agreement expresses the complete understanding of the parties with respect to the subject matter and supersedes all prior proposals, agreements, representations, and understandings.

8. GOVERNING LAW
This Agreement shall be governed by and construed in accordance with the laws of the State of {{governing_state}}.

IN WITNESS WHEREOF, the parties have executed this Agreement as of the date first above written.

DISCLOSING PARTY: _________________________
Name: {{disclosing_party}}
Date: _____________

RECEIVING PARTY: _________________________
Name: {{receiving_party}}
Date: _____________
''',
      ),
      LegalTemplate(
        id: 'employment_basic',
        name: 'Employment Agreement',
        description: 'A standard employment agreement for full-time employees.',
        category: TemplateCategory.employment,
        isPremium: false,
        createdAt: DateTime.now(),
        tags: ['employment', 'HR', 'hiring'],
        fields: [
          const TemplateFieldDefinition(id: 'employer_name', label: 'Employer Name', required: true),
          const TemplateFieldDefinition(id: 'employer_address', label: 'Employer Address', type: TemplateField.address, required: true),
          const TemplateFieldDefinition(id: 'employee_name', label: 'Employee Name', required: true),
          const TemplateFieldDefinition(id: 'employee_address', label: 'Employee Address', type: TemplateField.address, required: true),
          const TemplateFieldDefinition(id: 'position', label: 'Position/Title', required: true),
          const TemplateFieldDefinition(id: 'start_date', label: 'Start Date', type: TemplateField.date, required: true),
          const TemplateFieldDefinition(id: 'salary', label: 'Annual Salary', type: TemplateField.currency, required: true),
          const TemplateFieldDefinition(id: 'governing_state', label: 'Governing State', required: true),
        ],
        content: '''
EMPLOYMENT AGREEMENT

This Employment Agreement (the "Agreement") is made and entered into as of {{start_date}}, by and between:

EMPLOYER:
{{employer_name}}
{{employer_address}}

and

EMPLOYEE:
{{employee_name}}
{{employee_address}}

1. POSITION AND DUTIES
Employer hereby employs Employee in the position of {{position}}, and Employee hereby accepts such employment. Employee shall perform such duties as are customarily associated with such position, together with such other duties as may from time to time be assigned by Employer.

2. TERM
The term of this Agreement shall commence on {{start_date}} and shall continue until terminated by either party in accordance with the terms hereof.

3. COMPENSATION
Employer shall pay Employee a base salary at the rate of {{salary}} per year, payable in accordance with Employer's standard payroll practices.

4. BENEFITS
Employee shall be entitled to participate in all benefit programs that Employer establishes and makes available to its employees, subject to the terms and conditions of such programs.

5. CONFIDENTIALITY
Employee acknowledges that during the course of employment, Employee will have access to confidential and proprietary information. Employee agrees not to disclose such information to third parties during or after employment.

6. TERMINATION
Either party may terminate this Agreement at any time, with or without cause, upon providing two weeks' written notice.

7. NON-COMPETE
During the term of this Agreement and for a period of one (1) year thereafter, Employee shall not engage in any business that directly competes with Employer.

8. GOVERNING LAW
This Agreement shall be governed by and construed in accordance with the laws of the State of {{governing_state}}.

IN WITNESS WHEREOF, the parties have executed this Agreement as of the date first written above.

EMPLOYER: _________________________
By: {{employer_name}}
Date: _____________

EMPLOYEE: _________________________
{{employee_name}}
Date: _____________
''',
      ),
      LegalTemplate(
        id: 'service_contract',
        name: 'Service Agreement',
        description: 'A general service agreement for contracting services between two parties.',
        category: TemplateCategory.contracts,
        isPremium: false,
        createdAt: DateTime.now(),
        tags: ['services', 'contractor', 'freelance'],
        fields: [
          const TemplateFieldDefinition(id: 'client_name', label: 'Client Name', required: true),
          const TemplateFieldDefinition(id: 'client_address', label: 'Client Address', type: TemplateField.address, required: true),
          const TemplateFieldDefinition(id: 'provider_name', label: 'Service Provider Name', required: true),
          const TemplateFieldDefinition(id: 'provider_address', label: 'Service Provider Address', type: TemplateField.address, required: true),
          const TemplateFieldDefinition(id: 'service_description', label: 'Description of Services', type: TemplateField.multilineText, required: true),
          const TemplateFieldDefinition(id: 'start_date', label: 'Start Date', type: TemplateField.date, required: true),
          const TemplateFieldDefinition(id: 'end_date', label: 'End Date', type: TemplateField.date, required: true),
          const TemplateFieldDefinition(id: 'payment_amount', label: 'Payment Amount', type: TemplateField.currency, required: true),
          const TemplateFieldDefinition(id: 'governing_state', label: 'Governing State', required: true),
        ],
        content: '''
SERVICE AGREEMENT

This Service Agreement (the "Agreement") is entered into as of {{start_date}} (the "Effective Date") by and between:

CLIENT:
{{client_name}}
{{client_address}}

and

SERVICE PROVIDER:
{{provider_name}}
{{provider_address}}

1. SERVICES
Service Provider agrees to provide the following services (the "Services"):
{{service_description}}

2. TERM
This Agreement shall commence on {{start_date}} and shall continue until {{end_date}}, unless terminated earlier in accordance with the terms hereof.

3. COMPENSATION
Client agrees to pay Service Provider the sum of {{payment_amount}} for the Services rendered. Payment shall be made within thirty (30) days of invoice receipt.

4. INDEPENDENT CONTRACTOR
Service Provider is an independent contractor and nothing in this Agreement shall be construed to create a partnership, joint venture, or employer-employee relationship.

5. CONFIDENTIALITY
Each party agrees to maintain the confidentiality of any proprietary information received from the other party during the term of this Agreement.

6. INTELLECTUAL PROPERTY
All work product created by Service Provider in connection with the Services shall be the exclusive property of Client.

7. TERMINATION
Either party may terminate this Agreement upon thirty (30) days' written notice. In the event of termination, Service Provider shall be entitled to payment for Services rendered prior to the termination date.

8. LIMITATION OF LIABILITY
Neither party shall be liable to the other for any indirect, incidental, or consequential damages arising out of this Agreement.

9. GOVERNING LAW
This Agreement shall be governed by and construed in accordance with the laws of the State of {{governing_state}}.

IN WITNESS WHEREOF, the parties have executed this Agreement as of the date first written above.

CLIENT: _________________________
{{client_name}}
Date: _____________

SERVICE PROVIDER: _________________________
{{provider_name}}
Date: _____________
''',
      ),
      LegalTemplate(
        id: 'privacy_policy',
        name: 'Privacy Policy',
        description: 'A comprehensive privacy policy template for websites and applications.',
        category: TemplateCategory.privacy,
        isPremium: true,
        createdAt: DateTime.now(),
        tags: ['privacy', 'website', 'data protection'],
        fields: [
          const TemplateFieldDefinition(id: 'company_name', label: 'Company Name', required: true),
          const TemplateFieldDefinition(id: 'website_url', label: 'Website URL', required: true),
          const TemplateFieldDefinition(id: 'contact_email', label: 'Contact Email', type: TemplateField.email, required: true),
          const TemplateFieldDefinition(id: 'effective_date', label: 'Effective Date', type: TemplateField.date, required: true),
        ],
        content: '''
PRIVACY POLICY

Last Updated: {{effective_date}}

{{company_name}} ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you visit our website {{website_url}}.

1. INFORMATION WE COLLECT
We may collect information about you in a variety of ways, including:
- Personal Data: Name, email address, phone number, and other contact information you provide.
- Derivative Data: Information our servers automatically collect when you access the website.
- Financial Data: Payment information related to transactions on our website.

2. USE OF YOUR INFORMATION
We may use the information collected about you to:
- Create and manage your account
- Process transactions and send related information
- Send you marketing and promotional communications
- Respond to your comments and questions

3. DISCLOSURE OF YOUR INFORMATION
We may share information we have collected about you in certain situations:
- By Law or to Protect Rights
- Third-Party Service Providers
- Marketing Partners

4. TRACKING TECHNOLOGIES
We use cookies and similar tracking technologies to track activity on our website and hold certain information.

5. SECURITY OF YOUR INFORMATION
We use administrative, technical, and physical security measures to protect your personal information.

6. YOUR RIGHTS
Depending on your location, you may have certain rights regarding your personal information, including:
- The right to access your personal data
- The right to correct inaccurate data
- The right to delete your personal data
- The right to restrict processing

7. CONTACT US
If you have questions or comments about this Privacy Policy, please contact us at:
{{contact_email}}

{{company_name}}
{{website_url}}
''',
      ),
      LegalTemplate(
        id: 'terms_of_service',
        name: 'Terms of Service',
        description: 'Standard terms of service agreement for websites and applications.',
        category: TemplateCategory.privacy,
        isPremium: true,
        createdAt: DateTime.now(),
        tags: ['terms', 'website', 'legal'],
        fields: [
          const TemplateFieldDefinition(id: 'company_name', label: 'Company Name', required: true),
          const TemplateFieldDefinition(id: 'service_name', label: 'Service/Website Name', required: true),
          const TemplateFieldDefinition(id: 'website_url', label: 'Website URL', required: true),
          const TemplateFieldDefinition(id: 'contact_email', label: 'Contact Email', type: TemplateField.email, required: true),
          const TemplateFieldDefinition(id: 'effective_date', label: 'Effective Date', type: TemplateField.date, required: true),
        ],
        content: '''
TERMS OF SERVICE

Last Updated: {{effective_date}}

1. ACCEPTANCE OF TERMS
By accessing and using {{service_name}} ("Service"), provided by {{company_name}}, you accept and agree to be bound by these Terms of Service.

2. DESCRIPTION OF SERVICE
{{service_name}} provides [description of services]. Access to the Service is available through {{website_url}}.

3. USER ACCOUNTS
You are responsible for maintaining the confidentiality of your account credentials. You agree to notify us immediately of any unauthorized use of your account.

4. ACCEPTABLE USE
You agree not to:
- Use the Service for any unlawful purpose
- Attempt to gain unauthorized access to any portion of the Service
- Interfere with the proper working of the Service
- Use automated systems to access the Service

5. INTELLECTUAL PROPERTY
All content, features, and functionality of the Service are owned by {{company_name}} and are protected by intellectual property laws.

6. USER CONTENT
You retain ownership of content you submit to the Service. By submitting content, you grant us a license to use, reproduce, and distribute such content.

7. PRIVACY
Your use of the Service is also governed by our Privacy Policy.

8. TERMINATION
We may terminate or suspend your access to the Service at any time, without prior notice, for any reason.

9. LIMITATION OF LIABILITY
{{company_name}} shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of the Service.

10. CHANGES TO TERMS
We reserve the right to modify these Terms at any time. We will notify you of any changes by posting the new Terms on this page.

11. CONTACT
Questions about these Terms may be sent to {{contact_email}}.

{{company_name}}
{{website_url}}
''',
      ),
      LegalTemplate(
        id: 'lease_agreement',
        name: 'Residential Lease Agreement',
        description: 'A residential lease agreement for rental properties.',
        category: TemplateCategory.realEstate,
        isPremium: true,
        createdAt: DateTime.now(),
        tags: ['lease', 'rental', 'property'],
        fields: [
          const TemplateFieldDefinition(id: 'landlord_name', label: 'Landlord Name', required: true),
          const TemplateFieldDefinition(id: 'landlord_address', label: 'Landlord Address', type: TemplateField.address, required: true),
          const TemplateFieldDefinition(id: 'tenant_name', label: 'Tenant Name', required: true),
          const TemplateFieldDefinition(id: 'property_address', label: 'Property Address', type: TemplateField.address, required: true),
          const TemplateFieldDefinition(id: 'start_date', label: 'Lease Start Date', type: TemplateField.date, required: true),
          const TemplateFieldDefinition(id: 'end_date', label: 'Lease End Date', type: TemplateField.date, required: true),
          const TemplateFieldDefinition(id: 'monthly_rent', label: 'Monthly Rent', type: TemplateField.currency, required: true),
          const TemplateFieldDefinition(id: 'security_deposit', label: 'Security Deposit', type: TemplateField.currency, required: true),
          const TemplateFieldDefinition(id: 'governing_state', label: 'Governing State', required: true),
        ],
        content: '''
RESIDENTIAL LEASE AGREEMENT

This Residential Lease Agreement (the "Lease") is made and entered into as of {{start_date}}, by and between:

LANDLORD:
{{landlord_name}}
{{landlord_address}}

and

TENANT:
{{tenant_name}}

PROPERTY:
{{property_address}}

1. PREMISES
Landlord leases to Tenant the residential premises located at the address above (the "Premises"), together with all fixtures and appliances.

2. TERM
The term of this Lease shall be from {{start_date}} through {{end_date}}.

3. RENT
Tenant agrees to pay Landlord monthly rent of {{monthly_rent}}, payable on the first day of each month.

4. SECURITY DEPOSIT
Tenant shall pay a security deposit of {{security_deposit}} upon execution of this Lease. The deposit shall be returned within the time required by law after Tenant vacates the Premises.

5. UTILITIES
Tenant shall be responsible for payment of all utilities and services, except: [list utilities paid by Landlord].

6. USE OF PREMISES
The Premises shall be used solely for residential purposes. Tenant shall not engage in any illegal activities on the Premises.

7. MAINTENANCE
Tenant shall keep the Premises in clean and sanitary condition. Tenant shall promptly notify Landlord of any needed repairs.

8. ALTERATIONS
Tenant shall not make any alterations to the Premises without Landlord's prior written consent.

9. PETS
[ ] Pets are NOT allowed
[ ] Pets are allowed with Landlord's written consent and additional deposit

10. ACCESS BY LANDLORD
Landlord may enter the Premises with reasonable notice for inspection, repairs, or showing to prospective tenants.

11. DEFAULT
If Tenant fails to pay rent or violates any term of this Lease, Landlord may terminate this Lease and regain possession.

12. GOVERNING LAW
This Lease shall be governed by and construed in accordance with the laws of the State of {{governing_state}}.

IN WITNESS WHEREOF, the parties have executed this Lease as of the date first written above.

LANDLORD: _________________________
{{landlord_name}}
Date: _____________

TENANT: _________________________
{{tenant_name}}
Date: _____________
''',
      ),
    ];
  }

  List<LegalTemplate> getTemplatesByCategory(TemplateCategory category) {
    return _templates.where((t) => t.category == category).toList();
  }

  List<LegalTemplate> searchTemplates(String query) {
    final normalizedQuery = query.toLowerCase();
    return _templates.where((t) {
      return t.name.toLowerCase().contains(normalizedQuery) ||
          t.description.toLowerCase().contains(normalizedQuery) ||
          t.tags.any((tag) => tag.toLowerCase().contains(normalizedQuery));
    }).toList();
  }

  LegalTemplate? getTemplateById(String id) {
    try {
      return _templates.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}
