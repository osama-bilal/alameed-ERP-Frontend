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

  @override
  String get attendances => 'الحضور';

  @override
  String get sales => 'المبيعات';

  @override
  String get expenses => 'المصروفات';

  @override
  String get reports => 'التقارير';

  @override
  String get settings => 'الإعدادات';

  @override
  String get appearance => 'المظهر';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get help => 'مساعدة';

  @override
  String get about => 'حول';

  @override
  String get language => 'اللغة';

  @override
  String get currency => 'العملة';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get backup => 'النسخ الاحتياطي';

  @override
  String get restore => 'استعادة';

  @override
  String get dataSync => 'مزامنة البيانات';

  @override
  String get users => 'المستخدمون';

  @override
  String get roles => 'الأدوار';

  @override
  String get permissions => 'الصلاحيات';

  @override
  String get logs => 'السجلات';

  @override
  String get systemInfo => 'معلومات النظام';

  @override
  String get support => 'الدعم';

  @override
  String get feedback => 'التعليقات';

  @override
  String get deletedSuccessfully => 'تم الحذف بنجاح';

  @override
  String get updatedSuccessfully => 'تم التحديث بنجاح';

  @override
  String get createdSuccessfully => 'تم الإنشاء بنجاح';

  @override
  String get brands => 'العلامات التجارية';

  @override
  String get categories => 'الفئات';

  @override
  String get options => 'الخيارات';

  @override
  String get values => 'القيم';

  @override
  String get customers => 'العملاء';

  @override
  String get employees => 'الموظفون';

  @override
  String get suppliers => 'الموردون';

  @override
  String get products => 'المنتجات';

  @override
  String get invoices => 'الفواتير';

  @override
  String get expensesPlural => 'المصروفات';

  @override
  String get reportsPlural => 'التقارير';

  @override
  String get settingsPlural => 'الإعدادات';

  @override
  String get usersPlural => 'المستخدمون';

  @override
  String get rolesPlural => 'الأدوار';

  @override
  String get permissionsPlural => 'الصلاحيات';

  @override
  String get debtsPayments => 'مبالغ الديون المدفوعة';

  @override
  String get debts => 'الديون';

  @override
  String get deposits => 'الودائع';

  @override
  String get groups => 'المجموعات';

  @override
  String get createGroup => 'إنشاء مجموعة';

  @override
  String get editGroup => 'تعديل مجموعة';

  @override
  String get groupName => 'اسم المجموعة';

  @override
  String get pleaseEnterGroupName => 'الرجاء إدخال اسم المجموعة';

  @override
  String get permissionsForGroup => 'الصلاحيات للمجموعة';

  @override
  String get addPermission => 'إضافة صلاحية';

  @override
  String get removePermission => 'إزالة صلاحية';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get createPaymentMethod => 'إنشاء طريقة دفع';

  @override
  String get editPaymentMethod => 'تعديل طريقة دفع';

  @override
  String get methodName => 'اسم الطريقة';

  @override
  String get pleaseEnterMethodName => 'الرجاء إدخال اسم الطريقة';

  @override
  String get payrolls => 'الرواتب';

  @override
  String get salary => 'الراتب';

  @override
  String get createPayroll => 'إنشاء راتب';

  @override
  String get editPayroll => 'تعديل راتب';

  @override
  String get employee => 'الموظف';

  @override
  String get selectEmployee => 'اختر موظف';

  @override
  String get amount => 'المبلغ';

  @override
  String get pleaseEnterAmount => 'الرجاء إدخال المبلغ';

  @override
  String get paymentDate => 'تاريخ الدفع';

  @override
  String get selectPaymentDate => 'اختر تاريخ الدفع';

  @override
  String get productsInStock => 'المنتجات في المخزون';

  @override
  String get outOfStock => 'نفد من المخزون';

  @override
  String get lowStock => 'المخزون منخفض';

  @override
  String get stockAdjustments => 'تسويات المخزون';

  @override
  String get stockMovements => 'حركات المخزون';

  @override
  String get editStockAdjustment => 'تعديل تسوية المخزون';

  @override
  String get adjustmentDate => 'تاريخ التسوية';

  @override
  String get selectAdjustmentDate => 'اختر تاريخ التسوية';

  @override
  String get notes => 'ملاحظات';

  @override
  String get transactionType => 'نوع المعاملة';

  @override
  String get increaseStock => 'زيادة المخزون';

  @override
  String get decreaseStock => 'تقليل المخزون';

  @override
  String get transactionDate => 'تاريخ المعاملة';

  @override
  String get selectTransactionDate => 'اختر تاريخ المعاملة';

  @override
  String get transactions => 'المعاملات';

  @override
  String get confirmDelete => 'تأكيد الحذف';

  @override
  String confirmDeleteGroup(Object name) {
    return 'هل أنت متأكد من حذف المجموعة $name?';
  }

  @override
  String get purchaseInvoice => 'فاتورة شراء';

  @override
  String get salesInvoice => 'فاتورة بيع';

  @override
  String get createInvoice => 'إنشاء فاتورة';

  @override
  String get purchases => 'المشتريات';

  @override
  String get shifts => 'الورودية';

  @override
  String get returns => 'الإرجاعات';

  @override
  String get notFound => 'لم يتم العثور';

  @override
  String get createBrand => 'اضافة براند';

  @override
  String get editBrand => 'تعديل براند';

  @override
  String get chooseInvoiceSaveLocation => 'اختر موقع حفظ الفاتورة';

  @override
  String get saveAsPdfCancelled => 'تم إلغاء حفظ كملف PDF';

  @override
  String errorSavingPdf(Object error) {
    return 'حدث خطأ أثناء حفظ ملف PDF: $error';
  }

  @override
  String get failedToLoadPaymentMethods =>
      'فشل في تحميل طرق الدفع. الرجاء المحاولة مرة أخرى.';

  @override
  String get accounting => 'الحسابات';

  @override
  String get hr => 'الموارد البشرية';

  @override
  String get inventory => 'المخزون';

  @override
  String get setting => 'الإعدادات';

  @override
  String get pos => 'نقطة المبيعات';

  @override
  String get home => 'الرئيسية';

  @override
  String get admin => 'إدارة';

  @override
  String get account => 'حساب';

  @override
  String get description => 'الوصف';

  @override
  String get categoryName => 'اسم الفئة';

  @override
  String get refundStatus => 'حالة الاسترداد';

  @override
  String get reportIdLabel => 'رقم التقرير';

  @override
  String get reportTypeLabel => 'نوع التقرير';

  @override
  String get periodLabel => 'فترة';

  @override
  String get financialSummaryLabel => 'ملخص مالي';

  @override
  String get totalSalesLabel => 'إجمالي المبيعات';

  @override
  String get totalDepositsLabel => 'إجمالي الودائع';

  @override
  String get totalExpensesLabel => 'إجمالي المصروفات';

  @override
  String get totalWithdrawsLabel => 'إجمالي التحويلات';

  @override
  String get netProfitLabel => 'الربح';

  @override
  String get activitySummaryLabel => 'ملخص النشاط';

  @override
  String get totalInvoicesLabel => 'إجمالي الفواتير';

  @override
  String get productsSoldLabel => 'إجمالي المنتجات المبيعات';

  @override
  String get productsReturnedLabel => 'إجمالي المنتجات المرتجعة';

  @override
  String get report => 'التقرير';

  @override
  String get printReport => 'طباعة التقرير';

  @override
  String get user => 'المستخدم';

  @override
  String get note => 'ملاحظة';

  @override
  String get done => 'تم';

  @override
  String get languageCode => 'ar';

  @override
  String get product => 'المنتج';

  @override
  String get unitPrice => 'سعر الوحدة';
}
