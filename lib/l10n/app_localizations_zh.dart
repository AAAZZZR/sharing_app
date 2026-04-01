// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '學習庫';

  @override
  String get navHome => '首頁';

  @override
  String get navTags => '標籤';

  @override
  String get navSearch => '搜尋';

  @override
  String get navSettings => '設定';

  @override
  String get homeTitle => '學習庫';

  @override
  String get filterAll => '全部';

  @override
  String get homeEmpty => '還沒有內容\n從其他 app 分享連結到這裡';

  @override
  String get openOriginal => '開啟原文';

  @override
  String get aiSummary => 'AI 摘要';

  @override
  String get myNotes => '我的筆記';

  @override
  String get noteHint => '輸入筆記...';

  @override
  String get addNewTag => '+ 新標籤';

  @override
  String get addTagTitle => '新增標籤';

  @override
  String get tagNameHint => '標籤名稱';

  @override
  String get cancel => '取消';

  @override
  String get add => '新增';

  @override
  String get contentNotFound => '內容不存在';

  @override
  String get searchTitle => '搜尋';

  @override
  String get searchHint => '搜尋標題、摘要、筆記...';

  @override
  String get searchEmpty => '輸入關鍵字搜尋\n搜尋範圍：標題、AI 摘要、筆記';

  @override
  String get searchNoResults => '找不到相關內容';

  @override
  String get settingsTitle => '設定';

  @override
  String get aiService => 'AI 服務';

  @override
  String get apiKeys => 'API Keys';

  @override
  String get dataSection => '資料';

  @override
  String get savedContent => '已儲存內容';

  @override
  String contentCount(int count) {
    return '$count 則';
  }

  @override
  String get apiKeySet => '已設定 ✓';

  @override
  String get apiKeyNotSet => '未設定';

  @override
  String get pasteApiKey => '貼上 API Key';

  @override
  String get saveToVault => '儲存到學習庫';

  @override
  String get link => '連結';

  @override
  String platformDetected(String platform) {
    return '平台辨識：$platform';
  }

  @override
  String get detecting => '辨識中...';

  @override
  String get metadataLoading => 'Metadata 擷取中...';

  @override
  String get metadataDone => 'Metadata 擷取完成';

  @override
  String get aiSummaryLoading => 'AI 摘要生成中...';

  @override
  String get aiSummaryDone => 'AI 摘要完成';

  @override
  String get quickNote => '快速筆記（選填）';

  @override
  String get save => '儲存';

  @override
  String get noApiKey => '未設定 API Key，請到設定頁設定';

  @override
  String aiSummaryError(String error) {
    return 'AI 摘要失敗：$error';
  }

  @override
  String get tagsTitle => '標籤';

  @override
  String get noTags => '還沒有標籤';

  @override
  String daysAgo(int count) {
    return '$count 天前';
  }

  @override
  String hoursAgo(int count) {
    return '$count 小時前';
  }

  @override
  String minutesAgo(int count) {
    return '$count 分鐘前';
  }

  @override
  String get justNow => '剛剛';

  @override
  String errorMessage(String error) {
    return '錯誤：$error';
  }

  @override
  String get error => '錯誤';

  @override
  String get loading => '...';
}

/// The translations for Chinese, as used in China (`zh_CN`).
class AppLocalizationsZhCn extends AppLocalizationsZh {
  AppLocalizationsZhCn() : super('zh_CN');

  @override
  String get appTitle => '学习库';

  @override
  String get navHome => '首页';

  @override
  String get navTags => '标签';

  @override
  String get navSearch => '搜索';

  @override
  String get navSettings => '设置';

  @override
  String get homeTitle => '学习库';

  @override
  String get filterAll => '全部';

  @override
  String get homeEmpty => '还没有内容\n从其他 app 分享链接到这里';

  @override
  String get openOriginal => '打开原文';

  @override
  String get aiSummary => 'AI 摘要';

  @override
  String get myNotes => '我的笔记';

  @override
  String get noteHint => '输入笔记...';

  @override
  String get addNewTag => '+ 新标签';

  @override
  String get addTagTitle => '新增标签';

  @override
  String get tagNameHint => '标签名称';

  @override
  String get cancel => '取消';

  @override
  String get add => '新增';

  @override
  String get contentNotFound => '内容不存在';

  @override
  String get searchTitle => '搜索';

  @override
  String get searchHint => '搜索标题、摘要、笔记...';

  @override
  String get searchEmpty => '输入关键字搜索\n搜索范围：标题、AI 摘要、笔记';

  @override
  String get searchNoResults => '找不到相关内容';

  @override
  String get settingsTitle => '设置';

  @override
  String get aiService => 'AI 服务';

  @override
  String get apiKeys => 'API Keys';

  @override
  String get dataSection => '数据';

  @override
  String get savedContent => '已保存内容';

  @override
  String contentCount(int count) {
    return '$count 条';
  }

  @override
  String get apiKeySet => '已设定 ✓';

  @override
  String get apiKeyNotSet => '未设定';

  @override
  String get pasteApiKey => '粘贴 API Key';

  @override
  String get saveToVault => '保存到学习库';

  @override
  String get link => '链接';

  @override
  String platformDetected(String platform) {
    return '平台识别：$platform';
  }

  @override
  String get detecting => '识别中...';

  @override
  String get metadataLoading => 'Metadata 提取中...';

  @override
  String get metadataDone => 'Metadata 提取完成';

  @override
  String get aiSummaryLoading => 'AI 摘要生成中...';

  @override
  String get aiSummaryDone => 'AI 摘要完成';

  @override
  String get quickNote => '快速笔记（选填）';

  @override
  String get save => '保存';

  @override
  String get noApiKey => '未设定 API Key，请到设置页设定';

  @override
  String aiSummaryError(String error) {
    return 'AI 摘要失败：$error';
  }

  @override
  String get tagsTitle => '标签';

  @override
  String get noTags => '还没有标签';

  @override
  String daysAgo(int count) {
    return '$count 天前';
  }

  @override
  String hoursAgo(int count) {
    return '$count 小时前';
  }

  @override
  String minutesAgo(int count) {
    return '$count 分钟前';
  }

  @override
  String get justNow => '刚刚';

  @override
  String errorMessage(String error) {
    return '错误：$error';
  }

  @override
  String get error => '错误';

  @override
  String get loading => '...';
}
