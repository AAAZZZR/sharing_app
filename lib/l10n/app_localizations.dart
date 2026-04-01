import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale('zh', 'CN'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'學習庫'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In zh, this message translates to:
  /// **'首頁'**
  String get navHome;

  /// No description provided for @navTags.
  ///
  /// In zh, this message translates to:
  /// **'標籤'**
  String get navTags;

  /// No description provided for @navSearch.
  ///
  /// In zh, this message translates to:
  /// **'搜尋'**
  String get navSearch;

  /// No description provided for @navSettings.
  ///
  /// In zh, this message translates to:
  /// **'設定'**
  String get navSettings;

  /// No description provided for @homeTitle.
  ///
  /// In zh, this message translates to:
  /// **'學習庫'**
  String get homeTitle;

  /// No description provided for @filterAll.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get filterAll;

  /// No description provided for @homeEmpty.
  ///
  /// In zh, this message translates to:
  /// **'還沒有內容\n從其他 app 分享連結到這裡'**
  String get homeEmpty;

  /// No description provided for @openOriginal.
  ///
  /// In zh, this message translates to:
  /// **'開啟原文'**
  String get openOriginal;

  /// No description provided for @aiSummary.
  ///
  /// In zh, this message translates to:
  /// **'AI 摘要'**
  String get aiSummary;

  /// No description provided for @myNotes.
  ///
  /// In zh, this message translates to:
  /// **'我的筆記'**
  String get myNotes;

  /// No description provided for @noteHint.
  ///
  /// In zh, this message translates to:
  /// **'輸入筆記...'**
  String get noteHint;

  /// No description provided for @addNewTag.
  ///
  /// In zh, this message translates to:
  /// **'+ 新標籤'**
  String get addNewTag;

  /// No description provided for @addTagTitle.
  ///
  /// In zh, this message translates to:
  /// **'新增標籤'**
  String get addTagTitle;

  /// No description provided for @tagNameHint.
  ///
  /// In zh, this message translates to:
  /// **'標籤名稱'**
  String get tagNameHint;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In zh, this message translates to:
  /// **'新增'**
  String get add;

  /// No description provided for @contentNotFound.
  ///
  /// In zh, this message translates to:
  /// **'內容不存在'**
  String get contentNotFound;

  /// No description provided for @searchTitle.
  ///
  /// In zh, this message translates to:
  /// **'搜尋'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜尋標題、摘要、筆記...'**
  String get searchHint;

  /// No description provided for @searchEmpty.
  ///
  /// In zh, this message translates to:
  /// **'輸入關鍵字搜尋\n搜尋範圍：標題、AI 摘要、筆記'**
  String get searchEmpty;

  /// No description provided for @searchNoResults.
  ///
  /// In zh, this message translates to:
  /// **'找不到相關內容'**
  String get searchNoResults;

  /// No description provided for @settingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'設定'**
  String get settingsTitle;

  /// No description provided for @aiService.
  ///
  /// In zh, this message translates to:
  /// **'AI 服務'**
  String get aiService;

  /// No description provided for @apiKeys.
  ///
  /// In zh, this message translates to:
  /// **'API Keys'**
  String get apiKeys;

  /// No description provided for @dataSection.
  ///
  /// In zh, this message translates to:
  /// **'資料'**
  String get dataSection;

  /// No description provided for @savedContent.
  ///
  /// In zh, this message translates to:
  /// **'已儲存內容'**
  String get savedContent;

  /// No description provided for @contentCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 則'**
  String contentCount(int count);

  /// No description provided for @apiKeySet.
  ///
  /// In zh, this message translates to:
  /// **'已設定 ✓'**
  String get apiKeySet;

  /// No description provided for @apiKeyNotSet.
  ///
  /// In zh, this message translates to:
  /// **'未設定'**
  String get apiKeyNotSet;

  /// No description provided for @pasteApiKey.
  ///
  /// In zh, this message translates to:
  /// **'貼上 API Key'**
  String get pasteApiKey;

  /// No description provided for @saveToVault.
  ///
  /// In zh, this message translates to:
  /// **'儲存到學習庫'**
  String get saveToVault;

  /// No description provided for @link.
  ///
  /// In zh, this message translates to:
  /// **'連結'**
  String get link;

  /// No description provided for @platformDetected.
  ///
  /// In zh, this message translates to:
  /// **'平台辨識：{platform}'**
  String platformDetected(String platform);

  /// No description provided for @detecting.
  ///
  /// In zh, this message translates to:
  /// **'辨識中...'**
  String get detecting;

  /// No description provided for @metadataLoading.
  ///
  /// In zh, this message translates to:
  /// **'Metadata 擷取中...'**
  String get metadataLoading;

  /// No description provided for @metadataDone.
  ///
  /// In zh, this message translates to:
  /// **'Metadata 擷取完成'**
  String get metadataDone;

  /// No description provided for @aiSummaryLoading.
  ///
  /// In zh, this message translates to:
  /// **'AI 摘要生成中...'**
  String get aiSummaryLoading;

  /// No description provided for @aiSummaryDone.
  ///
  /// In zh, this message translates to:
  /// **'AI 摘要完成'**
  String get aiSummaryDone;

  /// No description provided for @quickNote.
  ///
  /// In zh, this message translates to:
  /// **'快速筆記（選填）'**
  String get quickNote;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'儲存'**
  String get save;

  /// No description provided for @noApiKey.
  ///
  /// In zh, this message translates to:
  /// **'未設定 API Key，請到設定頁設定'**
  String get noApiKey;

  /// No description provided for @aiSummaryError.
  ///
  /// In zh, this message translates to:
  /// **'AI 摘要失敗：{error}'**
  String aiSummaryError(String error);

  /// No description provided for @tagsTitle.
  ///
  /// In zh, this message translates to:
  /// **'標籤'**
  String get tagsTitle;

  /// No description provided for @noTags.
  ///
  /// In zh, this message translates to:
  /// **'還沒有標籤'**
  String get noTags;

  /// No description provided for @daysAgo.
  ///
  /// In zh, this message translates to:
  /// **'{count} 天前'**
  String daysAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In zh, this message translates to:
  /// **'{count} 小時前'**
  String hoursAgo(int count);

  /// No description provided for @minutesAgo.
  ///
  /// In zh, this message translates to:
  /// **'{count} 分鐘前'**
  String minutesAgo(int count);

  /// No description provided for @justNow.
  ///
  /// In zh, this message translates to:
  /// **'剛剛'**
  String get justNow;

  /// No description provided for @errorMessage.
  ///
  /// In zh, this message translates to:
  /// **'錯誤：{error}'**
  String errorMessage(String error);

  /// No description provided for @error.
  ///
  /// In zh, this message translates to:
  /// **'錯誤'**
  String get error;

  /// No description provided for @loading.
  ///
  /// In zh, this message translates to:
  /// **'...'**
  String get loading;

  /// No description provided for @language.
  ///
  /// In zh, this message translates to:
  /// **'語言'**
  String get language;

  /// No description provided for @langZh.
  ///
  /// In zh, this message translates to:
  /// **'繁體中文'**
  String get langZh;

  /// No description provided for @langEn.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get langEn;

  /// No description provided for @addLink.
  ///
  /// In zh, this message translates to:
  /// **'新增連結'**
  String get addLink;

  /// No description provided for @pasteLinkHint.
  ///
  /// In zh, this message translates to:
  /// **'貼上網址...'**
  String get pasteLinkHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'CN':
            return AppLocalizationsZhCn();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
