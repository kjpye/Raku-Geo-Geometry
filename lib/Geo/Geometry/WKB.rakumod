unit class Geo::Geometry::WKB;

use Geo::Geometry;

sub wkb-get-point($buff, $offset is rw, $endian) {
    my $x = $buff.read-num64($offset, $endian); $offset += 8;
    my $y = $buff.read-num64($offset, $endian); $offset += 8;
    Point.new($x, $y);
}

sub wkb-get-pointz($buff, $offset is rw, $endian) {
    my $x = $buff.read-num64($offset, $endian); $offset += 8;
    my $y = $buff.read-num64($offset, $endian); $offset += 8;
    my $z = $buff.read-num64($offset, $endian); $offset += 8;
    PointZ.new($x, $y, $z);
}

sub wkb-get-pointm($buff, $offset is rw, $endian) {
    my $x = $buff.read-num64($offset, $endian); $offset += 8;
    my $y = $buff.read-num64($offset, $endian); $offset += 8;
    my $m = $buff.read-num64($offset, $endian); $offset += 8;
    PointM.new($x, $y, $m);
}

sub wkb-get-pointzm($buff, $offset is rw, $endian) {
    my $x = $buff.read-num64($offset, $endian); $offset += 8;
    my $y = $buff.read-num64($offset, $endian); $offset += 8;
    my $z = $buff.read-num64($offset, $endian); $offset += 8;
    my $m = $buff.read-num64($offset, $endian); $offset += 8;
    PointZM.new($x, $y, $z, $m);
}

sub wkb-get-linearring($buff, $offset is rw, $endian) {
    my $num-points = $buff.read-uint32($offset, $endian); $offset += 4;
    my @points;
    for ^$num-points {
        @points.push: wkb-get-point($buff, $offset, $endian);
    }
    LinearRing.new(points => @points);
}

sub wkb-get-linearringz($buff, $offset is rw, $endian) {
    my $num-points = $buff.read-uint32($offset, $endian); $offset += 4;
    my @points;
    for ^$num-points {
        @points.push: wkb-get-pointz($buff, $offset, $endian);
    }
    LinearRingZ.new(points => @points);
}

sub wkb-get-linearringm($buff, $offset is rw, $endian) {
    my $num-points = $buff.read-uint32($offset, $endian); $offset += 4;
    my @points;
    for ^$num-points {
        @points.push: wkb-get-pointm($buff, $offset, $endian);
    }
    LinearRingM.new(points => @points);
}

sub wkb-get-linearringzm($buff, $offset is rw, $endian) {
    my $num-points = $buff.read-uint32($offset, $endian); $offset += 4;
    my @points;
    for ^$num-points {
        @points.push: wkb-get-pointzm($buff, $offset, $endian);
    }
    LinearRingZM.new(points => @points);
}

sub wkb-get-linestring($buff, $offset is rw, $endian) {
    my @points;
    my $num-points = $buff.read-uint32($offset, $endian); $offset += 4;
    for ^$num-points {
        @points.push: wkb-get-point($buff, $offset, $endian);
    }
    LineString.new(points => @points);
}

sub wkb-get-linestringz($buff, $offset is rw, $endian) {
    my @points;
    my $num-points = $buff.read-uint32($offset, $endian); $offset += 4;
    for ^$num-points {
        @points.push: wkb-get-pointz($buff, $offset, $endian);
    }
    LineStringZ.new(points => @points);
}

sub wkb-get-linestringm($buff, $offset is rw, $endian) {
    my @points;
    my $num-points = $buff.read-uint32($offset, $endian); $offset += 4;
    for ^$num-points {
        @points.push: wkb-get-pointm($buff, $offset, $endian);
    }
    LineStringM.new(points => @points);
}

sub wkb-get-linestringzm($buff, $offset is rw, $endian) {
    my @points;
    my $num-points = $buff.read-uint32($offset, $endian); $offset += 4;
    for ^$num-points {
        @points.push: wkb-get-pointzm($buff, $offset, $endian);
    }
    LineStringZM.new(points => @points);
}

sub wkb-get-polygon($buff, $offset is rw, $endian) {
    my @rings;
    my $num-rings = $buff.read-uint32($offset, $endian); $offset += 4;
    for ^$num-rings {
        @rings.push: wkb-get-linearring($buff, $offset, $endian);
    }
    Polygon.new(rings => @rings);
}

