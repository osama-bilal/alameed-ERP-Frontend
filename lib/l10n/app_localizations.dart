import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About Alameed ERP'**
  String get aboutTitle;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'Alameed Telecom'**
  String get companyName;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Alameed ERP Application'**
  String get appName;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'This application was developed with Flutter as the client-side for the Alameed Telecom shop ERP (Enterprise Resource Planning) project.'**
  String get appDescription;

  /// No description provided for @githubLinkText.
  ///
  /// In en, this message translates to:
  /// **'The application serves as the interface to control and manage data on the server, which you can find on GitHub.'**
  String get githubLinkText;

  /// No description provided for @developmentPhaseNote.
  ///
  /// In en, this message translates to:
  /// **'The project is still in the development phase and requires significant upgrades to reach its full potential.'**
  String get developmentPhaseNote;

  /// No description provided for @personalJourneyTitle.
  ///
  /// In en, this message translates to:
  /// **'A Personal Journey'**
  String get personalJourneyTitle;

  /// No description provided for @personalJourneyText1.
  ///
  /// In en, this message translates to:
  /// **'This front-end application was developed by Osama Bilal using Flutter. The project began in September 2025, following his graduation from computer college and after accompanying his mother on her treatment journey from parosteal osteosarcoma in Egypt.'**
  String get personalJourneyText1;

  /// No description provided for @personalJourneyText2.
  ///
  /// In en, this message translates to:
  /// **'The main project was established as a way of expressing gratitude to his father and to fulfill the need for this system in their store.'**
  String get personalJourneyText2;

  /// No description provided for @personalJourneyText3.
  ///
  /// In en, this message translates to:
  /// **'This project is the result of over two and a half months of dedicated work, and development is ongoing to add features and fix issues.'**
  String get personalJourneyText3;

  /// No description provided for @dedicationText.
  ///
  /// In en, this message translates to:
  /// **'This was done with love, giving all the love and respect to my parents. I am grateful for their efforts to teach me and to raise me with a good education. I can only tell them, \"May God reward you for me with the best reward.\" Whatever I do and whatever I give you, I will not be able to reward you for what you have given me.'**
  String get dedicationText;

  /// No description provided for @madeWithLove.
  ///
  /// In en, this message translates to:
  /// **'Made with love. ❤️'**
  String get madeWithLove;

  /// No description provided for @couldNotLaunchUrl.
  ///
  /// In en, this message translates to:
  /// **'Could not launch {url}'**
  String couldNotLaunchUrl(Object url);

  /// No description provided for @invoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'Invoice Number: {id}'**
  String invoiceNumber(Object id);

  /// No description provided for @returnMoney.
  ///
  /// In en, this message translates to:
  /// **'Return Money'**
  String get returnMoney;

  /// No description provided for @replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replace;

  /// No description provided for @invoiceNotFound.
  ///
  /// In en, this message translates to:
  /// **'Invoice not found or has no items.'**
  String get invoiceNotFound;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @chooseItemToReturn.
  ///
  /// In en, this message translates to:
  /// **'Choose Item to return'**
  String get chooseItemToReturn;

  /// No description provided for @returnForInvoice.
  ///
  /// In en, this message translates to:
  /// **'Return for Invoice #{id}'**
  String returnForInvoice(Object id);

  /// No description provided for @replaceStarted.
  ///
  /// In en, this message translates to:
  /// **'Replace started for new invoice #{id}'**
  String replaceStarted(Object id);

  /// No description provided for @returnSuccess.
  ///
  /// In en, this message translates to:
  /// **'Return processed successfully!'**
  String get returnSuccess;

  /// No description provided for @totalReturnAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Return Amount'**
  String get totalReturnAmount;

  /// No description provided for @createStockAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Create Stock Adjustment'**
  String get createStockAdjustment;

  /// No description provided for @saveAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Save Adjustment'**
  String get saveAdjustment;

  /// No description provided for @adjustmentSaved.
  ///
  /// In en, this message translates to:
  /// **'Adjustment saved successfully!'**
  String get adjustmentSaved;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error(Object error);

  /// No description provided for @selectProductVariant.
  ///
  /// In en, this message translates to:
  /// **'Select Product Variant'**
  String get selectProductVariant;

  /// No description provided for @productVariant.
  ///
  /// In en, this message translates to:
  /// **'Product Variant'**
  String get productVariant;

  /// No description provided for @pleaseSelectVariant.
  ///
  /// In en, this message translates to:
  /// **'Please select a variant'**
  String get pleaseSelectVariant;

  /// No description provided for @increase.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get increase;

  /// No description provided for @decrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get decrease;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @enterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please enter a quantity'**
  String get enterQuantity;

  /// No description provided for @enterValidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid positive quantity'**
  String get enterValidQuantity;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get notesOptional;

  /// No description provided for @editCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Customer Details'**
  String get editCustomerTitle;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @emailOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Email (Optional)'**
  String get emailOptionalLabel;

  /// No description provided for @addressOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Address (Optional)'**
  String get addressOptionalLabel;

  /// No description provided for @creditLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'Credit Limit'**
  String get creditLimitLabel;

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// No description provided for @updateButton.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateButton;

  /// No description provided for @addButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;

  /// No description provided for @cantAccessPage.
  ///
  /// In en, this message translates to:
  /// **'You cant access to this page'**
  String get cantAccessPage;

  /// No description provided for @openingBalance.
  ///
  /// In en, this message translates to:
  /// **'Opening Balance'**
  String get openingBalance;

  /// No description provided for @closingBalance.
  ///
  /// In en, this message translates to:
  /// **'Closing Balance'**
  String get closingBalance;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **' Cancel'**
  String get cancel;

  /// No description provided for @continueString.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueString;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @whatHappenInyourShop.
  ///
  /// In en, this message translates to:
  /// **'Here is whats happen in your shop'**
  String get whatHappenInyourShop;

  /// No description provided for @openShiftFirst.
  ///
  /// In en, this message translates to:
  /// **'Please Open Shift first befor do any thing'**
  String get openShiftFirst;

  /// No description provided for @openShift.
  ///
  /// In en, this message translates to:
  /// **'open Shift'**
  String get openShift;

  /// No description provided for @openedAt.
  ///
  /// In en, this message translates to:
  /// **'Opened At'**
  String get openedAt;

  /// No description provided for @openBalance.
  ///
  /// In en, this message translates to:
  /// **'Open Balance'**
  String get openBalance;

  /// No description provided for @openBalanceNote.
  ///
  /// In en, this message translates to:
  /// **'The opening balance is the amount that the shop starts with at the beginning of the day.'**
  String get openBalanceNote;

  /// No description provided for @closeShift.
  ///
  /// In en, this message translates to:
  /// **'Close Shift'**
  String get closeShift;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get loginFailed;

  /// No description provided for @productWithBarcode.
  ///
  /// In en, this message translates to:
  /// **'Product with barcode {barcode} Not Found'**
  String productWithBarcode(Object barcode);

  /// No description provided for @invoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get invoice;

  /// No description provided for @returnString.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get returnString;

  /// No description provided for @scanCode.
  ///
  /// In en, this message translates to:
  /// **'Scan Code'**
  String get scanCode;

  /// No description provided for @chooseProducts.
  ///
  /// In en, this message translates to:
  /// **'Choose Products'**
  String get chooseProducts;

  /// No description provided for @editVariant.
  ///
  /// In en, this message translates to:
  /// **'Edit Variant'**
  String get editVariant;

  /// No description provided for @addVariant.
  ///
  /// In en, this message translates to:
  /// **'Add Variant'**
  String get addVariant;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @createProduct.
  ///
  /// In en, this message translates to:
  /// **'Create Product'**
  String get createProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// No description provided for @productDetails.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productDetails;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// No description provided for @pleaseEnterAName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterAName;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @brandName.
  ///
  /// In en, this message translates to:
  /// **'Brand Name'**
  String get brandName;

  /// No description provided for @selectBrand.
  ///
  /// In en, this message translates to:
  /// **'Select Brand'**
  String get selectBrand;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @isActive.
  ///
  /// In en, this message translates to:
  /// **'Is Active'**
  String get isActive;

  /// No description provided for @variants.
  ///
  /// In en, this message translates to:
  /// **'Variants'**
  String get variants;

  /// No description provided for @novariantsAddedClickTheButtonToAddOne.
  ///
  /// In en, this message translates to:
  /// **'No variants added. Click the + button to add one.'**
  String get novariantsAddedClickTheButtonToAddOne;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @qty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qty;

  /// No description provided for @barcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get barcode;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get cost;

  /// No description provided for @areYouSureCancleTheInvoice.
  ///
  /// In en, this message translates to:
  /// **'Are you sure Cancle the invoice?'**
  String get areYouSureCancleTheInvoice;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @makeCancelled.
  ///
  /// In en, this message translates to:
  /// **'Make Cancelled'**
  String get makeCancelled;

  /// No description provided for @selectAction.
  ///
  /// In en, this message translates to:
  /// **'Select Action'**
  String get selectAction;

  /// No description provided for @choseOneOfThoseActionsToDoOrExit.
  ///
  /// In en, this message translates to:
  /// **'Chose one of those actions to do or exit'**
  String get choseOneOfThoseActionsToDoOrExit;

  /// No description provided for @saveAsPDF.
  ///
  /// In en, this message translates to:
  /// **'Save as PDF'**
  String get saveAsPDF;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @forCustomer.
  ///
  /// In en, this message translates to:
  /// **'For Customer'**
  String get forCustomer;

  /// No description provided for @notExist.
  ///
  /// In en, this message translates to:
  /// **'Not Exist!'**
  String get notExist;

  /// No description provided for @selectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get selectPaymentMethod;

  /// No description provided for @filedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Filed to load'**
  String get filedToLoad;

  /// No description provided for @thePaidAmount.
  ///
  /// In en, this message translates to:
  /// **'The Paid Amount'**
  String get thePaidAmount;

  /// No description provided for @theRemainingWillBeAddedAsADebtOnTheCustomer.
  ///
  /// In en, this message translates to:
  /// **'The remaining will be added as a debt on the customer'**
  String get theRemainingWillBeAddedAsADebtOnTheCustomer;

  /// No description provided for @partial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get partial;

  /// No description provided for @addNotesToTheInvoice.
  ///
  /// In en, this message translates to:
  /// **'Add notes to the invoice'**
  String get addNotesToTheInvoice;

  /// No description provided for @thePaidMustBeEqualOrGreaterThanTotal.
  ///
  /// In en, this message translates to:
  /// **'The Paid must be equal or greater than total'**
  String get thePaidMustBeEqualOrGreaterThanTotal;

  /// No description provided for @savePrint.
  ///
  /// In en, this message translates to:
  /// **'Save & Print'**
  String get savePrint;

  /// No description provided for @addToDebit.
  ///
  /// In en, this message translates to:
  /// **'Add to debit'**
  String get addToDebit;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get confirmLogout;

  /// No description provided for @sureToLogOut.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get sureToLogOut;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @manageGroups.
  ///
  /// In en, this message translates to:
  /// **'Manage Groups'**
  String get manageGroups;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @supplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplier;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @sureSaveBill.
  ///
  /// In en, this message translates to:
  /// **'Are you sure! save the Bill?'**
  String get sureSaveBill;

  /// No description provided for @afterContinueYouCantEditBill.
  ///
  /// In en, this message translates to:
  /// **'After continue you can\'t edit anything in the Bill.'**
  String get afterContinueYouCantEditBill;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @attendances.
  ///
  /// In en, this message translates to:
  /// **'Attendances'**
  String get attendances;

  /// No description provided for @sales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get sales;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @dataSync.
  ///
  /// In en, this message translates to:
  /// **'Data Sync'**
  String get dataSync;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @roles.
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get roles;

  /// No description provided for @permissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissions;

  /// No description provided for @logs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logs;

  /// No description provided for @systemInfo.
  ///
  /// In en, this message translates to:
  /// **'System Info'**
  String get systemInfo;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @deletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'deleted successfully'**
  String get deletedSuccessfully;

  /// No description provided for @updatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'updated successfully'**
  String get updatedSuccessfully;

  /// No description provided for @createdSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'created successfully'**
  String get createdSuccessfully;

  /// No description provided for @brands.
  ///
  /// In en, this message translates to:
  /// **'Brands'**
  String get brands;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @values.
  ///
  /// In en, this message translates to:
  /// **'Values'**
  String get values;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @employees.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get employees;

  /// No description provided for @suppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get suppliers;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @invoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoices;

  /// No description provided for @expensesPlural.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesPlural;

  /// No description provided for @reportsPlural.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsPlural;

  /// No description provided for @settingsPlural.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsPlural;

  /// No description provided for @usersPlural.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get usersPlural;

  /// No description provided for @rolesPlural.
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get rolesPlural;

  /// No description provided for @permissionsPlural.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissionsPlural;

  /// No description provided for @debtsPayments.
  ///
  /// In en, this message translates to:
  /// **'Debts Payments'**
  String get debtsPayments;

  /// No description provided for @debts.
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get debts;

  /// No description provided for @deposits.
  ///
  /// In en, this message translates to:
  /// **'Deposits'**
  String get deposits;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get createGroup;

  /// No description provided for @editGroup.
  ///
  /// In en, this message translates to:
  /// **'Edit Group'**
  String get editGroup;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get groupName;

  /// No description provided for @pleaseEnterGroupName.
  ///
  /// In en, this message translates to:
  /// **'Please enter group name'**
  String get pleaseEnterGroupName;

  /// No description provided for @permissionsForGroup.
  ///
  /// In en, this message translates to:
  /// **'Permissions for Group'**
  String get permissionsForGroup;

  /// No description provided for @addPermission.
  ///
  /// In en, this message translates to:
  /// **'Add Permission'**
  String get addPermission;

  /// No description provided for @removePermission.
  ///
  /// In en, this message translates to:
  /// **'Remove Permission'**
  String get removePermission;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @createPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Create Payment Method'**
  String get createPaymentMethod;

  /// No description provided for @editPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Edit Payment Method'**
  String get editPaymentMethod;

  /// No description provided for @methodName.
  ///
  /// In en, this message translates to:
  /// **'Method Name'**
  String get methodName;

  /// No description provided for @pleaseEnterMethodName.
  ///
  /// In en, this message translates to:
  /// **'Please enter method name'**
  String get pleaseEnterMethodName;

  /// No description provided for @payrolls.
  ///
  /// In en, this message translates to:
  /// **'Payrolls'**
  String get payrolls;

  /// No description provided for @salary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get salary;

  /// No description provided for @createPayroll.
  ///
  /// In en, this message translates to:
  /// **'Create Payroll'**
  String get createPayroll;

  /// No description provided for @editPayroll.
  ///
  /// In en, this message translates to:
  /// **'Edit Payroll'**
  String get editPayroll;

  /// No description provided for @employee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get employee;

  /// No description provided for @selectEmployee.
  ///
  /// In en, this message translates to:
  /// **'Select Employee'**
  String get selectEmployee;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @pleaseEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter amount'**
  String get pleaseEnterAmount;

  /// No description provided for @paymentDate.
  ///
  /// In en, this message translates to:
  /// **'Payment Date'**
  String get paymentDate;

  /// No description provided for @selectPaymentDate.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Date'**
  String get selectPaymentDate;

  /// No description provided for @productsInStock.
  ///
  /// In en, this message translates to:
  /// **'Products in Stock'**
  String get productsInStock;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// No description provided for @stockAdjustments.
  ///
  /// In en, this message translates to:
  /// **'Stock Adjustments'**
  String get stockAdjustments;

  /// No description provided for @stockMovements.
  ///
  /// In en, this message translates to:
  /// **'Stock Movements'**
  String get stockMovements;

  /// No description provided for @editStockAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Edit Stock Adjustment'**
  String get editStockAdjustment;

  /// No description provided for @adjustmentDate.
  ///
  /// In en, this message translates to:
  /// **'Adjustment Date'**
  String get adjustmentDate;

  /// No description provided for @selectAdjustmentDate.
  ///
  /// In en, this message translates to:
  /// **'Select Adjustment Date'**
  String get selectAdjustmentDate;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @transactionType.
  ///
  /// In en, this message translates to:
  /// **'Transaction Type'**
  String get transactionType;

  /// No description provided for @increaseStock.
  ///
  /// In en, this message translates to:
  /// **'Increase Stock'**
  String get increaseStock;

  /// No description provided for @decreaseStock.
  ///
  /// In en, this message translates to:
  /// **'Decrease Stock'**
  String get decreaseStock;

  /// No description provided for @transactionDate.
  ///
  /// In en, this message translates to:
  /// **'Transaction Date'**
  String get transactionDate;

  /// No description provided for @selectTransactionDate.
  ///
  /// In en, this message translates to:
  /// **'Select Transaction Date'**
  String get selectTransactionDate;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteGroup.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the group {name}?'**
  String confirmDeleteGroup(Object name);

  /// No description provided for @purchaseInvoice.
  ///
  /// In en, this message translates to:
  /// **'Purchase Invoice'**
  String get purchaseInvoice;

  /// No description provided for @salesInvoice.
  ///
  /// In en, this message translates to:
  /// **'Sales Invoice'**
  String get salesInvoice;

  /// No description provided for @createInvoice.
  ///
  /// In en, this message translates to:
  /// **'Create Invoice'**
  String get createInvoice;

  /// No description provided for @purchases.
  ///
  /// In en, this message translates to:
  /// **'Purchases'**
  String get purchases;

  /// No description provided for @shifts.
  ///
  /// In en, this message translates to:
  /// **'Shifts'**
  String get shifts;

  /// No description provided for @returns.
  ///
  /// In en, this message translates to:
  /// **'Returns'**
  String get returns;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'Not Found'**
  String get notFound;

  /// No description provided for @createBrand.
  ///
  /// In en, this message translates to:
  /// **'Create Brand'**
  String get createBrand;

  /// No description provided for @editBrand.
  ///
  /// In en, this message translates to:
  /// **'Edit Brand'**
  String get editBrand;

  /// No description provided for @chooseInvoiceSaveLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose Invoice Save Location'**
  String get chooseInvoiceSaveLocation;

  /// No description provided for @saveAsPdfCancelled.
  ///
  /// In en, this message translates to:
  /// **'Save as PDF cancelled'**
  String get saveAsPdfCancelled;

  /// No description provided for @errorSavingPdf.
  ///
  /// In en, this message translates to:
  /// **'Error saving PDF: {error}'**
  String errorSavingPdf(Object error);

  /// No description provided for @failedToLoadPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Failed to load payment methods. Please try again.'**
  String get failedToLoadPaymentMethods;

  /// No description provided for @accounting.
  ///
  /// In en, this message translates to:
  /// **'Accounting'**
  String get accounting;

  /// No description provided for @hr.
  ///
  /// In en, this message translates to:
  /// **'HR'**
  String get hr;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @setting.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get setting;

  /// No description provided for @pos.
  ///
  /// In en, this message translates to:
  /// **'point of sales'**
  String get pos;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @refundStatus.
  ///
  /// In en, this message translates to:
  /// **'Refund Status'**
  String get refundStatus;

  /// No description provided for @reportIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Report ID'**
  String get reportIdLabel;

  /// No description provided for @reportTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Report Type'**
  String get reportTypeLabel;

  /// No description provided for @periodLabel.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get periodLabel;

  /// No description provided for @financialSummaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Financial Summary'**
  String get financialSummaryLabel;

  /// No description provided for @totalSalesLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get totalSalesLabel;

  /// No description provided for @totalDepositsLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Deposits'**
  String get totalDepositsLabel;

  /// No description provided for @totalExpensesLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpensesLabel;

  /// No description provided for @totalWithdrawsLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Withdraws'**
  String get totalWithdrawsLabel;

  /// No description provided for @netProfitLabel.
  ///
  /// In en, this message translates to:
  /// **'Net Profit'**
  String get netProfitLabel;

  /// No description provided for @activitySummaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Activity Summary'**
  String get activitySummaryLabel;

  /// No description provided for @totalInvoicesLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Invoices'**
  String get totalInvoicesLabel;

  /// No description provided for @productsSoldLabel.
  ///
  /// In en, this message translates to:
  /// **'Products Sold'**
  String get productsSoldLabel;

  /// No description provided for @productsReturnedLabel.
  ///
  /// In en, this message translates to:
  /// **'Products Returned'**
  String get productsReturnedLabel;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @printReport.
  ///
  /// In en, this message translates to:
  /// **'Print Report'**
  String get printReport;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @languageCode.
  ///
  /// In en, this message translates to:
  /// **'en'**
  String get languageCode;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @unitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get unitPrice;

  /// No description provided for @returnType.
  ///
  /// In en, this message translates to:
  /// **'Return Type'**
  String get returnType;

  /// No description provided for @returnDate.
  ///
  /// In en, this message translates to:
  /// **'Return Date'**
  String get returnDate;

  /// No description provided for @saleItem.
  ///
  /// In en, this message translates to:
  /// **'Sale Item'**
  String get saleItem;

  /// No description provided for @purchaseItem.
  ///
  /// In en, this message translates to:
  /// **'Purchase Item'**
  String get purchaseItem;

  /// No description provided for @subTotal.
  ///
  /// In en, this message translates to:
  /// **'Sub Total'**
  String get subTotal;

  /// No description provided for @grandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand Total'**
  String get grandTotal;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @id.
  ///
  /// In en, this message translates to:
  /// **'id'**
  String get id;

  /// No description provided for @isPresent.
  ///
  /// In en, this message translates to:
  /// **'is Present'**
  String get isPresent;

  /// No description provided for @workHours.
  ///
  /// In en, this message translates to:
  /// **'work hours'**
  String get workHours;

  /// No description provided for @lateMinutes.
  ///
  /// In en, this message translates to:
  /// **'late minutes'**
  String get lateMinutes;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'name'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'phone'**
  String get phone;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'email'**
  String get email;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'address'**
  String get address;

  /// No description provided for @creditLimit.
  ///
  /// In en, this message translates to:
  /// **'credit limit'**
  String get creditLimit;

  /// No description provided for @createdBy.
  ///
  /// In en, this message translates to:
  /// **'created by'**
  String get createdBy;

  /// No description provided for @updatedBy.
  ///
  /// In en, this message translates to:
  /// **'updated by'**
  String get updatedBy;

  /// No description provided for @deletedBy.
  ///
  /// In en, this message translates to:
  /// **'deleted by'**
  String get deletedBy;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'created at'**
  String get createdAt;

  /// No description provided for @updatedAt.
  ///
  /// In en, this message translates to:
  /// **'updated at'**
  String get updatedAt;

  /// No description provided for @deletedAt.
  ///
  /// In en, this message translates to:
  /// **'deleted at'**
  String get deletedAt;

  /// No description provided for @partyType.
  ///
  /// In en, this message translates to:
  /// **'party type'**
  String get partyType;

  /// No description provided for @party.
  ///
  /// In en, this message translates to:
  /// **'party'**
  String get party;

  /// No description provided for @partyName.
  ///
  /// In en, this message translates to:
  /// **'party name'**
  String get partyName;

  /// No description provided for @kind.
  ///
  /// In en, this message translates to:
  /// **'kind'**
  String get kind;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'source'**
  String get source;

  /// No description provided for @sourceId.
  ///
  /// In en, this message translates to:
  /// **'source id'**
  String get sourceId;

  /// No description provided for @sourceName.
  ///
  /// In en, this message translates to:
  /// **'source name'**
  String get sourceName;

  /// No description provided for @returned.
  ///
  /// In en, this message translates to:
  /// **'returned'**
  String get returned;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'due date'**
  String get dueDate;

  /// No description provided for @recordedBy.
  ///
  /// In en, this message translates to:
  /// **'recorded by'**
  String get recordedBy;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'reason'**
  String get reason;

  /// No description provided for @shift.
  ///
  /// In en, this message translates to:
  /// **'shift'**
  String get shift;

  /// No description provided for @payMethod.
  ///
  /// In en, this message translates to:
  /// **'pay method'**
  String get payMethod;

  /// No description provided for @depositedBy.
  ///
  /// In en, this message translates to:
  /// **'deposited by'**
  String get depositedBy;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'first name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'last name'**
  String get lastName;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'birth date'**
  String get birthDate;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'gender'**
  String get gender;

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'position'**
  String get position;

  /// No description provided for @hireDate.
  ///
  /// In en, this message translates to:
  /// **'hire date'**
  String get hireDate;

  /// No description provided for @userAccount.
  ///
  /// In en, this message translates to:
  /// **'user account'**
  String get userAccount;

  /// No description provided for @takenBy.
  ///
  /// In en, this message translates to:
  /// **'taken by'**
  String get takenBy;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'type'**
  String get type;

  /// No description provided for @barnd.
  ///
  /// In en, this message translates to:
  /// **'brand'**
  String get barnd;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'category'**
  String get category;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'unit'**
  String get unit;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'start date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'end date'**
  String get endDate;

  /// No description provided for @reportType.
  ///
  /// In en, this message translates to:
  /// **'report type'**
  String get reportType;

  /// No description provided for @totalSales.
  ///
  /// In en, this message translates to:
  /// **'total sales'**
  String get totalSales;

  /// No description provided for @totalDeposits.
  ///
  /// In en, this message translates to:
  /// **'total deposits'**
  String get totalDeposits;

  /// No description provided for @totalExpenses.
  ///
  /// In en, this message translates to:
  /// **'total expenses'**
  String get totalExpenses;

  /// No description provided for @totalWithdraws.
  ///
  /// In en, this message translates to:
  /// **'total withdraws'**
  String get totalWithdraws;

  /// No description provided for @netProfit.
  ///
  /// In en, this message translates to:
  /// **'net profit'**
  String get netProfit;

  /// No description provided for @totalInvoices.
  ///
  /// In en, this message translates to:
  /// **'total invoices'**
  String get totalInvoices;

  /// No description provided for @productsSold.
  ///
  /// In en, this message translates to:
  /// **'total products sold'**
  String get productsSold;

  /// No description provided for @productsReturned.
  ///
  /// In en, this message translates to:
  /// **'total products returned'**
  String get productsReturned;

  /// No description provided for @openedBy.
  ///
  /// In en, this message translates to:
  /// **'opened by'**
  String get openedBy;

  /// No description provided for @closedBy.
  ///
  /// In en, this message translates to:
  /// **'closed by'**
  String get closedBy;

  /// No description provided for @closedAt.
  ///
  /// In en, this message translates to:
  /// **'closed at'**
  String get closedAt;

  /// No description provided for @countedCash.
  ///
  /// In en, this message translates to:
  /// **'counted cash'**
  String get countedCash;

  /// No description provided for @isAttendance.
  ///
  /// In en, this message translates to:
  /// **'is attendance'**
  String get isAttendance;

  /// No description provided for @expectedCash.
  ///
  /// In en, this message translates to:
  /// **'expected cash'**
  String get expectedCash;

  /// No description provided for @variant.
  ///
  /// In en, this message translates to:
  /// **'variant'**
  String get variant;

  /// No description provided for @sourceType.
  ///
  /// In en, this message translates to:
  /// **'source type'**
  String get sourceType;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'username'**
  String get username;

  /// No description provided for @isAdmin.
  ///
  /// In en, this message translates to:
  /// **'is admin'**
  String get isAdmin;

  /// No description provided for @paymentMethd.
  ///
  /// In en, this message translates to:
  /// **'payment method'**
  String get paymentMethd;

  /// No description provided for @exchangeWith.
  ///
  /// In en, this message translates to:
  /// **'exchange with'**
  String get exchangeWith;

  /// No description provided for @exchangeInvoice.
  ///
  /// In en, this message translates to:
  /// **'exchange invoice'**
  String get exchangeInvoice;

  /// No description provided for @debt.
  ///
  /// In en, this message translates to:
  /// **'debt'**
  String get debt;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @newButton.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newButton;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @stopScan.
  ///
  /// In en, this message translates to:
  /// **'Stop Scan'**
  String get stopScan;

  /// No description provided for @printPlugin.
  ///
  /// In en, this message translates to:
  /// **'Print Plugin'**
  String get printPlugin;

  /// No description provided for @network.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get network;

  /// No description provided for @testNetworkPrinter.
  ///
  /// In en, this message translates to:
  /// **'Test Network Printer'**
  String get testNetworkPrinter;

  /// No description provided for @testNetworkPrinterWidget.
  ///
  /// In en, this message translates to:
  /// **'Test Network Printer Widget'**
  String get testNetworkPrinterWidget;

  /// No description provided for @usbBle.
  ///
  /// In en, this message translates to:
  /// **'USB/BLE'**
  String get usbBle;

  /// No description provided for @getPrinters.
  ///
  /// In en, this message translates to:
  /// **'Get Printers'**
  String get getPrinters;

  /// No description provided for @printPdf.
  ///
  /// In en, this message translates to:
  /// **'Print PDF'**
  String get printPdf;

  /// No description provided for @printPdfWidget.
  ///
  /// In en, this message translates to:
  /// **'Print PDF Widget'**
  String get printPdfWidget;

  /// No description provided for @bluetoothNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth is not supported on this device'**
  String get bluetoothNotSupported;

  /// No description provided for @bluetoothRequired.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Required'**
  String get bluetoothRequired;

  /// No description provided for @bluetoothRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Please turn on Bluetooth to connect to the printer.'**
  String get bluetoothRequiredMessage;

  /// No description provided for @turnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn On'**
  String get turnOn;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
