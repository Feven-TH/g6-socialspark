import 'package:flutter/foundation.dart';
import '../models/library_item.dart';

class LibraryLocalDataSource extends ChangeNotifier {
  LibraryLocalDataSource._();

  static final LibraryLocalDataSource instance = LibraryLocalDataSource._();

  final List<LibraryItem> _items = [];
  
  Future<List<LibraryItem>> getLibraryItems() async {
    return List.unmodifiable(_items);
  }

  Future<void> saveLibraryItem(LibraryItem item) async {
    _items.add(item);
    notifyListeners();
  }

  Future<void> deleteLibraryItem(String id) async {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}
