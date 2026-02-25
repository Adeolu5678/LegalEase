import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, dynamic> _localizedStrings;

  AppLocalizations(this.locale);

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('pt'),
  ];

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    AppLocalizationsDelegate(),
  ];

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();

  Future<bool> load() async {
    String jsonString = await rootBundle.loadString(
      'lib/l10n/app_${locale.languageCode}.arb',
    );
    _localizedStrings = json.decode(jsonString) as Map<String, dynamic>;
    return true;
  }

  String translate(String key) {
    final keys = key.split('.');
    dynamic value = _localizedStrings;
    
    for (final k in keys) {
      if (value is Map<String, dynamic> && value.containsKey(k)) {
        value = value[k];
      } else {
        return key;
      }
    }
    
    return value is String ? value : key;
  }

  String t(String key) => translate(key);

  String? translateWithArgs(String key, Map<String, String> args) {
    String text = translate(key);
    args.forEach((argKey, argValue) {
      text = text.replaceAll('{$argKey}', argValue);
    });
    return text;
  }

  String get appName => translate('appName');
  String get appTagline => translate('appTagline');
  
  String get home => translate('navigation.home');
  String get scan => translate('navigation.scan');
  String get chat => translate('navigation.chat');
  String get settings => translate('navigation.settings');
  String get dictionary => translate('navigation.dictionary');
  String get subscription => translate('navigation.subscription');

  String get homeScreenTitle => translate('homeScreen.title');
  String get homeScreenSubtitle => translate('homeScreen.subtitle');
  String get scanNewDocument => translate('homeScreen.scanNewDocument');
  String get recentDocuments => translate('homeScreen.recentDocuments');
  String get noDocuments => translate('homeScreen.noDocuments');
  String get quickActions => translate('homeScreen.quickActions');

  String get documentScanTitle => translate('documentScan.title');
  String get uploadFromGallery => translate('documentScan.uploadFromGallery');
  String get takePhoto => translate('documentScan.takePhoto');
  String get uploadPdf => translate('documentScan.uploadPdf');
  String get uploadFromCloud => translate('documentScan.uploadFromCloud');
  String get analyzing => translate('documentScan.analyzing');
  String get analysisComplete => translate('documentScan.analysisComplete');
  String get analysisFailed => translate('documentScan.analysisFailed');

  String get analysisTitle => translate('analysis.title');
  String get summary => translate('analysis.summary');
  String get redFlags => translate('analysis.redFlags');
  String get plainEnglish => translate('analysis.plainEnglish');
  String get originalText => translate('analysis.originalText');
  String get noRedFlags => translate('analysis.noRedFlags');
  String redFlagsFound(int count) => translateWithArgs('analysis.redFlagsFound', {'count': count.toString()}) ?? '';
  String get criticalSeverity => translate('analysis.criticalSeverity');
  String get warningSeverity => translate('analysis.warningSeverity');
  String get infoSeverity => translate('analysis.infoSeverity');
  String get confidence => translate('analysis.confidence');
  String get highConfidence => translate('analysis.highConfidence');
  String get mediumConfidence => translate('analysis.mediumConfidence');
  String get lowConfidence => translate('analysis.lowConfidence');

  String get chatTitle => translate('chat.title');
  String get chatPlaceholder => translate('chat.placeholder');
  String get send => translate('chat.send');
  String get typing => translate('chat.typing');
  String get suggestedQuestions => translate('chat.suggestedQuestions');
  String get noMessages => translate('chat.noMessages');
  String get voiceInput => translate('chat.voiceInput');

  String get dictionaryTitle => translate('dictionary.title');
  String get dictionarySearch => translate('dictionary.search');
  String get noResults => translate('dictionary.noResults');

  String get exportTitle => translate('export.title');
  String get exportPdf => translate('export.exportPdf');
  String get exportWord => translate('export.exportWord');
  String get exportEmail => translate('export.exportEmail');
  String get shareAnalysis => translate('export.shareAnalysis');
  String get exporting => translate('export.exporting');
  String get exportSuccess => translate('export.exportSuccess');
  String get exportFailed => translate('export.exportFailed');

  String get subscriptionTitle => translate('subscription.title');
  String get currentPlan => translate('subscription.currentPlan');
  String get free => translate('subscription.free');
  String get premium => translate('subscription.premium');
  String get premiumFeatures => translate('subscription.premiumFeatures');
  String get unlimitedScans => translate('subscription.unlimitedScans');
  String get advancedAnalysis => translate('subscription.advancedAnalysis');
  String get prioritySupport => translate('subscription.prioritySupport');
  String get exportOptions => translate('subscription.exportOptions');
  String get subscribe => translate('subscription.subscribe');
  String get restorePurchases => translate('subscription.restorePurchases');
  String get manageSubscription => translate('subscription.manageSubscription');

  String get login => translate('auth.login');
  String get signup => translate('auth.signup');
  String get email => translate('auth.email');
  String get password => translate('auth.password');
  String get confirmPassword => translate('auth.confirmPassword');
  String get forgotPassword => translate('auth.forgotPassword');
  String get loginWithGoogle => translate('auth.loginWithGoogle');
  String get loginWithApple => translate('auth.loginWithApple');
  String get noAccount => translate('auth.noAccount');
  String get hasAccount => translate('auth.hasAccount');
  String get logout => translate('auth.logout');

  String get settingsTitle => translate('settings.title');
  String get account => translate('settings.account');
  String get preferences => translate('settings.preferences');
  String get language => translate('settings.language');
  String get theme => translate('settings.theme');
  String get notifications => translate('settings.notifications');
  String get privacy => translate('settings.privacy');
  String get about => translate('settings.about');
  String get version => translate('settings.version');

  String get annotationsTitle => translate('annotations.title');
  String get addAnnotation => translate('annotations.addAnnotation');
  String get editAnnotation => translate('annotations.editAnnotation');
  String get deleteAnnotation => translate('annotations.deleteAnnotation');
  String get resolved => translate('annotations.resolved');
  String get open => translate('annotations.open');
  String get total => translate('annotations.total');
  String get noAnnotations => translate('annotations.noAnnotations');
  String get selectTextHint => translate('annotations.selectTextHint');

  String get searchTitle => translate('search.title');
  String get searchPlaceholder => translate('search.placeholder');
  String get noSearchResults => translate('search.noResults');
  String get recentSearches => translate('search.recentSearches');
  String get filters => translate('search.filters');

  String get comparisonTitle => translate('comparison.title');
  String get selectDocuments => translate('comparison.selectDocuments');
  String get document1 => translate('comparison.document1');
  String get document2 => translate('comparison.document2');
  String get compare => translate('comparison.compare');
  String get differences => translate('comparison.differences');
  String get additions => translate('comparison.additions');
  String get deletions => translate('comparison.deletions');
  String get noDifferences => translate('comparison.noDifferences');

  String get templatesTitle => translate('templates.title');
  String get preview => translate('templates.preview');
  String get useTemplate => translate('templates.useTemplate');
  String get customize => translate('templates.customize');

  String get sharingTitle => translate('sharing.title');
  String get generateLink => translate('sharing.generateLink');
  String get linkExpires => translate('sharing.linkExpires');
  String get passwordProtection => translate('sharing.passwordProtection');
  String get copyLink => translate('sharing.copyLink');
  String get shareViaEmail => translate('sharing.shareViaEmail');
  String get qrCode => translate('sharing.qrCode');

  String get cloudStorageTitle => translate('cloudStorage.title');
  String get connectAccount => translate('cloudStorage.connectAccount');
  String get googleDrive => translate('cloudStorage.googleDrive');
  String get dropbox => translate('cloudStorage.dropbox');
  String get oneDrive => translate('cloudStorage.oneDrive');
  String get connected => translate('cloudStorage.connected');
  String get disconnect => translate('cloudStorage.disconnect');
  String get browseFiles => translate('cloudStorage.browseFiles');
  String get syncSettings => translate('cloudStorage.syncSettings');

  String get offlineMode => translate('offline.offlineMode');
  String get offlineMessage => translate('offline.offlineMessage');
  String get syncPending => translate('offline.syncPending');
  String get lastSynced => translate('offline.lastSynced');

  String get teamTitle => translate('team.title');
  String get createTeam => translate('team.createTeam');
  String get joinTeam => translate('team.joinTeam');
  String get teamMembers => translate('team.teamMembers');
  String get inviteMember => translate('team.inviteMember');
  String get teamDocuments => translate('team.teamDocuments');

  String get remindersTitle => translate('reminders.title');
  String get addReminder => translate('reminders.addReminder');
  String get contractDeadline => translate('reminders.contractDeadline');
  String get renewalDate => translate('reminders.renewalDate');
  String get expirationDate => translate('reminders.expirationDate');
  String get notificationTime => translate('reminders.notificationTime');
  String get noReminders => translate('reminders.noReminders');

  String get loading => translate('common.loading');
  String get error => translate('common.error');
  String get success => translate('common.success');
  String get cancel => translate('common.cancel');
  String get save => translate('common.save');
  String get delete => translate('common.delete');
  String get edit => translate('common.edit');
  String get done => translate('common.done');
  String get next => translate('common.next');
  String get previous => translate('common.previous');
  String get close => translate('common.close');
  String get confirm => translate('common.confirm');
  String get retry => translate('common.retry');
  String get yes => translate('common.yes');
  String get no => translate('common.no');
  String get ok => translate('common.ok');

  String get genericError => translate('errors.generic');
  String get networkError => translate('errors.networkError');
  String get authError => translate('errors.authError');
  String get permissionDenied => translate('errors.permissionDenied');
  String get fileNotFound => translate('errors.fileNotFound');
  String get invalidFile => translate('errors.invalidFile');
  String get analysisFailedError => translate('errors.analysisFailed');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es', 'fr', 'de', 'pt'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this) ?? AppLocalizations(const Locale('en'));
}