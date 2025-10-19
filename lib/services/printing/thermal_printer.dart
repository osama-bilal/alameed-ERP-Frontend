// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/models/pos_view.dart';
import 'package:ponit_of_sales/services/auth_service.dart';
import 'package:ponit_of_sales/services/printing/generate_web_pdf.dart';
import 'package:ponit_of_sales/utils/main.dart';
import 'package:printing/printing.dart' show Printing;

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
  bool goin = false;
  @override
  void dispose() {
    _devicesStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _printPdf() async {
    if (mounted) {
      setState(() {
        goin = true;
      });
    }
    Uint8List pdfBytes = await generateReceipt(
      invoice: widget.invoice,
      products: widget.products,
      customer: widget.customer,
    );
    debugPrint(pdfBytes.length.toString());
    try {
      if (await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        format: PdfPageFormat.roll80,
      )) {
        log("print started");
      } else {
        log('print faild');
      }
    } on Exception catch (e) {
      log(e.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    if (mounted) {
      setState(() {
        goin = false;
      });
    }
  }

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
    return grayscaleImage;
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
    if (goin) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Plugin'),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
        actions: [
          ElevatedButton(onPressed: _printPdf, child: const Text("Print")),
        ],
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
              decoration: const InputDecoration(labelText: 'Enter IP Address'),
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
    bytes += generator.text(
      'Date: ${formatDateTimeSmart(widget.invoice.date, reference: DateTime(1990), use24Hour: true)}',
    );
    bytes += generator.feed(1);
    bytes += generator.text(
      'Customer: ${widget.customer}',
      styles: const PosStyles(align: PosAlign.left),
    );
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
    bytes += generator.text('User: $userName');
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
}
