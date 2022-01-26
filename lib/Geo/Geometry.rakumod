# use Grammar::Debugger;

enum WKBByteOrder (
    wkbXDR => 0,
    wkbNDR => 1,
);

enum WKBGeometryType (
    wkbPoint              => 1,
    wkbLineString         => 2,
    wkbPolygon            => 3,
    wkbMultiPoint         => 4,
    wkbMultiLineString    => 5,
    wkbMultiPolygon       => 6,
    wkbGeometryCollection => 7,
    wkbPolyhedralSurface  => 15,
    wkbTIN                => 16,
    wkbTriangle           => 17,

    wkbPointZ              => 1001,
    wkbLineStringZ         => 1002,
    wkbPolygonZ            => 1003,
    wkbMultiPointZ         => 1004,
    wkbMultiLineStringZ    => 1005,
    wkbMultiPolygonZ       => 1006,
    wkbGeometryCollectionZ => 1007,
    wkbPolyhedralSurfaceZ  => 1015,
    wkbTINZ                => 1016,
    wkbTriangleZ           => 1017,

    wkbPointM              => 2001,
    wkbLineStringM         => 2002,
    wkbPolygonM            => 2003,
    wkbMultiPointM         => 2004,
    wkbMultiLineStringM    => 2005,
    wkbMultiPolygonM       => 2006,
    wkbGeometryCollectionM => 2007,
    wkbPolyhedralSurfaceM  => 2015,
    wkbTINM                => 2016,
    wkbTriangleM           => 2017,

    wkbPointZM              => 3001,
    wkbLineStringZM         => 3002,
    wkbPolygonZM            => 3003,
    wkbMultiPointZM         => 3004,
    wkbMultiLineStringZM    => 3005,
    wkbMultiPolygonZM       => 3006,
    wkbGeometryCollectionZM => 3007,
    wkbPolyhedralSurfaceZM  => 3015,
    wkbTINZM                => 3016,
    wkbTriangleZM           => 3017,
);

class Geometry {
}

class Point is Geometry {
    has num $.x is required;
    has num $.y is required;

    method type { wkbPoint };
    multi method new($x, $y) { self.bless(x => $x.Num, y => $y.Num) }
    method Str() { "{$!x} {$!y}" }
    method wkt() { "POINT({self.Str})"; }
    method tobuf($endian) {
        my $b = Buf.allocate(16);
        $b.write-num64(0, $!x, $endian);
        $b.write-num64(8, $!y, $endian);
    }
    method wkb(:$byteorder = wkbXDR) {
        my $b = Buf.new($byteorder);
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        $b.write-uint32(1, wkbPoint, $endian);
        $b ~ self.tobuf($endian);
    }
}

class PointZ is Geometry {
    has num $.x is required;
    has num $.y is required;
    has num $.z is required;

    method type { wkbPointZ }
    multi method new($x, $y, $z) { self.bless(x => $x.Num, y => $y.Num, z => $z.Num) }
    method Str() { "{$!x} {$!y} {$!z}" }
    method wkt() { "POINTZ({self.Str})"; }
    method tobuf($endian) {
        my $b = Buf.allocate(24);
        $b.write-num64(0,  $!x, $endian);
        $b.write-num64(8,  $!y, $endian);
        $b.write-num64(16, $!z, $endian);
    }
    method wkb(:$byteorder = wkbXDR) {
        my $b = Buf.new($byteorder);
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        $b.write-uint32(1, wkbPointZ, $endian);
        $b ~ self.tobuf($endian);
    }
}

class PointM is Geometry {
    has num $.x is required;
    has num $.y is required;
    has num $.m is required;
    
    method type { wkbPointM }
    multi method new($x, $y, $m) { self.bless(x => $x.Num, y => $y.Num, m => $m.Num) }
    method Str() { "{$!x} {$!y} {$!m}" }
    method wkt() { "POINTM({self.Str})"; }
    method tobuf($endian) {
        my $b = Buf.allocate(24);
        $b.write-num64(0,  $!x, $endian);
        $b.write-num64(8,  $!y, $endian);
        $b.write-num64(16, $!m, $endian);
    }
    method wkb(:$byteorder = wkbXDR) {
        my $b = Buf.new($byteorder);
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        $b.write-uint32(1, wkbPointM, $endian);
        $b ~ self.tobuf($endian);
    }
}

class PointZM is Geometry {
    has num $.x is required;
    has num $.y is required;
    has num $.z is required;
    has num $.m is required;
    
    method type { wkbPointZM }
    multi method new($x, $y, $z, $m) { self.bless(x => $x.Num, y => $y.Num, z => $z.Num, m => $m.Num) }
    method Str() { "{$!x} {$!y} {$!z} {$!m}" }
    method wkt() { "POINTZM({self.Str})"; }
    method tobuf($endian) {
        my $b = Buf.allocate(32);
        $b.write-num64(0,  $!x, $endian);
        $b.write-num64(8,  $!y, $endian);
        $b.write-num64(16, $!z, $endian);
        $b.write-num64(24, $!m, $endian);
    }
    method wkb(:$byteorder = wkbXDR) {
        my $b = Buf.new($byteorder);
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        $b.write-uint32(1, wkbPointZM, $endian);
        $b ~ self.tobuf($endian);
    }
}

class LineString is Geometry {
    has $!type = wkbLineString;
    has $!num-points;
    has Point @!points is required is built;

    method type { $!type; }
    method TWEAK { $!num-points = +@!points; }
    method Str() { @!points.map({.Str}).join(',') };
    method wkt() { "LINESTRING({self.Str})"; }
    method tobuf($endian) {
        my $b = Buf.allocate(4 + 16 × $!num-points);
        $b.write-uint32(0, $!num-points, $endian);
        my $offset = 4;
        for @!points -> $point {
            $b.write-num64($offset, $point.x, $endian); $offset += 8;
            $b.write-num64($offset, $point.y, $endian); $offset += 8;
        }
        $b
    }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-uint32(1, wkbLineString, $endian);
        $b ~ self.tobuf($endian);
    }
}

class LineStringZ is Geometry {
    has $!type = wkbLineStringZ;
    has $!num-points;
    has PointZ @!points is required is built;

    method type { $!type; }
    method TWEAK { $!num-points = +@!points; }
    method Str() { @!points.map({.Str}).join(',') };
    method wkt() { "LINESTRINGZ({self.Str})"; }
    method tobuf($endian) {
        my $b = Buf.allocate(4 + 24 × $!num-points);
        $b.write-uint32(0, $!num-points, $endian);
        my $offset = 4;
        for @!points -> $point {
            $b.write-num64($offset, $point.x, $endian); $offset += 8;
            $b.write-num64($offset, $point.y, $endian); $offset += 8;
            $b.write-num64($offset, $point.z, $endian); $offset += 8;
        }
        $b
    }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-uint32(1, wkbLineStringZ, $endian);
        $b ~ self.tobuf($endian);
    }
}

class LineStringM is Geometry {
    has $!type = wkbLineStringM;
    has $!num-points;
    has PointM @!points is required is built;

