# Pacemaker

A free data field for Garmin running watches designed to help runners keep pace with a customisable goal. You can set a
custom goal distance and time in the app settings to see a prediction of your finish time which takes account of both
your current pace and average pace for the distance completed so far. It will also show you remaining distance to your
goal, and colour the pace and finish time text red or green to indicate whether you are on target.

Pacemaker has five display fields, each of which can be customised to show one of the following metrics:
- Heart rate
- Cadence
- Power (including from Stryd, if connected as a power meter)
- Pace
- Pace delta (+/- difference from target)
- Calories
- Elapsed distance
- Remaining distance
- Predicted finish time
- Predicted finish time delta (+/- difference from target)
- Elapsed time

You can also independently customise how heart rate, cadence, power and pace are calculated, using either current values,
average from start or average over the previous 3 / 5 / 10 / 30 / 60 seconds.

Pacemaker is aware of and supports device settings for distance units (KM or miles) and background colours (black or white).

![Screenshot Light](/supporting-files/screenshots/screenshot-1.png) ![Screenshot Dark](/supporting-files/screenshots/screenshot-2.png)

## BETA
Pacemaker is currently in BETA. I am in the process of testing it on my own runs and intend to release it in the Garmin
app store when I am confident that it is reasonably stable. For anyone stumbling across this repository, feel free to
download and try it out, but be warned - it has had insufficient real world testing yet so if it crashes your watch during
a race, don't blame me.

## Known Issues
- Some devices such as vivoactive 3 do not provide a running power value (it looks like it should do so when paired with an external
power meter device like Stryd, but I can't tell for sure). On unsupported devices, the power value will show as zero.

## Supported Devices
- Approach S60
- D2 Charlie
- fenix 5 / 5S / 5X Chronos
- Forerunner 645 / 645 Music / 735xt / 935
- vivoactive 3

*Note: Only tested in on a real fenix 5X in the field, all other watches tested only in the SDK device simulator.*

## Unsupported Devices
I have made every reasonable effort to support as many devices as I can with the initial release of this data field.
Supporting multiple devices in the Garmin SDK is hard work due to screen size variations and severe limitations on memory usage
in the less powerful devices in the range.

I have not supported the Descent MK1 device because the current SDK won't let me
test it with Connect IQ 2.4, which is the miminum version I support. If this changes, I will support the Descent MK1 in a future
release. I have not supported the vivoactive HR because it's screen is too small for my layout. I could support it with some
considerable amount of effort if there is any interest in the future.

I will never be able to support older Connect IQ 1.x devices like the Forerunner 235. Those devices have a limitation of
16KB memory for data fields, and it is almost impossible to work within that limit without abandoning all principles
of maintainable object-oriented programming, and dropping down to a procedural coding style which I have no interest in doing.
As it is, most of the devices I am supporting have a memory limit of 28.6KB which is pretty challenging.

## Source
Pacemaker is open source (MIT license) and it's code resides on GitHub at https://github.com/wwarby/pacemaker

## Credits
This project borrows code and ideas from [RunnersField by kpaumann](https://github.com/kopa/RunnersField).
Thanks [kpaumann](https://apps.garmin.com/en-GB/developer/ab0f2743-88d2-4f32-9fb0-5fc8ba61e55a/apps) for open sourcing
your project and giving me a leg up in writing for the Garmin SDK.

### Icon Credits
- Icons by [Freepic](https://www.flaticon.com/authors/freepik) from [www.flaticon.com](https://www.flaticon.com)
- Chequered flag icon by [Vaadin](https://www.flaticon.com/authors/vaadin) from [www.flaticon.com](https://www.flaticon.com/free-icon/checkered-flag_106935)
- Flame icon by [Those Icons](https://www.flaticon.com/authors/those-icons) from [www.flaticon.com](https://www.flaticon.com/free-icon/fire_483675)

## Changelog
- 0.4.0
  - Support reversed icons
  - Add calories metric
  - Add pace delta metric
  - Add finish time delta metric
- 0.3.3
  - Fix crash in pace average calculation, change settings defaults
- 0.3.2
  - Fix power value stuck at zero
- 0.3.1
  - Fix startup crash
- 0.3.0
  - Concept redesign
- 0.2.0
  - Concept redesign
- 0.1.1
  - Tweak settings layout
- 0.1.0
  - Initial release