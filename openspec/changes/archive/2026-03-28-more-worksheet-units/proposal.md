## Why

The initial worksheet templates fill out to 10 units for Volume but leave 7 of the other 9
templates short of that mark (gaps range from 1 to 4 rows).  Bringing every template up to 10
units before the first release makes the worksheets feel complete and consistent, and avoids
needing a follow-up update immediately after launch.

## What Changes

- **Length** (+1): add microns (`µm`)
- **Mass** (+1): add micrograms (`µg`)
- **Time** (+3): add nanoseconds (`ns`), microseconds (`µs`), centuries (`century`)
- **Temperature**: no change — only 5 temperature scale functions exist in the unit database
  (K, °C, °F, °Ré, Rankine); adding obscure historical scales would not be useful
- **Area** (+2): add sq millimeters (`mm^2`), sq yards (`yd^2`)
- **Speed** (+2): add meters/minute (`m/min`), inches/sec (`in/s`)
- **Pressure** (+4): add megapascals (`MPa`), inches Hg (`inHg`), millibars (`mbar`), torr (`torr`)
- **Energy** (+1): add watt-hours (`Wh`); rename existing "calories" row to "small calories" with
  expression `cal_th`; rename existing "kilocalories" row to "food Calories"
- **Digital Storage** (+4): add kilobytes (`kB`), megabytes (`MB`), gigabytes (`GB`), terabytes (`TB`)
  — these are the SI (decimal) counterparts to the existing IEC binary rows, making
  the worksheet useful for understanding the binary/decimal distinction

All proposed units are already present in the unit database (as registered units or via SI
prefix resolution).

## Capabilities

### New Capabilities

*(none — this change extends existing templates only)*

### Modified Capabilities

- `worksheet-templates`: row lists for 8 of the 10 predefined templates are changing

## Impact

- `lib/features/worksheet/data/predefined_worksheets.dart` — only file that changes
- No model, engine, or state changes required
- Test coverage: existing worksheet engine tests cover the conversion logic; new snapshot/count
  tests for the updated row lists will be added
