-------------------------------
-- Based on "chrono" by Matthias Richter: https://github.com/adnzzzzZ/chrono
-- MIT License
-- Copyright (c) 2019, 4v0v
-------------------------------
local Timer = {}

function Timer:__call() return setmetatable({timers = {}}, {__index = Timer}) end

--###########################--
local _t = {
    out     = function(f) return function(x, ...) return 1 - f(1-x, ...) end end,
    chain   = function(f1, f2) return function(x, ...) return (x < 0.5 and f1(2*x, ...) or 1 + f2(2*x-1, ...))*0.5 end end,
    linear  = function(x) return x end,
    quad    = function(x) return x*x end,
    cubic   = function(x) return x*x*x end,
    quart   = function(x) return x*x*x*x end,
    quint   = function(x) return x*x*x*x*x end,
    sine    = function(x) return 1-math.cos(x*math.pi/2) end,
    expo    = function(x) return 2^(10*(x-1)) end,
    circ    = function(x) return 1-math.sqrt(1-x*x) end,
    back    = function(x, b) b = b or 1.70158; return x*x*((b+1)*x - b) end, --bounciness
    bounce  = function(x) local a, b = 7.5625, 1/2.75; return math.min(a*x^2, a*(x-1.5*b)^2 + 0.75, a*(x-2.25*b)^2 + 0.9375, a*(x-2.625*b)^2 + 0.984375) end,
    elastic = function(x, a, p) a, p = a and math.max(1, a) or 1, p or 0.3; return (-a*math.sin(2*math.pi/p*(x-1) - math.asin(1/a)))*2^(10*(x-1)) end -- amp, period
}
local function _tween(f, ...)
    if     f == "linear"       then return _t.linear(...)
    elseif f:find("in%-out%-") then return _t.chain(_t[f:sub(8, -1)], _t.out(_t[f:sub(8, -1)]))(...) 
    elseif f:find("in%-")      then return _t[f:sub(4, -1)](...)
    elseif f:find("out%-")     then return _t.out(_t[f:sub(5, -1)])(...) end