    method type { $!type; }
    method TWEAK { $!num-points = +@!points; }
    method Str() { @!points.map({.Str}).join(',') };
    method wkt() { "LINESTRINGM({self.Str})"; }
    method tobuf($endian) {
        my $b = Buf.allocate(4 + 24 × $!num-points);
        $b.write-uint32(0, $!num-points, $endian);
        my $offset = 4;
        for @!points -> $point {
            $b.write-num64($offset, $point.x, $endian); $offset += 8;
            $b.write-num64($offset, $point.y, $endian); $offset += 8;
            $b.write-num64($offset, $point.m, $endian); $offset += 8;
        }
        $b
    }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-uint32(1, wkbLineStringM, $endian);
        $b ~ self.tobuf($endian);
    }
}

class LineStringZM is Geometry {
    has $!type = wkbLineStringZM;
    has $!num-points;
    has PointZM @!points is required is built;

    method type { $!type; }
    method TWEAK { $!num-points = +@!points; }
    method Str() { @!points.map({.Str}).join(',') };
    method wkt() { "LINESTRINGZM({self.Str})"; }
    method tobuf($endian) {
        my $b = Buf.allocate(4 + 32 × $!num-points);
        $b.write-uint32(0, $!num-points, $endian);
        my $offset = 4;
        for @!points -> $point {
            $b.write-num64($offset, $point.x, $endian); $offset += 8;
            $b.write-num64($offset, $point.y, $endian); $offset += 8;
            $b.write-num64($offset, $point.z, $endian); $offset += 8;
            $b.write-num64($offset, $point.m, $endian); $offset += 8;
        }
        $b
    }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-uint32(1, wkbLineStringZM, $endian);
        $b ~ self.tobuf($endian);
    }
}

    # Calculate the winding of a linear ring
    #
    # Assumes the ring is well-formed
    # Works for Point, PointZ, PointM and PointZM by ignoring everything but
    #     the x and y coordinates
    #
    # There are certainly much more efficient ways to calculate this...
    
    sub winding(@points) {
        my $area; # Actually double the area, but who cares?
        for 0 .. +@points - 2 -> $i {
            $area += (@points[$i].y + @points[$i+1].y) * (@points[$i+1].x - @points[$i].x);
        }
        $area ≥ 0 ?? 1 !! -1;
    }
    
class LinearRing is Geometry {
    has $!num-points;
    has Point @!points is required is built;

# TWEAK should check that the linear ring is simple and closed
    method TWEAK { $!num-points = +@!points ; }
    method Str() { @!points.map({.Str}).join(',') };
    method winding() {
        winding(@!points);
    }
    method tobuf($endian) {
        my $b = Buf.allocate(4 + 16 × $!num-points);
        $b.write-int32(0, $!num-points, $endian);
        my $offset = 4;
        for @!points -> $point {
            $b.write-num64($offset, $point.x.Num, $endian); $offset += 8;
            $b.write-num64($offset, $point.y.Num, $endian); $offset += 8;
        }
        $b;
    }
}

class LinearRingZ is Geometry {
    has $!num-points;
    has PointZ @!points is required is built;

    method TWEAK { $!num-points = +@!points ; }
    method Str() { @!points.map({.Str}).join(',') };
    method winding() {
        winding(@!points);
    }
    method tobuf($endian) {
        my $b = Buf.new(0);
        $b.reallocate(4 + 24 × $!num-points);
        $b.write-int32(0, $!num-points, $endian);
        my $offset = 4;
        for @!points -> $point {
            $b.write-num64($offset, $point.x.Num, $endian); $offset += 8;
            $b.write-num64($offset, $point.y.Num, $endian); $offset += 8;
            $b.write-num64($offset, $point.z.Num, $endian); $offset += 8;
        }
        $b;
    }
}

class LinearRingM is Geometry {
    has $!num-points;
    has PointM @!points is required is built;

    method TWEAK { $!num-points = +@!points ; }
    method Str() { @!points.map({.Str}).join(',') };
    method winding() {
        winding(@!points);
    }
    method tobuf($endian) {
        my $b = Buf.allocate(4 + 24 × $!num-points);
        $b.write-int32(0, $!num-points, $endian);
        my $offset = 4;
        for @!points -> $point {
            $b.write-num64($offset, $point.x.Num, $endian); $offset += 8;
            $b.write-num64($offset, $point.y.Num, $endian); $offset += 8;
            $b.write-num64($offset, $point.m.Num, $endian); $offset += 8;
        }
        $b;
    }
}

class LinearRingZM is Geometry {
    has $!num-points;
    has PointZM @!points is required is built;

    method TWEAK { $!num-points = +@!points ; }
    method Str() { @!points.map({.Str}).join(',') };
    method winding() {
        winding(@!points);
    }
    method tobuf($endian) {
        my $b = Buf.allocate(4 + 32 × $!num-points);
        $b.write-int32(0, $!num-points, $endian);
        my $offset = 4;
        for @!points -> $point {
            $b.write-num64($offset, $point.x.Num, $endian); $offset += 8;
            $b.write-num64($offset, $point.y.Num, $endian); $offset += 8;
            $b.write-num64($offset, $point.z.Num, $endian); $offset += 8;
            $b.write-num64($offset, $point.m.Num, $endian); $offset += 8;
        }
        $b;
    }
}

class Polygon is Geometry {
    has $!type = wkbPolygon;
    has $!num-rings;
    has LinearRing @!rings is required is built;

    method type { $!type; }
    method TWEAK { $!num-rings = +@!rings; }
    method Str() { '(' ~ @!rings.map({.Str}).join('),(') ~ ')' };
    method wkt() { "POLYGON({self.Str})"; }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-uint32(1, wkbPolygon,  $endian);
        $b.write-uint32(5, $!num-rings, $endian);
        $b ~ [~] @!rings.map({.tobuf($endian)})
    }
}

class PolygonZ is Geometry {
    has $!type = wkbPolygonZ;
    has $!num-rings;
    has LinearRingZ @!rings is required is built;

    method type { $!type; }
    method TWEAK { $!num-rings = +@!rings; }
    method Str() { '(' ~ @!rings.map({.Str}).join('),(') ~ ')' };
    method wkt() { "POLYGONZ({self.Str})"; }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-uint32(1, wkbPolygonZ, $endian);
        $b.write-uint32(5, $!num-rings, $endian);
        $b ~ [~] @!rings.map({.tobuf($endian)})
    }
}

class PolygonM is Geometry {
    has $!type = wkbPolygonM;
    has $!num-rings;
    has LinearRingM @!rings is required is built;

    method type { $!type; }
    method TWEAK { $!num-rings = +@!rings; }
    method Str() { '(' ~ @!rings.map({.Str}).join('),(') ~ ')' };
    method wkt() { "POLYGONM({self.Str})"; }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-uint32(1, wkbPolygonM, $endian);
        $b.write-uint32(5, $!num-rings, $endian);
        $b ~ [~] @!rings.map({.tobuf($endian)})
    }
}

