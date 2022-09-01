[![Actions Status](https://github.com/kjpye/Raku-Geo-Geometry/actions/workflows/test.yml/badge.svg)](https://github.com/kjpye/Raku-Geo-Geometry/actions)

TITLE
=====

Geo::Geometry

`Geo::Geometry` is a group of modules for handling geographic data.

The included modules are

  * `Geo::Geometry`

  * `Geo::Geometry::WKB`

  * `Geo::Geometry::WKT`

  * `Geo::Geometry::WKT::Grammar`

These modules are based on chapters 8 and 9 of the Open Geospatial Consortium's *OpenGISⓇ Implemantation Standard for Geographic Information - Simple Feature Access - part 1: Common architecture*. This can be obtained from [https://www.ogc.org/standards/sfa](https://www.ogc.org/standards/sfa).

Geo::Geometry
=============

A series of classes for storing geographic data.

Generic Methods
---------------

The following methods are available for most classes. Classes for which they are not available are documented below.

### type

The `type` method returns a member of the `WKBGeometryType` enum corresponding to the geometry type.

### Str

The `Str` method returns a string representing the object. Note that this is **not** the WKT representation, which can be obtained using the `wkt` method described below.

### wkb

The `wkb` method will produce a `Buf` object with the well-known-binary representation of the object. An optional named argument `byteorder` parameter is available. The value of the argument is one of the values of the `WKBByteOrder` enum. The default value is `wkbXDR` (little endian) with the alternative being `wkbNDR` (big endian).

### wkt

The `wkt` method returns a string containing the well-known text representation of the geometry.

### tobuf

The `tobuf` method is used internally; This interface may change without warning.

Subroutines
-----------

### from-wkt

The `from-wkt` subroutine takes a string as parameter and returns a `Geometry` object if the string contains a WKT representation of a geometry.

### from-wkb

The `from-wkb` subroutine takes a Buf as parameter, and returns a `Geometry` object if the Buf contains a WKΒ representation of a geometry.

Enums
-----

Two enums are defined which represent values used in the WKB representation of a geometry.

### WKBByteOrder

The `WKBByteOrder` enum gives the values used in the byte order field of a WKB representation. It contains two values `wkbXDR` (0, little-endian) and `wkbBDR` (1, big-endian).

### WKBGeometryType

The `WKBGeometryType` enum contains the values used in the geometry type filed of a WKB representation. It allows for the following values:

<table class="pod-table">
<tbody>
<tr> <td>1</td> <td>wkbPoint</td> </tr> <tr> <td>2</td> <td>wkbLineString</td> </tr> <tr> <td>3</td> <td>wkbPolygon</td> </tr> <tr> <td>4</td> <td>wkbMultiPoint</td> </tr> <tr> <td>5</td> <td>wkbMultiLineString</td> </tr> <tr> <td>6</td> <td>wkbMultiPolygon</td> </tr> <tr> <td>7</td> <td>wkbGeometryCollection</td> </tr> <tr> <td>15</td> <td>wkbPolyhedralSurface</td> </tr> <tr> <td>16</td> <td>wkbTIN</td> </tr> <tr> <td>17</td> <td>wkbTriangle</td> </tr> <tr> <td>1001</td> <td>wkbPointZ</td> </tr> <tr> <td>1002</td> <td>wkbLineStringZ</td> </tr> <tr> <td>1003</td> <td>wkbPolygonZ</td> </tr> <tr> <td>1004</td> <td>wkbMultiPointZ</td> </tr> <tr> <td>1005</td> <td>wkbMultiLineStringZ</td> </tr> <tr> <td>1006</td> <td>wkbMultiPolygonZ</td> </tr> <tr> <td>1007</td> <td>wkbGeometryCollectionZ</td> </tr> <tr> <td>1015</td> <td>wkbPolyhedralSurfaceZ</td> </tr> <tr> <td>1016</td> <td>wkbTINZ</td> </tr> <tr> <td>1017</td> <td>wkbTriangleZ</td> </tr> <tr> <td>2001</td> <td>wkbPointM</td> </tr> <tr> <td>2002</td> <td>wkbLineStringM</td> </tr> <tr> <td>2003</td> <td>wkbPolygonM</td> </tr> <tr> <td>2004</td> <td>wkbMultiPointM</td> </tr> <tr> <td>2005</td> <td>wkbMultiLineStringM</td> </tr> <tr> <td>2006</td> <td>wkbMultiPolygonM</td> </tr> <tr> <td>2007</td> <td>wkbGeometryCollectionM</td> </tr> <tr> <td>2015</td> <td>wkbPolyhedralSurfaceM</td> </tr> <tr> <td>2016</td> <td>wkbTINM</td> </tr> <tr> <td>2017</td> <td>wkbTriangleM</td> </tr> <tr> <td>3001</td> <td>wkbPointZM</td> </tr> <tr> <td>3002</td> <td>wkbLineStringZM</td> </tr> <tr> <td>3003</td> <td>wkbPolygonZM</td> </tr> <tr> <td>3004</td> <td>wkbMultiPointZM</td> </tr> <tr> <td>3005</td> <td>wkbMultiLineStringZM</td> </tr> <tr> <td>3006</td> <td>wkbMultiPolygonZM</td> </tr> <tr> <td>3007</td> <td>wkbGeometryCollectionZM</td> </tr> <tr> <td>3015</td> <td>wkbPolyhedralSurfaceZM</td> </tr> <tr> <td>3016</td> <td>wkbTINZM</td> </tr> <tr> <td>3017</td> <td>wkbTriangleZM</td> </tr>
</tbody>
</table>

Object types (classes)
----------------------

### Geometry

`Geometry` is a role which all the other objects inherit. It contains no methods, and is simply a marker that another class is a Geometry type.

If you want to check whether a variable contains any of the geometry classes, then code like

      if $variable ~~ Geometry { ... }

can be useful.

### Point

### PointZ

### PointM

### PointZM

The `Point` class represents a single point geometry. It has two attributes, `x` and `y`, each of which is constrained to be a 64-bit floating point number (`num`).

The `PointZ` class also contains a third attribute `z` to represent a third dimension.

The `PointM` class, in addition to the `X` and `y` attributes contains an `m` attribute which can contain an arbitrary "measure" in addition to the two-dimensionallocation.

The `PointMZ` class combines the `z` attribute of `PointZ` and the `m` attribute of `PointM`.

An object of each class may be constructed either by using named parameters (`Point.new(x => 10, y => 12)`, or by using positional parameters (`PointZ.new(1,2,3)`). When positional parameters are used, the ordering of the parameters is `x`, `y`, `z`, `m`; omitting those parameters which are not appropriate for the object type.

All the parameters of a point geometry are required. `NaN` might be used if an `m` parameter for example were not required.

Accessor methodes are available for the `x`, `y`, `z` and `m`.

LineString
----------

LineStringZ
-----------

LineStringM
-----------

LineStringZM
------------

The `LineString` class represents a single line, a sequence of `Point`s, not necessarily closed.

Similarly, `LineStringZ`, `LineStringM` and `LineStringZM` are lines consisting of sequences of `PointZ`s, `PointM`sand `PointZM`s respectively.

An object in the LineString family is created by passing an array of the appropriate point type geometries, to the named argument `points`.

At the moment there is no way of accessing the contents of a LineString geometry other than using the standard methods.

An accessor method `points` will give the constituent points.

### LinearRing

### LinearRingZ

### LinearRingM

### LinearRingZM

Objects in the LinearRing classes are not normally intended for end users, apart from their use in creating more complex objects. None of the usual methods apply to these types of object.

A linear ring is similar to a line string, but is closed; i.e. the last point should be identical to the first point. This is not currently enforced, but may be in the future. Creation of a linear ring is the same as that of a line string. The ring should be simple; the path should not cross itself. This is also not enforced.

Each of these classes has a `winding` method. This determines whether the linear ring is clockwise (a positive number is returned) or anti-clockwise (a negative number is returned). This method will be unreliable unless the linear ring actually is a simple closed loop. The winding method ignores everything except the `x` and `y` attributes.

An accessor method `points` will give the constituent points.

### Polygon

### PolygonZ

### PolygonM

### PolygonZM

A `Polygon` consists of one or more `LinearRings`. In general, the first linear ring should be clockwise (with a positive winding number). The other linear rings should be fully enclosed within the first and be disjoint from each other. They should have a negative winding number. These rings represent a polygon (the first ring) and holes within that polygon, represented by the other rings. Having only a single ring specified is acceptable (and normal under most circumstances), representing a polygon without holes.

A `Polygon` is created using an array of rings, such as `Polygon.new(rings => @rings)`.

An accessor method `rings` will give the constituent rings.

`PolygonZ`, `PolygonM` and `PolygonZM` behave similarly.

### Triangle

### TriangleZ

### TriangleM

### TriangleZM

A triangle is a polygon where the outer ring has exactly four points, the fourth being the same as the first and otherwise having no oints in common. The points must not be in a straight line. No internal rings are permitted.

An accessor method `rings` gives the constituent rings.

### PolyhedralSurface

### PolyhedralSurfaceZ

### PolyhedralSurfaceM

### PolyhedralSurfaceZM

A polyhedral surface is a set of contiguous non-overlapping polygons. (There are further restrictions.)

### TIN

### TINZ

### TINM

### TINZM

A triangular irregular network is a polyhedral surface consisting only of triangles.

### MultiPoint

### MultiPointZ

### MultiPointM

### MultiPointZM

The MultiPoint classes behave just like LineStrings, including their definition. The difference is the intent of the object. A LineString, as the name implies, forms a line. A MultiPoint object is just a collection of points.

### MultiLineString

### MultiLineStringZ

### MultiLineStringM

### MultiLineStringZM

A `MultiLineString` object contains an array of `LineString`s. It is created with that array:

         MultiLineString.new(linestrings => @array-of-linestrings)

### MultiPolygon

### MultiPolygonZ

### MultiPolygonM

### MultiPolygonZM

Just as a `MultiPoint` is a collections of `Point`s, and a `MultiLineString` is a collection of `LineString`s, a `MultiPolygon` is a collection of `Polygon`s.

### GeometryCollection

### GeometryCollectionZ

### GeometryCollectionM

### GeometryCollectionZM

A GeometryCollection is an arbitrary collection of geometry objects. Unlike a PointCollection, a LineStringCollection or a PolygonCollection, the objects do not need to be of the same geometry type.

Geo::Geometry::WKB
==================

The `Geo::Geometry::WKB` module contains a single function:

from-wkb
--------

`from-wkb` takes a single `Buf` parameter, and returns a single `Geo::Geometry` object corresponding to the wkb specification, or a `Failure` if the contents of the Buff cannot be interpreted as a geometry object.

