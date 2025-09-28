import 'package:flutter/material.dart';

class ScreenCardWidget extends StatelessWidget {
  const ScreenCardWidget({
    super.key,
    required this.screenToGo,
    required this.name,
    required this.icon,
  });
  final Widget screenToGo;
  final String name;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => screenToGo)),
      child: Card(
        shadowColor: Colors.grey,

        color: Colors.lightBlueAccent,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LayoutBuilder(
              builder: (context, constrains) {
                return ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                  child: Icon(icon, size: constrains.maxWidth / 2),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