class PolygonZM is Geometry {
    has $!type = wkbPolygonZM;
    has $!num-rings;
    has LinearRingZM @!rings is required is built;

    method type { $!type; }
    method TWEAK { $!num-rings = +@!rings; }
    method Str() { '(' ~ @!rings.map({.Str}).join('),(') ~ ')' };
    method wkt() { "POLYGONZM({self.Str})"; }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-uint32(1, wkbPolygonZM, $endian);
        $b.write-uint32(5, $!num-rings,  $endian);
        $b ~ [~] @!rings.map({.tobuf($endian)})
    }
}

class Triangle is Geometry {
    has $!type = wkbTriangle;
    has $!num-rings;
    has LinearRing @!rings is required is built;

    method type { $!type; }
    method TWEAK { $!num-rings = +@!rings; }
    method Str() { '(' ~ @!rings.map({.Str}).join('),(') ~ ')' };
    method wkt() { "TRIANGLE({self.Str})"; }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-uint32(1, wkbTriangle, $endian);
        $b.write-uint32(5, $!num-rings, $endian);
        $b ~ [~] @!rings.map({.tobuf($endian)})
    }
}

class TriangleZ is Geometry {
    has $!type = wkbTriangleZ;
    has $!num-rings;
    has LinearRingZ @!rings is required is built;

    method type { $!type; }
    method TWEAK { $!num-rings = +@!rings; }
    method Str() { '(' ~ @!rings.map({.Str}).join('),(') ~ ')' };
    method wkt() { "TRIANGLEZ({self.Str})"; }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-uint32(1, wkbTriangleZ, $endian);
        $b.write-uint32(5, $!num-rings,  $endian);
        $b ~ [~] @!rings.map({.tobuf($endian)})
    }
}

class TriangleM is Geometry {
    has $!type = wkbTriangleM;
    has $!num-rings;
    has LinearRingM @!rings is required is built;

    method type { $!type; }
    method TWEAK { $!num-rings = +@!rings; }
    method Str() { '(' ~ @!rings.map({.Str}).join('),(') ~ ')' };
    method wkt() { "TRIANGLEM({self.Str})"; }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-uint32(1, wkbTriangleM, $endian);
        $b.write-uint32(5, $!num-rings,  $endian);
        $b ~ [~] @!rings.map({.tobuf($endian)})
    }
}

class TriangleZM is Geometry {
    has $!type = wkbTriangleZM;
    has $!num-rings;
    has LinearRingZM @!rings is required is built;

    method type { $!type; }
    method TWEAK { $!num-rings = +@!rings; }
    method Str() { '(' ~ @!rings.map({.Str}).join('),(') ~ ')' };
    method wkt() { "TRIANGLEZM({self.Str})"; }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-uint32(1, wkbTriangleZM, $endian);
        $b.write-uint32(5, $!num-rings,  $endian);
        $b ~ [~] @!rings.map({.tobuf($endian)})
    }
}

class PolyhedralSurface is Geometry {
    has $!type = wkbPolyhedralSurface;
    has $!num-polygons;
    has Polygon @!polygons is required is built;

    method type { $!type; }
    method TWEAK { $!num-polygons = +@!polygons; }
    method Str() { '(' ~ @!polygons.map({.Str}).join('),(') ~ ')' };
    method wkt() { "POLYHEDRALSURFACE({self.Str})"; }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-uint32(1, wkbPolyhedralSurface, $endian);
        $b.write-uint32(5, $!num-polygons,       $endian);
        $b ~ [~] @!polygons.map({.tobuf($endian)})
    }
}


class PolyhedralSurfaceZ is Geometry {
    has $!type = wkbPolyhedralSurfaceZ;
    has $!num-polygons;
    has PolygonZ @!polygons is required is built;

    method type { $!type; }
    method TWEAK { $!num-polygons = +@!polygons; }
    method Str() { '(' ~ @!polygons.map({.Str}).join('),(') ~ ')' };
    method wkt() { "POLYHEDRALSURFACEZ({self.Str})"; }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-uint32(1, wkbPolyhedralSurfaceZ, $endian);
        $b.write-uint32(5, $!num-polygons,        $endian);
        $b ~ [~] @!polygons.map({.tobuf($endian)})
    }
}


class PolyhedralSurfaceM is Geometry {
    has $!type = wkbPolyhedralSurfaceM;
    has $!num-polygons;
    has PolygonM @!polygons is required is built;

    method type { $!type; }
    method TWEAK { $!num-polygons = +@!polygons; }
    method Str() { '(' ~ @!polygons.map({.Str}).join('),(') ~ ')' };
    method wkt() { "POLYHEDRALSURFACEM({self.Str})"; }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-uint32(1, wkbPolyhedralSurfaceM, $endian);
        $b.write-uint32(5, $!num-polygons,        $endian);
        $b ~ [~] @!polygons.map({.tobuf($endian)})
    }
}


class PolyhedralSurfaceZM is Geometry {
    has $!type = wkbPolyhedralSurfaceZM;
    has $!num-polygons;
    has PolygonZM @!polygons is required is built;

    method type { $!type; }
    method TWEAK { $!num-polygons = +@!polygons; }
    method Str() { '(' ~ @!polygons.map({.Str}).join('),(') ~ ')' };
    method wkt() { "POLYHEDRALSURFACEZM({self.Str})"; }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-uint32(1, wkbPolyhedralSurfaceZM, $endian);
        $b.write-uint32(5, $!num-polygons,         $endian);
        $b ~ [~] @!polygons.map({.tobuf($endian)})
    }
}

class TIN is Geometry {
    has $!type = wkbTIN;
    has $!num-polygons;
    has Polygon @!polygons is required is built;

    method type { $!type; }
    method TWEAK { $!num-polygons = +@!polygons; }
    method Str() { '(' ~ @!polygons.map({.Str}).join('),(') ~ ')' };
    method wkt() { "TIN({self.Str})"; }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-uint32(1, wkbTIN,         $endian);
        $b.write-uint32(5, $!num-polygons, $endian);
        $b ~ [~] @!polygons.map({.tobuf($endian)})
    }
}


class TINZ is Geometry {
    has $!type = wkbTINZ;
    has $!num-polygons;
    has PolygonZ @!polygons is required is built;

    method type { $!type; }
    method TWEAK { $!num-polygons = +@!polygons; }
    method Str() { '(' ~ @!polygons.map({.Str}).join('),(') ~ ')' };
    method wkt() { "TINZ({self.Str})"; }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-uint32(1, wkbTINZ,        $endian);
        $b.write-uint32(5, $!num-polygons, $endian);
        $b ~ [~] @!polygons.map({.tobuf($endian)})
    }
}


class TINM is Geometry {
    has $!type = wkbTINM;
    has $!num-polygons;
    has PolygonM @!polygons is required is built;

