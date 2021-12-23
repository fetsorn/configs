-- https://gist.github.com/asmagill/cf1d6398aecc2cee37af--
-- uses debug.sethook and a timer to break out of infinite loops in lua code within Hammerspoon
--
-- Haven't had any problems with it or false positives, but YMMV -- standard disclaimers, etc.
--
-- Updates 2015-12-21:
--      should play nicely with other hooks by storing info about it and chaining
--      you can force an "immediate" break by holding down CMD-CTRL-SHIFT-ALT-CAPSLOCK-FN all at once
--          you'll need to remove "and mods.fn" where noted below if your keyboard does not have this
--          modifier (non-laptops, I suspect)
--
-- Original Release Notes:
--
-- Motivation:  one day I was happily programming and testing and debugging, you know, fun stuff, right?  Well, at some point
-- I commented out something that wasn't working.  And it still wasn't working, so I commented out some more... and well,
-- eventually what used to be a nice loop with a well defined terminating condition ended up being the equivalant of
--
-- while true do end
--
-- Hammerspoon offers no way to break out of the lua interpreter without killing the whole application... looking closely
-- at the code, it's not an easy problem to fix without introducing a whole slew of issues having to do with the interpreters
-- state and re-entrancy and... well, it's not worth it for me to figure it out right now... so, this is the next best thing:
-- 
-- 1) start a timer that updates a global value with the current timestamp every 5 seconds
-- 2) use Lua's own debug library to set a hook which is executed every X # of commands (in this example 100)
-- 3) in this hook, check to see if the time stamp from step 1 is more than 30 seconds out of date... if so,
--       use lua's own error routines to break out of the loop
--
-- The hs.caffienate stuff is used to catch when the system is going to go to sleep to prevent it from being triggered
-- when the system wakes up.
--
-- There are probably other issues I haven't come across yet, but its been working quite nicely for me for some time now.
--
-- Known limitations:
--  it can't do anything about an inifinate loop within an external function (something added via the C-API)
--  other activities that block Hammerspoon could cause false positives (clicking on a menu item created within
--       Hammerspoon is a blocking activity -- all Hammerspoon code halts until you select a menu item or click
--       outside of the menu so it disappears)
--  the stack trace provided may or may not be useful for determining where the loop is occurring... if the lua code
--       which was running was in a callback from an external action (hotkey, timer, basically any callback which is
--       triggered by an action outside of the Hammerspoon console) then the traceback can only go back so far, and
--       can't always figure out what file/line the loop was in
--  if you're using debug.sethook for something else, you'll need to incorporate this code into it somehow...
--       assigning a hook replaces all others -- if anyone knows of a way to easily chain them, let me know in the
--       comments.
--
-- If you're still interested after reading all that, stick this module somewhere in your .hammerspoon directory and
-- then put something like require("thisfile")
--
-- in your init.lua file.
--
-- You can disable it at any time by typing 'debug.sethook()' in the Hammerspoon console.

local module = {}

local timer      = require("hs.timer")
local caffeinate = require("hs.caffeinate")
local eventtap   = require("hs.eventtap")

-- -- testing infinite loop detector with debug.sethook

local lastFn, lastMask, lastCount = debug.gethook()

local setHook = function(ourFn, ourMask, ourCount)
    if ourFn then
        lastFn, lastMask, lastCount = debug.gethook()
        if lastCount > 0 and lastCount < ourCount then ourCount = lastCount end
        for i = 1, #lastMask, 1 do
            if not ourMask:match(lastMask:sub(i,i)) then
                ourMask = ourMask..lastMask:sub(i,i)
            end
        end
--     print("*** setting Hook:", ourFn, ourMask.."("..#ourMask..")", ourCount)
        debug.sethook(ourFn, ourMask, ourCount)
    else
        debug.sethook(lastFn, lastMask, lastCount)
    end
end

module._loopTimeStamp = os.time()
module._loopTimer = timer.new(5, function() module._loopTimeStamp = os.time() end):start()
module._loopChecker = function(t,l)
    if lastFn then lastFn(t, l) end
    if (os.time() - module._loopTimeStamp) > 60 then
        module._loopTimeStamp = os.time()
        error("*** timeout -- infinite loop somewhere?\n\n"..debug.traceback(), 0)
    end
    local mods = eventtap.checkKeyboardModifiers()
-- remove "and mods.fn" if your keyboard does not have this key (non laptops most likely)
    if mods.capslock and mods.fn and mods.cmd and mods.ctrl and mods.alt and mods.shift then
        error("*** forced break\n\n"..debug.traceback(), 0)
    end
end

module._loopSleepWatcher = caffeinate.watcher.new(function(event)
    if event == caffeinate.watcher.systemDidWake then
        module._loopTimeStamp = os.time()
        setHook(module._loopChecker, "", 1000)
    elseif event == caffeinate.watcher.systemWillSleep then
        setHook(nil)
    end
end):start()

setHook(module._loopChecker, "", 1000)

return module
