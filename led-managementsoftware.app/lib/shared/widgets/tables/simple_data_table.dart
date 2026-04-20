import 'package:flutter/material.dart';

class SimpleDataTable extends StatelessWidget {
  const SimpleDataTable({
    super.key,
    required this.columns,
    required this.rows,
  });

  final List<String> columns;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: columns.map((column) => DataColumn(label: Text(column))).toList(),
      rows: rows
          .map(
            (row) => DataRow(
              cells: row.map((cell) => DataCell(Text(cell))).toList(),
            ),
          )
          .toList(),
    );
  }
}
