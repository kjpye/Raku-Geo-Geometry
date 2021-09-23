class Point {
  has $!x;
  has $!y;
  method new($x, $y) { self.bless(:$x, :$y) }
}

class PointZ {
  has $!x;
  has $!y;
  has $!z;
  method new($x, $y, $z) { self.bless(:$x, :$y, :$z) }
}

class PointM {
  has $!x;
  has $!y;
  has $!m;
  method new($x, $y, $m) { self.bless(:$x, :$y, :$m) }
}

class PointZM {
  has $!x;
  has $!y;
  has $!z;
  has $!m;
  method new($x, $y, $z, $m) { self.bless(:$x, :$y, :$z, :$m) }
}
