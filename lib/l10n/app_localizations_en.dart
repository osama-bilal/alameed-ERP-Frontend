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

  @override
  String get attendances => 'Attendances';

  @override
  String get sales => 'Sales';

  @override
  String get expenses => 'Expenses';

  @override
  String get reports => 'Reports';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get profile => 'Profile';

  @override
  String get help => 'Help';

  @override
  String get about => 'About';

  @override
  String get language => 'Language';

  @override
  String get currency => 'Currency';

  @override
  String get notifications => 'Notifications';

  @override
  String get backup => 'Backup';

  @override
  String get restore => 'Restore';

  @override
  String get dataSync => 'Data Sync';

  @override
  String get users => 'Users';

  @override
  String get roles => 'Roles';

  @override
  String get permissions => 'Permissions';

  @override
  String get logs => 'Logs';

  @override
  String get systemInfo => 'System Info';

  @override
  String get support => 'Support';

  @override
  String get feedback => 'Feedback';

  @override
  String get deletedSuccessfully => 'deleted successfully';

  @override
  String get updatedSuccessfully => 'updated successfully';

  @override
  String get createdSuccessfully => 'created successfully';

  @override
  String get brands => 'Brands';

  @override
  String get categories => 'Categories';

  @override
  String get options => 'Options';

  @override
  String get values => 'Values';

  @override
  String get customers => 'Customers';

  @override
  String get employees => 'Employees';

  @override
  String get suppliers => 'Suppliers';

  @override
  String get products => 'Products';

  @override
  String get invoices => 'Invoices';

  @override
  String get expensesPlural => 'Expenses';

  @override
  String get reportsPlural => 'Reports';

  @override
  String get settingsPlural => 'Settings';

  @override
  String get usersPlural => 'Users';

  @override
  String get rolesPlural => 'Roles';

  @override
  String get permissionsPlural => 'Permissions';

  @override
  String get debtsPayments => 'Debts Payments';

  @override
  String get debts => 'Debts';

  @override
  String get deposits => 'Deposits';

  @override
  String get groups => 'Groups';

  @override
  String get createGroup => 'Create Group';

  @override
  String get editGroup => 'Edit Group';

  @override
  String get groupName => 'Group Name';

  @override
  String get pleaseEnterGroupName => 'Please enter group name';

  @override
  String get permissionsForGroup => 'Permissions for Group';

  @override
  String get addPermission => 'Add Permission';

  @override
  String get removePermission => 'Remove Permission';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get createPaymentMethod => 'Create Payment Method';

  @override
  String get editPaymentMethod => 'Edit Payment Method';

  @override
  String get methodName => 'Method Name';

  @override
  String get pleaseEnterMethodName => 'Please enter method name';

  @override
  String get payrolls => 'Payrolls';

  @override
  String get salary => 'Salary';

  @override
  String get createPayroll => 'Create Payroll';

  @override
  String get editPayroll => 'Edit Payroll';

  @override
  String get employee => 'Employee';

  @override
  String get selectEmployee => 'Select Employee';

  @override
  String get amount => 'Amount';

  @override
  String get pleaseEnterAmount => 'Please enter amount';

  @override
  String get paymentDate => 'Payment Date';

  @override
  String get selectPaymentDate => 'Select Payment Date';

  @override
  String get productsInStock => 'Products in Stock';

  @override
  String get outOfStock => 'Out of Stock';

  @override
  String get lowStock => 'Low Stock';

  @override
  String get stockAdjustments => 'Stock Adjustments';

  @override
  String get stockMovements => 'Stock Movements';

  @override
  String get editStockAdjustment => 'Edit Stock Adjustment';

  @override
  String get adjustmentDate => 'Adjustment Date';

  @override
  String get selectAdjustmentDate => 'Select Adjustment Date';

  @override
  String get notes => 'Notes';

  @override
  String get transactionType => 'Transaction Type';

  @override
  String get increaseStock => 'Increase Stock';

  @override
  String get decreaseStock => 'Decrease Stock';

  @override
  String get transactionDate => 'Transaction Date';

  @override
  String get selectTransactionDate => 'Select Transaction Date';

  @override
  String get transactions => 'Transactions';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String confirmDeleteGroup(Object name) {
    return 'Are you sure you want to delete the group $name?';
  }

  @override
  String get purchaseInvoice => 'Purchase Invoice';

  @override
  String get salesInvoice => 'Sales Invoice';

  @override
  String get createInvoice => 'Create Invoice';

  @override
  String get purchases => 'Purchases';

  @override
  String get shifts => 'Shifts';

  @override
  String get returns => 'Returns';

  @override
  String get notFound => 'Not Found';

  @override
  String get createBrand => 'Create Brand';

  @override
  String get editBrand => 'Edit Brand';

  @override
  String get chooseInvoiceSaveLocation => 'Choose Invoice Save Location';

  @override
  String get saveAsPdfCancelled => 'Save as PDF cancelled';

  @override
  String errorSavingPdf(Object error) {
    return 'Error saving PDF: $error';
  }

  @override
  String get failedToLoadPaymentMethods =>
      'Failed to load payment methods. Please try again.';

  @override
  String get accounting => 'Accounting';

  @override
  String get hr => 'HR';

  @override
  String get inventory => 'Inventory';

  @override
  String get setting => 'Setting';

  @override
  String get pos => 'point of sales';

  @override
  String get home => 'Home';

  @override
  String get admin => 'Admin';

  @override
  String get account => 'Account';

  @override
  String get description => 'Description';

  @override
  String get categoryName => 'Category Name';

  @override
  String get refundStatus => 'Refund Status';

  @override
  String get reportIdLabel => 'Report ID';

  @override
  String get reportTypeLabel => 'Report Type';

  @override
  String get periodLabel => 'Period';

  @override
  String get financialSummaryLabel => 'Financial Summary';

  @override
  String get totalSalesLabel => 'Total Sales';

  @override
  String get totalDepositsLabel => 'Total Deposits';

  @override
  String get totalExpensesLabel => 'Total Expenses';

  @override
  String get totalWithdrawsLabel => 'Total Withdraws';

  @override
  String get netProfitLabel => 'Net Profit';

  @override
  String get activitySummaryLabel => 'Activity Summary';

  @override
  String get totalInvoicesLabel => 'Total Invoices';

  @override
  String get productsSoldLabel => 'Products Sold';

  @override
  String get productsReturnedLabel => 'Products Returned';

  @override
  String get report => 'Report';

  @override
  String get printReport => 'Print Report';

  @override
  String get user => 'User';

  @override
  String get note => 'Note';

  @override
  String get done => 'Done';

  @override
  String get languageCode => 'en';

  @override
  String get product => 'Product';

  @override
  String get unitPrice => 'Unit Price';

  @override
  String get returnType => 'Return Type';

  @override
  String get returnDate => 'Return Date';

  @override
  String get saleItem => 'Sale Item';

  @override
  String get purchaseItem => 'Purchase Item';

  @override
  String get subTotal => 'Sub Total';

  @override
  String get grandTotal => 'Grand Total';

  @override
  String get payment => 'Payment';

  @override
  String get change => 'Change';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get update => 'Update';

  @override
  String get view => 'View';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get reset => 'Reset';

  @override
  String get id => 'id';

  @override
  String get isPresent => 'is Present';

  @override
  String get workHours => 'work hours';

  @override
  String get lateMinutes => 'late minutes';

  @override
  String get name => 'name';

  @override
  String get phone => 'phone';

  @override
  String get email => 'email';

  @override
  String get address => 'address';

  @override
  String get creditLimit => 'credit limit';

  @override
  String get createdBy => 'created by';

  @override
  String get updatedBy => 'updated by';

  @override
  String get deletedBy => 'deleted by';

  @override
  String get createdAt => 'created at';

  @override
  String get updatedAt => 'updated at';

  @override
  String get deletedAt => 'deleted at';

  @override
  String get partyType => 'party type';

  @override
  String get party => 'party';

  @override
  String get partyName => 'party name';

  @override
  String get kind => 'kind';

  @override
  String get source => 'source';

  @override
  String get sourceId => 'source id';

  @override
  String get sourceName => 'source name';

  @override
  String get returned => 'returned';

  @override
  String get dueDate => 'due date';

  @override
  String get recordedBy => 'recorded by';

  @override
  String get reason => 'reason';

  @override
  String get shift => 'shift';

  @override
  String get payMethod => 'pay method';

  @override
  String get depositedBy => 'deposited by';

  @override
  String get firstName => 'first name';

  @override
  String get lastName => 'last name';

  @override
  String get birthDate => 'birth date';

  @override
  String get gender => 'gender';

  @override
  String get position => 'position';

  @override
  String get hireDate => 'hire date';

  @override
  String get userAccount => 'user account';

  @override
  String get takenBy => 'taken by';

  @override
  String get type => 'type';

  @override
  String get barnd => 'brand';

  @override
  String get category => 'category';

  @override
  String get unit => 'unit';

  @override
  String get startDate => 'start date';

  @override
  String get endDate => 'end date';

  @override
  String get reportType => 'report type';

  @override
  String get totalSales => 'total sales';

  @override
  String get totalDeposits => 'total deposits';

  @override
  String get totalExpenses => 'total expenses';

  @override
  String get totalWithdraws => 'total withdraws';

  @override
  String get netProfit => 'net profit';

  @override
  String get totalInvoices => 'total invoices';

  @override
  String get productsSold => 'total products sold';

  @override
  String get productsReturned => 'total products returned';

  @override
  String get openedBy => 'opened by';

  @override
  String get closedBy => 'closed by';

  @override
  String get closedAt => 'closed at';

  @override
  String get countedCash => 'counted cash';

  @override
  String get isAttendance => 'is attendance';

  @override
  String get expectedCash => 'expected cash';

  @override
  String get variant => 'variant';

  @override
  String get sourceType => 'source type';

  @override
  String get username => 'username';

  @override
  String get isAdmin => 'is admin';

  @override
  String get paymentMethd => 'payment method';

  @override
  String get exchangeWith => 'exchange with';

  @override
  String get exchangeInvoice => 'exchange invoice';

  @override
  String get debt => 'debt';

  @override
  String get all => 'All';

  @override
  String get newButton => 'New';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get actions => 'Actions';

  @override
  String get stopScan => 'Stop Scan';

  @override
  String get printPlugin => 'Print Plugin';

  @override
  String get network => 'Network';

  @override
  String get testNetworkPrinter => 'Test Network Printer';

  @override
  String get testNetworkPrinterWidget => 'Test Network Printer Widget';

  @override
  String get usbBle => 'USB/BLE';

  @override
  String get getPrinters => 'Get Printers';

  @override
  String get printPdf => 'Print PDF';

  @override
  String get printPdfWidget => 'Print PDF Widget';

  @override
  String get bluetoothNotSupported =>
      'Bluetooth is not supported on this device';

  @override
  String get bluetoothRequired => 'Bluetooth Required';

  @override
  String get bluetoothRequiredMessage =>
      'Please turn on Bluetooth to connect to the printer.';

  @override
  String get turnOn => 'Turn On';
}
