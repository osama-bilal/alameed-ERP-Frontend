import 'package:flutter/material.dart';

class MyDataSource<T> extends DataTableSource {
  final List<T> _data;
  final Map<String, dynamic> Function(T) toMap;
  List<String> excludeFields;
  final void Function(T)? editObject;
  final void Function(T)? deleteObject;
  final void Function(T)? viewObject;
  MyDataSource(
    this._data,
    this.toMap, {
    this.editObject,
    this.deleteObject,
    this.viewObject,
    this.excludeFields = const [
      'created_at',
      'updated_at',
      'deleted_at',
      'updated_by',
      'created_by',
    ],
  });

  // new: expose length (optional) or add helper methods if needed
  int get length => _data.length;

  // new: sort helper that updates the underlying list and notifies listeners
  void sortByKey(String key, bool ascending) {
    int compareValues(dynamic aVal, dynamic bVal) {
      if (aVal == null && bVal == null) return 0;
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

    _data.sort((a, b) {
      final aVal = toMap(a)[key];
      final bVal = toMap(b)[key];
      final cmp = compareValues(aVal, bVal);
      return ascending ? cmp : -cmp;
    });

    // notify the PaginatedDataTable to rebuild immediately
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    if (index >= _data.length) return null;
    final item = _data[index];
    return DataRow(
      cells: toMap(item).entries
          .where((element) => !excludeFields.contains(element.key))
          .map((v) {
            if (v.key == "is_active") {
              return DataCell(
                Checkbox(
                  value: v.value == 1 || v.value == true,
                  onChanged: null,
                ),
              );
            }
            return DataCell(
              Text(v.value?.toString() ?? "", overflow: TextOverflow.ellipsis),
            );
          })
          .followedBy([
            DataCell(
              Row(
                children: [
                  IconButton(
                    onPressed: viewObject == null
                        ? null
                        : () {
                            viewObject!(item);
                          },
                    icon: Icon(Icons.remove_red_eye),
                  ),
                  IconButton(
                    onPressed: editObject == null
                        ? null
                        : () {
                            editObject!(item);
                          },
                    icon: Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: deleteObject == null
                        ? null
                        : () {
                            deleteObject!(item);
                          },
                    icon: Icon(Icons.delete),
                  ),
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
  State<MyPaginatedDataTable> createState() => _MyPaginatedDataTableState();
}

class _MyPaginatedDataTableState extends State<MyPaginatedDataTable> {
  int sortedBy = 0;

  bool isAscending = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Theme(
        data: Theme.of(context).copyWith(
          cardTheme: CardThemeData(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          dataTableTheme: DataTableThemeData(
            dataRowColor: WidgetStatePropertyAll(Colors.white),
            dividerThickness: 0.5,
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            dataTextStyle: const TextStyle(color: Colors.black87),
          ),
        ),
        child: PaginatedDataTable(
          showEmptyRows: false,
          columns: widget.columnsName
              .map(
                (e) => DataColumn(
                  label: Text(e, overflow: TextOverflow.ellipsis),
                  onSort: (columnIndex, ascending) {
                    final key = e.toLowerCase().replaceAll(' ', '_');
                    if (sortedBy == columnIndex) {
                      isAscending = !isAscending;
                    } else {
                      sortedBy = columnIndex;
                      isAscending = true;
                    }
                    widget.datasource.sortByKey(key, isAscending);
                  },
                ),
              )
              .followedBy([DataColumn(label: Text("Action"))])
              .toList(),
          source: widget.datasource,

          showFirstLastButtons: true,
        ),
      ),
    );
  }
}
