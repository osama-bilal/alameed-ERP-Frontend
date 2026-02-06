// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import 'package:point_of_sales/utils/bluetooth_helper.dart';
import '/controllers/provider/pos_view.dart';
import '/l10n/app_localizations.dart';
import '/models/invoices/invoice.dart';
import '/services/printing/generate_receipt.dart';
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
  });
  final Invoice invoice;
  final String customer;
  @override
  State<ThermalPrinting> createState() => _ThermalPrintingState();
}

class _ThermalPrintingState extends State<ThermalPrinting> {
  final _flutterThermalPrinterPlugin = FlutterThermalPrinter.instance;
  late var l10n = AppLocalizations.of(context)!;
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
      products: context.read<ProductsProvider>().pros,
      customer: widget.customer,
      l10n: l10n,
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      bool isReady = await checkAndRequestBluetooth(context);
      if (isReady) {
        startScan();
      }
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
        title: Text(AppLocalizations.of(context)!.printPlugin),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
        actions: [
          ElevatedButton(
            onPressed: _printPdf,
            child: Text(AppLocalizations.of(context)!.print),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.network,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _ip,
              decoration: const InputDecoration(labelText: 'IP Address'),
              onChanged: (value) {
                _ip = value;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _port,
              decoration: const InputDecoration(labelText: 'Port'),
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
                        bytes = await _generateReceipt();
                        bytes += generator.cut();
                        await service.printTicket(bytes);
                      }
                      await service.disconnect();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.testNetworkPrinter,
                    ),
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
                    child: Text(
                      AppLocalizations.of(context)!.testNetworkPrinterWidget,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 22),
            Text(
              AppLocalizations.of(context)!.usbBle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      startScan();
                    },
                    child: Text(AppLocalizations.of(context)!.getPrinters),
                  ),
                ),
                const SizedBox(width: 22),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      stopScan();
                    },
                    child: Text(AppLocalizations.of(context)!.stopScan),
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
                        await printer.disconnect();
                      } else {
                        await printer.connect();
                      }
                      if (mounted) {
                        setState(() {
                          printers[index] = printer;
                        });
                      }
                    },
                    title: Text(printer.name ?? 'No Name'),
                    subtitle: Text(
                      "${AppLocalizations.of(context)!.connected}: ${printer.paired ?? false}",
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.connect_without_contact),
                      onPressed: () async {
                        final data = await _generateReceipt(
                          type: printer.connectionTypeString,
                        );
                        await _flutterThermalPrinterPlugin.printData(
                          printer,
                          data,
                          longData: true,
                        );
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
    // 1. Generate the PDF (which handles Arabic correctly)
    final Uint8List pdfBytes = await generateReceipt(
      invoice: widget.invoice,
      products: context.read<ProductsProvider>().pros,
      customer: widget.customer,
      l10n: l10n,
    );

    // 2. Rasterize the PDF to an image
    // roll80 is usually 203dpi or similar.
    // We iterate over pages, but receipt is usually 1 page or continuous.
    List<int> bytes = [];
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    await for (final page in Printing.raster(pdfBytes, dpi: 203)) {
      final img.Image? image = img.decodePng(await page.toPng());

      if (image != null) {
        // Resize if needed, but 80mm at 203dpi is ~570-600px width.
        // The generator usually handles width, but ensuring it fits is good.
        // However, printing package rasterizes to the PDF page format size.
        // We'll just pass the image to the generator.

        // Convert to grayscale might be needed for some printers,
        // but generator.image usually handles it (dithering).
        bytes += generator.image(image);
      }
    }

    bytes += generator.cut();
    return bytes;
  }
}
