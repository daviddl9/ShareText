import 'package:meta/meta.dart';

class Book {
  static final db_title = "title";
  static final db_url = "url";
  static final db_id = "id";
  static final db_notes = "notes";
  static final db_star = "star";
  static final db_author = "author";
  static final db_description = "description";
  static final db_subtitle = "subtitle";
  static final db_wishlisted = "wishlisted";

  String title, url, id, notes, description, subtitle;
  //First author
  String author;
  bool starred;
  bool wishlisted;
  Book({
    @required this.title,
    @required this.url,
    @required this.id,
    @required this.author,
    @required this.description,
    @required this.subtitle,
    this.starred = false,
    this.notes = "",
    this.wishlisted = false
  });

  Book.fromMap(Map<String, dynamic> map): this(
    title: map[db_title],
    url: map[db_url],
    id: map[db_id],
    starred: map[db_star] == 1,
    notes: map[db_notes],
    description: map[db_description],
    author: map[db_author],
    subtitle: map[db_subtitle],
    wishlisted: map[db_wishlisted] == 1
  );

}
