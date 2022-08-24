class WKT-Actions {

# Point
    method point($/) {
        make Point.new(x => $<value>[0].made.Num,
                       y => $<value>[1].made.Num
                      );
    }
    method pointz($/) {
        make PointZ.new(x => $<value>[0].made.Num,
                        y => $<value>[1].made.Num,
                        z => $<value>[2].made.Num
                       );
    }
    method pointm($/) {
        make PointM.new(x => $<value>[0].made.Num,
                        y => $<value>[1].made.Num,
                        m => $<value>[2].made.Num
                       );
    }
    method pointzm($/) {
        make PointZM.new(x => $<value>[0].made.Num,
                         y => $<value>[1].made.Num,
                         z => $<value>[2].made.Num,
                         m => $<value>[3].made.Num
                        );
    }

# LineString
    method linestring-text($/) {
        make LineString.new(points => $<point>.map({.made}));
    }
    method linestringz-text($/) {
        make LineString.new(points => $<pointz>.map({.made}));
    }
    method linestringm-text($/) {
        make LineString.new(points => $<pointm>.map({.made}));
    }
    method linestringzm-text($/) {
        make LineString.new(points => $<pointzm>.map({.made}));
    }

# LinearRing
    method linearring-text($/) {
        make LinearRing.new(points => $<point>.map({.made}));
    }
    method linearringz-text($/) {
        make LinearRing.new(points => $<pointz>.map({.made}));
    }
    method linearringm-text($/) {
        make LinearRing.new(points => $<pointm>.map({.made}));
    }
    method linearringzm-text($/) {
        make LinearRing.new(points => $<pointzm>.map({.made}));
    }

# Polygon
    method polygon-text($/) {
        make Polygon.new(rings => $<linearring>.map({.made}));
    }
    method polygonz-text($/) {
        make PolygonZ.new(rings => $<linearring>.map({.made}));
    }
    method polygonm-text($/) {
        make PolygonM.new(rings => $<linearring>.map({.made}));
    }
    method polygonzm-text($/) {
        make PolygonZM.new(rings => $<linearring>.map({.made}));
    }

# PolyhedralSurface
    method polyhedralsurface-text($/) {
        make PolyhedralSurface.new(polygons => $<polygon>.map({.made}));
    }
    method polyhedralsurfacez-text($/) {
        make PolyhedralSurfaceZ.new(polygons => $<polygon>.map({.made}));
    }
    method polyhedralsurfacem-text($/) {
        make PolyhedralSurfaceM.new(polygons => $<polygon>.map({.made}));
    }
    method polyhedralsurfacezm-text($/) {
        make PolyhedralSurfaceZM.new(polygons => $<polygon>.map({.made}));
    }

# MultiPoint
    method multipoint-text($/) {
        make MultiPoint.new(points => $<point>.map({.made}));
    }
    method multipointz-text($/) {
        make MultiPointZ.new(points => $<point>.map({.made}));
    }
    method multipointm-text($/) {
        make MultiPointM.new(points => $<point>.map({.made}));
    }
    method multipointzm-text($/) {
        make MultiPointZM.new(points => $<point>.map({.made}));
    }

# MultiLineString
    method multilinestring-text($/) {
        make MultLineString.new(linestrings => $<linestring>.map({.made}));
    }
    method multilinestringz-text($/) {
        make MultLineStringZ.new(linestrings => $<linestring>.map({.made}));
    }
    method multilinestringm-text($/) {
        make MultLineStringM.new(linestrings => $<linestring>.map({.made}));
    }
    method multilinestringzm-text($/) {
        make MultLineStringZM.new(linestrings => $<linestring>.map({.made}));
    }

# MultiPolygon    
    method multipolygon-text($/) {
        make MultiPolygon.new(polygons => $<polygon>.map({.made}));
    }
    method multipolygonz-text($/) {
        make MultiPolygonZ.new(polygons => $<polygon>.map({.made}));
    }
    method multipolygonm-text($/) {
        make MultiPolygonM.new(polygons => $<polygon>.map({.made}));
    }
    method multipolygonzm-text($/) {
        make MultiPolygonZM.new(polygons => $<polygon>.map({.made}));
    }

# GeometryCollection
    method geometrycollection-text($/) {
        make GeometryCollection.new(geometries => $<geometry>.map({.made}));
    }
    method geometrycollectionz-text($/) {
        make GeometryCollectionZ.new(geometries => $<geometry>.map({.made}));
    }
    method geometrycollectionm-text($/) {
        make GeometryCollectionM.new(geometries => $<geometry>.map({.made}));
    }
    method geometrycollectionzm-text($/) {
        make GeometryCollectionZM.new(geometries => $<geometry>.map({.made}));
    }
}

our sub from-wkt(Str $s) {
    WKT.parse($s, actions => WKT-actions).made;
}