    method type { $!type; }
    method TWEAK { $!num-polygons = +@!polygons; }
    method Str() { '(' ~ @!polygons.map({.Str}).join('),(') ~ ')' };
    method wkt() { "TINM({self.Str})"; }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-uint32(1, wkbTINM,        $endian);
        $b.write-uint32(5, $!num-polygons, $endian);
        $b ~ [~] @!polygons.map({.tobuf($endian)})
    }
}


class TINZM is Geometry {
    has $!type = wkbTINZM;
    has $!num-polygons;
    has PolygonZM @!polygons is required is built;

    method type { $!type; }
    method TWEAK { $!num-polygons = +@!polygons; }
    method Str() { '(' ~ @!polygons.map({.Str}).join('),(') ~ ')' };
    method wkt() { "TINZM({self.Str})"; }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-uint32(1, wkbTINZM,       $endian);
        $b.write-uint32(5, $!num-polygons, $endian);
        $b ~ [~] @!polygons.map({.tobuf($endian)})
    }
}

class MultiPoint is Geometry {
    has $!type = wkbMultiPoint;
    has $!num-points;
    has Point @!points is required is built;

    method type { $!type; }
    method TWEAK { $!num-points = +@!points; }
    method Str() { '(' ~ @!points.map({.Str}).join('),(') ~ ')' };
    method wkt() { "MULTIPOINT({self.Str})"; }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.reallocate(9 + 16 × $!num-points);
        $b.write-uint32(1, wkbMultiPoint, $endian);
        $b.write-uint32(5, $!num-points,  $endian);
        my $offset = 9;
        for @!points -> $point {
            $b.write-num64($offset, $point.x, $endian); $offset += 8;
            $b.write-num64($offset, $point.y, $endian); $offset += 8;
        }
        $b
    }
}


    
class MultiPointZ is Geometry {
    has $!type = wkbMultiPointZ;
    has $!num-points;
    has PointZ @!points is required is built;

    method type { $!type; }
    method TWEAK { $!num-points = +@!points; }
    method Str() { @!points.map({.Str}).join(',') };
    method wkt() { "MULTIPOINTZ({self.Str})"; }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.reallocate(9 + 16 × $!num-points);
        $b.write-uint32(1, wkbMultiPointZ, $endian);
        $b.write-uint32(5, $!num-points,   $endian);
        my $offset = 9;
        for @!points -> $point {
            $b.write-num64($offset, $point.x, $endian); $offset += 8;
            $b.write-num64($offset, $point.y, $endian); $offset += 8;
        }
        $b
    }
}
    
class MultiPointM is Geometry {
    has $!type = wkbMultiPointM;
    has $!num-points;
    has PointM @!points is required is built;

    method type { $!type; }
    method TWEAK { $!num-points = +@!points; }
    method Str() { @!points.map({.Str}).join(',') };
    method wkt() { "MULTIPOINTM({self.Str})"; }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.reallocate(9 + 16 × $!num-points);
        $b.write-uint32(1, wkbMultiPointM, $endian);
        $b.write-uint32(5, $!num-points,   $endian);
        my $offset = 9;
        for @!points -> $point {
            $b.write-num64($offset, $point.x, $endian); $offset += 8;
            $b.write-num64($offset, $point.y, $endian); $offset += 8;
        }
        $b
    }
}
    
class MultiPointZM is Geometry {
    has $!type = wkbMultiPointZM;
    has $!num-points;
    has PointZM @!points is required is built;

    method type { $!type; }
    method TWEAK { $!num-points = +@!points; }
    method Str() { @!points.map({.Str}).join(',') };
    method wkt() { "MULTIPOINTZM({self.Str})"; }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.reallocate(9 + 16 × $!num-points);
        $b.write-uint32(1, wkbMultiPointZM, $endian);
        $b.write-uint32(5, $!num-points,    $endian);
        my $offset = 9;
        for @!points -> $point {
            $b.write-num64($offset, $point.x, $endian); $offset += 8;
            $b.write-num64($offset, $point.y, $endian); $offset += 8;
        }
        $b;
    }
}

class MultiLineString is Geometry {
    has $!type = wkbMultiLineString;
    has $!num-linestrings;
    has LineString @!linestrings is required is built;

    method type { $!type; }
    method TWEAK { $!num-linestrings = +@!linestrings; }
    method Str { '(' ~ @!linestrings.map({.Str}).join('),(') ~ ')'; }
    method wkt { 'MultiLineString(' ~ self.Str ~ ')'; }
    method tobuf($endian) {
        my $b = Buf.new(0);
        $b.write-uint32(0, $!num-linestrings, $endian);
        $b ~ [~] @!linestrings.map({.tobuf($endian)});
    }
    method wkb($byteorder) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-int32(1, wkbMultiLineString, $endian);
        $b.write-int32(5, $!num-linestrings,  $endian);
        $b ~ self.tobuf($endian);
    }
}

class MultiLineStringZ is Geometry {
    has $!type = wkbMultiLineStringZ;
    has $!num-linestrings;
    has LineStringZ @!linestrings is required is built;

    method type { $!type; }
    method TWEAK { $!num-linestrings = +@!linestrings; }
    method tobuf($endian) {
        my $b = Buf.new(0);
        $b.write-uint32(0, $!num-linestrings, $endian);
        $b ~ [~] @!linestrings.map({.tobuf($endian)});
    }
    method wkb($byteorder) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-int32(1, wkbMultiLineStringZ, $endian);
        $b.write-int32(5, $!num-linestrings,   $endian);
        $b ~ self.tobuf($endian);
    }
}

class MultiLineStringM is Geometry {
    has $!type = wkbMultiLineStringM;
    has $!num-linestrings;
    has LineStringM @!linestrings is required is built;

    method type { $!type; }
    method TWEAK { $!num-linestrings = +@!linestrings; }
    method tobuf($endian) {
        my $b = Buf.new(0);
        $b.write-uint32(0, $!num-linestrings, $endian);
        $b ~ [~] @!linestrings.map({.tobuf($endian)});
    }
    method wkb($byteorder) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-int32(1, wkbMultiLineStringM, $endian);
        $b.write-int32(5, $!num-linestrings,   $endian);
        $b ~ self.tobuf($endian);
    }
}

class MultiLineStringZM is Geometry {
    has $!type = wkbMultiLineStringZM;
    has $!num-linestrings;
    has LineStringZM @!linestrings is required is built;

    method type { $!type; }
    method TWEAK { $!num-linestrings = +@!linestrings; }
    method tobuf($endian) {
        my $b = Buf.new(0);
        $b.write-uint32(0, $!num-linestrings, $endian);
        $b ~ [~] @!linestrings.map({.tobuf($endian)});
    }
    method wkb($byteorder) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-int32(1, wkbMultiLineStringZM, $endian);
        $b.write-int32(5, $!num-linestrings, $endian);
        $b ~ self.tobuf($endian);
    }
}

class MultiPolygon is Geometry {
    has $!type = wkbMultiPolygon;
    has $!num-polygons;
    has Polygon @!polygons is required is built;

