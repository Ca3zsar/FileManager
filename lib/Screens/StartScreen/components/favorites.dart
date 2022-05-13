import 'package:flutter/material.dart';

class Favorites extends StatefulWidget {
  final double height;

  const Favorites({Key? key, required this.height}) : super(key: key);

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  final List<String> favorites = ["Folder1", "File1", "Folder2", "Folder3"];
  final List<String> paths = ["path1", "path/subpath/file1", "path2", "path3"];

  void deleteFavorite(int index) {
    setState(() {
      favorites.removeAt(index);
    });
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
    return Card(
        child: ListTile(
      onTap: () {
        print("aici sunt");
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
          style: const TextStyle(fontFamily: "Gilroy", fontSize: 10)),
      trailing: IconButton(
          onPressed: () {
            callback(index);
          },
          icon: const Icon(Icons.remove_circle_rounded)),
    ));
  }
}
