local Timer = {}

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

local function _rand(t) if type(t) == 'table' then return love.math.random()*(t[1] - t[2]) + t[2] else return t end end

local function _tween(f, ...)
	if     f:find('linear')    then return _t.linear(...)
	elseif f:find('in%-out%-') then return _t.chain(_t[f:sub(8, -1)], _t.out(_t[f:sub(8, -1)]))(...) 
	elseif f:find('in%-')      then return _t[f:sub(4, -1)](...)
	elseif f:find('out%-')     then return _t.out(_t[f:sub(5, -1)])(...) end
end

local function _calc_tween(subject, target, out)
	for k, v in pairs(target) do
		if type(v) == 'table' then _calc_tween(subject[k], v, out)
		else local ok, delta = pcall(function() return (v - subject[k])*1 end); out[#out+1] = {subject, k, delta} end
	end
	return out
end

function Timer:new()
	local obj = {}
		obj.timers = {}
	return setmetatable(obj, {__index = Timer})
end

function Timer:update(dt)
  for tag, v in pairs(self.timers) do
		if v.status ~= 'play' then break end
		v.t = v.t + dt

		if v.type == 'after' then 
			if v.t >= v.total then v.action(); self.timers[tag] = nil end

		elseif v.type == 'during' then
			if v.e == v.each then v.action(); v.e = 0 end
			v.e = v.e + 1
			if v.t >= v.total then v.after(); self.timers[tag] = nil end

		elseif v.type == 'every' then  
			if v.c == 0 or v.t >= v.total then
				if v.c == 0 then v.t = v.total end -- first loop 
				v.action()
				v.c = v.c + 1
				v.t = v.t - v.total
				v.total = _rand(v.any_total)
				if v.c == v.count then v.after(); self.timers[tag] = nil end
			end

		elseif v.type == 'tween' then
			local s  = _tween(v.method, math.min(1, v.t/v.total))
			local ds = s - v.last_s
			v.last_s = s
			for _, info in ipairs(v.payload) do local ref, key, delta = unpack(info); ref[key] = ref[key] + delta*ds end
			if v.t >= v.total then 
				for _, info in ipairs(v.payload) do local ref, key, _ = unpack(info); ref[key] = v.target[key] end
				v.after(); self.timers[tag] = nil 
			end
		end
	end
end

function Timer:after(time, action, tag)
	local tag = tag or uid()
	if self.timers[tag] then return false end
	self.timers[tag] = {
		type   = 'after', 
		status = 'play',
		t      = 0, 
		total  = _rand(time), 
		action = action,
	}
	return tag
end

function Timer:every(time, action, count, tag, after)
	local tag = tag or uid()
	if self.timers[tag] then return false end
	self.timers[tag] = {
		type      = 'every', 
		status    = 'play',
		total     = _rand(time), 
		any_total = time, 
		t         = 0, 
		count     = count or -1, 
		c         = 0, 
		action    = action, 
		after     = after or function() end,
	}
	return tag
end

function Timer:during(time, action, each, tag, after)
	local tag = tag or uid()
  if self.timers[tag] then return false end
	self.timers[tag] = {
		type    = 'during', 
		status  = 'play',
		t       = 0,
		each    = each or 1,
		e       = each or 1, 
		total   = _rand(time), 
		action  = action, 
		after   = after or function() end,
	}
	return tag
end

function Timer:tween(time, subject, target, method, tag, after)
	local tag = tag or uid()
	if self.timers[tag] then return false end
	self.timers[tag] = { 
		type    = 'tween', 
		status  = 'play',
		t       = 0,
		total   = _rand(time), 
		subject = subject, 
		target  = target, 
		method  = method, 
		last_s  = 0, 
		payload = _calc_tween(subject, target, {}),
		after   = after or function() end, 
	}
	return tag
end

function Timer:once(action, tag) 
	return self:every(math.huge, action, tag) 
end

function Timer:always(action, each, tag)
	return self:during(math.huge, action, each, tag) 
end

function Timer:get(tag) 
	return self.timers[tag] 
end

function Timer:pause(tag) 
	self.timers[tag].status = 'pause' 
end

function Timer:play(tag) 
	self.timers[tag].status = 'play' 
end

function Timer:remove(tag) 
	self.timers[tag] = nil 
end

function Timer:destroy() 
	self.timers = {} 
end

return setmetatable({}, {__call = Timer.new})
