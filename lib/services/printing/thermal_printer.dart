// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
// import 'dart:developer';
// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/models/pos_view.dart';
import 'package:ponit_of_sales/services/auth_service.dart';

Future<void> requestBluetoothPermissions() async {
  if (await Permission.bluetoothScan.isDenied ||
      await Permission.bluetoothConnect.isDenied) {
    await [Permission.bluetoothScan, Permission.bluetoothConnect].request();
  }
}

class ThermalPrinting extends StatefulWidget {
  const ThermalPrinting({
    super.key,
    required this.invoice,
    required this.customer,
    required this.products,
  });
  final SaleInvoice invoice;
  final List<POSView> products;
  final String customer;
  @override
  State<ThermalPrinting> createState() => _ThermalPrintingState();
}

class _ThermalPrintingState extends State<ThermalPrinting> {
  final _flutterThermalPrinterPlugin = FlutterThermalPrinter.instance;

  String _ip = '192.168.0.100';
  String _port = '9100';

  List<Printer> printers = [];

  StreamSubscription<List<Printer>>? _devicesStreamSubscription;

  Future<img.Image?> _getImageBytes(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();
    final img.Image? image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('Could not decode image from asset.');
    }
    img.Image resizedImage = img.copyResize(
      image,
      width: 250, // حدد العرض المطلوب
      height: 250, // حدد الارتفاع المطلوب
    );