sub wkb-get-polygonz($buff, $offset is rw, $endian) {
    my @rings;
    my $num-rings = $buff.read-uint32($offset, $endian); $offset += 4;
    for ^$num-rings {
        @rings.push: wkb-get-linearringz($buff, $offset, $endian);
    }
    PolygonZ.new(rings => @rings);
}

sub wkb-get-polygonm($buff, $offset is rw, $endian) {
    my @rings;
    my $num-rings = $buff.read-uint32($offset, $endian); $offset += 4;
    for ^$num-rings {
        @rings.push: wkb-get-linearringm($buff, $offset, $endian);
    }
    PolygonM.new(rings => @rings);
}

sub wkb-get-polygonzm($buff, $offset is rw, $endian) {
    my @rings;
    my $num-rings = $buff.read-uint32($offset, $endian); $offset += 4;
    for ^$num-rings {
        @rings.push: wkb-get-linearringzm($buff, $offset, $endian);
    }
    PolygonZM.new(rings => @rings);
}

sub wkb-get-triangle($buff, $offset is rw, $endian) {
    my @rings;
    my $num-rings = $buff.read-uint32($offset, $endian); $offset += 4;
    for ^$num-rings {
        @rings.push: wkb-get-linearring($buff, $offset, $endian);
    }
    Triangle.new(rings => @rings);
}

sub wkb-get-trianglez($buff, $offset is rw, $endian) {
    my @rings;
    my $num-rings = $buff.read-uint32($offset, $endian); $offset += 4;
    for ^$num-rings {
        @rings.push: wkb-get-linearringz($buff, $offset, $endian);
    }
    TriangleZ.new(rings => @rings);
}

sub wkb-get-trianglem($buff, $offset is rw, $endian) {
    my @rings;
    my $num-rings = $buff.read-uint32($offset, $endian); $offset += 4;
    for ^$num-rings {
        @rings.push: wkb-get-linearringm($buff, $offset, $endian);
    }
    TriangleM.new(rings => @rings);
}

sub wkb-get-trianglezm($buff, $offset is rw, $endian) {
    my @rings;
    my $num-rings = $buff.read-uint32($offset, $endian); $offset += 4;
    for ^$num-rings {
        @rings.push: wkb-get-linearringzm($buff, $offset, $endian);
    }
    TriangleZM.new(rings => @rings);
}

