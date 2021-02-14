# t1m3r

## What is it ?
**trigger** is a Löve framework library that handle doing action under certain conditions.

The name and a lot of the ideas behind it are take from https://github.com/a327ex/Anchor/blob/master/engine/game/trigger.lua

I use it to deal with boolean farms when coding complex behaviors for my games.

It's build around [chrono.lua](https://github.com/adnzzzzZ/chrono) and [hump.timer](https://github.com/vrld/hump/blob/master/timer.lua).
Like those two libraries it also handle tweening values.

All timer functions contains a **tag** parameter. It act like a primary key of the Timer object so it's unique to it. If you try to call a timer function with an already existing **tag**, the function will return false. If you delete the timer function, the tag is available again. If you don't put a tag parameter, it will be automaticaly generated.

The **time** parameter for every function can either be a number of a table with the format `{x, y}`, it generate a random time between `x` and `y` seconds.
In an **every timer**, the **time** will be randomized after every execution of the action.

## API
---
```lua
local Timer = require("path/to/timer")
```

_Initialize the library._

---
```lua
local timer = Timer()
```

_Create a new timer instance._

---
```lua
timer:update(dt)
```
  - `dt(number)`: _delta time._

_Update the timer, put this in your `love.update(dt)` function._

---
```lua
timer:after(time, action[, after, tag])
```
  - `time(number or table)`
  - `action(function)`
  - `after(function)`
  - `tag(string)`
  
 **return :** `tag(string)` or`false`

_After an amount of time (in seconds), execute the action function and then the after function._

---
```lua
timer:every(time, action[, count, after, tag])
```
  - `time(number or table)` 
  - `action(function)`: function called after time
  - `count(number)`: number of executions
  - `after(function)`: function called after the number of executions or if action return false
  - `tag(string)`: name of this **every timer**
  
**return :** `tag(string)` or `false`

_Execute the action the moment this every function is called then every amount of time, execute the action function again.
If there is a count parameter, the every function will execute this number of time then stop then call the after function.
If the action function return false, the every function will stop then call the after function._

---
```lua
timer:during(time, action[, each, after, tag])
```
  - `time(number)`
  - `action(function)`
  - `each(number)`
  - `after(function)`
  - `tag(string)`
  
**return :** `tag(string)` or `false`

_During an amount of time, execute the action function every **each** number of update loop then execute the after function. 
By default, the action function is called every frame._

---
```lua
timer:tween(time, subject, target, method[,after, tag])
```
  - `time(number)`
  - `subject(table)`
  - `target(table)`
  - `after(function)`
  - `tag(string)`
   
**return :** `tag(string)` or `false`
  
_In an amount of time, tween all the values of the table **subject** to the **target** values.
At the end of the tween the values wil be **exactly** equal to the target values._
 
---
```lua
timer:script(function(wait) end, tag)
```

 **return :** `tag(string)`, `resume(function)` or `false`
 
_Easy way to chain and schedule actions using coroutines. 
- If you call the **wait function** with a delay it stop the function this amount of time then continue to execute.
- If you call the **wait function** without parameter, it stop the function until you call **Timer:resume_script()** or the **resume** function returned.
 
 ---
```lua
Timer:always(action[, each, tag])
```
  - `action(function)`
  - `each(number)`
  - `tag(string)`
  
**return :** `tag(string)` or `false`

_Do an action every frame. Shortcut of **timer:during(math.huge, ...)**._

---
```lua
Timer:once(action[, tag])
```
  - `action(function)`
  - `tag(string)`

**return :** `tag(string)` or `false`

_Do an action once, can't do it again until the **once timer** is removed. Shortcut of **timer:every(math.huge, ...)**._

---
```lua
Timer:is_timer(tag)
Timer:get_time(tag)
Timer:get_count(tag)
Timer:resume_script(tag)
Timer:pause(tag)
Timer:play(tag)
Timer:remove(tag)
Timer:destroy()
```
