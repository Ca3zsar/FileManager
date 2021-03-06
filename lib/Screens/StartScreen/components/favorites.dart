import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tppm/utils/favorites_manager.dart';

class Favorites extends StatefulWidget {
  final double height;

  const Favorites({Key? key, required this.height}) : super(key: key);

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  final List<String> favorites = [];
  final List<String> paths = [];
  Timer? _timer;

  void deleteFavorite(int index) {
    setState(() {
      favorites.removeAt(index);
      paths.removeAt(index);
      writeFavorites(paths);
    });
  }

  Future<void> loadFavoritesIntoUI() async {
    final favoritesList = await loadFavorites();
    setState(() {
      favorites
        ..clear()
        ..addAll(favoritesList.map((e) => e.split('/').last));
      paths
        ..clear()
        ..addAll(favoritesList);
    });
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (Timer timer) {
      setState(() => {loadFavoritesIntoUI()});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: widget.height * 0.3,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x476b7d94),
                spreadRadius: 0,
                blurRadius: 10,
                offset: Offset(0, 10), // changes position of shadow
              ),
            ]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/images/favorite.png',
                  )
                ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Text(
                      "Favorite Files/Folders",
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: "GilroyBold",
                          fontWeight: FontWeight.w700),
                    )
                  ],
                )
              ],
            ),
            Expanded(
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15)),
                  child: ListView.builder(
                    itemCount: favorites.length,
                    itemBuilder: (BuildContext context, int index) {
                      return FavoriteItem(index, favorites[index], paths[index],
                          deleteFavorite);
                    },
                  )),
            )
          ],
        ));
  }
}

class FavoriteItem extends StatelessWidget {
  final int index;
  final String title;
  final String path;

  final void Function(int) callback;

  const FavoriteItem(this.index, this.title, this.path, this.callback);

  @override
  Widget build(BuildContext context) {
    final type = path.split('/')[2] == 'emulated' ? "Internal" : "SD Card";
    return Card(
        child: ListTile(
      onTap: () {
        if (File(path).statSync().type == FileSystemEntityType.directory) {
          Navigator.pushNamed(context, '/filelist', arguments: [type, path]);
        }
      },
      // minVerticalPadding: 1,
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      title: Text(
        title,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontFamily: "Gilroy",
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(path,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontFamily: "Gilroy", fontSize: 10, fontWeight: FontWeight.w600)),
      trailing: IconButton(
          onPressed: () {
            callback(index);
          },
          icon: const Icon(Icons.remove_circle_rounded)),
    ));
  }
}