sub wkb-read-geometry($buff, $offset is rw, $endian) {
    my $geometry;
    my $geometry-type = $buff.read-uint32($offset, $endian); $offset += 4;
    if $geometry-type +& 0x20000000 {
        $offset += 4; # skip SRID
        $geometry-type +^= 0x20000000;
    }
    given $geometry-type {
        when wkbPoint {
            $geometry = wkb-get-point($buff, $offset, $endian);
        }
        when wkbPointZ {
            $geometry = wkb-get-pointz($buff, $offset, $endian);
        }
        when wkbPointM {
            $geometry = wkb-get-pointm($buff, $offset, $endian);
        }
        when wkbPointZM {
            $geometry = wkb-get-pointzm($buff, $offset, $endian);
        }
        when wkbLineString {
            $geometry = wkb-get-linestring($buff, $offset, $endian);
        }
        when wkbLineStringZ {
            $geometry = wkb-get-linestringz($buff, $offset, $endian);
        }
        when wkbLineStringM {
            $geometry = wkb-get-linestringm($buff, $offset, $endian);
        }
        when wkbLineStringZM {
            $geometry = wkb-get-linestringzm($buff, $offset, $endian);
        }
        when wkbPolygon {
            $geometry = wkb-get-polygon($buff, $offset, $endian);
        }
        when wkbPolygonZ {
            $geometry = wkb-get-polygonz($buff, $offset, $endian);
        }
        when wkbPolygonM {
            $geometry = wkb-get-polygonm($buff, $offset, $endian);
        }
        when wkbPolygonZM {
            $geometry = wkb-get-polygonzm($buff, $offset, $endian);
        }
        when wkbTriangle {
            $geometry = wkb-get-triangle($buff, $offset, $endian);
        }
        when wkbTriangleZ {
            $geometry = wkb-get-trianglez($buff, $offset, $endian);
        }
        when wkbTriangleM {
            $geometry = wkb-get-trianglem($buff, $offset, $endian);
        }
        when wkbTriangleZM {
            $geometry = wkb-get-trianglezm($buff, $offset, $endian);
        }
        when wkbPolyhedralSurface {
            my @polygons;
            my $num-polygons = $buff.read-uint32($buff, $offset, $endian);
            for ^$num-polygons {
                @polygons.push: wkb-get-polygon($buff, $offset, $endian);
            }
            $geometry = PolyhedralSurface.new(polygons => @polygons);
        }
        when wkbPolyhedralSurfaceZ {
            my @polygons;
            my $num-polygons = $buff.read-uint32($buff, $offset, $endian);
            for ^$num-polygons {
                @polygons.push: wkb-get-polygonz($buff, $offset, $endian);
            }
            $geometry = PolyhedralSurfaceZ.new(polygons => @polygons);
        }
        when wkbPolyhedralSurfaceM {
            my @polygons;
            my $num-polygons = $buff.read-uint32($buff, $offset, $endian);
            for ^$num-polygons {
                @polygons.push: wkb-get-polygonm($buff, $offset, $endian);
            }
            $geometry = PolyhedralSurfaceM.new(polygons => @polygons);
        }
        when wkbPolyhedralSurfaceZM {
            my @polygons;
            my $num-polygons = $buff.read-uint32($buff, $offset, $endian);
            for ^$num-polygons {
                @polygons.push: wkb-get-polygonzm($buff, $offset, $endian);
            }
            $geometry = PolyhedralSurfaceZM.new(polygons => @polygons);
        }
        when wkbTIN {
            my @polygons;
            my $num-polygons = $buff.read-uint32($buff, $offset, $endian);
            for ^$num-polygons {
                @polygons.push: wkb-get-polygon($buff, $offset, $endian);
            }
            $geometry = TIN.new(polygons => @polygons);
        }
        when wkbTINZ {
            my @polygons;
            my $num-polygons = $buff.read-uint32($buff, $offset, $endian);
            for ^$num-polygons {
                @polygons.push: wkb-get-polygonz($buff, $offset, $endian);
            }
            $geometry = TINZ.new(polygons => @polygons);
        }
        when wkbTINM {
            my @polygons;
            my $num-polygons = $buff.read-uint32($buff, $offset, $endian);
            for ^$num-polygons {
                @polygons.push: wkb-get-polygonm($buff, $offset, $endian);
            }
            $geometry = TINM.new(polygons => @polygons);
        }
        when wkbTINZM {
            my @polygons;
            my $num-polygons = $buff.read-uint32($buff, $offset, $endian);
            for ^$num-polygons {
                @polygons.push: wkb-get-polygonzm($buff, $offset, $endian);
            }
            $geometry = TINZM.new(polygons => @polygons);
        }
        when wkbMultiPoint {
            my @points;
            my $num-points = $buff.read-uint32($buff, $offset, $endian);
            for ^$num-points {
                @points.push: wkb-get-point($buff, $offset, $endian);
            }
            $geometry = MultiPoint.new(points => @points);
        }
        when wkbMultiPointZ {
            my @points;
            my $num-points = $buff.read-uint32($buff, $offset, $endian);
            for ^$num-points {
                @points.push: wkb-get-pointz($buff, $offset, $endian);
            }
            $geometry = MultiPointZ.new(points => @points);
        }
        when wkbMultiPointM {
            my @points;
            my $num-points = $buff.read-uint32($buff, $offset, $endian);
            for ^$num-points {
                @points.push: wkb-get-pointm($buff, $offset, $endian);
            }
            $geometry = MultiPointM.new(points => @points);
        }
        when wkbMultiPointZM {
            my @points;
            my $num-points = $buff.read-uint32($buff, $offset, $endian);
            for ^$num-points {
                @points.push: wkb-get-pointzm($buff, $offset, $endian);
            }
            $geometry = MultiPointZM.new(points => @points);
        }
        when wkbMultiLineString {
            my @lines;
            my $num-lines = $buff.read-uint32($buff, $offset, $endian);
            for ^$num-lines {
                @lines.push: wkb-get-linestring($buff, $offset, $endian);
            }
            $geometry = MultiLineString.new(linestrings => @lines);
        }
        when wkbMultiLineStringZ {
            my @lines;
            my $num-lines = $buff.read-uint32($buff, $offset, $endian);
            for ^$num-lines {
                @lines.push: wkb-get-linestringz($buff, $offset, $endian);
            }
            $geometry = MultiLineStringZ.new(linestrings => @lines);
        }
        when wkbMultiLineStringM {
            my @lines;
            my $num-lines = $buff.read-uint32($buff, $offset, $endian);
            for ^$num-lines {
                @lines.push: wkb-get-linestringm($buff, $offset, $endian);
            }
            $geometry = MultiLineStringM.new(linestrings => @lines);
        }
        when wkbMultiLineStringZM {
            my @lines;
            my $num-lines = $buff.read-uint32($buff, $offset, $endian);
            for ^$num-lines {
                @lines.push: wkb-get-linestringzm($buff, $offset, $endian);
            }
            $geometry = MultiLineStringZM.new(linestrings => @lines);
        }
        when wkbMultiPolygon {
            my @polygons;
            my $num-polygons = $buff.read-uint32($buff, $offset, $endian);
            for ^$num-polygons {
                @polygons.push: wkb-get-polygon($buff, $offset, $endian);
            }
            $geometry = MultiPolygon.new(polygons => @polygons);
        }
        when wkbMultiPolygonZ {
            my @polygons;
            my $num-polygons = $buff.read-uint32($buff, $offset, $endian);
            for ^$num-polygons {
                @polygons.push: wkb-get-polygonz($buff, $offset, $endian);
            }
            $geometry = MultiPolygonZ.new(polygons => @polygons);
        }
        when wkbMultiPolygonM {
            my @polygons;
            my $num-polygons = $buff.read-uint32($buff, $offset, $endian);
            for ^$num-polygons {
                @polygons.push: wkb-get-polygonm($buff, $offset, $endian);
            }
            $geometry = MultiPolygonM.new(polygons => @polygons);
        }
        when wkbMultiPolygonZM {
            my @polygons;
            my $num-polygons = $buff.read-uint32($buff, $offset, $endian);
            for ^$num-polygons {
                @polygons.push: wkb-get-polygonzm($buff, $offset, $endian);
            }
            $geometry = MultiPolygonZM.new(polygons => @polygons);
        }
        when wkbGeometryCollection {
            my @geometries;
            my $num-geometries = $buff.read-uint32($buff, $offset, $endian);
            for ^$num-geometries {
                @geometries.push: wkb-read-geometry($buff, $offset, $endian);
            }
            $geometry = GeometryCollection.new(geometries => @geometries);
        }
        when wkbGeometryCollectionZ {
            my @geometries;
            my $num-geometries = $buff.read-uint32($buff, $offset, $endian);
            for ^$num-geometries {
                @geometries.push: wkb-read-geometry($buff, $offset, $endian);
            }
            $geometry = GeometryCollectionZ.new(geometries => @geometries);
        }
        when wkbGeometryCollectionM {
            my @geometries;
            my $num-geometries = $buff.read-uint32($buff, $offset, $endian);
            for ^$num-geometries {
                @geometries.push: wkb-read-geometry($buff, $offset, $endian);
            }
            $geometry = GeometryCollectionM.new(geometries => @geometries);
        }
        when wkbGeometryCollectionZM {
            my @geometries;
            my $num-geometries = $buff.read-uint32($buff, $offset, $endian);
            for ^$num-geometries {
                @geometries.push: wkb-read-geometry($buff, $offset, $endian);
            }
            $geometry = GeometryCollectionZM.new(geometries => @geometries);
        }
        default { fail "Can't handle geometry type $geometry-type in from-wkb"; }
    }
    $geometry;
}

our sub from-wkb(Buf $buff) is export {
    my $length = $buff.elems;
    my $byteorder = $buff[0] ?? wkbNDR !! wkbXDR;
    my $endian = $byteorder == wkbNDR ?? BigEndian !! LittleEndian;
    my $offset = 1;
    my $geometry = wkb-read-geometry($buff, $offset, $endian);
    fail "from-wkb: buffer too short" if $offset > $length;
    $geometry;
}

