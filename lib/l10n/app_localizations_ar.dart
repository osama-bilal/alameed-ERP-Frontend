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

  @override
  String get cantAccessPage => 'لا يمكن الوصول إلى هذه الصفحة.';

  @override
  String get openingBalance => 'الرصيد الافتتاحي';

  @override
  String get closingBalance => 'الرصيد الختامي';

  @override
  String get cancel => ' إلغاء';

  @override
  String get continueString => 'متابعة';

  @override
  String get welcome => 'مرحباً';

  @override
  String get whatHappenInyourShop => 'هنا ما يحدث في متجرك';

  @override
  String get openShiftFirst => 'افتح الوردية أولاً';

  @override
  String get openShift => 'افتح الوردية';

  @override
  String get openedAt => 'تم الفتح في';

  @override
  String get openBalance => 'الرصيد الافتتاحي';

  @override
  String get openBalanceNote =>
      'الرصيد الافتتاحي هو المبلغ الذي يبدأ به المتجر في بداية اليوم.';

  @override
  String get closeShift => 'إغلاق الوردية';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get loginFailed =>
      'فشل تسجيل الدخول. الرجاء التحقق من بيانات الاعتماد الخاصة بك والمحاولة مرة أخرى.';

  @override
  String productWithBarcode(Object barcode) {
    return 'لم يتم العثور على المنتج $barcode ';
  }

  @override
  String get invoice => 'فاتورة';

  @override
  String get returnString => 'إرجاع';

  @override
  String get scanCode => 'مسح الرمز';

  @override
  String get chooseProducts => 'اختر المنتجات';

  @override
  String get editVariant => 'تعديل النوع';

  @override
  String get addVariant => 'إضافة نوع';

  @override
  String get loading => 'جار التحميل...';

  @override
  String get save => 'حفظ';

  @override
  String get createProduct => 'إنشاء منتج';

  @override
  String get editProduct => 'تعديل المنتج';

  @override
  String get productDetails => 'تفاصيل المنتج';

  @override
  String get productName => 'اسم المنتج';

  @override
  String get pleaseEnterAName => 'الرجاء إدخال اسم';

  @override
  String get add => 'إضافة';

  @override
  String get brandName => 'اسم العلامة التجارية';

  @override
  String get selectBrand => 'اختر العلامة التجارية';

  @override
  String get selectCategory => 'اختر الفئة';

  @override
  String get isActive => 'نشط';

  @override
  String get variants => 'الأنواع';

  @override
  String get novariantsAddedClickTheButtonToAddOne =>
      'لم تتم إضافة أنواع. انقر على الزر لإضافة نوع.';

  @override
  String get price => 'السعر';

  @override
  String get qty => 'الكمية';

  @override
  String get barcode => 'الباركود';

  @override
  String get cost => 'التكلفة';

  @override
  String get areYouSureCancleTheInvoice => 'هل أنت متأكد من إلغاء الفاتورة؟';

  @override
  String get no => 'لا';

  @override
  String get makeCancelled => 'إلغاء الفاتورة';

  @override
  String get selectAction => 'اختر إجراء';

  @override
  String get choseOneOfThoseActionsToDoOrExit =>
      'اختر إحدى الإجراءات لتنفيذها أو الخروج';

  @override
  String get saveAsPDF => 'حفظ كملف PDF';

  @override
  String get print => 'طباعة';

  @override
  String get subtotal => 'المجموع الفرعي';

  @override
  String get discount => 'الخصم';

  @override
  String get tax => 'الضريبة';

  @override
  String get total => 'المجموع الإجمالي';

  @override
  String get forCustomer => 'لعميل';

  @override
  String get notExist => 'غير موجود!';

  @override
  String get selectPaymentMethod => 'اختر طريقة الدفع';

  @override
  String get filedToLoad => 'فشل التحميل. الرجاء المحاولة مرة أخرى.';

  @override
  String get thePaidAmount => 'المبلغ المدفوع';

  @override
  String get theRemainingWillBeAddedAsADebtOnTheCustomer =>
      'سيتم إضافة المبلغ المتبقي كديون على العميل';

  @override
  String get partial => 'جزئي';

  @override
  String get addNotesToTheInvoice => 'إضافة ملاحظات إلى الفاتورة';

  @override
  String get thePaidMustBeEqualOrGreaterThanTotal =>
      'يجب أن يكون المبلغ المدفوع مساويًا أو أكبر من المجموع الإجمالي';

  @override
  String get savePrint => 'حفظ وطباعة';

  @override
  String get addToDebit => 'إضافة إلى الديون';

  @override
  String get confirmLogout => 'تأكيد تسجيل الخروج';

  @override
  String get sureToLogOut => 'هل أنت متأكد من أنك تريد تسجيل الخروج؟';

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get darkMode => 'الوضع الليلي';

  @override
  String get manageGroups => 'إدارة المجموعات';

  @override
  String get customer => 'عميل';

  @override
  String get supplier => 'المورد';

  @override
  String get items => 'العناصر';

  @override
  String get date => 'التاريخ';

  @override
  String get status => 'الحالة';

  @override
  String get paid => 'مدفوع';

  @override
  String get remaining => 'المتبقي';

  @override
  String get sureSaveBill => 'هل أنت متأكد من حفظ الفاتورة؟';

  @override
  String get afterContinueYouCantEditBill =>
      'بعد المتابعة لا يمكنك تعديل أي شيء في الفاتورة.';

  @override
  String get checkout => 'الدفع';

  @override
  String get clear => 'مسح';
}
