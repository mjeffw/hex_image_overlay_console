import 'dart:io';
import 'dart:math';

import 'package:hexagonal_grid/hexagonal_grid.dart';
import 'package:image/image.dart' as img;
import 'package:quiver/core.dart';

var hexes = <Hex>{};
var TRANSPARENT = img.getColor(0, 0, 0, 0);

main(List<String> arguments) {
  print('Hello world!');

  // input parameters
  // var pixelsPerYard = 120.0;
  var pixelsPerYard = 120.0;
  var toEdge = false;
  var fname = 'The Strong Gate HoJ p50-hexes.png';
  var color = img.getColor(255, 255, 0);
  var thickness = 5;

  // give user the choice: print the hex image alone, or composite on top of other image.
  // if hex image, require user enters dimensions (width x height). if composite, use
  // source image dimensions.
  // var height = 640;
  // var width = 480;

  var image = img.decodeImage(File(
          '/Users/jw9615/Personal/docs/HoJ_20Encounter_20Maps/The Strong Gate HoJ p50.jpg')
      .readAsBytesSync());

  // Given a right triangle, ABC, where AB and AC are the sides and BC is the
  // hypotenuse, find the hypotenuse of a right triangle where AB =
  // pixelsPerYard/2.0, and angle ACB is 60 degrees.
  var edge = (0.5 * pixelsPerYard) / sin(60.0 * pi / 180.0);

  // var image = img.Image(width, height);
  // image.fill(img.getColor(127, 127, 255));

  var size = Point(edge, edge);
  var origin = Point(10, 10); // inset from the edge a little bit
  var layout = HexLayout.orientPointy(size, origin);

  for (var x = 0; x < image.width; x += size.x.toInt()) {
    for (var y = 0; y < image.height; y += size.y.toInt()) {
      var pt = Point(x, y);
      var hex = Hex.fromPoint(layout, pt);

      if (toEdge || allPointsAreIn(hex.corners(layout), image)) hexes.add(hex);
    }
  }

  print('total number of hexes: ${hexes.length}');

  for (var hex in hexes) {
    var points = hex.corners(layout);

    for (var i = 0; i < points.length; i++) {
      var current = points[i];
      var next = points.last == current ? points[0] : points[i + 1];

      _drawLine(image, current, next, color, thickness);
    }
  }

  File(fname).writeAsBytesSync(img.encodePng(image));
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

void _drawLine(img.Image image, Point<num> current, Point<num> next, int color,
    num thickness) {
  if (!lines.contains(Line(current, next))) {
    img.drawLine(image, current.x.round(), current.y.round(), next.x.round(),
        next.y.round(), color,
        thickness: thickness, antialias: false);
    lines.add(Line(current, next));
  }
}
