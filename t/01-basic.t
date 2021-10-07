use Test;
use lib 'lib';

use Geo::Coordinates;

my $p  = Point.new(10, 20);
my $z  = PointZ.new(10, 20, 30);
my $m  = PointM.new(10, 20, 30);
my $zm = PointZM.new(10, 20, 30, 40);

is        $p.wkt.lc,                    'point(10 20)',                                                                                'point wkt';
is-deeply $p.wkb(byteorder => wkbNDR),  Buf.new(1,0,0,0,1,64,36,0,0,0,0,0,0,64,52,0,0,0,0,0,0),                                        'point wkb.be';
is-deeply $p.wkb(byteorder => wkbXDR),  Buf.new(0,1,0,0,0,0,0,0,0,0,0,36,64,0,0,0,0,0,0,52,64),                                        'point wkb.le';
is        $z.wkt.lc,                    'pointz(10 20 30)',                                                                            'pointz wkt';
is-deeply $z.wkb(byteorder => wkbNDR),  Buf.new(1,0,0,3,233,64,36,0,0,0,0,0,0,64,52,0,0,0,0,0,0,64,62,0,0,0,0,0,0),                    'pointz wkb.be';
is-deeply $z.wkb(byteorder => wkbXDR),  Buf.new(0,233,3,0,0,0,0,0,0,0,0,36,64,0,0,0,0,0,0,52,64,0,0,0,0,0,0,62,64),                    'pointz wkb.le';
is        $m.wkt.lc,                    'pointm(10 20 30)',                                                                            'pointm wkt';
is-deeply $m.wkb(byteorder => wkbNDR),  Buf.new(1,0,0,7,209,64,36,0,0,0,0,0,0,64,52,0,0,0,0,0,0,64,62,0,0,0,0,0,0),                    'pointm wkb.be';
is-deeply $m.wkb(byteorder => wkbXDR),  Buf.new(0,209,7,0,0,0,0,0,0,0,0,36,64,0,0,0,0,0,0,52,64,0,0,0,0,0,0,62,64),                    'pointm wkb.le';
is        $zm.wkt.lc,                   'pointzm(10 20 30 40)',                                                                        'pointzm wkt';
is-deeply $zm.wkb(byteorder => wkbNDR), Buf.new(1,0,0,11,185,64,36,0,0,0,0,0,0,64,52,0,0,0,0,0,0,64,62,0,0,0,0,0,0,64,68,0,0,0,0,0,0), 'pointzm wkb.be';
is-deeply $zm.wkb(byteorder => wkbXDR), Buf.new(0,185,11,0,0,0,0,0,0,0,0,36,64,0,0,0,0,0,0,52,64,0,0,0,0,0,0,62,64,0,0,0,0,0,0,68,64), 'pointzm wkb.le';
is from-wkb($p.wkb(byteorder => wkbNDR)), $p, 'from-wkb point be';
is from-wkb($p.wkb(byteorder => wkbXDR)), $p, 'from-wkb point le';
my @points;
@points.push: Point.new(1,2);
@points.push: Point.new(3,4);

my $ls = LineString.new(points => @points);

is        $ls.wkt.lc,
          'linestring(1 2,3 4)',
          'linestring wkt';
is-deeply $ls.wkb(byteorder => wkbNDR),
          Buf.new(1,0,0,0,2,0,0,0,2,63,240,0,0,0,0,0,0,64,0,0,0,0,0,0,0,64,8,0,0,0,0,0,0,64,16,0,0,0,0,0,0),
          'linestring wkb.be';
is-deeply $ls.wkb(byteorder => wkbXDR),
          Buf.new(0,2,0,0,0,2,0,0,0,0,0,0,0,0,0,240,63,0,0,0,0,0,0,0,64,0,0,0,0,0,0,8,64,0,0,0,0,0,0,16,64),
          'linestring wkb.le';
is from-wkb($ls.wkb(byteorder => wkbNDR)), $ls, 'from-wkb linestring be';
is from-wkb($ls.wkb(byteorder => wkbXDR)), $ls, 'from-wkb linestring le';

my @pointsZ;
@pointsZ.push: PointZ.new(1, 2, 11);
@pointsZ.push: PointZ.new(3, 4, 12);

my $lsz = LineStringZ.new(points => @pointsZ);
is        $lsz.wkt.lc, 'linestringz(1 2 11,3 4 12)', 'linestringz wkt';
is-deeply $lsz.wkb(byteorder => wkbNDR),
          Buf.new(1,0,0,3,234,0,0,0,2,63,240,0,0,0,0,0,0,64,0,0,0,0,0,0,0,64,38,0,0,0,0,0,0,64,8,0,0,0,0,0,0,64,16,0,0,0,0,0,0,64,40,0,0,0,0,0,0),
          'linestringz wkb.be';
is-deeply $lsz.wkb,
          Buf.new(0,234,3,0,0,2,0,0,0,0,0,0,0,0,0,240,63,0,0,0,0,0,0,0,64,0,0,0,0,0,0,38,64,0,0,0,0,0,0,8,64,0,0,0,0,0,0,16,64,0,0,0,0,0,0,40,64),
          'linestringz wkb.le';
is from-wkb($lsz.wkb(byteorder => wkbNDR)), $lsz, 'from-wkb linestringz be';
is from-wkb($lsz.wkb(byteorder => wkbXDR)), $lsz, 'from-wkb linestringz le';

my $lr = LinearRing.new(points => @points);
my $py = Polygon.new(rings => @($lr));
is        $py.wkt.lc,
          'polygon((1 2,3 4))',
          'polygon wkt';
is-deeply $py.wkb(byteorder => wkbNDR),
          Buf.new(1,0,0,0,3,0,0,0,1,0,0,0,2,63,240,0,0,0,0,0,0,64,0,0,0,0,0,0,0,64,8,0,0,0,0,0,0,64,16,0,0,0,0,0,0),
          'polygon wkb.be';
is-deeply $py.wkb(byteorder => wkbXDR),
          Buf.new(0,3,0,0,0,1,0,0,0,2,0,0,0,0,0,0,0,0,0,240,63,0,0,0,0,0,0,0,64,0,0,0,0,0,0,8,64,0,0,0,0,0,0,16,64),
          'polygon wkb.le';
is from-wkb($py.wkb(byteorder => wkbNDR)), $py, 'from-wkb polygon be';
is from-wkb($py.wkb(byteorder => wkbXDR)), $py, 'from-wkb polygon le';

my @examples = (
    'Point (10 10)',
    'LineString ( 10.01 10.3, 20 20.0, 30 50)',
    'Polygon ((10 10.1, 10 20.2, 20 20.3, 20 15.4, 19 19))',
    'MultiPoint ( (10.01 10.3), (20 20.0), (30 50))',
    'MultiPoint ((10 10), (20 20))',
    'MultiPolygon ( ((10 10, 10 20, 20 20, 20 15, 10 10)), ((60 60, 70 70, 80 60, 60 60 )) )',
    'MultiLineString ( (10 10, 20 20), (15 15, 30 15) )',
    'GeometryCollection ( POINT (10 10), POINT (30 30), LINESTRING (15 15, 20 20) )',
);

for @examples -> $ex {
    my $wkt = WKT.parse($ex).made;
    dd $wkt;
    dd $wkt.wkt;
    note '';
}

done-testing;
