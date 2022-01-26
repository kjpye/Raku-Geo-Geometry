TITLE
=====

Geo::Geometry

Geo::Geometry
=============

A series of classes for storing geographic data

Generic Methods
===============

The following methods are available for most classes. Classes for which they are not available are documented below.

type
----

The `type` method returns a member of the WKBGeometryType enum corresponding to the geometry type.

Str
---

The `Str` method returns a string representing the object.

tobuf
-----

The `tobuf` method is used internally as part of generating the `wkb` output. It is probably not otherwise useful.

wkb
---

The `wkb` method will produce a `Buf` object with the well-known-binary representation of the object. An optional named argument `byteorder` parameter is available. The value of the argument is one of the values of the `WKBByteOrder` enum. The default value is `wkbXDR` (little endian) with the alternative being `wkbNDR` (big endian).

wkt
---

The `wkt` method returns a string containing the well-known text representation of the geometry.

Subroutines
===========

from-wkt
--------

The `from-wkt` subroutine takes a string as parameter and returns a `Geometry` object if the string contains a WKT represenation of a geometry.

from-wkb
--------

The `from-wkb` subroutine takes a Buf as parameter, and returns a `Geometry` object is the Buf contains a WKΒrepresentation of a geometry.

Object types (classes)
======================

Geometry
--------

An object in the `Geometry` class contains, in general, no attributes or methods, except as defined as below. It is a generic object which can contain any of the other geometry classes.

If you want to check whether a variable contains any of the gemoetry classes, then code like

      if $variable ~~ Geometry { ... }

can be useful.

Point
-----

PointZ
------

PointM
------

PointZM
-------

The `Point` class represents a single point geometry. It has two attributes, `x` and `y`, each of which is constrained to be a 64-bit floating point number (`num`).

The `PointZ` class also contains a third attribute `z` to represent a third dimension.

The `PointM` class, in addition to the `X` and `y` attributes contains an `m` attribute which can contain an arbitrary "measure" in addition to the two-dimensional location.

The `PointMZ` class combines the `z` attribute of `PointZ` and the `m` attribute of `PointM`.

An object of each class may be constructed either by using named parameters (`Point.new(x =` 10, y => 12)>, or by using positional parameters (`PointZ.new(1,2,3)`). When positional parameters are used, the ordering of the parameters is `x`, `y`, `z`, `m`; omitting those parameters which are not appropriate for the object type.

All the parameters of a point geometry are required. `NaN` might be used if an `m` parameter for example were not required.

LineString
----------

LineStringZ
-----------

LineStringM
-----------

LineStringZM
------------

The `LineString` class represents a single line, a sequence of `Point`s, not necessarily closed.

Similarly, `LineStringZ`, `LineStringM` and `LineStringZM` are lines consisting of sequences of `PointZ`s, `PointM`s and `PointZM`s respectively.

An object in the LineString family is created by passing an array of the appropriate point type geometries, to the named argument `points`.

At the moment there is no way of accessing the contents of a LineString geometry other than using the standard methods.

LinearRing
----------

LinearRingZ
-----------

LinearRingM
-----------

LinearRingZM
------------

Objects in the LinearRing classes are not normally intended for end users, apart from their use in creating more complex objects. None of the usual methods apply to these types of object. (There is a `tobuf` method, but it should not normally be used by end-user code; it is necessary for internal use.)

A linear ring is similar to a line string, but is closed; i.e. the last point should be identical to the first point. This is not currently enforced, but may be in the future. Creation of a linear ring is the same as that of a line string. The ring should be simple; the path should not cross itself. This is also not enforced.

Each of these classes has a `winding` method. This determines whether the linear ring is clockwise (a positive number is returned) or anti-clockwise (a negative number is returned). This method will be unreliable unless the linear ring actually is a simple closed loop. The winding method ignores everything except the `x` and `y` attributes.

Polygon
-------

PolygonZ
--------

PolygonM
--------

PolygonZM
---------

A `Polygon` consists of one or more `LinearRings`. In general, the first linear ring should be clockwise (with a positive winding number). The other linear rings should be fully enclosed within the first and be disjoint from each other. They should have a negative winding number. These rings represent a polygon (the first ring) and holes within that polygon, represented by the other rings. Having only a single ring specified is acceptable (and normal under most circumstances), representing a polygon without holes.

A `Polygon` is created using an array of rings, such as `Polygon.new(rings =` @rings)>.

`PolygonZ`, `PolygonM` and `PolygonZM` behave similarly.

Triangle
--------

TriangleZ
---------

TriangleM
---------

TriangleZM
----------

To be added.

PolyhedralSurface
-----------------

PolyhedralSurfaceZ
------------------

PolyhedralSurfaceM
------------------

PolyhedralSurfaceZM
-------------------

To be added.

TIN
---

TINZ
----

TINM
----

TINZM
-----

To be added.

MultiPoint
----------

MultiPointZ
-----------

MultiPointM
-----------

MultiPointZM
------------

The MultiPoint classes behave just like LineStrings, including their definition. The difference is the intent of the object. A LineString, as the name implies, forms a line. A MultiPoint object is just a collection of points.

MultiLineString
---------------

MultiLineStringZ
----------------

MultiLineStringM
----------------

MultiLineStringZM
-----------------

A `MultiLineString` object contains an array of `LineString`s. It is created with that array: `MultiLineString.new(linestrings =` @array-of-linestrings)>.

MultiPolygon
------------

MultiPolygonZ
-------------

MultiPolygonM
-------------

MultiPolygonZM
--------------

Just as a `MultiPoint` is a collections of `Point`s, and a `MultiLineString` is a collection of `LineString`s, a `MultiPolygon` is a collection of `Polygon`s.

GeometryCollection
------------------

GeometryCollectionZ
-------------------

GeometryCollectionM
-------------------

GeometryCollectionZM
--------------------

To be added.

