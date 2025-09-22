import 'package:flutter/material.dart';

class MyDataSource<T> extends DataTableSource {
  final List<T> _data;
  final Map<String, dynamic> Function(T) toMap;
  List<String> excludeFields;
  MyDataSource(
    this._data,
    this.toMap, {
    this.excludeFields = const [
      'created_at',
      'updated_at',
      'deleted_at',
      'updated_by',
      'created_by',
    ],
  });

  @override
  DataRow? getRow(int index) {
    if (index >= _data.length) return null;
    final item = _data[index];
    return DataRow(
      cells: toMap(item).entries
          .where((element) => !excludeFields.contains(element.key))
          .map(
            (v) => DataCell(
              Text(v.value.toString(), overflow: TextOverflow.ellipsis),
            ),
          )
          .followedBy([
            DataCell(
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.remove_red_eye),
                  ),
                  IconButton(onPressed: () {}, icon: Icon(Icons.edit)),
                  IconButton(onPressed: () {}, icon: Icon(Icons.delete)),
                ],
              ),
            ),
          ])
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

class MyPaginatedDataTable extends StatefulWidget {
  final MyDataSource datasource;
  final List<String> columnsName;
  const MyPaginatedDataTable({
    super.key,
    required this.datasource,
    required this.columnsName,
  });
  @override
  createState() => _MyPaginatedDataTableState();
}

class _MyPaginatedDataTableState extends State<MyPaginatedDataTable> {
  late MyDataSource _dataSource;
  String? sortBy;

  @override
  void initState() {
    _dataSource = widget.datasource;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // _dataSource = widget.datasource;
    return PaginatedDataTable(
      columnSpacing: 20,
      headingRowColor: WidgetStatePropertyAll(Colors.grey[350]),
      rowsPerPage: 10,
      columns: widget.columnsName
          .map(
            (e) => DataColumn(
              columnWidth: MinColumnWidth(
                FixedColumnWidth(150),
                IntrinsicColumnWidth(),
              ),
              label: Text(e, overflow: TextOverflow.ellipsis),
              onSort: (columnIndex, ascending) {
                final key = e.toLowerCase().replaceAll(' ', '_');
                int compareValues(dynamic aVal, dynamic bVal) {
                  if (aVal == null && bVal == null) {
                    return 0;
                  }
                  if (aVal == null) return -1;
                  if (bVal == null) return 1;
                  final aNum = num.tryParse(aVal.toString());
                  final bNum = num.tryParse(bVal.toString());
                  if (aNum != null && bNum != null) {
                    return aNum.compareTo(bNum);
                  }
                  return aVal.toString().toLowerCase().compareTo(
                    bVal.toString().toLowerCase(),
                  );
                }

                // Scaffold.of(context).setState(() {
                  setState(() {
                    // If already sorted by this column, reverse order; otherwise sort ascending.
                    if (sortBy == key) {
                      _dataSource._data.sort((a, b) {
                        final aVal = a.toMap()[key];
                        final bVal = b.toMap()[key];
                        return -compareValues(aVal, bVal);
                      });
                    } else {
                      _dataSource._data.sort((a, b) {
                        final aVal = a.toMap()[key];
                        final bVal = b.toMap()[key];
                        return compareValues(aVal, bVal);
                      });
                      sortBy = key;
                    }
                  });
                // });
              },
            ),
          )
          .followedBy([DataColumn(label: Text("Action"))])
          .toList(),
      source: _dataSource,
      // actions: [],
      controller: null,
      showCheckboxColumn: true,
    );
  }
}
