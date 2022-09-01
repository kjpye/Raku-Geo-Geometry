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

role Geometry {
}

class Point does Geometry {
    has Num $.x is required is built;
    has Num $.y is required is built;

    method type { wkbPoint };
    multi method new($x, $y) { self.bless(x => $x.Num, y => $y.Num) }
    method Str() { "{$!x} {$!y}" }
    method wkt() { "Point({self.Str})"; }
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

class PointZ does Geometry {
    has Num $.x is required is built;
    has Num $.y is required is built;
    has Num $.z is required is built;

    method type { wkbPointZ }
    multi method new($x, $y, $z) { self.bless(x => $x.Num, y => $y.Num, z => $z.Num) }
    method Str() { "{$!x} {$!y} {$!z}" }
    method wkt() { "PointZ({self.Str})"; }
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

class PointM does Geometry {
    has Num $.x is required is built;
    has Num $.y is required is built;
    has Num $.m is required is built;
    
    method type { wkbPointM }
    multi method new($x, $y, $m) { self.bless(x => $x.Num, y => $y.Num, m => $m.Num) }
    method Str() { "{$!x} {$!y} {$!m}" }
    method wkt() { "PointM({self.Str})"; }
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

class PointZM does Geometry {
    has Num $.x is required is built;
    has Num $.y is required is built;
    has Num $.z is required is built;
    has Num $.m is required is built;
    
    method type { wkbPointZM }
    multi method new($x, $y, $z, $m) { self.bless(x => $x.Num, y => $y.Num, z => $z.Num, m => $m.Num) }
    method Str() { "{$!x} {$!y} {$!z} {$!m}" }
    method wkt() { "PointZM({self.Str})"; }
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

class LineString does Geometry {
    has $!type = wkbLineString;
    has $.num-points;
    has Point @.points is required is built;

    method type { $!type; }
    method TWEAK { $!num-points = +@!points; }
    method Str() { @!points.map({.Str}).join(',') };
    method wkt() { "LineString({self.Str})"; }
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

class LineStringZ does Geometry {
    has $!type = wkbLineStringZ;
    has $.num-points;
    has PointZ @.points is required is built;

    method type { $!type; }
    method TWEAK { $!num-points = +@!points; }
    method Str() { @!points.map({.Str}).join(',') };
    method wkt() { "LineStringZ({self.Str})"; }
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

class LineStringM does Geometry {
    has $!type = wkbLineStringM;
    has $.num-points;
    has PointM @.points is required is built;

    method type { $!type; }
    method TWEAK { $!num-points = +@!points; }
    method Str() { @!points.map({.Str}).join(',') };
    method wkt() { "LineStringM({self.Str})"; }
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

class LineStringZM does Geometry {
    has $!type = wkbLineStringZM;
    has $.num-points;
    has PointZM @.points is required is built;

    method type { $!type; }
    method TWEAK { $!num-points = +@!points; }
    method Str() { @!points.map({.Str}).join(',') };
    method wkt() { "LineStringZM({self.Str})"; }
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
    
class LinearRing does Geometry {
    has $.num-points;
    has Point @.points is required is built;

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

class LinearRingZ does Geometry {
    has $.num-points;
    has PointZ @.points is required is built;

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

class LinearRingM does Geometry {
    has $.num-points;
    has PointM @.points is required is built;

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

class LinearRingZM does Geometry {
    has $.num-points;
    has PointZM @.points is required is built;

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

class Polygon does Geometry {
    has $!type = wkbPolygon;
    has $.num-rings;
    has LinearRing @.rings is required is built;

    method type { $!type; }
    method TWEAK { $!num-rings = +@!rings; }
    method Str() { '(' ~ @!rings.map({.Str}).join('),(') ~ ')' };
    method wkt() { "Polygon({self.Str})"; }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-uint32(1, wkbPolygon,  $endian);
        $b.write-uint32(5, $!num-rings, $endian);
        $b ~ [~] @!rings.map({.tobuf($endian)})
    }
}

class PolygonZ does Geometry {
    has $!type = wkbPolygonZ;
    has $.num-rings;
    has LinearRingZ @.rings is required is built;

