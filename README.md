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
