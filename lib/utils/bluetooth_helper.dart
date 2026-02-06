import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:point_of_sales/l10n/app_localizations.dart';

Future<bool> checkAndRequestBluetooth(BuildContext context) async {
  // 1. Check if Bluetooth is supported
  if (!await FlutterBluePlus.isSupported) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.bluetoothNotSupported),
        ),
      );
    }
    return false;
  }

  // 2. Check current state
  // Using a timeout to avoid hanging if the stream is empty (though it shouldn't be)
  BluetoothAdapterState state = BluetoothAdapterState.unknown;
  try {
    state = await FlutterBluePlus.adapterState.first;
  } catch (e) {
    // Fallback or retry?
    debugPrint("Error getting bluetooth state: $e");
  }

  if (state == BluetoothAdapterState.on) {
    return true;
  }

  // 3. If off, show dialog
  if (context.mounted) {
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.bluetoothRequired),
        content: Text(
          AppLocalizations.of(context)!.bluetoothRequiredMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (Platform.isAndroid) {
                try {
                  await FlutterBluePlus.turnOn();
                } catch (e) {
                  debugPrint("Error turning on bluetooth: $e");
                }
              }
              Navigator.of(context).pop(true);
            },
            child: Text(AppLocalizations.of(context)!.turnOn),
          ),
        ],
      ),
    );

    if (result == true) {
      // Wait for it to turn on
      try {
        // Wait up to 5 seconds for state to change to on
        await FlutterBluePlus.adapterState
            .where((s) => s == BluetoothAdapterState.on)
            .first
            .timeout(const Duration(seconds: 5));
        return true;
      } catch (e) {
        return false;
      }
    }
  }

  return false;
}
