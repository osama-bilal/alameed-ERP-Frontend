import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '/blocs/general/general_bloc.dart';
import '/models/report.dart';

class ReportCreatePage extends StatefulWidget {
  const ReportCreatePage({super.key});

  @override
  State<ReportCreatePage> createState() => _ReportCreatePageState();
}

class _ReportCreatePageState extends State<ReportCreatePage> {
  final _formKey = GlobalKey<FormState>();

  String _reportType = 'daily';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  final Map<String, String> _reportTypes = {
    'daily': 'Daily',
    'weekly': 'Weekly',
    'monthly': 'Monthly',
    'yearly': 'Yearly',
    'custom': 'Custom Range',
  };

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _generateReport() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // The backend will calculate the details. We just send the parameters.
      final reportToCreate = Report(
        id: 0, // Placeholder, will be set by backend
        reportType: _reportType,
        startDate: _startDate,
        endDate: _endDate,
        totalSales: "0",
        totalDeposits: "0",
        totalExpenses: "0",
        totalWithdraws: "0",
        netProfit: "0",
        totalInvoices: 0,
        totalProductsSold: 0,
        totalProductsReturned: 0,
      );

      context.read<GeneralBloc<Report>>().add(AddItem(reportToCreate));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _generateReport,
            tooltip: 'Generate Report',
          ),
        ],
      ),
      body: BlocListener<GeneralBloc<Report>, GeneralState<Report>>(
        listener: (context, state) {
          if (state is ItemOperationSuccess<Report>) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Report generated successfully!')),
            );
            Navigator.of(context).pop();
          } else if (state is ItemLoadFailure<Report>) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                DropdownButtonFormField<String>(
                  errorBuilder: (context, errorText) => Text(errorText),
                  initialValue: _reportType,
                  hint: const Text('Select Report Type'),
                  items: _reportTypes.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _reportType = value;
                      });
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Report Type'),
                  validator: (value) =>
                      value == null ? 'Please select a report type' : null,
                ),
                if (_reportType == 'custom') ...[
                  const SizedBox(height: 24),
                  Text(
                    'Custom Date Range',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Start Date: ${DateFormat.yMd().format(_startDate)}',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context, true),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'End Date: ${DateFormat.yMd().format(_endDate)}',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context, false),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