end
local function _calc_tween(subject, target, out)
    for k, v in pairs(target) do
        local ref = subject[k]
        if type(v) == 'table' then 
	    _calc_tween(ref, v, out)
        else 
            local ok, delta = pcall(function() return (v-ref)*1 end)
            out[#out+1] = {subject, k, delta} 
        end
    end
    return out
end
local function _rand(time) 
    if type(time) == 'number' then return time 
    elseif type(time) == 'table' then 
        local min, max = time[1] or 0, time[2] or 1 
        return (min > max and (love.math.random()*(min - max) + max)) or (love.math.random()*(max - min) + min)
    end 
end
local function _uid()
    local func = function() local r = math.random(16) return ("0123456789ABCDEF"):sub(r, r) end 
    return ("xxxxxxxxxxxxxxxx"):gsub("[x]", func)
end
--###########################--
function Timer:update(dt)
    for tag, v in pairs(self.timers) do
        if v.status == "play" then 
            v.t = v.t + dt
            if     v.type == "after" then 
                if v.t >= v.total then v.action(); v.after(); self.timers[tag] = nil end

            elseif v.type == "during" then
		        if v.e == v.each then v.action(); v.e = 0 end
		        v.e = v.e + 1
		        if v.t >= v.total then v.after(); self.timers[tag] = nil end

            elseif v.type == "script" then
                if coroutine.status(v.coroutine) == "dead" then self.timers[tag] = nil end

            elseif v.type == "every" then  
                if v.c == 0 or v.t >= v.total then
		    if v.c == 0 then v.t = v.total end -- first loop 
                    v.action()
                    v.c = v.c + 1
                    v.t = v.t - v.total
                    v.total = _rand(v.any_total)
                    if v.c == v.count then v.after(); self.timers[tag] = nil end
                end

            elseif v.type == "tween" then
                local s  = _tween(v.method, math.min(1, v.t/v.total))
                local ds = s - v.last_s
                v.last_s = s
                for _, info in ipairs(v.payload) do local ref, key, delta = unpack(info); ref[key] = ref[key] + delta*ds end
                if v.t >= v.total then 
                    for _, info in ipairs(v.payload) do local ref, key, _ = unpack(info); ref[key] = v.target[key] end
                    v.after()
                    self.timers[tag] = nil 
                end
            end
        end
    end
end
function Timer:after(time, action, a, b)
    local tag, after
    if     type(a) == "nil"      and type(b) == "nil"    then after, tag = function() end, _uid() 
    elseif type(a) == "string"   and type(b) == "nil"    then after, tag = function() end, a      
    elseif type(a) == "function" and type(b) == "nil"    then after, tag = a      , _uid() 
    elseif type(a) == "function" and type(b) == "string" then after, tag = a      , b      end
    if self.timers[tag] then return false end

    self.timers[tag] = {
        type   = "after", 
        status = "play",
        t      = 0, 
        total  = _rand(time), 
        action = action,
        after  = after,
    }
    return tag
end
function Timer:every(time, action, a, b, c)
    local tag, after, count
    if     type(a) == "nil"      and type(b) == "nil"      and type(c) == "nil"    then after, count, tag = function() end, -1, _uid()
    elseif type(a) == "string"   and type(b) == "nil"      and type(c) == "nil"    then after, count, tag = function() end, -1, a     
    elseif type(a) == "number"   and type(b) == "nil"      and type(c) == "nil"    then after, count, tag = function() end,  a, _uid()     
    elseif type(a) == "function" and type(b) == "nil"      and type(c) == "nil"    then after, count, tag = a      , -1, _uid()     
    elseif type(a) == "number"   and type(b) == "string"   and type(c) == "nil"    then after, count, tag = function() end,  a, b     
    elseif type(a) == "function" and type(b) == "string"   and type(c) == "nil"    then after, count, tag = a      , -1, b     
    elseif type(a) == "function" and type(b) == "number"   and type(c) == "nil"    then after, count, tag = a      ,  b, _uid()
    elseif type(a) == "number"   and type(b) == "function" and type(c) == "nil"    then after, count, tag = b      ,  a, _uid()
    elseif type(a) == "function" and type(b) == "number"   and type(c) == "string" then after, count, tag = a      ,  b, c     
    elseif type(a) == "number"   and type(b) == "function" and type(c) == "string" then after, count, tag = b      ,  a, c      end
    if self.timers[tag] then return false end
	
    self.timers[tag] = {
        type      = "every", 
        status    = "play",
        total     = _rand(time), 
        any_total = time, 
        t         = 0, 
        count     = count, 
        c         = 0, 
        action    = action, 
        after     = after
    }
    return tag
end
function Timer:during(time, action, a, b, c)
    local tag, after, each
    if     type(a) == "nil"      and type(b) == "nil"      and type(c) == "nil"    then after, each, tag = function() end,  1, _uid()
    elseif type(a) == "string"   and type(b) == "nil"      and type(c) == "nil"    then after, each, tag = function() end,  1, a     
    elseif type(a) == "number"   and type(b) == "nil"      and type(c) == "nil"    then after, each, tag = function() end,  a, _uid()     
    elseif type(a) == "function" and type(b) == "nil"      and type(c) == "nil"    then after, each, tag = a      ,  1, _uid()     
    elseif type(a) == "number"   and type(b) == "string"   and type(c) == "nil"    then after, each, tag = function() end,  a, b     
    elseif type(a) == "function" and type(b) == "string"   and type(c) == "nil"    then after, each, tag = a      ,  1, b     
    elseif type(a) == "function" and type(b) == "number"   and type(c) == "nil"    then after, each, tag = a      ,  b, _uid()
    elseif type(a) == "number"   and type(b) == "function" and type(c) == "nil"    then after, each, tag = b      ,  a, _uid()
    elseif type(a) == "function" and type(b) == "number"   and type(c) == "string" then after, each, tag = a      ,  b, c     
    elseif type(a) == "number"   and type(b) == "function" and type(c) == "string" then after, each, tag = b      ,  a, c      end
    if self.timers[tag] then return false end
	
    self.timers[tag] = {
        type    = "during", 
        status  = "play",
        t       = 0,
	    each    = each,
	    e       = each, 
        total   = _rand(time), 
        action  = action, 
        after   = after
    }
    return tag
end
function Timer:tween(time, subject, target, method, a, b)
    local tag, after
    if     type(a) == "nil"      and type(b) == "nil"    then after, tag = function() end, _uid() 
    elseif type(a) == "string"   and type(b) == "nil"    then after, tag = function() end, a      
    elseif type(a) == "function" and type(b) == "nil"    then after, tag = a      , _uid() 
    elseif type(a) == "function" and type(b) == "string" then after, tag = a      , b      end
    if self.timers[tag] then return false end

    self.timers[tag] = { 
        type    = "tween", 
        status  = "play",
        t       = 0,
        total   = _rand(time), 
        subject = subject, 
        target  = target, 
        method  = method, 
        after   = after, 
        last_s  = 0, 
        payload = _calc_tween(subject, target, {})
    }
    return tag
end
function Timer:once(action, tag)
    return self:every(math.huge, action, tag)
end

function Timer:always(action, a, b) 
    return self:during(math.huge, action, a, b) 
end

function Timer:script(action, tag)
    tag = tag or _uid()
    if self.timers[tag] then return false end

    self.timers[tag] = {
        type       = "script",
        status     = "play",
        t          = 0,
        after_tag  = "",
        coroutine  = coroutine.create(action),
        resume     = function()
                        local _error, _message = coroutine.resume(self.timers[tag].coroutine)
                        assert(_no_error, _message) 
                    end
    }

    local _error, _message = coroutine.resume(self.timers[tag].coroutine, 
        function(time, after_tag)
            if type(time) == "number" then 
                self.timers[tag].after_tag = self:after(time, function()
                    local _error, _message = coroutine.resume(self.timers[tag].coroutine) 
                    assert(_error, _message) 
                end, after_tag)
                coroutine.yield()

            elseif not time then 
                coroutine.yield() 
            end
        end
    )
    assert(_error, _message)
    return tag, self.timers[tag].resume
end
--###########################--
function Timer:is_timer(tag)  return not not self.timers[tag]    end
function Timer:get_time(tag)  return self.timers[tag].t, self.timers[tag].total end
function Timer:get_count(tag) return self.timers[tag].c, self.timers[tag].count end
function Timer:resume_script(tag) self.timers[tag].resume() end
function Timer:pause(tag)
    if self.timers[tag].type == "script" then if self.timers[self.timers[tag].after_tag] then self.timers[self.timers[tag].after_tag].status = "pause" end end
    self.timers[tag].status = "pause" 
end
function Timer:play(tag)
    if self.timers[tag].type == "script" then if self.timers[self.timers[tag].after_tag] then self.timers[self.timers[tag].after_tag].status = "play" end end
    self.timers[tag].status = "play"  
end
function Timer:remove(tag)
    assert(self.timers[tag] ~= nil, "Timer '" .. tag .. "' doesn't exist.")
    if self.timers[tag].type == "script" then if self.timers[self.timers[tag].after_tag] then self.timers[self.timers[tag].after_tag] = nil end end
    self.timers[tag]        = nil     
end
function Timer:destroy() self.timers = {} end
--###########################--

return setmetatable({}, Timer)
