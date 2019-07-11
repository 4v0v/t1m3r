# timer

## What is it ?
**timer** is a Löve framework library that handle doing action under certain conditions.
I use it to deal with boolean farms when coding complex behaviors for my games.

It's build around [chrono.lua](https://github.com/adnzzzzZ/chrono) and [hump.timer](https://github.com/vrld/hump/blob/master/timer.lua).
Like those two libraries it also handle tweening values.

## API
- **Timer:update(dt)**: Put this in the love.update function.

Update the internal of one timer, put this in your **love.update** function.

- **Timer:after(time, action[, after, tag])**:
  - **time**   = number
  - **action** = function 
  - **after**  = function 
  - **tag**    = string

After an amount of time (in seconds), execute the action function and then the after function.

- **Timer:every(time, action[, count, after, tag])**:
  - **time** = number
  - **action** = function 
  - **count** = number
  - **after** = function 
  - **tag**  = string

Every amount of time, execute the action function.
If there is a count parameter, the every function will execute this number of time then stop then call the after function.
If the action function return false, the every function will stop then call the after function.

- **Timer:during(time, action[, each, after, tag])**:
  - **time** = number
  - **action** = function
  - **each**   = number
  - **after**  = function 
  - **tag**    = string

During an amount of time, execute the action function every **each** number of update loop then execute the after function. 
By default, the action function is called every frame.

- **Timer:tween(time, subject, target, method[,after, tag])**:
  - **time** = number
  - **subject** = table
  - **target**   = table
  - **after**  = function 
  - **tag**    = string
  
 In an amount of time, tween all the values of the table **subject** to the **target** values.
 At the end of the tween the values wil be **exactly** equal to the target values.
 
- **Timer:script(function(wait) end):**
 
 Easy way to chain and schedule actions using coroutines. 
 When you call the wait function with a delay it stop the function this amount of time then continue to execute.
 When you call the wait function without parameter, it stop the function until you call **Timer:resume_script(tag)**.
 When you call the wait function with a string, it stop the function until you call **Timer:resume_script(tag)** and you can use the **Timer:get_resume_tag(tag)** function to return the string of the current **wait** function.
 
- **Timer:always(action[, each, tag]):**
  - **action** = function
  - **parameters** = table
  - **tag**   = string

Like a during function without a time restriction


- **Timer:once(action[, tag])**:
  - **action** = function 
  - **tag**    = string
  
 Do an action once until the once timer is removed

