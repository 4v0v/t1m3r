# timer

## What is it ?
**timer** is a Löve framework library that handle doing action under certain conditions.
I use it to deal with boolean farms when coding complex behaviors for my games.

It's build around [chrono.lua](https://github.com/adnzzzzZ/chrono) and [hump.timer](https://github.com/vrld/hump/blob/master/timer.lua).
Like those two libraries it also handle tweening values.

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

_Update the timer, put this in your `love.update(dt)` function._

---
```lua
timer:after(time, action[, after, tag])
```
  - `time(number)`
  - `action(function)`
  - `after(function)`
  - `tag(string)`

_After an amount of time (in seconds), execute the action function and then the after function._

---
```lua
timer:every(time, action[, count, after, tag])
```
  - `time(number)`
  - `action(function)`
  - `count(number)`
  - `after(function)`
  - `tag(string)`

_Every amount of time, execute the action function.
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

_During an amount of time, execute the action function every **each** number of update loop then execute the after function. 
By default, the action function is called every frame._

---
```lua
timer:tween(time, subject, target, method[,after, tag])**
```
  - `time(number)`
  - `subject(table)`
  - `target(table)`
  - `after(function)`
  - `tag(string)`
  
_In an amount of time, tween all the values of the table **subject** to the **target** values.
At the end of the tween the values wil be **exactly** equal to the target values._
 
---
```lua
timer:script(function(wait) end)
```
 
_Easy way to chain and schedule actions using coroutines. 
When you call the wait function with a delay it stop the function this amount of time then continue to execute.
When you call the wait function without parameter, it stop the function until you call **Timer:resume_script()**.
the **Timer:get_resume_tag(tag)** function to return the string of the current **wait** function._
 
 ---
```lua
Timer:always(action[, each, tag])
```
  - `action(function)`
  - `each(number)`
  - `tag(string)`

_Do an action every frame. Shortcut of **Timer:during** without a time restriction._

---
```lua
Timer:once(action[, tag])
```
  - `action(function)`
  - `tag(string)`
  
_Do an action once until the once timer is removed._