    method type { $!type; }
    method TWEAK { $!num-rings = +@!rings; }
    method Str() { '(' ~ @!rings.map({.Str}).join('),(') ~ ')' };
    method wkt() { "PolygonZ({self.Str})"; }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-uint32(1, wkbPolygonZ, $endian);
        $b.write-uint32(5, $!num-rings, $endian);
        $b ~ [~] @!rings.map({.tobuf($endian)})
    }
}

class PolygonM does Geometry {
    has $!type = wkbPolygonM;
    has $.num-rings;
    has LinearRingM @.rings is required is built;

    method type { $!type; }
    method TWEAK { $!num-rings = +@!rings; }
    method Str() { '(' ~ @!rings.map({.Str}).join('),(') ~ ')' };
    method wkt() { "PolygonM({self.Str})"; }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-uint32(1, wkbPolygonM, $endian);
        $b.write-uint32(5, $!num-rings, $endian);
        $b ~ [~] @!rings.map({.tobuf($endian)})
    }
}

class PolygonZM does Geometry {
    has $!type = wkbPolygonZM;
    has $.num-rings;
    has LinearRingZM @.rings is required is built;

    method type { $!type; }
    method TWEAK { $!num-rings = +@!rings; }
    method Str() { '(' ~ @!rings.map({.Str}).join('),(') ~ ')' };
    method wkt() { "PolygonZM({self.Str})"; }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-uint32(1, wkbPolygonZM, $endian);
        $b.write-uint32(5, $!num-rings,  $endian);
        $b ~ [~] @!rings.map({.tobuf($endian)})
    }
}

class Triangle does Geometry {
    has $!type = wkbTriangle;
    has $.num-rings;
    has LinearRing @.rings is required is built;

    method type { $!type; }
    method TWEAK { $!num-rings = +@!rings; }
    method Str() { '(' ~ @!rings.map({.Str}).join('),(') ~ ')' };
    method wkt() { "Triangle({self.Str})"; }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-uint32(1, wkbTriangle, $endian);
        $b.write-uint32(5, $!num-rings, $endian);
        $b ~ [~] @!rings.map({.tobuf($endian)})
    }
}

class TriangleZ does Geometry {
    has $!type = wkbTriangleZ;
    has $.num-rings;
    has LinearRingZ @.rings is required is built;

    method type { $!type; }
    method TWEAK { $!num-rings = +@!rings; }
    method Str() { '(' ~ @!rings.map({.Str}).join('),(') ~ ')' };
    method wkt() { "TriangleZ({self.Str})"; }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-uint32(1, wkbTriangleZ, $endian);
        $b.write-uint32(5, $!num-rings,  $endian);
        $b ~ [~] @!rings.map({.tobuf($endian)})
    }
}

class TriangleM does Geometry {
    has $!type = wkbTriangleM;
    has $.num-rings;
    has LinearRingM @.rings is required is built;

    method type { $!type; }
    method TWEAK { $!num-rings = +@!rings; }
    method Str() { '(' ~ @!rings.map({.Str}).join('),(') ~ ')' };
    method wkt() { "TriangleM({self.Str})"; }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-uint32(1, wkbTriangleM, $endian);
        $b.write-uint32(5, $!num-rings,  $endian);
        $b ~ [~] @!rings.map({.tobuf($endian)})
    }
}

class TriangleZM does Geometry {
    has $!type = wkbTriangleZM;
    has $.num-rings;
    has LinearRingZM @.rings is required is built;

    method type { $!type; }
    method TWEAK { $!num-rings = +@!rings; }
    method Str() { '(' ~ @!rings.map({.Str}).join('),(') ~ ')' };
    method wkt() { "TriangleZM({self.Str})"; }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-uint32(1, wkbTriangleZM, $endian);
        $b.write-uint32(5, $!num-rings,  $endian);
        $b ~ [~] @!rings.map({.tobuf($endian)})
    }
}

class PolyhedralSurface does Geometry {
    has $!type = wkbPolyhedralSurface;
    has $.num-polygons;
    has Polygon @.polygons is required is built;

