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

  String get editCustomerTitle;

  String get nameLabel;

  String get phoneLabel ;

  String get emailOptionalLabel;

  String get addressOptionalLabel;

  String get creditLimitLabel;

  String get closeButton;

  String get updateButton;

  String get addButton ;
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