    method type { $!type; }
    method TWEAK { $!num-polygons = +@!polygons; }
    method Str   { '(' ~ @!polygons.map({.Str}).join('),(') ~ ')'; }
    method wkt   { 'MultiPolygon(' ~ self.Str ~ ')'; }
    method tobuf($endian) {
        my $b = Buf.new(0);
        $b.write-uint32(0, $!num-polygons, $endian);
        $b ~ [~] @!polygons.map({.tobuf($endian)});
    }
    method wkb($byteorder) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-int32(1, wkbPolygon,     $endian);
        $b.write-int32(5, $!num-polygons, $endian);
        $b ~ self.tobuf($endian);
    }
}

class MultiPolygonZ is Geometry {
    has $!type = wkbMultiPolygonZ;
    has $!num-polygons;
    has PolygonZ @!polygons is required is built;

    method type { $!type; }
    method TWEAK { $!num-polygons = +@!polygons; }
    method tobuf($endian) {
        my $b = Buf.new(0);
        $b.write-uint32(0, $!num-polygons, $endian);
        $b ~ [~] @!polygons.map({.tobuf($endian)});
    }
    method wkb($byteorder) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-int32(1, wkbPolygonZ, $endian);
        $b.write-int32(5, $!num-polygons, $endian);
        $b ~ self.tobuf($endian);
    }
}

class MultiPolygonM is Geometry {
    has $!type = wkbMultiPolygonM;
    has $!num-polygons;
    has PolygonM @!polygons is required is built;

    method type { $!type; }
    method TWEAK { $!num-polygons = +@!polygons; }
    method tobuf($endian) {
        my $b = Buf.new(0);
        $b.write-uint32(0, $!num-polygons, $endian);
        $b ~ [~] @!polygons.map({.tobuf($endian)});
    }
    method wkb($byteorder) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-int32(1, wkbPolygonM, $endian);
        $b.write-int32(5, $!num-polygons, $endian);
        $b ~ self.tobuf($endian);
    }
}

class MultiPolygonZM is Geometry {
    has $!type = wkbMultiPolygonZM;
    has $!num-polygons;
    has PolygonZM @!polygons is required is built;

    method type { $!type; }
    method TWEAK { $!num-polygons = +@!polygons; }
    method tobuf($endian) {
        my $b = Buf.new(0);
        $b.write-uint32(0, $!num-polygons, $endian);
        $b ~ [~] @!polygons.map({.tobuf($endian)});
    }
    method wkb($byteorder) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-int32(1, wkbPolygonZM, $endian);
        $b.write-int32(5, $!num-polygons, $endian);
        $b ~ self.tobuf($endian);
    }
}

class GeometryCollection is Geometry {
    has $!num-geometries;
    has Geometry @!geometries is required is built;

    method TWEAK { $!num-geometries = +@!geometries; }
    method Str { @!geometries.map({.wkt}).join(','); }
    method wkt { 'GeeometryCollection(' ~ self.Str ~ ')'; }
    method tobuf($endian) {
        my $b = Buf.new(0);
        $b.write-uint32(0, $!num-geometries, $endian);
        $b ~ [~] @!geometries.map({.tobuf($endian)});
    }
    method wkb($byteorder) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-int32(1, wkbGeometryCollection, $endian);
        $b ~ self.tobuf($endian);
    }
}

class GeometryCollectionZ is Geometry {
    has $!num-geometries;
    has Geometry @!geometries is required is built;

    method TWEAK { $!num-geometries = +@!geometries; }
    method Str { @!geometries.map({.wkt}).join(','); }
    method wkt { 'GeeometryCollectionZ(' ~ self.Str ~ ')'; }
    method tobuf($endian) {
        my $b = Buf.new(0);
        $b.write-uint32(0, $!num-geometries, $endian);
        $b ~ [~] @!geometries.map({.tobuf($endian)});
    }
    method wkb($byteorder) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-int32(1, wkbGeometryCollectionZ, $endian);
        $b ~ self.tobuf($endian);
    }
}

class GeometryCollectionM is Geometry {
    has $!num-geometries;
    has Geometry @!geometries is required is built;

    method TWEAK { $!num-geometries = +@!geometries; }
    method Str { @!geometries.map({.wkt}).join(','); }
    method wkt { 'GeeometryCollectionM(' ~ self.Str ~ ')'; }
    method tobuf($endian) {
        my $b = Buf.new(0);
        $b.write-uint32(0, $!num-geometries, $endian);
        $b ~ [~] @!geometries.map({.tobuf($endian)});
    }
    method wkb($byteorder) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-int32(1, wkbGeometryCollectionM, $endian);
        $b ~ self.tobuf($endian);
    }
}

class GeometryCollectionZM is Geometry {
    has $!num-geometries;
    has Geometry @!geometries is required is built;

    method TWEAK { $!num-geometries = +@!geometries; }
    method Str { @!geometries.map({.wkt}).join(','); }
    method wkt { 'GeeometryCollectionZM(' ~ self.Str ~ ')'; }
    method tobuf($endian) {
        my $b = Buf.new(0);
        $b.write-uint32(0, $!num-geometries, $endian);
        $b ~ [~] @!geometries.map({.tobuf($endian)});
    }
    method wkb($byteorder) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-int32(1, wkbGeometryCollectionZM, $endian);
        $b ~ self.tobuf($endian);
    }
}

