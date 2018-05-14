# Pacemaker

A free data field for Garmin running watches designed to help runners keep pace with customisable goals. You can set up to
10 goals in the app settings, each with a specified distance and target time and the data field will track whether you are
on target. For each goal in turn, it will show you:
- A prediction of your time
- How far ahead (or behind) your target time you are (in seconds)
- How much you need to adjust your running pace by to hit your target time (in seconds)
- Whether you are on target to hit your target time (by colouring text red or green)
- The remaining distance to the next goal

You could use these features to (for example):
- Chase your personal best time for a fixed distance
- Set a series of markers to help pace even splits across the run

Pacemaker also show the common metrics most runners use during a run: pace, distance, elapsed time, cadence
and heart rate, and you can configure how some of these values are averaged during your run.

![Screenshot Light](/screenshots/screenshot-1.png) ![Screenshot Dark](/screenshots/screenshot-2.png)

## BETA
Pacemaker is currently in BETA. I am in the process of testing it on my own runs and intend to release it in the Garmin
app store when I am confident that it is reasonably stable. For anyone stumbling across this repository, feel free to
download and try it out, but be warned - it has had insufficient real world testing yet so if it crashes your watch during
a race, don't blame me.

## Features
- Pace
- Pace adjust recommendation for next goal
- Total distance
- Elapsed time
- Predicted time for next goal
- Delta of predicted time vs. target time for next goal
- Remaining distance to next goal
- Cadence
- Heart rate
- Configuration settings for
   - Setting goals
   - Coloured text
   - Calculation method for pace, cadence and heart rate
- Supports device light/dark mode setting
- Supports device units setting (KM or miles)

## Supported Devices
- D2 Charlie
- Descent MK1
- fenix 5X

*Note: Only tested in on a real fenix 5X in the field, all other watches tested only in the SDK device simulator.*

## Goal Settings
You can set up to 10 goals with Pacemaker. Each goal is comprised of 3 values: distance, target time and name. You must set
the distance in meters and the target time in seconds for each goal. The name field is optional - if you leave it blank,
a goal name will be generated automatically from the distance field, e.g. `5K` for a distance of `5000`.

The goals do not have to be set in any particular order (in other words you can put shorter distances after longer ones)
and the app will work out the order based on distance, but you do have to match the distances and times together using the
goal numbers (e.g. the distance for Goal 3 always goes with the target time for Goal 3).

## One Goal at a Time
Note that only one goal is active at a time, and it is always the goal with the shortest distance that is still further than
you have run so far. As soon as you pass that distance, the data field will immediately start predictions for your next goal.
When you pass the distance of your longest goal, the finish time for that longest goal will remain on screen.

## Unsupported Devices
Supporting multiple devices in the Garmin SDK is hard work, mostly due to severe limitations on memory usage in the less
powerful devices in the range. The following devices are currently unsupported due to memory limit issues, but I may be
able to reduce memory usage to support them if there is enough interest:

- Approach S60
- D2 Charlie
- Descent MK1
- fenix 5 / 5S / Chronos
- Forerunner 645 / Music
- Forerunner 935
- vivoactive 3

I will never be able to support older Connect IQ 1.x devices like the Forerunner 235. Those devices have a limitation of
16KB memory for data fields, and it is almost impossible to work within that limit without abandoning all principles
of maintainable object-oriented programming, and dropping down to a procedural coding style which I have no interest in doing.

## Source
Pacemaker is open source (MIT license) and it's code resides on GitHub at https://github.com/wwarby/pacemaker

## Credits
This project borrows code and ideas from [RunnersField by kpaumann](https://github.com/kopa/RunnersField).
Thanks [kpaumann](https://apps.garmin.com/en-GB/developer/ab0f2743-88d2-4f32-9fb0-5fc8ba61e55a/apps) for open sourcing
your project and giving me a leg up in writing for the Garmin SDK.

### Icon Credits
- Running shoe icon made by [Freepic](https://www.flaticon.com/authors/freepik) from [www.flaticon.com](https://www.flaticon.com/free-icon/trainers_105191)
- Running man icon made by [Freepic](https://www.flaticon.com/authors/freepik) from [www.flaticon.com](https://www.flaticon.com/free-icon/running_763965)
- Chequered flag icon made by [Vaadin](https://www.flaticon.com/authors/vaadin) from [www.flaticon.com](https://www.flaticon.com/free-icon/checkered-flag_106935)


## Changelog 0.1.0
- Initial release