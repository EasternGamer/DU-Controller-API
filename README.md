# DU-Controller-API
An abstraction layer in order to "standardize" controller-based inputs across any script using this API. Includes deadzones, custom throttle modes as well.
To start, copy over the Controller_API.lua somewhere in your control unit, preferably in onStart in Library.
Then in unit start or any initialization area do the following:
```lua
controller = Controller()
```
This initializes a global variable instance of the controller to make use of.

Then, there are a few base functions you use:
```lua
controller.getRawX()
controller.getXInput()
controller.setXDeadzone()
controller.getBrakeVectorUnpacked() -- in the form local x, y, z = controller.getBrakeVectorUnpacked()
controller.getBrakeVector() -- array in the form {xValue, yValue, zValue}
```
Where the X can be replaced with `Pitch`, `Roll`, `Yaw`, `Throttle`, `Brake`, `Strafe`, `Vertical`, `Axis7`, `Axis8`, `Axis9`
If you just want to use this as a standard (no need to reference axis indices) then the `Raw` functions will return the correct axis values.
If you want to make use of the deadzone functioning and such, use the `Input` functions.

## Advanced Options
With this API, there are a few optional parameters you can enable which affect how the API judges the throttle input.
These parameters affect the raw inputs as well.
The boolean parameters are `hybrid`, `hasBrake` and `range`. 
```lua
-- local hybrid, hasBrake, range = true, false, false
controller = Controller(hybrid, hasBrake, range)
```
### Hybrid
This mode overrides both the `hasBrake` and `range` parameters, setting both to false.
This mode says that the throttle should be considered both the brake and throttle input. Values below 50% of the throttle will be considered braking which in principle means that around half, there is no thrust or brake since the is a center deadzone.
### Not Hybrid
This mode now takes into account `hasBrake` and `range`.
- Range
  - If `true`, the throttle will consider the entire axis to be 0% to 100% (0 to 1).
  - If `false`, the throttle will consider the entire axis to be -100% to 100% (-1 to 1).
- Has Brake
  - If `true`, it will return 0% to 100% (0 to 1) using the brake axis.
  - If `false`, it will return 0% (0 to 0).

## The Standard
In the Lua settings the follow axes are bound. You may need to choose either the +- variant of the axis in order to invert the output.
| Axis | Description | Dir |
| :---: | :---: | :---: |
| `Lua Axis 0` | Roll | + |
| `Lua Axis 1` | Pitch | + |
| `Lua Axis 2` | Yaw | - |
| `Lua Axis 3` | Throttle | - |
| `Lua Axis 4` | Brake | - |
| `Lua Axis 5` | Strafe Left/Right | ?[^1] |
| `Lua Axis 6` | Vertical Up/Down | ?[^1] |
| `Lua Axis 7` | Custom[^2] | ?[^1] |
| `Lua Axis 8` | Custom[^2] | ?[^1] |
| `Lua Axis 9` | Custom[^2] | ?[^1] |
[^1]: No set standard direction decided yet.
[^2]: Script specific axis.

## Other Versions
There are some cases where you don't need the extra weight of the API.
Maybe you just need the standard itself, or maybe you just don't need the advanced translations done.
Here, you will find alternative packaged versions of the API so that if you need it as small as possible.

### Standard Only
The standard only version only includes the raw inputs, it has no deadzone checking, no caching, no error input checking. It is basically as simple as it can get while assigning names to each getAxis input.
[Here you will find the normal version.](alternatives/Controller_API_standard.lua) `1.71 KB`
[Here you will find the minified version.](alternatives/Controller_API_mini_standard.lua) `0.83 KB`

### No Brake Vector
This version excludes only the brake vector stuff which may be very niche in use. 
[Here you will find the normal version.](alternatives/Controller_API_no_brake_vector.lua) `5.99 KB`
[Here you will find the minified version.](alternatives/Controller_API_mini_no_brake_vector.lua) `2.49 KB`