    method type { $!type; }
    method TWEAK { $!num-polygons = +@!polygons; }
    method Str() { '(' ~ @!polygons.map({.Str}).join('),(') ~ ')' };
    method wkt() { "PolyhedralSurface({self.Str})"; }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-uint32(1, wkbPolyhedralSurface, $endian);
        $b.write-uint32(5, $!num-polygons,       $endian);
        $b ~ [~] @!polygons.map({.tobuf($endian)})
    }
}


class PolyhedralSurfaceZ does Geometry {
    has $!type = wkbPolyhedralSurfaceZ;
    has $.num-polygons;
    has PolygonZ @.polygons is required is built;

    method type { $!type; }
    method TWEAK { $!num-polygons = +@!polygons; }
    method Str() { '(' ~ @!polygons.map({.Str}).join('),(') ~ ')' };
    method wkt() { "PolyhedralSurfaceZ({self.Str})"; }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-uint32(1, wkbPolyhedralSurfaceZ, $endian);
        $b.write-uint32(5, $!num-polygons,        $endian);
        $b ~ [~] @!polygons.map({.tobuf($endian)})
    }
}


class PolyhedralSurfaceM does Geometry {
    has $!type = wkbPolyhedralSurfaceM;
    has $.num-polygons;
    has PolygonM @.polygons is required is built;

    method type { $!type; }
    method TWEAK { $!num-polygons = +@!polygons; }
    method Str() { '(' ~ @!polygons.map({.Str}).join('),(') ~ ')' };
    method wkt() { "PolyhedralSurfaceM({self.Str})"; }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-uint32(1, wkbPolyhedralSurfaceM, $endian);
        $b.write-uint32(5, $!num-polygons,        $endian);
        $b ~ [~] @!polygons.map({.tobuf($endian)})
    }
}


class PolyhedralSurfaceZM does Geometry {
    has $!type = wkbPolyhedralSurfaceZM;
    has $.num-polygons;
    has PolygonZM @.polygons is required is built;

    method type { $!type; }
    method TWEAK { $!num-polygons = +@!polygons; }
    method Str() { '(' ~ @!polygons.map({.Str}).join('),(') ~ ')' };
    method wkt() { "PolyhedralSurfaceZM({self.Str})"; }
    method wkb(:$byteorder = wkbXDR) {
        my $endian = $byteorder == wkbXDR ?? LittleEndian !! BigEndian;
        my $b = Buf.new($byteorder);
        $b.write-uint32(1, wkbPolyhedralSurfaceZM, $endian);
        $b.write-uint32(5, $!num-polygons,         $endian);
        $b ~ [~] @!polygons.map({.tobuf($endian)})
    }
}

class TIN does Geometry {
    has $!type = wkbTIN;
    has $.num-polygons;
    has Polygon @.polygons is required is built;

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


class TINZ does Geometry {
    has $!type = wkbTINZ;
    has $.num-polygons;
    has PolygonZ @.polygons is required is built;

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


class TINM does Geometry {
    has $!type = wkbTINM;
    has $.num-polygons;
    has PolygonM @.polygons is required is built;

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


class TINZM does Geometry {
    has $!type = wkbTINZM;
    has $.num-polygons;
    has PolygonZM @.polygons is required is built;

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

class MultiPoint does Geometry {
    has $!type = wkbMultiPoint;
    has $.num-points;
    has Point @.points is required is built;

    method type { $!type; }
    method TWEAK { $!num-points = +@!points; }
    method Str() { '(' ~ @!points.map({.Str}).join('),(') ~ ')' };
    method wkt() { "MultiPoint({self.Str})"; }
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


    
class MultiPointZ does Geometry {
    has $!type = wkbMultiPointZ;
    has $.num-points;
    has PointZ @.points is required is built;

    method type { $!type; }
    method TWEAK { $!num-points = +@!points; }
    method Str() { @!points.map({.Str}).join(',') };
    method wkt() { "MultiPointZ({self.Str})"; }
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
    
class MultiPointM does Geometry {
    has $!type = wkbMultiPointM;
    has $.num-points;
    has PointM @.points is required is built;

    method type { $!type; }
    method TWEAK { $!num-points = +@!points; }
    method Str() { @!points.map({.Str}).join(',') };
    method wkt() { "MultiPointM({self.Str})"; }
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
    
class MultiPointZM does Geometry {
    has $!type = wkbMultiPointZM;
    has $.num-points;
    has PointZM @.points is required is built;