    // تحويل الصورة إلى تدرج رمادي
    img.Image grayscaleImage = img.grayscale(resizedImage);
    // Optional: Resize or convert to grayscale if needed for your printer
    // final resizedImage = img.copyResize(image, width: 200);
    // final grayscaleImage = img.grayscale(resizedImage);
    return grayscaleImage;
    // return img.encodePng(
    //   image,
    // ); // Or encodeBmp for better compatibility with some printers
  }

  // Get Printer List
  void startScan() async {
    await requestBluetoothPermissions();
    _devicesStreamSubscription?.cancel();
    await _flutterThermalPrinterPlugin.getPrinters(
      connectionTypes: [ConnectionType.USB, ConnectionType.BLE],
    );
    _devicesStreamSubscription = _flutterThermalPrinterPlugin.devicesStream
        .listen((List<Printer> event) {
          setState(() {
            printers = event;
            printers.removeWhere(
              (element) =>
                  element.name == null ||
                  element.name == '' ||
                  element.name!.toLowerCase().contains("print") == false,
            );
          });
        });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      startScan();
    });
  }

  void stopScan() {
    _flutterThermalPrinterPlugin.stopScan();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('NETWORK', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _ip,
                decoration: const InputDecoration(
                  labelText: 'Enter IP Address',
                ),
                onChanged: (value) {
                  _ip = value;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _port,
                decoration: const InputDecoration(labelText: 'Enter Port'),
                onChanged: (value) {
                  _port = value;
                },
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final service = FlutterThermalPrinterNetwork(
                          _ip,
                          port: int.parse(_port),
                        );
                        await service.connect();
                        final profile = await CapabilityProfile.load();
                        final generator = Generator(PaperSize.mm80, profile);
                        List<int> bytes = [];
                        if (context.mounted) {
                          // bytes = await FlutterThermalPrinter.instance
                          //     .screenShotWidget(
                          //       context,
                          //       generator: generator,
                          //       widget: receiptWidget("Network"),
                          //     );
                          bytes = await _generateReceipt();
                          bytes += generator.cut();
                          await service.printTicket(bytes);
                        }
                        await service.disconnect();
                      },
                      child: const Text('Test network printer'),
                    ),
                  ),
                  const SizedBox(width: 22),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final service = FlutterThermalPrinterNetwork(
                          _ip,
                          port: int.parse(_port),
                        );
                        await service.connect();
                        final bytes = await _generateReceipt();
                        await service.printTicket(bytes);
                        await service.disconnect();
                      },
                      child: const Text('Test network printer widget'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 22),
              Text('USB/BLE', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // startScan();
                        startScan();
                      },
                      child: const Text('Get Printers'),
                    ),
                  ),
                  const SizedBox(width: 22),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // startScan();
                        stopScan();
                      },
                      child: const Text('Stop Scan'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: printers.length,
                  itemBuilder: (context, index) {
                    final printer = printers[index];
                    return ListTile(
                      onTap: () async {
                        if (printer.isConnected ?? false) {
                          // await printer.unpair();
                          await printer.disconnect();
                          // await _flutterThermalPrinterPlugin.disconnect(
                          //   printers[index],
                          // );
                        } else {
                          await printer.connect();
                          // await printer.pair();
                          // await _flutterThermalPrinterPlugin.connect(
                          //   printers[index],
                          // );
                        }
                        if (mounted) {
                          setState(() {
                            printers[index] = printer;
                          });
                        }
                      },
                      title: Text(printer.name ?? 'No Name'),
                      subtitle: Text("Connected: ${printer.isConnected}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.connect_without_contact),
                        onPressed: () async {
                          // final profile = await CapabilityProfile.load();
                          // final generator = Generator(PaperSize.mm80, profile);
                          // List<int> bytes = [];
                          // if (context.mounted) {
                          //   bytes = await FlutterThermalPrinter.instance
                          //       .screenShotWidget(
                          //         context,
                          //         generator: generator,
                          //         widget: receiptWidget("Network"),
                          //       );
                          //   bytes += generator.cut();
                          //   await _flutterThermalPrinterPlugin.printData(
                          //     printers[index],
                          //     bytes,
                          //   );
                          // }
                          final data = await _generateReceipt(
                            type: printer.connectionTypeString,
                          );
                          await _flutterThermalPrinterPlugin.printData(
                            printer,
                            data,
                            longData: true,
                          );
                          // await _flutterThermalPrinterPlugin.printWidget(
                          //   context,
                          //   printOnBle: true,
                          //   cutAfterPrinted: true,
                          //   printer: printers[index],
                          //   widget: receiptWidget(
                          //     printers[index].connectionTypeString,
                          //   ),
                          // );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<int>> _generateReceipt({String? type}) async {
    final user = await AuthService().getStoredUser();
    String userName = "";
    if (user != null) userName = user.firstName ?? "";
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    final imageBytes = await _getImageBytes('assets/logo/logo.png');
    List<int> bytes = [];
    bytes += generator.image(imageBytes!);
    bytes += generator.text(
      'Al-Ameed Shop',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.feed(1);
    bytes += generator.text('User: $userName');
    bytes += generator.text(DateTime.now().toIso8601String());
    bytes += generator.feed(1);
    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: 'Item', width: 4, styles: const PosStyles(bold: true)),
      PosColumn(
        text: 'Quantity',
        width: 2,
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
      PosColumn(
        text: 'Unit Price',
        width: 3,
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
      PosColumn(
        text: 'Total',
        width: 3,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);
    bytes += generator.hr();
    widget.invoice.items.map((e) {
      final product = widget.products.firstWhere((p) => p.id == e.variantId);
      final total = e.total.toStringAsFixed(2);
      bytes += generator.row([
        PosColumn(text: product.name, width: 4),
        PosColumn(
          text: e.quantity.toString(),
          width: 2,
          styles: const PosStyles(align: PosAlign.center),
        ),
        PosColumn(
          text: e.unitPrice,
          width: 3,
          styles: const PosStyles(align: PosAlign.center),
        ),
        PosColumn(
          text: total,
          width: 3,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    });

    // bytes += generator.row([
    //   PosColumn(text: 'Galaxy S25 ultra, 512GB, 12GB Ram, White', width: 4),
    //   PosColumn(
    //     text: '1',
    //     width: 2,
    //     styles: const PosStyles(align: PosAlign.center),
    //   ),
    //   PosColumn(
    //     text: '\$5000.00',
    //     width: 3,
    //     styles: const PosStyles(align: PosAlign.center),
    //   ),
    //   PosColumn(
    //     text: '\$5000.00',
    //     width: 3,
    //     styles: const PosStyles(align: PosAlign.right),
    //   ),
    // ]);
    // bytes += generator.row([
    //   PosColumn(text: 'Galaxy S24 Ultra, 512GB, 12GB Ram, Black', width: 4),
    //   PosColumn(
    //     text: '2',
    //     width: 2,
    //     styles: const PosStyles(align: PosAlign.center),
    //   ),
    //   PosColumn(
    //     text: '\$4000.00',
    //     width: 3,
    //     styles: const PosStyles(align: PosAlign.center),
    //   ),
    //   PosColumn(
    //     text: '\$8000.00',
    //     width: 3,
    //     styles: const PosStyles(align: PosAlign.right),
    //   ),
    // ]);
    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: 'Total', width: 6, styles: const PosStyles(bold: true)),
      PosColumn(
        text: widget.invoice.total ?? "",
        width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);
    bytes += generator.feed(1);
    bytes += generator.text(
      'Customer: ${widget.customer}', //${type ?? "Unknown"}',
      styles: const PosStyles(align: PosAlign.left),
    );
    bytes += generator.feed(1);
    bytes += generator.barcode(
      Barcode.code128(widget.invoice.returnBarcode?.split('') ?? []),
    );
    bytes += generator.feed(2);
    bytes += generator.text(
      'Thank you for your purchase!',
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.cut();
    return bytes;
  }

  //   Widget receiptWidget(String printerType) {
  //     log("Date1: ${DateTime.now()}");
  //     final widget = SizedBox(
  //       width: 550,
  //       child: Material(
  //         child: Padding(
  //           padding: const EdgeInsets.all(16.0),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               const Center(
  //                 child: Text(
  //                   'FLUTTER THERMAL PRINTER',
  //                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  //                 ),
  //               ),
  //               const Divider(thickness: 2),
  //               const SizedBox(height: 10),
  //               _buildReceiptRow('Item', 'Price'),
  //               const Divider(),
  //               _buildReceiptRow('Apple', '\$1.00'),
  //               _buildReceiptRow('Banana', '\$0.50'),
  //               _buildReceiptRow('Orange', '\$0.75'),
  //               const Divider(thickness: 2),
  //               _buildReceiptRow('Total', '\$2.25', isBold: true),
  //               const SizedBox(height: 20),
  //               _buildReceiptRow('Printer Type', printerType),
  //               const SizedBox(height: 50),
  //               const Center(
  //                 child: Text(
  //                   'Thank you for your purchase!',
  //                   style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     );
  //     log("Date1: ${DateTime.now()}");
  //     return widget;
  //   }
  // }

  // Widget _buildReceiptRow(
  //   String leftText,
  //   String rightText, {
  //   bool isBold = false,
  // }) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 4.0),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(
  //           leftText,
  //           style: TextStyle(
  //             fontSize: 16,
  //             fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
  //           ),
  //         ),
  //         Text(
  //           rightText,
  //           style: TextStyle(
  //             fontSize: 16,
  //             fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
}
