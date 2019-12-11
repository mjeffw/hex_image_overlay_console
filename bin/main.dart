import 'dart:io';
import 'dart:math';

import 'package:hex_paper_generator_console/placeholder.dart'
    as hex_paper_generator_console;
import 'package:hexagonal_grid/hexagonal_grid.dart';
import 'package:image/image.dart' as img;
import 'package:quiver/core.dart';

var hexes = <Hex>{};

main(List<String> arguments) {
  print('Hello world!');

  var image = img.Image(4800, 6400);
  image.fill(img.getColor(127, 127, 255, 0));

  var size = Point(69.2820323027551, 69.2820323027551);
  var origin = Point(10, 10);
  var layout = HexLayout.orientFlat(size, origin);

  for (var x = 0; x < image.width; x += size.x.toInt()) {
    for (var y = 0; y < image.height; y += size.y.toInt()) {
      var pt = Point(x, y);
      var hex = Hex.fromPoint(layout, pt);

      if (allPointsAreIn(hex.corners(layout), image)) hexes.add(hex);
    }
  }

  print('total number of hexes: ${hexes.length}');

  for (var hex in hexes) {
    var points = hex.corners(layout);

    for (var i = 0; i < points.length; i++) {
      var current = points[i];
      var next = points.last == current ? points[0] : points[i + 1];

      _drawLine(image, current, next);
    }
  }

  File('temp.png').writeAsBytesSync(img.encodePng(image));
  print('Exit?');
}

bool allPointsAreIn(List<Point<num>> points, img.Image image) {
  for (var p in points) {
    if (!image.boundsSafe(p.x.round(), p.y.round())) return false;
  }
  return true;
}

class Line {
  Point p1;
  Point p2;
  Line(this.p1, this.p2);

  @override
  bool operator ==(dynamic other) {
    return other is Line && p1 == other.p1 && p2 == other.p2;
  }

  @override
  int get hashCode => hash2(p1, p2);
}

var lines = <Line>{};

void _drawLine(img.Image image, Point<num> current, Point<num> next) {
  if (!lines.contains(Line(current, next))) {
    img.drawLine(image, current.x.round(), current.y.round(), next.x.round(),
        next.y.round(), img.getColor(0, 0, 0),
        thickness: 2.5, antialias: false);
    lines.add(Line(current, next));
  }
}
