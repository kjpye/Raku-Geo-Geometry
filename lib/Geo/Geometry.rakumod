use Grammar::Tracer;
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
    has num $.x is required is built;
    has num $.y is required is built;

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
    has num $.x is required is built;
    has num $.y is required is built;
    has num $.z is required is built;

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
    has num $.x is required is built;
    has num $.y is required is built;
    has num $.m is required is built;
    
    method type { wkbPointM }
    multi method new($x, $y, $m) { dd $m; dd $m.Num; self.bless(x => $x.Num, y => $y.Num, m => $m.Num) }
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
    has num $.x is required is built;
    has num $.y is required is built;
    has num $.z is required is built;
    has num $.m is required is built;
    
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

grammar WKT {
    regex TOP {
        | <geometry-tagged-text>   { make $<geometry-tagged-text>.made;   }
        | <geometryz-tagged-text>  { make $<geometryz-tagged-text>.made;  }
        | <geometrym-tagged-text>  { make $<geometrym-tagged-text>.made;  }
        | <geometryzm-tagged-text> { make $<geometryzm-tagged-text>.made; }
    }
    regex value                          { <signed-numeric-literal> { make $<signed-numeric-literal>.made; } }
    token sign                           {       { make  1; }
                                           | '+' { make  1; }
                                           | '-' { make -1; }
                                         }
    token signed-numeric-literal         { <sign> <unsigned-numeric-literal> { make $<sign>.made * $<unsigned-numeric-literal>.made; } }
    token unsigned-numeric-literal       { <approximate-numeric-literal> { make $<approximate-numeric-literal>.made; } }
    token exponent {
                     |                                  { make 1;                                               }
                     | :i 'e' <sign> <unsigned-integer> { make 10e0 ** ($<sign>.made × $<unsigned-integer>.made); }
                   }
    token approximate-numeric-literal    { <exact-numeric-literal> <exponent>
                                              { make $<exact-numeric-literal>.made × $<exponent>.made; }
                                         }
    token exact-numeric-literal          {
                                           | <unsigned-integer> [ <decimal-point> <unsigned-integer>? ]?
                                             {
                                                 if $<unsigned-integer>[1].defined {
                                                     make $<unsigned-integer>[0] +
                                                     $<unsigned-integer>[1] ÷ 10 ** ($<unsigned-integer>[1].pos - $<unsigned-integer>[1].from);
                                                 } else {
                                                     make $<unsigned-integer>[0];
                                                 }
                                             }
                                           | <decimal-point> <unsigned-integer> { make 1e0 ÷ 10**($<unsigned-integer>.pos - $<unsigned-integer>.from); }
                                         }
    token signed-integer                 { <sign> <unsigned-integer> { make $<sign>.made * $<unsigned-integer>.made; } }
    token unsigned-integer               { (\d+) { make +$0; } }
#    token decimal-point                  { '.' | ',' }
    token decimal-point                  { '.' }
    token empty-set                      { "EMPTY" }

# The non-Z or Μ variants
    
    rule point { <value> <value> { make Point.new(x => $<value>[0].made.Num,
                                                  y => $<value>[1].made.Num,
                                                 ); } }
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
    
    token point-tagged-text              { :s:i "point"              <.ws>? <point-text>              { make $<point-text>.made;              } }
    token linestring-tagged-text         { :s:i "linestring"         <.ws>? <linestring-text>         { make $<linestring-text>.made;         } }
    token polygon-tagged-text            { :s:i "polygon"            <.ws>? <polygon-text>            { make $<polygon-text>.made;            } }
    token triangle-tagged-text           { :s:i "triangle"           <.ws>? <triangle-text>           { make $<triangle-text>.made;           } }
    token polyhedralsurface-tagged-text  { :s:i "polyhedralsurface"  <.ws>? <polyhedralsurface-text>  { make $<polyhedralsurface-text>.made;  } }
    token tin-tagged-text                { :s:i "tin"                <.ws>? <tin-text>                { make $<tin-text>.made;                } }
    token multipoint-tagged-text         { :s:i "multipoint"         <.ws>? <multipoint-text>         { make $<multipoint-text>.made;         } }
    token multilinestring-tagged-text    { :s:i "multilinestring"    <.ws>? <multilinestring-text>    { make $<multilinestring-text>.made;    } }
    token multipolygon-tagged-text       { :s:i "multipolygon"       <.ws>? <multipolygon-text>       { make $<multipolygon-text>.made;       } }
    token geometrycollection-tagged-text { :s:i "geometrycollection" <.ws>? <geometrycollection-text> { make $<geometrycollection-text>.made; } }

    rule point-text { | <empty-set>
                        | '(' <point> ')' { make $<point>.made; }
                        | '[' <point> ']' { make $<point>.made; }
                      }
    rule linestring-text { | <empty-set>
                             | '(' <point>+ % ',' ')' { make LineString.new(points => $<point>.map({.made})); }
                             | '[' <point>+ % ',' ']' { make LineString.new(points => $<point>.map({.made})); }
                           }
    rule linearring-text { | <empty-set>
                             | '(' <point>+ % ',' ')' { make LinearRing.new(points => $<point>.map({.made})); }
                             | '[' <point>+ % ',' ']' { make LinearRing.new(points => $<point>.map({.made})); }
                           }
    rule polygon-text { | <empty-set>
                          | '(' <linearring-text>+ % ',' ')' { make Polygon.new(rings => $<linearring>.map({.made})); }
                          | '[' <linearring-text>+ % ',' ']' { make Polygon.new(rings => $<linearring>.map({.made})); }
                        }
    rule polyhedralsurface-text { | <empty-set>
                                    | '(' <polygon-text>+ % ',' ')' { make PolyhedralSurface.new(polygons => $<polygon-text>.map({.made})); }
                                    | '[' <polygon-text>+ % ',' ']' { make PolyhedralSurface.new(polygons => $<polygon-text>.map({.made})); }

                                  }
    rule multipoint-text { | <empty-set>
                             | '(' <point-text>+ % ',' ')' { make MultiPoint.new(points => $<point-text>.map({.made})); }
                             | '[' <point-text>+ % ',' ']' { make MultiPoint.new(points => $<point-text>.map({.made})); }
                           }
    rule multilinestring-text { | <empty-set>
                                  | '(' <linestring-text>+ % ',' ')' { make MultiLineString.new(linestrings => $<linestring-text>.map({.made})); }
                                  | '[' <linestring-text>+ % ',' ']' { make MultiLineString.new(linestrings => $<linestring-text>.map({.made})); }
                                }
    rule multipolygon-text { | <empty-set>
                               | '(' <multipolygon-text>+ % ',' ')' { make MultiPolygon.new(polygons => $<multipolygon-text>.map({.made})); }
                               | '[' <multipolygon-text>+ % ',' ']' { make MultiPolygon.new(polygons => $<multipolygon-text>.map({.made})); }
                             }
    rule geometrycollection-text { | <empty-set>
                                     | '(' <geometry-tagged-text>+ % ',' ')' { make GeometryCollection.new(geometries => $<geometry-tagged-text>.map({.made})); }
                                     | '[' <geometry-tagged-text>+ % ',' ']' { make GeometryCollection.new(geometries => $<geometry-tagged-text>.map({.made})); }
                                 }
# The Z variants
    
    rule pointz { <value> <value> <value> { make PointZ.new(x => $<value>[0].made.Num,
                                                            y => $<value>[1].made.Num,
                                                            z => $<value>[2].made.Num,
                                                           ); } }
    rule geometryz-tagged-text {
        | <pointz-tagged-text>              { make $<pointz-tagged-text>.made;              }
        | <linestringz-tagged-text>         { make $<linestringz-tagged-text>.made;         }
        | <polygonz-tagged-text>            { make $<polygonz-tagged-text>.made;            }
        | <trianglez-tagged-text>           { make $<trianglez-tagged-text>.made;           }
        | <polyhedralsurfacez-tagged-text>  { make $<polyhedralsurfacez-tagged-text>.made;  }
        | <tinz-tagged-text>                { make $<tinz-tagged-text>.made;                }
        | <multipointz-tagged-text>         { make $<multipointz-tagged-text>.made;         }
        | <multilinestringz-tagged-text>    { make $<multilinestringz-tagged-text>.made;    }
        | <multipolygonz-tagged-text>       { make $<multipolygonz-tagged-text>.made;       }
        | <geometrycollectionz-tagged-text> { make $<geometrycollectionz-tagged-text>.made; }
    }
    
    regex pointz-tagged-text              { :i "point"              <.ws>? "z" <.ws>? <pointz-text>              { make $<pointz-text>.made;              } }
    regex linestringz-tagged-text         { :i "linestring"         <.ws>? "z" <.ws>? <linestringz-text>         { make $<linestringz-text>.made;         } }
    regex polygonz-tagged-text            { :i "polygon"            <.ws>? "z" <.ws>? <polygonz-text>            { make $<polygonz-text>.made;            } }
    regex trianglez-tagged-text           { :i "triangle"           <.ws>? "z" <.ws>? <trianglez-text>           { make $<trianglez-text>.made;           } }
    regex polyhedralsurfacez-tagged-text  { :i "polyhedralsurface"  <.ws>? "z" <.ws>? <polyhedralsurfacez-text>  { make $<polyhedralsurfacez-text>.made;  } }
    regex tinz-tagged-text                { :i "tin"                <.ws>? "z" <.ws>? <tinz-text>                { make $<tinz-text>.made;                } }
    regex multipointz-tagged-text         { :i "multipoint"         <.ws>? "z" <.ws>? <multipointz-text>         { make $<multipointz-text>.made;         } }
    regex multilinestringz-tagged-text    { :i "multilinestring"    <.ws>? "z" <.ws>? <multilinestringz-text>    { make $<multilinestringz-text>.made;    } }
    regex multipolygonz-tagged-text       { :i "multipolygon"       <.ws>? "z" <.ws>? <multipolygonz-text>       { make $<multipolygonz-text>.made;       } }
    regex geometrycollectionz-tagged-text { :i "geometrycollection" <.ws>? "z" <.ws>? <geometrycollectionz-text> { make $<geometrycollectionz-text>.made; } }

    rule pointz-text { | <empty-set>
                        | '(' <pointz> ')' { make $<pointz>.made; }
                        | '[' <pointz> ']' { make $<pointz>.made; }
                      }
    rule linestringz-text { | <empty-set>
                             | '(' <pointz>+ % ',' ')' { make LineStringZ.new(points => $<pointz>.map({.made})); }
                             | '[' <pointz>+ % ',' ']' { make LineStringZ.new(points => $<pointz>.map({.made})); }
                           }
    rule linearringz-text { | <empty-set>
                             | '(' <pointz>+ % ',' ')' { make LinearRingZ.new(points => $<pointz>.map({.made})); }
                             | '[' <pointz>+ % ',' ']' { make LinearRingZ.new(points => $<pointz>.map({.made})); }
                           }
    rule polygon-textz { | <empty-set>
                          | '(' <linearringz-text>+ % ',' ')' { make PolygonZ.new(rings => $<linearringz>.map({.made})); }
                          | '[' <linearringz-text>+ % ',' ']' { make PolygonZ.new(rings => $<linearringz>.map({.made})); }
                        }
    rule polyhedralsurfacez-text { | <empty-set>
                                    | '(' <polygonz-text>+ % ',' ')' { make PolyhedralSurfaceZ.new(polygons => $<polygonz-text>.map({.made})); }
                                    | '[' <polygonz-text>+ % ',' ']' { make PolyhedralSurfaceZ.new(polygons => $<polygonz-text>.map({.made})); }

                                  }
    rule multipointz-text { | <empty-set>
                             | '(' <pointz-text>+ % ',' ')' { make MultiPointZ.new(points => $<pointz-text>.map({.made})); }
                             | '[' <pointz-text>+ % ',' ']' { make MultiPointZ.new(points => $<pointz-text>.map({.made})); }
                           }
    rule multilinestringz-text { | <empty-set>
                                  | '(' <linestringz-text>+ % ',' ')' { make MultiLineStringZ.new(linestrings => $<linestringz-text>.map({.made})); }
                                  | '[' <linestringz-text>+ % ',' ']' { make MultiLineStringZ.new(linestrings => $<linestringz-text>.map({.made})); }
                                }
    rule multipolygonz-text { | <empty-set>
                               | '(' <multipolygonz-text>+ % ',' ')' { make MultiPolygonZ.new(polygons => $<multipolygonz-text>.map({.made})); }
                               | '[' <multipolygonz-text>+ % ',' ']' { make MultiPolygonZ.new(polygons => $<multipolygonz-text>.map({.made})); }
                             }
    rule geometrycollectionz-text { | <empty-set>
                                     | '(' <geometryz-tagged-text>+ % ',' ')' { make GeometryCollectionZ.new(geometries => $<geometryz-tagged-text>.map({.made})); }
                                     | '[' <geometryz-tagged-text>+ % ',' ']' { make GeometryCollectionZ.new(geometries => $<geometryz-tagged-text>.map({.made})); }
                                 }
# The Μ variants
    
    rule pointm { <value> <value> <value> { make PointM.new(x => $<value>[0].made.Num,
                                                            y => $<value>[1].made.Num,
                                                            m => $<value>[2].made.Num
                                                           ); } }
    rule geometrym-tagged-text {
        | <pointm-tagged-text>              { make $<pointm-tagged-text>.made;              }
        | <linestringm-tagged-text>         { make $<linestringm-tagged-text>.made;         }
        | <polygonm-tagged-text>            { make $<polygonm-tagged-text>.made;            }
        | <trianglem-tagged-text>           { make $<trianglem-tagged-text>.made;           }
        | <polyhedralsurfacem-tagged-text>  { make $<polyhedralsurfacem-tagged-text>.made;  }
        | <tinm-tagged-text>                { make $<tinm-tagged-text>.made;                }
        | <multipointm-tagged-text>         { make $<multipointm-tagged-text>.made;         }
        | <multilinestringm-tagged-text>    { make $<multilinestringm-tagged-text>.made;    }
        | <multipolygonm-tagged-text>       { make $<multipolygonm-tagged-text>.made;       }
        | <geometrycollectionm-tagged-text> { make $<geometrycollectionm-tagged-text>.made; }
    }
    
    regex pointm-tagged-text              { :i "point"              <.ws>? "m" <.ws> <pointm-text>              { make $<pointm-text>.made;              } }
    regex linestringm-tagged-text         { :i "linestring"         <.ws>? "m" <.ws> <linestringm-text>         { make $<linestringm-text>.made;         } }
    regex polygonm-tagged-text            { :i "polygon"            <.ws>? "m" <.ws> <polygonm-text>            { make $<polygonm-text>.made;            } }
    regex trianglem-tagged-text           { :i "triangle"           <.ws>? "m" <.ws> <trianglem-text>           { make $<trianglem-text>.made;           } }
    regex polyhedralsurfacem-tagged-text  { :i "polyhedralsurface"  <.ws>? "m" <.ws> <polyhedralsurfacem-text>  { make $<polyhedralsurfacem-text>.made;  } }
    regex tinm-tagged-text                { :i "tin"                <.ws>? "m" <.ws> <tinm-text>                { make $<tinm-text>.made;                } }
    regex multipointm-tagged-text         { :i "multipoint"         <.ws>? "m" <.ws> <multipointm-text>         { make $<multipointm-text>.made;         } }
    regex multilinestringm-tagged-text    { :i "multilinestring"    <.ws>? "m" <.ws> <multilinestringm-text>    { make $<multilinestringm-text>.made;    } }
    regex multipolygonm-tagged-text       { :i "multipolygon"       <.ws>? "m" <.ws> <multipolygonm-text>       { make $<multipolygonm-text>.made;       } }
    regex geometrycollectionm-tagged-text { :i "geometrycollection" <.ws>? "m" <.ws> <geometrycollectionm-text> { make $<geometrycollectionm-text>.made; } }

    rule pointm-text { | <empty-set>
                        | '(' <pointm> ')' { make $<pointm>.made; }
                        | '[' <pointm> ']' { make $<pointm>.made; }
                      }
    rule linestringm-text { | <empty-set>
                             | '(' <pointm>+ % ',' ')' { make LineStringM.new(points => $<pointm>.map({.made})); }
                             | '[' <pointm>+ % ',' ']' { make LineStringM.new(points => $<pointm>.map({.made})); }
                           }
    rule linearringm-text { | <empty-set>
                             | '(' <pointm>+ % ',' ')' { make LinearRingM.new(points => $<pointm>.map({.made})); }
                             | '[' <pointm>+ % ',' ']' { make LinearRingM.new(points => $<pointm>.map({.made})); }
                           }
    rule polygon-textm { | <empty-set>
                          | '(' <linearringm-text>+ % ',' ')' { make PolygonM.new(rings => $<linearringm>.map({.made})); }
                          | '[' <linearringm-text>+ % ',' ']' { make PolygonM.new(rings => $<linearringm>.map({.made})); }
                        }
    rule polyhedralsurfacem-text { | <empty-set>
                                    | '(' <polygonm-text>+ % ',' ')' { make PolyhedralSurfaceM.new(polygons => $<polygonm-text>.map({.made})); }
                                    | '[' <polygonm-text>+ % ',' ']' { make PolyhedralSurfaceM.new(polygons => $<polygonm-text>.map({.made})); }

                                  }
    rule multipointm-text { | <empty-set>
                             | '(' <pointm-text>+ % ',' ')' { make MultiPointM.new(points => $<pointm-text>.map({.made})); }
                             | '[' <pointm-text>+ % ',' ']' { make MultiPointM.new(points => $<pointm-text>.map({.made})); }
                           }
    rule multilinestringm-text { | <empty-set>
                                  | '(' <linestringm-text>+ % ',' ')' { make MultiLineStringM.new(linestrings => $<linestringm-text>.map({.made})); }
                                  | '[' <linestringm-text>+ % ',' ']' { make MultiLineStringM.new(linestrings => $<linestringm-text>.map({.made})); }
                                }
    rule multipolygonm-text { | <empty-set>
                               | '(' <multipolygonm-text>+ % ',' ')' { make MultiPolygonM.new(polygons => $<multipolygonm-text>.map({.made})); }
                               | '[' <multipolygonm-text>+ % ',' ']' { make MultiPolygonM.new(polygons => $<multipolygonm-text>.map({.made})); }
                             }
    rule geometrycollectionm-text { | <empty-set>
                                     | '(' <geometrym-tagged-text>+ % ',' ')' { make GeometryCollectionM.new(geometries => $<geometrym-tagged-text>.map({.made})); }
                                     | '[' <geometrym-tagged-text>+ % ',' ']' { make GeometryCollectionM.new(geometries => $<geometrym-tagged-text>.map({.made})); }
                                 }
# The ZΜ variants
    
    rule pointzm { <value> <value> <value> <value> { make PointZM.new(x => $<value>[0].made.Num,
                                                                      y => $<value>[1].made.Num,
                                                                      z => $<value>[2].made.Num,
                                                                      m => $<value>[3].made.Num
                                                                     ); } }
    rule geometryzm-tagged-text {
        | <pointzm-tagged-text>              { make $<pointzm-tagged-text>.made;              }
        | <linestringzm-tagged-text>         { make $<linestringzm-tagged-text>.made;         }
        | <polygonzm-tagged-text>            { make $<polygonzm-tagged-text>.made;            }
        | <trianglezm-tagged-text>           { make $<trianglezm-tagged-text>.made;           }
        | <polyhedralsurfacezm-tagged-text>  { make $<polyhedralsurfacezm-tagged-text>.made;  }
        | <tinzm-tagged-text>                { make $<tinzm-tagged-text>.made;                }
        | <multipointzm-tagged-text>         { make $<multipointzm-tagged-text>.made;         }
        | <multilinestringzm-tagged-text>    { make $<multilinestringzm-tagged-text>.made;    }
        | <multipolygonzm-tagged-text>       { make $<multipolygonzm-tagged-text>.made;       }
        | <geometrycollectionzm-tagged-text> { make $<geometrycollectionzm-tagged-text>.made; }
    }
    
    regex pointzm-tagged-text              { :i "point"              <.ws>? "zm" <.ws> <pointzm-text>              { make $<pointzm-text>.made;              } }
    regex linestringzm-tagged-text         { :i "linestring"         <.ws>? "zm" <.ws> <linestringzm-text>         { make $<linestringzm-text>.made;         } }
    regex polygonzm-tagged-text            { :i "polygon"            <.ws>? "zm" <.ws> <polygonzm-text>            { make $<polygonzm-text>.made;            } }
    regex trianglezm-tagged-text           { :i "triangle"           <.ws>? "zm" <.ws> <trianglezm-text>           { make $<trianglezm-text>.made;           } }
    regex polyhedralsurfacezm-tagged-text  { :i "polyhedralsurface"  <.ws>? "zm" <.ws> <polyhedralsurfacezm-text>  { make $<polyhedralsurfacezm-text>.made;  } }
    regex tinzm-tagged-text                { :i "tin"                <.ws>? "zm" <.ws> <tinzm-text>                { make $<tinzm-text>.made;                } }
    regex multipointzm-tagged-text         { :i "multipoint"         <.ws>? "zm" <.ws> <multipointzm-text>         { make $<multipointzm-text>.made;         } }
    regex multilinestringzm-tagged-text    { :i "multilinestring"    <.ws>? "zm" <.ws> <multilinestringzm-text>    { make $<multilinestringzm-text>.made;    } }
    regex multipolygonzm-tagged-text       { :i "multipolygon"       <.ws>? "zm" <.ws> <multipolygonzm-text>       { make $<multipolygonzm-text>.made;       } }
    regex geometrycollectionzm-tagged-text { :i "geometrycollection" <.ws>? "zm" <.ws> <geometrycollectionzm-text> { make $<geometrycollectionzm-text>.made; } }

    rule pointzm-text { | <empty-set>
                        | '(' <pointzm> ')' { make $<pointzm>.made; }
                        | '[' <pointzm> ']' { make $<pointzm>.made; }
                      }
    rule linestringzm-text { | <empty-set>
                             | '(' <pointzm>+ % ',' ')' { make LineStringZM.new(points => $<pointzm>.map({.made})); }
                             | '[' <pointzm>+ % ',' ']' { make LineStringZM.new(points => $<pointzm>.map({.made})); }
                           }
    rule linearringzm-text { | <empty-set>
                             | '(' <pointzm>+ % ',' ')' { make LinearRingZM.new(points => $<pointzm>.map({.made})); }
                             | '[' <pointzm>+ % ',' ']' { make LinearRingZM.new(points => $<pointzm>.map({.made})); }
                           }
    rule polygon-textzm { | <empty-set>
                          | '(' <linearringzm-text>+ % ',' ')' { make PolygonZM.new(rings => $<linearringzm>.map({.made})); }
                          | '[' <linearringzm-text>+ % ',' ']' { make PolygonZM.new(rings => $<linearringzm>.map({.made})); }
                        }
    rule polyhedralsurfacezm-text { | <empty-set>
                                    | '(' <polygonzm-text>+ % ',' ')' { make PolyhedralSurfaceZM.new(polygons => $<polygonzm-text>.map({.made})); }
                                    | '[' <polygonzm-text>+ % ',' ']' { make PolyhedralSurfaceZM.new(polygons => $<polygonzm-text>.map({.made})); }

                                  }
    rule multipointzm-text { | <empty-set>
                             | '(' <pointzm-text>+ % ',' ')' { make MultiPointZM.new(points => $<pointzm-text>.map({.made})); }
                             | '[' <pointzm-text>+ % ',' ']' { make MultiPointZM.new(points => $<pointzm-text>.map({.made})); }
                           }
    rule multilinestringzm-text { | <empty-set>
                                  | '(' <linestringzm-text>+ % ',' ')' { make MultiLineStringZM.new(linestrings => $<linestringzm-text>.map({.made})); }
                                  | '[' <linestringzm-text>+ % ',' ']' { make MultiLineStringZM.new(linestrings => $<linestringzm-text>.map({.made})); }
                                }
    rule multipolygonzm-text { | <empty-set>
                               | '(' <multipolygonzm-text>+ % ',' ')' { make MultiPolygonZM.new(polygons => $<multipolygonzm-text>.map({.made})); }
                               | '[' <multipolygonzm-text>+ % ',' ']' { make MultiPolygonZM.new(polygons => $<multipolygonzm-text>.map({.made})); }
                             }
    rule geometrycollectionzm-text { | <empty-set>
                                     | '(' <geometryzm-tagged-text>+ % ',' ')' { make GeometryCollectionZM.new(geometries => $<geometryzm-tagged-text>.map({.made})); }
                                     | '[' <geometryzm-tagged-text>+ % ',' ']' { make GeometryCollectionZM.new(geometries => $<geometryzm-tagged-text>.map({.made})); }
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

my @examples = (
    'Point(10 10)',
    'LineString(10.01 10.3,20 20,30 50)',
    'LineString M (10.01 10.3 1.3,20 20 1.2,30 50 1.1)',
#    'Polygon((10 10.1,10 20.2,20 20.3,20 15.4,19 19))',
#    'MultiPoint((10.01 10.3),(20 20),(30 50))',
#    'MultiPoint((10 10),(20 20))',
#    'MultiPolygon(((10 10,10 20,20 20,20 15,10 10)),((60 60,70 70,80 60,60 60)))',
#    'MultiLineString((10 10,20 20),(15 15,30 15))',
#    'GeometryCollection(Point(10 10),Point(30 30),LineString(15 15,20 20))',
# FROM UK OS:
    'LineString M(4 1 2,4 2 1)',
    'LineStringM(4 1 2,4 2 1)',
    'LineStringZ(4 1 2,4 1 3)',
    'Point ZM (1 2 3 4)',
#    'LineStringZM(4 1 2 1,4 1 3 4)',
#    'MULTILINESTRING ZM ((464759.47000000003 1212349.74 0 -1.797693134862316e+308,464816.08 1212360.29 0 -1.797693134862316e+308))',
    'MULTILINESTRING ZM ((615254.6 153137.68 0 -1.7976e+308,615288.79 153175.44 0 -1.7976e+308,615338.17 153247.95 0 -1.7976e+308))',
);

use Test;

for @examples -> $ex {
    dd $ex;
    my $wkt = WKT.parse($ex).made;
    dd $wkt;
    is $ex.lc, $wkt.wkt.lc, 'roundtrip';
}


=begin pod
=TITLE Geo::Geometry
=head1 Geo::Geometry

A series of classes for storing geographic data.

This module is based on chapters 8 and 9 of the Open Geospatial Consortium's
I<OpenGISⓇ Implemantation Standard for Geographic Information - Simple Feature Access - part 1: Common architecture>.
This can be obtained from L<https://www.ogc.org/standards/sfa>.

=head1 Generic Methods

The following methods are available for most classes.
Classes for which they are not available are documented below.

=head2 type

The C<type> method returns a member of the C<WKBGeometryType> enum
corresponding to the geometry type.

=head2 Str

The C<Str> method returns a string representing the object.
Note that this is B<not> the WKT representation, which can be obtained
using the C<wkt> method described below.

=head2 wkb

The C<wkb> method will produce a C<Buf> object with the
well-known-binary representation of the object. An optional
named argument C<byteorder> parameter is available.
The value of the argument is one of the values of the
C<WKBByteOrder> enum.
The default value is C<wkbXDR> (little endian)
with the alternative being C<wkbNDR> (big endian).

=head2 wkt

The C<wkt> method returns a string containing the well-known text representation of the geometry.

=head2 tobuf

The C<tobuf> method is used internally; This interface may change without warning.

=head1 Subroutines

=head2 from-wkt

The C<from-wkt> subroutine takes a string as parameter
and returns a C<Geometry> object if the string contains
a WKT representation of a geometry.

=head2 from-wkb

The C<from-wkb> subroutine takes a Buf as parameter,
and returns a C<Geometry> object if the Buf contains
a WKΒ representation of a geometry.

=head1 Enums

Two enums are defined which represent values used
in the WKB representation of a geometry.

=head2 WKBByteOrder

The C<WKBByteOrder> enum gives the values used in the byte order field of a WKB representation. It contains two values C<wkbXDR> (0, little-endian) and C<wkbBDR> (1, big-endian).

=head2 WKBGeometryType

The C<WKBGeometryType> enum contains the values used in the geometry type filed of a WKB representation. It allows for the following values:

=begin table
    1 | wkbPoint
    2 | wkbLineString
    3 | wkbPolygon
    4 | wkbMultiPoint
    5 | wkbMultiLineString
    6 | wkbMultiPolygon
    7 | wkbGeometryCollection
   15 | wkbPolyhedralSurface
   16 | wkbTIN
   17 | wkbTriangle
 1001 | wkbPointZ
 1002 | wkbLineStringZ
 1003 | wkbPolygonZ
 1004 | wkbMultiPointZ
 1005 | wkbMultiLineStringZ
 1006 | wkbMultiPolygonZ
 1007 | wkbGeometryCollectionZ
 1015 | wkbPolyhedralSurfaceZ
 1016 | wkbTINZ
 1017 | wkbTriangleZ
 2001 | wkbPointM
 2002 | wkbLineStringM
 2003 | wkbPolygonM
 2004 | wkbMultiPointM
 2005 | wkbMultiLineStringM
 2006 | wkbMultiPolygonM
 2007 | wkbGeometryCollectionM
 2015 | wkbPolyhedralSurfaceM
 2016 | wkbTINM
 2017 | wkbTriangleM
 3001 | wkbPointZM
 3002 | wkbLineStringZM
 3003 | wkbPolygonZM
 3004 | wkbMultiPointZM
 3005 | wkbMultiLineStringZM
 3006 | wkbMultiPolygonZM
 3007 | wkbGeometryCollectionZM
 3015 | wkbPolyhedralSurfaceZM
 3016 | wkbTINZM
 3017 | wkbTriangleZM
=end table

=head1 Object types (classes)

=head2 Geometry

C<Geometry> is a role which all the other objects inherit.
It contains no methods, and is simply a marker that another class
is a Geometry type.

If you want to check whether a variable contains any of
the gemoetry classes, then code like
=begin code
  if $variable ~~ Geometry { ... }
=end code
can be useful.

=head2 Point
=head2 PointZ
=head2 PointM
=head2 PointZM

The C<Point> class represents a single point geometry.
It has two attributes, C<x> and C<y>, each of which is
constrained to be a 64-bit floating point number (C<num>).

The C<PointZ> class also contains a third attribute C<z>
to represent a third dimension.

The C<PointM> class, in addition to the C<X> and C<y>
attributes contains an C<m> attribute which can contain
an arbitrary "measure" in addition to the two-dimensionallocation.

The C<PointMZ> class combines the C<z> attribute of C<PointZ>
and the C<m> attribute of C<PointM>.

An object of each class may be constructed either by using
named parameters (C<<Point.new(x => 10, y => 12)>>,
or by using positional parameters (C<<PointZ.new(1,2,3)>>).
When positional parameters are used, the ordering of
the parameters is C<x>, C<y>, C<z>, C<m>;
omitting those parameters which are not appropriate
for the object type.

All the parameters of a point geometry are required.
C<NaN> might be used if an C<m> parameter for example
were not required.

Accessor methodes are available for the C<x>, C<y>, C<z> and C<m>.

=head2 LineString
=head2 LineStringZ
=head2 LineStringM
=head2 LineStringZM

The C<LineString> class represents a single line,
a sequence of C<Point>s, not necessarily closed.

Similarly, C<LineStringZ>, C<LineStringM> and C<LineStringZM>
are lines consisting of  sequences of C<PointZ>s, C<PointM>sand C<PointZM>s respectively.

An object in the LineString family is created by passing
an array of the appropriate point type geometries,
to the named argument C<points>.

At the moment there is no way of accessing the contents
of a LineString geometry other than using the standard methods.

An accessor method C<points> will give the constituent points.

=head2 LinearRing
=head2 LinearRingZ
=head2 LinearRingM
=head2 LinearRingZM

Objects in the LinearRing classes are not normally
intended for end users, apart from their use in creating
more complex objects. None of the usual methods apply to
these types of object.

A linear ring is similar to a line string, but is closed;
i.e. the last point should be identical to the first point.
This is not currently enforced, but may be in the future.
Creation of a linear ring is the same as that of a line string.
The ring should be simple; the path should not cross itself.
This is also not enforced.

Each of these classes has a C<winding> method.
This determines whether the linear ring is clockwise
(a positive number is returned) or anti-clockwise
(a negative number is returned).
This method will be unreliable unless the linear ring
actually is a simple closed loop.
The winding method ignores everything except the
C<x> and C<y> attributes.

An accessor method C<points> will give the constituent points.

=head2 Polygon
=head2 PolygonZ
=head2 PolygonM
=head2 PolygonZM

A C<Polygon> consists of one or more C<LinearRings>. In general, the first linear ring should be clockwise (with a positive winding number). The other linear rings should be fully enclosed within the first and be disjoint from each other. They should have a negative winding number. These rings represent a polygon (the first ring) and holes within that polygon, represented by the other rings. Having only a single ring specified is acceptable (and normal under most circumstances), representing a polygon without holes.

A C<Polygon> is created using an array of rings, such as C<<Polygon.new(rings => @rings)>>.

An accessor method C<rings> will give the constituent rings.

C<PolygonZ>, C<PolygonM> and C<PolygonZM> behave similarly.

=head2 Triangle
=head2 TriangleZ
=head2 TriangleM
=head2 TriangleZM

A triangle is a polygon where the outer ring has exactly four points,
the fourth being the same as the first and otherwise having no oints in common.
The points must not be in a straight line. No internal rings are permitted.

An accessor method C<rings> gives the constituent rings.

=head2 PolyhedralSurface
=head2 PolyhedralSurfaceZ
=head2 PolyhedralSurfaceM
=head2 PolyhedralSurfaceZM

A polyhedral surface is a set of contiguous non-overlapping polygons. (There are further restrictions.)

=head2 TIN
=head2 TINZ
=head2 TINM
=head2 TINZM

A triangular irregular network is a polyhedral surface consisting
only of triangles.

=head2 MultiPoint
=head2 MultiPointZ
=head2 MultiPointM
=head2 MultiPointZM

The MultiPoint classes behave just like LineStrings,
including their definition.
The difference is the intent of the object.
A LineString, as the name implies, forms a line.
A MultiPoint object is just a collection of points.

=head2 MultiLineString
=head2 MultiLineStringZ
=head2 MultiLineStringM
=head2 MultiLineStringZM

A C<MultiLineString> object contains an array of C<LineString>s.
It is created with that array:
=begin code
     MultiLineString.new(linestrings => @array-of-linestrings)
=end code
     
=head2 MultiPolygon
=head2 MultiPolygonZ
=head2 MultiPolygonM
=head2 MultiPolygonZM

Just as a C<MultiPoint> is a collections of C<Point>s, and a C<MultiLineString> is a collection of C<LineString>s, a C<MultiPolygon> is a collection of C<Polygon>s.

=head2 GeometryCollection
=head2 GeometryCollectionZ
=head2 GeometryCollectionM
=head2 GeometryCollectionZM

A GeometryCollection is an arbitrary collection of geometry objects.
Unlike a PointCollection, a LineStringCollection or a PolygonCollection,
the objects do not need to be of the same geometry type.

=end pod
