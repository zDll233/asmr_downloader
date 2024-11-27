import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

List<Widget> ellipsisInMiddle(String nameWithExt) {
  final ext = p.extension(nameWithExt);
  if (ext.isEmpty) {
    return <Widget>[Text(nameWithExt, overflow: TextOverflow.ellipsis)];
  } else {
    final name = nameWithExt.split(ext)[0];
    return <Widget>[
      Flexible(
        child: Text(
          name,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Text(ext),
    ];
  }
}
