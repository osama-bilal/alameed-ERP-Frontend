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
  String get nameLabel => 'Name';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get emailOptionalLabel => 'Email (Optional)';

  @override
  String get addressOptionalLabel => 'Address (Optional)';

  @override
  String get creditLimitLabel => 'Credit Limit';

  @override
  String get closeButton => 'Close';

  @override
  String get updateButton => 'Update';

  @override
  String get addButton => 'Add';

  @override
  String get cantAccessPage => 'You cant access to this page';

  @override
  String get openingBalance => 'Opening Balance';

  @override
  String get closingBalance => 'Closing Balance';

  @override
  String get cancel => ' Cancel';

  @override
  String get continueString => 'Continue';

  @override
  String get welcome => 'Welcome';

  @override
  String get whatHappenInyourShop => 'Here is whats happen in your shop';

  @override
  String get openShiftFirst => 'Please Open Shift first befor do any thing';

  @override
  String get openShift => 'open Shift';

  @override
  String get openedAt => 'Opened At';

  @override
  String get openBalance => 'Open Balance';

  @override
  String get openBalanceNote =>
      'The opening balance is the amount that the shop starts with at the beginning of the day.';

  @override
  String get closeShift => 'Close Shift';

  @override
  String get login => 'Login';

  @override
  String get loginFailed => 'Login Failed';

  @override
  String productWithBarcode(Object barcode) {
    return 'Product with barcode $barcode Not Found';
  }

  @override
  String get invoice => 'Invoice';

  @override
  String get returnString => 'Return';

  @override
  String get scanCode => 'Scan Code';

  @override
  String get chooseProducts => 'Choose Products';

  @override
  String get editVariant => 'Edit Variant';

  @override
  String get addVariant => 'Add Variant';

  @override
  String get loading => 'Loading';

  @override
  String get save => 'Save';

  @override
  String get createProduct => 'Create Product';

  @override
  String get editProduct => 'Edit Product';

  @override
  String get productDetails => 'Product Details';

  @override
  String get productName => 'Product Name';

  @override
  String get pleaseEnterAName => 'Please enter a name';

  @override
  String get add => 'Add';

  @override
  String get brandName => 'Brand Name';

  @override
  String get selectBrand => 'Select Brand';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get isActive => 'Is Active';

  @override
  String get variants => 'Variants';

  @override
  String get novariantsAddedClickTheButtonToAddOne =>
      'No variants added. Click the + button to add one.';

  @override
  String get price => 'Price';

  @override
  String get qty => 'Qty';

  @override
  String get barcode => 'Barcode';

  @override
  String get cost => 'Cost';

  @override
  String get areYouSureCancleTheInvoice => 'Are you sure Cancle the invoice?';

  @override
  String get no => 'No';

  @override
  String get makeCancelled => 'Make Cancelled';

  @override
  String get selectAction => 'Select Action';

  @override
  String get choseOneOfThoseActionsToDoOrExit =>
      'Chose one of those actions to do or exit';

  @override
  String get saveAsPDF => 'Save as PDF';

  @override
  String get print => 'Print';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get discount => 'Discount';

  @override
  String get tax => 'Tax';

  @override
  String get total => 'Total';

  @override
  String get forCustomer => 'For Customer';

  @override
  String get notExist => 'Not Exist!';

  @override
  String get selectPaymentMethod => 'Select Payment Method';

  @override
  String get filedToLoad => 'Filed to load';

  @override
  String get thePaidAmount => 'The Paid Amount';

  @override
  String get theRemainingWillBeAddedAsADebtOnTheCustomer =>
      'The remaining will be added as a debt on the customer';

  @override
  String get partial => 'Partial';

  @override
  String get addNotesToTheInvoice => 'Add notes to the invoice';

  @override
  String get thePaidMustBeEqualOrGreaterThanTotal =>
      'The Paid must be equal or greater than total';

  @override
  String get savePrint => 'Save & Print';

  @override
  String get addToDebit => 'Add to debit';

  @override
  String get confirmLogout => 'Confirm Logout';

  @override
  String get sureToLogOut => 'Are you sure you want to log out?';

  @override
  String get logOut => 'Log Out';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get manageGroups => 'Manage Groups';

  @override
  String get customer => 'Customer';

  @override
  String get supplier => 'Supplier';

  @override
  String get items => 'Items';

  @override
  String get date => 'Date';

  @override
  String get status => 'Status';

  @override
  String get paid => 'Paid';

  @override
  String get remaining => 'Remaining';

  @override
  String get sureSaveBill => 'Are you sure! save the Bill?';

  @override
  String get afterContinueYouCantEditBill =>
      'After continue you can\'t edit anything in the Bill.';

  @override
  String get checkout => 'Checkout';

  @override
  String get clear => 'Clear';
}
