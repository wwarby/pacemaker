# Pacemaker

A free data field for the Garmin running watches designed to help runners keep pace with customisable goal times for
specified distances.

![PBSeeker Screenshot Bright](/screenshots/screenshot-1.png) ![PBSeeker Screenshot Dark](/screenshots/screenshot-2.png)

## Release Plan
This data field has not yet been submitted to the Garmin store. I will do so once I have tested it myself on a few runs.
For anyone stumbling across this repository, feel free to download and try it out, but be warned - it has had almost no
testing yet so if it crashes your watch during a race, don't blame me.

## Features
- Current pace
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
- Approach S60
- D2 Charlie
- Descent MK1
- fenix 5 / 5S / 5X / Chronos
- Forerunner 645 / Music
- Forerunner 935
- vivoactive 3

Note: Only tested in on a real fenix 5X in the field, all other watches tested only in the SDK device simulator.

## Goal Settings
PB Seeker allows you to track predicted finish times for multiple goals within a single activity, one after the other.
When you pass the distance for a goal, the prediction will switch over to the next goal until you have passed the distance
of the longest goal, at which point the finish time for that last goal will be shown. The idea is that you can go out for
a 15K run (for example), and see your estimated time at various key distances along the way. Of course you can just set
a single goal and watch your predicted time for that goal throughout the whole run (the default is a single 5K goal).

The following goal distances are available out of the box and can be enabled with a checkbox in the settings screen for
the data field:
- 1 / 2 / 5 / 10 / 15K
- 1 / 2 / 5 / 10 miles
- Half Marathon
- Marathon
Additionally, you can configure a custom goal distance and a label to show on the screen for that distance in the settings
screen.

## Unsupported Devices
I have supported as many devices as I could at the time of initial release. If there is any interest, I may add support
for newly released devices. I won't be adding support for devices that aren't designed for running (such as the Edge series)
or the older Connect IQ 1.x devices like the Forerunner 235. The problem with the older Connect IQ 1.x devices is that they
limit memory usage to 16KB, and the template for a data field uses over half of that before you've written a line of code.
My hat goes off to any developer who can work within that limit without dropping down to procedural coding style or
compromising heavily on functionality, but I don't want development of this data field be constrained to that limitation.

## Source
PB Seeker is open source (MIT license) and it's code resides on GitHub at https://github.com/wwarby/pbseeker

## Credits
This project borrows code and ideas from [RunnersField by kpaumann](https://github.com/kopa/RunnersField).
Thanks [kpaumann](https://apps.garmin.com/en-GB/developer/ab0f2743-88d2-4f32-9fb0-5fc8ba61e55a/apps) for open sourcing
your project and giving me a leg up in writing for the Garmin SDK.

## Changelog 0.1.0
- Initial release