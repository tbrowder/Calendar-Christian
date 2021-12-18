[![Actions Status](https://github.com/tbrowder/Date-Liturgical-Christian/workflows/test/badge.svg)](https://github.com/tbrowder/Date-Liturgical-Christian/actions)

NAME
====

Date::Liturgical::Christian - Dates of the Christian church year

SYNOPSIS
========

```raku
use Date::Liturgical::Christian;
```

DESCRIPTION
===========

**Date::Liturgical::Christian** is a Raku port of the Perl CPAN module *DateTime::Calendar::Liturgical::Christian*. It is a child class of the Raku Date class.

**IMPORTANT NOTE** The Perl module is designed for the ECUSA tradition, but this Raku module is designed only for the United Methodist Church (UMC) tradition. The ECUSA tradition in this module cannot be supported until this author has some questions answered by the original Perl author or until he has access to authoritative documentation from the ECUSA.

This module will return the name, season, week number and liturgical color for any day in the Gregorian calendar. It may eventually support the liturgical calendars of other churches (but only if their is any interest shown by any users). At present it only knows the calendar for the United Methodist Church.

If you find bugs, or if you have information on the calendar of another liturgical church, please file an issue or contact the author directly.

OVERVIEW
========

Some churches use a special church calendar. Days and seasons within the year may be either "fasts" (solemn times) or "feasts" (joyful times). The year is structured around the greatest feast in the calendar, the festival of the Resurrection of Jesus, known as Easter, and the second greatest feast, the festival of the Nativity of Jesus, known as Christmas. Before Christmas and Easter there are solemn fast seasons known as Advent and Lent, respectively. After Christmas comes the feast of Epiphany, and after Easter comes the feast of Pentecost. These days have the adjacent seasons named after them.

The church's new year falls on Advent Sunday, which occurs around the start of December. Then follows the four-week fast season of Advent, then comes the Christmas season, which lasts twelve days; then comes Epiphany, then the forty days of Lent. Then comes Easter, then the long season of Pentecost (which some churches call Trinity, after the feast which falls soon after Pentecost). Then the next year begins and we return to Advent again.

Along with all these, the church remembers the women and men who have made a positive difference in church history by designating feast days for them, usually on the anniversary of their death. For example, we remember St. Andrew on the 30th day of November in the Western churches. Every Sunday is the feast day of Jesus, and if it has no other name is numbered according to the season in which it falls. So, for example, the third Sunday in Pentecost season would be called Pentecost 3.

Seasons are traditionally assigned colors, which are used for clothing and other materials. The major feasts are colored white or gold. Fasts are purple. Feasts for martyrs (people who died for their faith) are red. Other days are green.

CONSTRUCTOR
===========

  * new ([ OPTIONS ])

This constructs a DateTime::Calendar::Liturgical::Christian object. It takes a series of named options. Possible options are:

**year** (required). The year AD in the Gregorian calendar.

**month** (required). The month number in the Gregorian calendar. 1 is January.

**day** (required). The day of the month.

**tradition** (recommended). The tradition to use. Currently only `UMC` is known.

METHODS
=======

  * name

Returns the name of the feast, if any.

  * season

Returns the season.

  * color

Returns the color of the day. Can be `red`, `green`, `white`, or `purple`, or `blue` or `rose` if the relevant options are set.

  * day

Returns the day number which was used to construct the object.

  * month

Returns the month number which was used to construct the object.

  * year

Returns the year number which was used to construct the object.

AUTHORS
=======

  * Tom Browder <tbrowder@acm.org>

  * Thomas Thurman <thomas@thurman.org.uk> [Perl]

COPYRIGHT AND LICENSE
=====================

  * Copyright © 2021 Tom Browder

  * Copyright © 2006 Thomas Thurman

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

