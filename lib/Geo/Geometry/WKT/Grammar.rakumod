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
    
    rule point { <value> <value> } # external action required
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
                             | '(' <point>+ % ',' ')' # external action required
                             | '[' <point>+ % ',' ']' # external action required
                           }
    rule linearring-text { | <empty-set>
                             | '(' <point>+ % ',' ')' # external action required
                             | '[' <point>+ % ',' ']' # external action required
                           }
    rule polygon-text { | <empty-set>
                          | '(' <linearring-text>+ % ',' ')' # external action required
                          | '[' <linearring-text>+ % ',' ']' # external action required
                        }
    rule polyhedralsurface-text { | <empty-set>
                                    | '(' <polygon-text>+ % ',' ')' # external action required
                                    | '[' <polygon-text>+ % ',' ']' # external action required

                                  }
    rule multipoint-text { | <empty-set>
                             | '(' <point-text>+ % ',' ')' # external action required
                             | '[' <point-text>+ % ',' ']' # external action required
                           }
    rule multilinestring-text { | <empty-set>
                                  | '(' <linestring-text>+ % ',' ')' # external action required
                                  | '[' <linestring-text>+ % ',' ']' # external action required
                                }
    rule multipolygon-text { | <empty-set>
                               | '(' <multipolygon-text>+ % ',' ')' # external action required
                               | '[' <multipolygon-text>+ % ',' ']' # external action required
                             }
    rule geometrycollection-text { | <empty-set>
                                     | '(' <geometry-tagged-text>+ % ',' ')' # 3external action required
                                     | '[' <geometry-tagged-text>+ % ',' ']' # external action required
                                 }
# The Z variants
    
    rule pointz { <value> <value> <value> } # external action required
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
                             | '(' <pointz>+ % ',' ')' # external action required
                             | '[' <pointz>+ % ',' ']' # external action required
                           }
    rule linearringz-text { | <empty-set>
                             | '(' <pointz>+ % ',' ')' # external action required
                             | '[' <pointz>+ % ',' ']' # external action required
                           }
    rule polygon-textz { | <empty-set>
                          | '(' <linearringz-text>+ % ',' ')' # external action required
                          | '[' <linearringz-text>+ % ',' ']' # external action required
                        }
    rule polyhedralsurfacez-text { | <empty-set>
                                    | '(' <polygonz-text>+ % ',' ')' # external action required
                                    | '[' <polygonz-text>+ % ',' ']' # external action required

                                  }
    rule multipointz-text { | <empty-set>
                             | '(' <pointz-text>+ % ',' ')' # external action required
                             | '[' <pointz-text>+ % ',' ']' # external action required
                           }
    rule multilinestringz-text { | <empty-set>
                                  | '(' <linestringz-text>+ % ',' ')' # external action required
                                  | '[' <linestringz-text>+ % ',' ']' # external action required
                                }
    rule multipolygonz-text { | <empty-set>
                               | '(' <multipolygonz-text>+ % ',' ')' # external action required
                               | '[' <multipolygonz-text>+ % ',' ']' # external action required
                             }
    rule geometrycollectionz-text { | <empty-set>
                                     | '(' <geometryz-tagged-text>+ % ',' ')' # external action required
                                     | '[' <geometryz-tagged-text>+ % ',' ']' # external action required
                                 }
# The Μ variants
    
    rule pointm { <value> <value> <value> } # external action required
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
                             | '(' <pointm>+ % ',' ')' # external action required
                             | '[' <pointm>+ % ',' ']' # external action required
                           }
    rule linearringm-text { | <empty-set>
                             | '(' <pointm>+ % ',' ')' # external action required
                             | '[' <pointm>+ % ',' ']' # external action required
                           }
    rule polygon-textm { | <empty-set>
                          | '(' <linearringm-text>+ % ',' ')' # external action required
                          | '[' <linearringm-text>+ % ',' ']' # external action required
                        }
    rule polyhedralsurfacem-text { | <empty-set>
                                    | '(' <polygonm-text>+ % ',' ')' # external action required
                                    | '[' <polygonm-text>+ % ',' ']' # external action required

                                  }
    rule multipointm-text { | <empty-set>
                             | '(' <pointm-text>+ % ',' ')' # external action required
                             | '[' <pointm-text>+ % ',' ']' # external action required
                           }
    rule multilinestringm-text { | <empty-set>
                                  | '(' <linestringm-text>+ % ',' ')' # external action required
                                  | '[' <linestringm-text>+ % ',' ']' # external action required
                                }
    rule multipolygonm-text { | <empty-set>
                               | '(' <multipolygonm-text>+ % ',' ')' # external action required
                               | '[' <multipolygonm-text>+ % ',' ']' # external action required
                             }
    rule geometrycollectionm-text { | <empty-set>
                                     | '(' <geometrym-tagged-text>+ % ',' ')' # external action required
                                     | '[' <geometrym-tagged-text>+ % ',' ']' # external action required
                                 }
# The ZΜ variants
    
    rule pointzm { <value> <value> <value> <value> } # external action required

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
                             | '(' <pointzm>+ % ',' ')' # external action required
                             | '[' <pointzm>+ % ',' ']' # external action required
                           }
    rule linearringzm-text { | <empty-set>
                             | '(' <pointzm>+ % ',' ')' # external action required
                             | '[' <pointzm>+ % ',' ']' # external action required
                           }
    rule polygon-textzm { | <empty-set>
                          | '(' <linearringzm-text>+ % ',' ')' # external action required
                          | '[' <linearringzm-text>+ % ',' ']' # external action required
                        }
    rule polyhedralsurfacezm-text { | <empty-set>
                                    | '(' <polygonzm-text>+ % ',' ')' # external action required
                                    | '[' <polygonzm-text>+ % ',' ']' # external action required

                                  }
    rule multipointzm-text { | <empty-set>
                             | '(' <pointzm-text>+ % ',' ')' # external action required
                             | '[' <pointzm-text>+ % ',' ']' # external action required
                           }
    rule multilinestringzm-text { | <empty-set>
                                  | '(' <linestringzm-text>+ % ',' ')' # external action required
                                  | '[' <linestringzm-text>+ % ',' ']' # external action required
                                }
    rule multipolygonzm-text { | <empty-set>
                               | '(' <multipolygonzm-text>+ % ',' ')' # external action required
                               | '[' <multipolygonzm-text>+ % ',' ']' # external action required
                             }
    rule geometrycollectionzm-text { | <empty-set>
                                     | '(' <geometryzm-tagged-text>+ % ',' ')' # external action required
                                     | '[' <geometryzm-tagged-text>+ % ',' ']' # external action required
                                 }
}