grammar WKT {
    regex TOP {
        | <geometry-tagged-text>   { make $<geometry-tagged-text>.made;   }
        | <geometryz-tagged-text>  { make $<geometryz-tagged-text>.made;  }
        | <geometrym-tagged-text>  { make $<geometrym-tagged-text>.made;  }
        | <geometryzm-tagged-text> { make $<geometryzm-tagged-text>.made; }
    }
    regex value                          { <signed-numeric-literal> { make $<signed-numeric-literal>.made; } }
    token quoted-name                    { '"' <name> '"' }
    token name                           { <letter>* }
    token letter                         { <[a..z A..Z]> | \d | <[\(\)\-\_\.\'\ ]> }
    token sign                           {       { make  1; }
                                           | '+' { make  1; }
                                           | '-' { make -1; }
                                         }
    regex signed-numeric-literal         { <sign> <unsigned-numeric-literal> { make $<sign>.made * $<unsigned-numeric-literal>.made; } }
    regex unsigned-numeric-literal       {
                                           | <exact-numeric-literal>       { make $<exact-numeric-literal>.made;       }
                                           | <approximate-numeric-literal> { make $<approximate-numeric-literal>.made; }
                                         }
    regex approximate-numeric-literal    { :i <exact-numeric-literal> 'e' <sign> <unsigned-integer>
                                              { make $<exact-numeric-literal>.made * 10e0 ** ($<sign> * $<unsigned-integer>.made); }
                                         }
    regex exact-numeric-literal          {
                                           | <unsigned-integer> [ <decimal-point> <unsigned-integer>? ]?
                                             {
                                                 if $<unsigned-integer>[1].defined {
                                                     make $<unsigned-integer>[0] +
                                                     $<unsigned-integer>[1] / 10 ** ($<unsigned-integer>[1].pos - $<unsigned-integer>[1].from);
                                                 } else {
                                                     make $<unsigned-integer>[0];
                                                 }
                                             }
                                           | <decimal-point> <unsigned-integer> { make 1e0/10**($<unsigned-integer>.pos - $<unsigned-integer>.from); }
                                         }
    token signed-integer                 { <sign> <unsigned-integer> { make $<sign>.made * $<unsigned-integer>.made; } }
    token unsigned-integer               { (\d+) { make +$0; } }
#    token decimal-point                  { '.' | ',' }
    token decimal-point                  { '.' }
    token empty-set                      { "EMPTY" }

    rule point { <value> <value> { make Point.new($<value>[0], $<value>[1]); } }
    rule geometry-tagged-text {
                                  | <point-tagged-text>              { make $<point-tagged-text>.made;              }
                                  | <linestring-tagged-text>         { make $<linestring-tagged-text>.made;         }
                                  | <polygon-tagged-text>            { make $<polygon-tagged-text>.made;            }
                                  | <triangle-tagged-text>           { make $<triangle-tagged-text>.made;           }
                                  | <polyhedralsurface-tagged-text>  { make $<polyhedralsurface-tagged-text>.made;  }
                                  | <tin-tagged-text>                { make $<tin-tagged-text>.made;                }
                                  | <multipoint-tagged-text>         { make $<multipoint-tagged-text>.made;         }
                                  | <multilinestring-tagged-text>    { make $<multilinestring-tagged-text>.made;    }
                                  | <multipolygon-tagged-text>       { make $<multipolygon-tagged-text>.made;       }
                                  | <geometrycollection-tagged-text> { make $<geometrycollection-tagged-text>.made; }
    }
    rule point-tagged-text              { :i "point"              <point-text>              { make $<point-text>.made;              } }
    rule linestring-tagged-text         { :i "linestring"         <linestring-text>         { make $<linestring-text>.made;         } }
    rule polygon-tagged-text            { :i "polygon"            <polygon-text>            { make $<polygon-text>.made;            } }
    rule triangle-tagged-text           { :i "triangle"           <triangle-text>           { make $<triangle-text>.made;           } }
    rule polyhedralsurface-tagged-text  { :i "polyhedralsurface"  <polyhedralsurface-text>  { make $<polyhedralsurface-text>.made;  } }
    rule tin-tagged-text                { :i "tin"                <tin-text>                { make $<tin-text>.made;                } }
    rule multipoint-tagged-text         { :i "multipoint"         <multipoint-text>         { make $<multipoint-text>.made;         } }
    rule multilinestring-tagged-text    { :i "multilinestring"    <multilinestring-text>    { make $<multilinestring-text>.made;    } }
    rule multipolygon-tagged-text       { :i "multipolygon"       <multipolygon-text>       { make $<multipolygon-text>.made;       } }
    rule geometrycollection-tagged-text { :i "geometrycollection" <geometrycollection-text> { make $<geometrycollection-text>.made; } }

    rule point-text { <empty-set>
                    |  '(' <point> ')' { make $<point>.made; }
                    |  '[' <point> ']' { make $<point>.made; }
                    }
    rule linestring-text {:s
                           | <empty-set>
                           | '(' <point>+ % ',' ')' { make LineString.new(points => $<point>.map: {.made}); }
                           | '[' <point>+ % ',' ']' { make LineString.new(points => $<point>.map: {.made}); }
                         }
    rule linearring-text { | <empty-set>
                           | '(' <point>+ % ',' ')' { make LinearRing.new(points => $<point>.map: {.made}); }
                           | '[' <point>+ % ',' ']' { make LinearRing.new(points => $<point>.map: {.made}); }
                         }
    rule polygon-text { | <empty-set>
                        | '(' <linearring-text>+ % ',' ')' { make Polygon.new(rings => $<linearring-text>.map: {.made}); }
                        | '[' <linearring-text>+ % ',' ']' { make Polygon.new(rings => $<linearring-text>.map: {.made}); }
                      }
    rule polyhedralsurface-text { | <empty-set>
                                  | '(' <polygon-text>+ % ',' ')' { make PolyhedralSurface.New(polygons => $<polygon-text>.map: {.made}); }
                                  | '[' <polygon-text>+ % ',' ']' { make PolyhedralSurface.New(polygons => $<polygon-text>.map: {.made}); }
                                }
    rule multipoint-text { | <empty-set>
                           | '(' <point-text>+ % ',' ')' { make MultiPoint.new(points => $<point-text>.map: {.made}); }
                           | '[' <point-text>+ % ',' ']' { make MultiPoint.new(points => $<point-text>.map: {.made}); }
                         }
    rule multilinestring-text { | <empty-set>
                                | '(' <linestring-text>+ % ',' ')' { make MultiLineString.new(linestrings => $<linestring-text>.map: {.made}); }
                                | '[' <linestring-text>+ % ',' ']' { make MultiLineString.new(linestrings => $<linestring-text>.map: {.made}); }
                              }
    rule multipolygon-text { | <empty-set>
                             | '(' <polygon-text>+ % ',' ')' { make MultiPolygon.new(polygons => $<polygon-text>.map: {.made}); }
                             | '[' <polygon-text>+ % ',' ']' { make MultiPolygon.new(polygons => $<polygon-text>.map: {.made}); }
                           }
    rule geometrycollection-text { | <empty-set>
                                   | '(' <geometry-tagged-text>+ % ',' ')' { make GeometryCollection.new(geometries => $<geometry-tagged-text>.map: {.made}); }
                                   | '[' <geometry-tagged-text>+ % ',' ']' { make GeometryCollection.new(geometries => $<geometry-tagged-text>.map: {.made}); }
                                 }

    rule pointz { <value> <value> <value> }
    rule geometryz-tagged-text {
        | <pointz-tagged-text>
        | <linestringz-tagged-text>
        | <polygonz-tagged-text>
        | <trianglez-tagged-text>
        | <polyhedralsurfacez-tagged-text>
        | <tinz-tagged-text>
        | <multipointz-tagged-text>
        | <multilinestringz-tagged-text>
        | <multipolygonz-tagged-text>
        | <geometrycollectionz-tagged-text>
    }
    rule pointz-tagged-text              { :i "point" "z"              <pointz-text> }
    rule linestringz-tagged-text         { :i "linestring" "z"         <linestringz-text> }
    rule polygonz-tagged-text            { :i "polygon" "z"            <polygonz-text> }
    rule trianglez-tagged-text           { :i "triangle" "z"           <trianglez-text> }
    rule polyhedralsurfacez-tagged-text  { :i "polyhedralsurface" "z"  <polyhedralsurfacez-text> }
    rule tinz-tagged-text                { :i "tin" "z"                <tinz-text> }
    rule multipointz-tagged-text         { :i "multipoint" "z"         <multipointz-text> }
    rule multilinestringz-tagged-text    { :i "multilinestring" "z"    <multilinestringz-text> }
    rule multipolygonz-tagged-text       { :i "multipolygon" "z"       <multipolygonz-text> }
    rule geometrycollectionz-tagged-text { :i "geometrycollection" "z" <geometrycollectionz-text> }

    rule pointz-text { <empty-set> |
                      '(' <pointz> ')' |
                      '[' <pointz> ']'
                    }
    rule linestringz-text { | <empty-set>
                           | '(' <pointz>+ % ',' ')'
                           | '[' <pointz>+ % ',' ']'
                         }
    rule polygon-textz { | <empty-set>
                        | '(' <linestringz-text>+ % ',' ')'
                        | '[' <linestringz-text>+ % ',' ']'
                      }
    rule polyhedralsurfacez-text { | <empty-set>
                                  | '(' <polygonz-text>+ % ',' ')'
                                  | '[' <polygonz-text>+ % ',' ']'
                                }
    rule multipointz-text { | <empty-set>
                           | '(' <pointz-text>+ % ',' ')'
                           | '[' <pointz-text>+ % ',' ']'
                         }
    rule multilinestringz-text { | <empty-set>
                                | '(' <multilinestringz-text>+ % ',' ')'
                                | '[' <multilinestringz-text>+ % ',' ']'
                              }
    rule multipolygonz-text { | <empty-set>
                             | '(' <multipolygonz-text>+ % ',' ')'
                             | '[' <multipolygonz-text>+ % ',' ']'
                           }
    rule geometrycollectionz-text { | <empty-set>
                                   | '(' <geometry-taggedz-text>+ % ',' ')'
                                   | '[' <geometry-taggedz-text>+ % ',' ']'
                                 }

    rule pointm { <value> <value> <value> }
    rule geometrym-tagged-text {
        | <pointz-tagged-text>
        | <linestringm-tagged-text>
        | <polygonm-tagged-text>
        | <trianglem-tagged-text>
        | <polyhedralsurfacem-tagged-text>
        | <tinm-tagged-text>
        | <multipointm-tagged-text>
        | <multilinestringm-tagged-text>
        | <multipolygonm-tagged-text>
        | <geometrycollectionm-tagged-text>
    }
    rule pointm-tagged-text              { :i "point" "m"              <pointm-text> }
    rule linestringm-tagged-text         { :i "linestring" "m"         <linestringm-text> }
    rule polygonm-tagged-text            { :i "polygon" "m"            <polygonm-text> }
    rule trianglem-tagged-text           { :i "triangle" "m"           <trianglem-text> }
    rule polyhedralsurfacem-tagged-text  { :i "polyhedralsurface" "m"  <polyhedralsurfacem-text> }
    rule tinm-tagged-text                { :i "tin" "m"                <tinm-text> }
    rule multipointm-tagged-text         { :i "multipoint" "m"         <multipointm-text> }
    rule multilinestringm-tagged-text    { :i "multilinestring" "m"    <multilinestringm-text> }
    rule multipolygonm-tagged-text       { :i "multipolygon" "m"       <multipolygonm-text> }
    rule geometrycollectionm-tagged-text { :i "geometrycollection" "m" <geometrycollectionm-text> }

    rule pointm-text { <empty-set> |
                      '(' <pointm> ')' |
                      '[' <pointm> ']'
                    }
    rule linestringm-text { | <empty-set>
                           | '(' <pointm>+ % ',' ')'
                           | '[' <pointm>+ % ',' ']'
                         }
    rule polygon-textm { | <empty-set>
                        | '(' <linestringm-text>+ % ',' ')'
                        | '[' <linestringm-text>+ % ',' ']'
                      }
    rule polyhedralsurfacem-text { | <empty-set>
                                  | '(' <polygonm-text>+ % ',' ')'
                                  | '[' <polygonm-text>+ % ',' ']'
                                }
    rule multipointm-text { | <empty-set>
                           | '(' <pointm-text>+ % ',' ')'
                           | '[' <pointm-text>+ % ',' ']'
                         }
    rule multilinestringm-text { | <empty-set>
                                | '(' <multilinestringm-text>+ % ',' ')'
                                | '[' <multilinestringm-text>+ % ',' ']'
                              }
    rule multipolygonm-text { | <empty-set>
                             | '(' <multipolygonm-text>+ % ',' ')'
                             | '[' <multipolygonm-text>+ % ',' ']'
                           }
    rule geometrycollectionm-text { | <empty-set>
                                   | '(' <geometry-taggedm-text>+ % ',' ')'
                                   | '[' <geometry-taggedm-text>+ % ',' ']'
                                 }

    rule pointzm { <value> <value> <value> <value>}
    rule geometryzm-tagged-text {
        | <pointzm-tagged-text>
        | <linestringzm-tagged-text>
        | <polygonzm-tagged-text>
        | <trianglezm-tagged-text>
        | <polyhedralsurfacezm-tagged-text>
        | <tinzm-tagged-text>
        | <multipointzm-tagged-text>
        | <multilinestringzm-tagged-text>
        | <multipolygonzm-tagged-text>
        | <geometrycollectionzm-tagged-text>
    }
    rule pointzm-tagged-text              { :i "point" "zm"              <pointzm-text> }
    rule linestringzm-tagged-text         { :i "linestring" "zm"         <linestringzm-text> }
    rule polygonzm-tagged-text            { :i "polygon" "zm"            <polygonzm-text> }
    rule trianglezm-tagged-text           { :i "triangle" "zm"           <trianglezm-text> }
    rule polyhedralsurfacezm-tagged-text  { :i "polyhedralsurface" "zm"  <polyhedralsurfacezm-text> }
    rule tinzm-tagged-text                { :i "tin" "zm"                <tinzm-text> }
    rule multipointzm-tagged-text         { :i "multipoint" "zm"         <multipointzm-text> }
    rule multilinestringzm-tagged-text    { :i "multilinestring" "zm"    <multilinestringzm-text> }
    rule multipolygonzm-tagged-text       { :i "multipolygon" "zm"       <multipolygonzm-text> }
    rule geometrycollectionzm-tagged-text { :i "geometrycollection" "zm" <geometrycollectionzm-text> }

    rule pointzm-text { <empty-set> |
                      '(' <pointzm> ')' |
                      '[' <pointzm> ']'
                    }
    rule linestringzm-text { | <empty-set>
                           | '(' <pointzm>+ % ',' ')'
                           | '[' <pointzm>+ % ',' ']'
                         }
    rule polygon-textzm { | <empty-set>
                        | '(' <linestringzm-text>+ % ',' ')'
                        | '[' <linestringzm-text>+ % ',' ']'
                      }
    rule polyhedralsurfacezm-text { | <empty-set>
                                  | '(' <polygonzm-text>+ % ',' ')'
                                  | '[' <polygonzm-text>+ % ',' ']'
                                }
    rule multipointzm-text { | <empty-set>
                           | '(' <pointzm-text>+ % ',' ')'
                           | '[' <pointzm-text>+ % ',' ']'
                         }
    rule multilinestringzm-text { | <empty-set>
                                | '(' <multilinestringzm-text>+ % ',' ')'
                                | '[' <multilinestringzm-text>+ % ',' ']'
                              }
    rule multipolygonzm-text { | <empty-set>
                             | '(' <multipolygonzm-text>+ % ',' ')'
                             | '[' <multipolygonzm-text>+ % ',' ']'
                           }
    rule geometrycollectionzm-text { | <empty-set>
                                   | '(' <geometry-taggedzm-text>+ % ',' ')'
                                   | '[' <geometry-taggedzm-text>+ % ',' ']'
                                 }
}

our sub from-wkt(Str $s) {
    WKT.parse($s).made;
}

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

our sub from-wkb(Buf $buff) {
    my $length = $buff.elems;
    my $byteorder = $buff[0] ?? wkbNDR !! wkbXDR;
    my $endian = $byteorder == wkbNDR ?? BigEndian !! LittleEndian;
    my $offset = 1;
    my $geometry = wkb-read-geometry($buff, $offset, $endian);
    fail "from-wkb: buffer too short" if $offset > $length;
    $geometry;
}

=begin pod
=TITLE Geo::Geometry
=head1 Geo::Geometry

A series of classes for storing geographic data

=head1 Generic Methods

The following methods are available for most classes. Classes for which they are not available are documented below.

=head2 type

The C<type> method returns a member of the WKBGeometryType enum corresponding to the geometry type.

=head2 Str

The C<Str> method returns a string representing the object.

=head2 tobuf

The C<tobuf> method is used internally as part of generating the C<wkb> output. It is probably not otherwise useful.

=head2 wkb

The C<wkb> method will produce a C<Buf> object with the well-known-binary representation of the object. An optional named argument C<byteorder> parameter is available. The value of the argument is one of the values of the C<WKBByteOrder> enum. The default value is C<wkbXDR> (little endian) with the alternative being C<wkbNDR> (big endian).

=head2 wkt

The C<wkt> method returns a string containing the well-known text representation of the geometry.

=head1 Subroutines

=head2 from-wkt

The C<from-wkt> subroutine takes a string as parameter and returns a C<Geometry> object if the string contains a WKT represenation of a geometry.

=head2 from-wkb

The C<from-wkb> subroutine takes a Buf as parameter, and returns a C<Geometry> object is the Buf contains a WKΒrepresentation of a geometry.
=head1 Object types (classes)

=head2 Geometry

An object in the C<Geometry> class contains, in general, no attributes or methods, except as defined as below. It is a generic object which can contain any of the other geometry classes.

If you want to check whether a variable contains any of the gemoetry classes, then code like
=begin code
  if $variable ~~ Geometry { ... }
=end code
can be useful.

=head2 Point
=head2 PointZ
=head2 PointM
=head2 PointZM

The C<Point> class represents a single point geometry. It has two attributes, C<x> and C<y>, each of which is constrained to be a 64-bit floating point number (C<num>).

The C<PointZ> class also contains a third attribute C<z> to represent a third dimension.

The C<PointM> class, in addition to the C<X> and C<y> attributes contains an C<m> attribute which can contain an arbitrary "measure" in addition to the two-dimensional location.

The C<PointMZ> class combines the C<z> attribute of C<PointZ> and the C<m> attribute of C<PointM>.

An object of each class may be constructed either by using named parameters (C<Point.new(x => 10, y => 12)>, or by using positional parameters (C<PointZ.new(1,2,3)>). When positional parameters are used, the ordering of the parameters is C<x>, C<y>, C<z>, C<m>; omitting those parameters which are not appropriate for the object type.

All the parameters of a point geometry are required. C<NaN> might be used if an C<m> parameter for example were not required.

=head2 LineString
=head2 LineStringZ
=head2 LineStringM
=head2 LineStringZM

The C<LineString> class represents a single line, a sequence of C<Point>s, not necessarily closed.

Similarly, C<LineStringZ>, C<LineStringM> and C<LineStringZM> are lines consisting of  sequences of C<PointZ>s, C<PointM>s and C<PointZM>s respectively.

An object in the LineString family is created by passing an array of the appropriate point type geometries, to the named argument C<points>.

At the moment there is no way of accessing the contents of a LineString geometry other than using the standard methods.

=head2 LinearRing
=head2 LinearRingZ
=head2 LinearRingM
=head2 LinearRingZM

Objects in the LinearRing classes are not normally intended for end users, apart from their use in creating more complex objects. None of the usual methods apply to these types of object. (There is a C<tobuf> method, but it should not normally be used by end-user code; it is necessary for internal use.)

A linear ring is similar to a line string, but is closed; i.e. the last point should be identical to the first point. This is not currently enforced, but may be in the future. Creation of a linear ring is the same as that of a line string. The ring should be simple; the path should not cross itself. This is also not enforced.

Each of these classes has a C<winding> method. This determines whether the linear ring is clockwise (a positive number is returned) or anti-clockwise (a negative number is returned). This method will be unreliable unless the linear ring actually is a simple closed loop. The winding method ignores everything except the C<x> and C<y> attributes.

=head2 Polygon
=head2 PolygonZ
=head2 PolygonM
=head2 PolygonZM

A C<Polygon> consists of one or more C<LinearRings>. In general, the first linear ring should be clockwise (with a positive winding number). The other linear rings should be fully enclosed within the first and be disjoint from each other. They should have a negative winding number. These rings represent a polygon (the first ring) and holes within that polygon, represented by the other rings. Having only a single ring specified is acceptable (and normal under most circumstances), representing a polygon without holes.

A C<Polygon> is created using an array of rings, such as C<Polygon.new(rings => @rings)>.

C<PolygonZ>, C<PolygonM> and C<PolygonZM> behave similarly.

=head2 Triangle
=head2 TriangleZ
=head2 TriangleM
=head2 TriangleZM

To be added.

=head2 PolyhedralSurface
=head2 PolyhedralSurfaceZ
=head2 PolyhedralSurfaceM
=head2 PolyhedralSurfaceZM

To be added.

=head2 TIN
=head2 TINZ
=head2 TINM
=head2 TINZM

To be added.

=head2 MultiPoint
=head2 MultiPointZ
=head2 MultiPointM
=head2 MultiPointZM

The MultiPoint classes behave just like LineStrings, including their definition. The difference is the intent of the object. A LineString, as the name implies, forms a line. A MultiPoint object is just a collection of points.

=head2 MultiLineString
=head2 MultiLineStringZ
=head2 MultiLineStringM
=head2 MultiLineStringZM

A C<MultiLineString> object contains an array of C<LineString>s. It is created with that array: C<MultiLineString.new(linestrings => @array-of-linestrings)>.

=head2 MultiPolygon
=head2 MultiPolygonZ
=head2 MultiPolygonM
=head2 MultiPolygonZM

Just as a C<MultiPoint> is a collections of C<Point>s, and a C<MultiLineString> is a collection of C<LineString>s, a C<MultiPolygon> is a collection of C<Polygon>s.

=head2 GeometryCollection
=head2 GeometryCollectionZ
=head2 GeometryCollectionM
=head2 GeometryCollectionZM

To be added.

=end pod
