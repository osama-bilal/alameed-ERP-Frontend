// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get aboutTitle => 'About Alameed ERP';

  @override
  String get companyName => 'Alameed Telecom';

  @override
  String get appName => 'Alameed ERP Application';

  @override
  String get appDescription =>
      'This application was developed with Flutter as the client-side for the Alameed Telecom shop ERP (Enterprise Resource Planning) project.';

  @override
  String get githubLinkText =>
      'The application serves as the interface to control and manage data on the server, which you can find on GitHub.';

  @override
  String get developmentPhaseNote =>
      'The project is still in the development phase and requires significant upgrades to reach its full potential.';

  @override
  String get personalJourneyTitle => 'A Personal Journey';

  @override
  String get personalJourneyText1 =>
      'This front-end application was developed by Osama Bilal using Flutter. The project began in September 2025, following his graduation from computer college and after accompanying his mother on her treatment journey from parosteal osteosarcoma in Egypt.';

  @override
  String get personalJourneyText2 =>
      'The main project was established as a way of expressing gratitude to his father and to fulfill the need for this system in their store.';

  @override
  String get personalJourneyText3 =>
      'This project is the result of over two and a half months of dedicated work, and development is ongoing to add features and fix issues.';

  @override
  String get dedicationText =>
      'This was done with love, giving all the love and respect to my parents. I am grateful for their efforts to teach me and to raise me with a good education. I can only tell them, \"May God reward you for me with the best reward.\" Whatever I do and whatever I give you, I will not be able to reward you for what you have given me.';

  @override
  String get madeWithLove => 'Made with love. ❤️';

  @override
  String couldNotLaunchUrl(Object url) {
    return 'Could not launch $url';
  }

  @override
  String invoiceNumber(Object id) {
    return 'Invoice Number: $id';
  }

  @override
  String get returnMoney => 'Return Money';

  @override
  String get replace => 'Replace';

  @override
  String get invoiceNotFound => 'Invoice not found or has no items.';

  @override
  String get unknown => 'Unknown';

  @override
  String get chooseItemToReturn => 'Choose Item to return';

  @override
  String returnForInvoice(Object id) {
    return 'Return for Invoice #$id';
  }

  @override
  String replaceStarted(Object id) {
    return 'Replace started for new invoice #$id';
  }

  @override
  String get returnSuccess => 'Return processed successfully!';

  @override
  String get totalReturnAmount => 'Total Return Amount';

  @override
  String get createStockAdjustment => 'Create Stock Adjustment';

  @override
  String get saveAdjustment => 'Save Adjustment';

  @override
  String get adjustmentSaved => 'Adjustment saved successfully!';

  @override
  String error(Object error) {
    return 'Error: $error';
  }

  @override
  String get selectProductVariant => 'Select Product Variant';

  @override
  String get productVariant => 'Product Variant';

  @override
  String get pleaseSelectVariant => 'Please select a variant';

  @override
  String get increase => 'Increase';

  @override
  String get decrease => 'Decrease';

  @override
  String get quantity => 'Quantity';

  @override
  String get enterQuantity => 'Please enter a quantity';

  @override
  String get enterValidQuantity => 'Please enter a valid positive quantity';

  @override
  String get notesOptional => 'Notes (Optional)';
  @override
  String get editCustomerTitle => 'Edit Customer Details';

  @override
  String get nameLabel => 'name';

  @override
  String get phoneLabel => 'phone';

  @override
  String get emailOptionalLabel => 'Email (Optional)';

  @override
  String get addressOptionalLabel => 'Address (Optional)';

  @override
  String get creditLimitLabel => 'credit limit';

  @override
  String get closeButton => 'close';

  @override
  String get updateButton => 'update';

  @override
  String get addButton => 'add';
}
