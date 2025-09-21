import 'package:flutter/material.dart';

class SearchButton extends StatefulWidget {
  const SearchButton({super.key});

  @override
  createState() => _SearchButtonState();
}

class _SearchButtonState extends State<SearchButton> {
  // متغير لتتبع حالة الحقل (ظاهر أو مخفي)
  bool _isSearchFieldVisible = false;

  // دالة لتغيير حالة الحقل
  void _toggleSearchField() {
    setState(() {
      _isSearchFieldVisible = !_isSearchFieldVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 300),
      // تحديد عرض الحاوية لضمان وجود مساحة كافية عند توسع الحقل
      // width: 300,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          // تأثير "التحول التدريجي" (fade)
          return FadeTransition(opacity: animation, child: child);
        },
        child: _isSearchFieldVisible
            ? // إذا كان الحقل مرئياً، اعرضه
              TextField(
                key: const ValueKey('searchField'),
                decoration: InputDecoration(
                  hintText: 'ابحث هنا...',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _toggleSearchField,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                autofocus: true, // يركز على الحقل تلقائياً عند ظهوره
              )
            : // وإلا، اعرض زر البحث
              IconButton(
                key: const ValueKey('searchButton'),
                onPressed: _toggleSearchField,
                icon: const Icon(Icons.search),
              ),
      ),
    );
  }
}
