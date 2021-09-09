import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class Entry {
  int id;
  String title;
  String content;
  String imageUrl;
  String createdAt;

  Entry.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        content = json['content'],
        imageUrl = json['image_url'],
        createdAt = new DateFormat.yMMMd("en_US")
            .format(DateTime.parse(json['created_at']));
}
