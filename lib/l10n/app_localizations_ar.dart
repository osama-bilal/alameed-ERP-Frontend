// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get aboutTitle => 'حول نظام العميد ERP';

  @override
  String get companyName => 'العميد للاتصالات';

  @override
  String get appName => 'تطبيق العميد ERP';

  @override
  String get appDescription =>
      'تم تطوير هذا التطبيق باستخدام Flutter كواجهة عميل لمشروع ERP (تخطيط موارد المؤسسات) لمتجر العميد للاتصالات.';

  @override
  String get githubLinkText =>
      'يعمل التطبيق كواجهة للتحكم وإدارة البيانات على الخادم، والذي يمكنك العثور عليه على GitHub.';

  @override
  String get developmentPhaseNote =>
      'لا يزال المشروع في مرحلة التطوير ويتطلب ترقيات كبيرة للوصول إلى إمكاناته الكاملة.';

  @override
  String get personalJourneyTitle => 'رحلة شخصية';

  @override
  String get personalJourneyText1 =>
      'تم تطوير تطبيق الواجهة الأمامية هذا بواسطة أسامة بلال باستخدام Flutter. بدأ المشروع في سبتمبر 2025، بعد تخرجه من كلية الحاسوب وبعد مرافقة والدته في رحلة علاجها من الساركوما العظمية في مصر.';

  @override
  String get personalJourneyText2 =>
      'تم إنشاء المشروع الرئيسي كوسيلة للتعبير عن الامتنان لوالده وتلبية الحاجة لهذا النظام في متجرهم.';

  @override
  String get personalJourneyText3 =>
      'هذا المشروع هو نتيجة أكثر من شهرين ونصف من العمل المتفاني، والتطوير مستمر لإضافة الميزات وإصلاح المشكلات.';

  @override
  String get dedicationText =>
      'تم ذلك بحب، مع تقديم كل الحب والاحترام لوالدي. أنا ممتن لجهودهم في تعليمي وتربيتي تربية صالحة. لا يسعني إلا أن أقول لهم: \"جزاكم الله عني خير الجزاء\". مهما فعلت ومهما قدمت لكم، لن أستطيع أن أوفيكم حقكم.';

  @override
  String get madeWithLove => 'صنع بحب. ❤️';

  @override
  String couldNotLaunchUrl(Object url) {
    return 'لا يمكن فتح الرابط $url';
  }

  @override
  String invoiceNumber(Object id) {
    return 'رقم الفاتورة: $id';
  }

  @override
  String get returnMoney => 'استرداد المبلغ';

  @override
  String get replace => 'استبدال';

  @override
  String get invoiceNotFound => 'الفاتورة غير موجودة أو لا تحتوي على عناصر.';

  @override
  String get unknown => 'غير معروف';

  @override
  String get chooseItemToReturn => 'اختر العنصر للإرجاع';

  @override
  String returnForInvoice(Object id) {
    return 'إرجاع للفاتورة رقم $id';
  }

  @override
  String replaceStarted(Object id) {
    return 'بدأ الاستبدال للفاتورة الجديدة رقم $id';
  }

  @override
  String get returnSuccess => 'تمت عملية الإرجاع بنجاح!';

  @override
  String get totalReturnAmount => 'إجمالي مبلغ الإرجاع';

  @override
  String get createStockAdjustment => 'إنشاء تسوية مخزون';

  @override
  String get saveAdjustment => 'حفظ التسوية';

  @override
  String get adjustmentSaved => 'تم حفظ التسوية بنجاح!';

  @override
  String error(Object error) {
    return 'خطأ: $error';
  }

  @override
  String get selectProductVariant => 'اختر نوع المنتج';

  @override
  String get productVariant => 'نوع المنتج';

  @override
  String get pleaseSelectVariant => 'الرجاء اختيار نوع';

  @override
  String get increase => 'زيادة';

  @override
  String get decrease => 'نقصان';

  @override
  String get quantity => 'الكمية';

  @override
  String get enterQuantity => 'الرجاء إدخال كمية';

  @override
  String get enterValidQuantity => 'الرجاء إدخال كمية موجبة صحيحة';

  @override
  String get notesOptional => 'ملاحظات (اختياري)';

  @override
  String get editCustomerTitle => 'تعديل بيانات العميل';

  @override
  String get nameLabel => 'الاسم';

  @override
  String get phoneLabel => 'الهاتف';

  @override
  String get emailOptionalLabel => 'البريد الإلكتروني (اختياري)';

  @override
  String get addressOptionalLabel => 'العنوان (اختياري)';

  @override
  String get creditLimitLabel => 'الحد الائتماني';

  @override
  String get closeButton => 'إغلاق';

  @override
  String get updateButton => 'تحديث';

  @override
  String get addButton => 'إضافة';
}