    method type { $!type; }
    method TWEAK { $!num-points = +@!points; }
    method Str() { @!points.map({.Str}).join(',') };
    method wkt() { "MultiPointZM({self.Str})"; }
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

class MultiLineString does Geometry {
    has $!type = wkbMultiLineString;
    has $.num-linestrings;
    has LineString @.linestrings is required is built;

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

class MultiLineStringZ does Geometry {
    has $!type = wkbMultiLineStringZ;
    has $.num-linestrings;
    has LineStringZ @.linestrings is required is built;

    method type { $!type; }
    method TWEAK { $!num-linestrings = +@!linestrings; }
    method Str { '(' ~ @!linestrings.map({.Str}).join('),(') ~ ')'; }
    method wkt { 'MultiLineStringZ(' ~ self.Str ~ ')'; }
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

class MultiLineStringM does Geometry {
    has $!type = wkbMultiLineStringM;
    has $.num-linestrings;
    has LineStringM @.linestrings is required is built;

    method type { $!type; }
    method TWEAK { $!num-linestrings = +@!linestrings; }
    method Str { '(' ~ @!linestrings.map({.Str}).join('),(') ~ ')'; }
    method wkt { 'MultiLineStringM(' ~ self.Str ~ ')'; }
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

class MultiLineStringZM does Geometry {
    has $!type = wkbMultiLineStringZM;
    has $.num-linestrings;
    has LineStringZM @.linestrings is required is built;

    method type { $!type; }
    method TWEAK { $!num-linestrings = +@!linestrings; }
    method Str { '(' ~ @!linestrings.map({.Str}).join('),(') ~ ')'; }
    method wkt { 'MultiLineStringZM(' ~ self.Str ~ ')'; }
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

class MultiPolygon does Geometry {
    has $!type = wkbMultiPolygon;
    has $.num-polygons;
    has Polygon @.polygons is required is built;

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

class MultiPolygonZ does Geometry {
    has $!type = wkbMultiPolygonZ;
    has $.num-polygons;
    has PolygonZ @.polygons is required is built;

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

class MultiPolygonM does Geometry {
    has $!type = wkbMultiPolygonM;
    has $.num-polygons;
    has PolygonM @.polygons is required is built;

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

class MultiPolygonZM does Geometry {
    has $!type = wkbMultiPolygonZM;
    has $.num-polygons;
    has PolygonZM @.polygons is required is built;

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

class GeometryCollection does Geometry {
    has $.num-geometries;
    has Geometry @.geometries is required is built;

    method TWEAK { $!num-geometries = +@!geometries; }
    method Str { @!geometries.map({.wkt}).join(','); }
    method wkt { 'GeometryCollection(' ~ self.Str ~ ')'; }
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

class GeometryCollectionZ does Geometry {
    has $.num-geometries;
    has Geometry @.geometries is required is built;

    method TWEAK { $!num-geometries = +@!geometries; }
    method Str { @!geometries.map({.wkt}).join(','); }
    method wkt { 'GeometryCollectionZ(' ~ self.Str ~ ')'; }
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

class GeometryCollectionM does Geometry {
    has $.num-geometries;
    has Geometry @.geometries is required is built;

    method TWEAK { $!num-geometries = +@!geometries; }
    method Str { @!geometries.map({.wkt}).join(','); }
    method wkt { 'GeometryCollectionM(' ~ self.Str ~ ')'; }
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

class GeometryCollectionZM does Geometry {
    has $.num-geometries;
    has Geometry @.geometries is required is built;

    method TWEAK { $!num-geometries = +@!geometries; }
    method Str { @!geometries.map({.wkt}).join(','); }
    method wkt { 'GeometryCollectionZM(' ~ self.Str ~ ')'; }
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

our sub from-wkt (Str $s) is DEPRECATED {
    Geo::WellKnownText::Grammar::WKT.parse($s, actions => Geo::WellKnownText::Grammar::Wkt-Actions).made;
}

our sub from-wkb(Buf $buff) is DEPRECATED {
    Geo::WellKnownBinary::from-wkb($buff);
}
