import 'package:flutter/material.dart';

class MyDataSource<T> extends DataTableSource {
  final List<T> _data;
  final Map<String, dynamic> Function(T) toMap;
  MyDataSource(this._data, this.toMap);

  @override
  DataRow? getRow(int index) {
    if (index >= _data.length) return null;
    final item = _data[index];
    return DataRow(
      cells: toMap(item)
                                            .entries
                                            .where(
                                              (element) =>
                                                  element.key != 'created_at' &&
                                                  element.key != 'updated_at' &&
                                                  element.key != 'deleted_at' &&
                                                  element.key != 'updated_by' &&
                                                  element.key != 'created_by',
                                            )
                                            .map(
                                              (v) => DataCell(
                                                Text(
                                                  v.value.toString(),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            )
                                            .toList(),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;
}

// class MyPaginatedDataTable extends StatefulWidget {
//   @override
//   _MyPaginatedDataTableState createState() => _MyPaginatedDataTableState();
// }

// class _MyPaginatedDataTableState extends State<MyPaginatedDataTable> {
//   late MyDataSource _dataSource;

//   @override
//   void initState() {
//     super.initState();
//     _dataSource = MyDataSource();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Paginated Data Table Example')),
//       body: SingleChildScrollView(
//         child: PaginatedDataTable(
//           header: Text('My Data'),
//           rowsPerPage: 10,
//           columns: const <DataColumn>[
//             DataColumn(label: Text('ID')),
//             DataColumn(label: Text('Name')),
//             DataColumn(label: Text('Value')),
//           ],
//           source: _dataSource,
//         ),
//       ),
//     );
//   }
// }
