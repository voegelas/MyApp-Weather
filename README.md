# MyApp::Weather

A [Mojolicious](https://mojolicious.org/) web application that gets weather
forecasts from [MET Norway](https://api.met.no/) and produces web calendars in
the iCalendar data format.  Calendars can be subscribed from software such as
[Thunderbird](https://www.thunderbird.net/) and
[ICSx⁵](https://icsx5.bitfire.at/).

    env WEATHER_USER_AGENT='example.com support@example.com' \
        script/weather daemon -l http://localhost:3000
    curl http://localhost:3000/Oslo.ics

Calendar events have got a summary consisting of emojis and temperatures as
well as a longer description of the weather conditions.

    BEGIN:VEVENT
    UID:58d61e67800ce518ca9eef11d0347fa3e6ea3a68
    DTSTAMP:20211106T020745Z
    DTSTART;VALUE=DATE:20211107
    SUMMARY:🌫☀️ 6/-1°
    LOCATION:Oslo
    DESCRIPTION:00-05:   2° Fair\n05-10:   1° Fog\n10-12:   4° Partly clo
     udy\n12-18:   6° Clear sky\n18-22:   2° Clear sky\n22-24:  -1° Fair
    COMMENT:Based on data from MET Norway
    CLASS:PUBLIC
    TRANSP:TRANSPARENT
    X-SOGO-SEND-APPOINTMENT-NOTIFICATIONS:NO
    END:VEVENT

## DEPENDENCIES

Requires Perl 5.20, Mojolicious 9 and Role::Tiny.

## QUERY PARAMETERS

* lang

    * de (German)
    * en (English)
    * nb (Norwegian)

* temperature_unit

    * C (Celsius)
    * F (Fahrenheit)

Example:

    curl 'http://localhost:3000/Oslo.ics?lang=en&temperature_unit=F'

## CONFIGURATION

### Environment Variables

#### CACHE_DIRECTORY

Weather forecasts and locations are cached in this directory.  The directory
must exist and be writable.

#### LANG

The default weather forecast language.

#### REQUEST_BASE

The base path in the frontend proxy, e.g. /weather.  Empty by default.

#### TEMPERATURE_UNIT

The default temperature unit.

#### WEATHER_USER_AGENT

An identifying user agent string.  See https://api.met.no/doc/TermsOfService
and https://operations.osmfoundation.org/policies/nominatim/ for more
information.

## LICENSE AND COPYRIGHT

Copyright 2022 Andreas Vögele

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.

[MET Norway](https://www.met.no/) provides data under the [Norwegian Licence
for Open Government Data (NLOD) 2.0](https://data.norge.no/nlod/en/2.0/) and
[Creative Commons 4.0 BY International](http://creativecommons.org/licenses/by/4.0)
licenses.
