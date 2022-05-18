import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<List<String>> loadFavorites() async {
  final directory = await getApplicationDocumentsDirectory();
  final path = directory.path;
  if (File('$path/favorites.txt').existsSync()) {
    final file = File('$path/favorites.txt');
    final favorites = await file.readAsString();
    if (favorites != '') {
      final favoritesList = favorites.split(',');
      return favoritesList;
    }
  }
  return [];
}

Future<void> addNewFavorites(List<String> newFavorites) async {
  final oldFavorites = await loadFavorites();
  final finalFavorites = oldFavorites
    ..toSet()
    ..addAll(newFavorites)
    ..toList();
  writeFavorites(finalFavorites);
}

Future<void> writeFavorites(List<String> newFavorites) async {
  final directory = await getApplicationDocumentsDirectory();
  final path = directory.path;
  final file = File('$path/favorites.txt');
  final Set favoritesList = {};

  favoritesList.addAll(newFavorites);
  final favoritesString = favoritesList.join(',');
  await file.writeAsString(favoritesString);
}
