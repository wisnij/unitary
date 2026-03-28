## 1. Update predefined_worksheets.dart

- [x] 1.1 Length: insert `WorksheetRow(label: 'microns', expression: 'µm', kind: _unit)` as the first row
- [x] 1.2 Mass: insert `WorksheetRow(label: 'micrograms', expression: 'µg', kind: _unit)` as the first row
- [x] 1.3 Time: insert nanoseconds (`ns`) and microseconds (`µs`) before milliseconds; append centuries (`century`) after years
- [x] 1.4 Area: insert sq millimeters (`mm^2`) before sq centimeters; insert sq yards (`yd^2`) between sq feet and sq meters
- [x] 1.5 Speed: insert meters/minute (`m/min`) and inches/sec (`in/s`) at the front (before km/hour), in that order
- [x] 1.6 Pressure: insert millibars (`mbar`) after pascals, torr (`torr`) after mmHg, inches Hg (`inHg`) after kilopascals, megapascals (`MPa`) at the end
- [x] 1.7 Energy: change calories row label to `'small calories'` and expression to `'cal_th'`; change kilocalories row label to `'food Calories'`; insert watt-hours (`Wh`) between BTU and food Calories
- [x] 1.8 Digital Storage: interleave SI units between IEC units — insert kilobytes (`kB`) before KiB, megabytes (`MB`) before MiB, gigabytes (`GB`) before GiB, terabytes (`TB`) before TiB

## 2. Update tests

- [x] 2.1 Update the length template row-count scenario: expect 10 rows (was 9)
- [x] 2.2 Update the time template scenario: expect 10 rows with ns, µs, ms, s, min, hr, d, wk, year, century
- [x] 2.3 Add/update speed scenario: verify `m/min` and `in/s` are present
- [x] 2.4 Add/update energy scenario: verify `cal_th` row has label `'small calories'` and `kcal` row has label `'food Calories'`
- [x] 2.5 Add/update digital storage scenario: verify 10 rows with kB, KiB, MB, MiB, GB, GiB, TB, TiB all present
- [x] 2.6 Run `flutter test --reporter failures-only` and confirm all tests pass
- [x] 2.7 Run `flutter analyze` and confirm no lint errors
