// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Learning Vault';

  @override
  String get navHome => 'Home';

  @override
  String get navTags => 'Tags';

  @override
  String get navSearch => 'Search';

  @override
  String get navSettings => 'Settings';

  @override
  String get homeTitle => 'Learning Vault';

  @override
  String get filterAll => 'All';

  @override
  String get homeEmpty => 'No content yet\nShare links from other apps';

  @override
  String get openOriginal => 'Open Original';

  @override
  String get aiSummary => 'AI Summary';

  @override
  String get myNotes => 'My Notes';

  @override
  String get noteHint => 'Enter notes...';

  @override
  String get addNewTag => '+ New Tag';

  @override
  String get addTagTitle => 'Add Tag';

  @override
  String get tagNameHint => 'Tag name';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get contentNotFound => 'Content not found';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchHint => 'Search titles, summaries, notes...';

  @override
  String get searchEmpty =>
      'Enter keywords to search\nScope: titles, AI summaries, notes';

  @override
  String get searchNoResults => 'No results found';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get aiService => 'AI Service';

  @override
  String get apiKeys => 'API Keys';

  @override
  String get dataSection => 'Data';

  @override
  String get savedContent => 'Saved Content';

  @override
  String contentCount(int count) {
    return '$count items';
  }

  @override
  String get apiKeySet => 'Set ✓';

  @override
  String get apiKeyNotSet => 'Not set';

  @override
  String get pasteApiKey => 'Paste API Key';

  @override
  String get saveToVault => 'Save to Vault';

  @override
  String get link => 'Link';

  @override
  String platformDetected(String platform) {
    return 'Platform: $platform';
  }

  @override
  String get detecting => 'Detecting...';

  @override
  String get metadataLoading => 'Extracting metadata...';

  @override
  String get metadataDone => 'Metadata extracted';

  @override
  String get aiSummaryLoading => 'Generating AI summary...';

  @override
  String get aiSummaryDone => 'AI summary complete';

  @override
  String get quickNote => 'Quick note (optional)';

  @override
  String get save => 'Save';

  @override
  String get noApiKey => 'API Key not set. Please configure in Settings.';

  @override
  String aiSummaryError(String error) {
    return 'AI summary failed: $error';
  }

  @override
  String get tagsTitle => 'Tags';

  @override
  String get noTags => 'No tags yet';

  @override
  String daysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String hoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String minutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String get justNow => 'Just now';

  @override
  String errorMessage(String error) {
    return 'Error: $error';
  }

  @override
  String get error => 'Error';

  @override
  String get loading => '...';

  @override
  String get language => 'Language';

  @override
  String get langZh => '繁體中文';

  @override
  String get langEn => 'English';

  @override
  String get addLink => 'Add Link';

  @override
  String get pasteLinkHint => 'Paste URL here...';
}
