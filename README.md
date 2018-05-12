# PB Seeker

A free data field for the Garmin running watches designed to help with attempts at personal best times.

## Release Plan
This data field has not yet been submitted to the Garmin store. I will do so once I have tested it myself on a few runs.
For anyone stumbling across this repository, feel free to download and try it out, but be warned - it has had almost no
testing yet so if it crashes your watch during a race, don't blame me.

![PBSeeker Screenshot Bright](/screenshots/screenshot-1.png) ![PBSeeker Screenshot Dark](/screenshots/screenshot-2.png)

## Features
- Current pace (average for the previous 10 seconds)
- Total distance
- Elapsed time
- Predicted finish time for next goal
- Remaining distance to next goal
- Goal configuration settings
- Current heart rate
- Battery life indicator
- Supports device units setting (KM or miles)
- Choose how pace is calculated from:
   - Current pace
   - Average pace
   - Average pace (last 3 seconds)
   - Average pace (last 10 seconds)
   - Average pace (last 30 seconds)

## Supported Devices
- D2 Charlie
- Descent MK1
- fenix 5 / 5S / 5X / Chronos
- Forerunner 645 / Music
- Forerunner 935

Note: Only tested in on a real fenix 5X in the field, all other watches tested only in the SDK device simulator.

## Goal Settings
PB Seeker allows you to track predicted finish times for multiple goals within a single activity, one after the other.
When you pass the distance for a goal, the prediction will switch over to the next goal until you have passed the distance
of the longest goal, at which point the finish time for that last goal will be shown. The idea is that you can go out for
a 15K run (for example), and see your estimated time at various key distances along the way. Of course you can just set
a single goal and watch your predicted time for that goal throughout the whole run (the default is a single 5K goal).

The following goal distances are available out of the box and can be enabled with a checkbox in the settings screen for
the data field:
- 1K
- 1 mile
- 2K
- 2 miles
- 5K
- 5 miles
- 10K
- 10 miles
- 15K
- Half Marathon
- Marathon
Additionally, you can configure a custom goal distance and a label to show on the screen for that distance in the settings
screen.

## Licence
PB Seeker is open source and it's code resides on GitHub at https://github.com/wwarby/pbseeker

## Credits
This project borrows code and ideas heavily from [RunnersField by kpaumann](https://github.com/kopa/RunnersField).
Thanks [kpaumann](https://apps.garmin.com/en-GB/developer/ab0f2743-88d2-4f32-9fb0-5fc8ba61e55a/apps) for open sourcing
your project and giving me a leg up in writing for the Garmin SDK.

## Changelog 0.1.0
- Initial release