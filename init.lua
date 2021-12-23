-- a snippet to break out of inifinite loops
require("loopstop.lua")

--- FUNCTIONS
-- jumps super high immediately after rolling
function rolljump(interval)
     -- start running
     hs.eventtap.event.newKeyEvent("w", true):post()
     -- roll
     hs.eventtap.event.newKeyEvent("q", true):post()
     -- unpress roll after 0.1s for game to notice
     hs.timer.doAfter(0.1, function()
                        hs.eventtap.event.newKeyEvent("q", false):post()
     end)
     -- jump right after the roll ends
     hs.timer.doAfter(interval, function()
                        hs.eventtap.event.newKeyEvent("SPACE", true):post()
     end)
     -- unpress jump after 0.1s for the game to notice
     hs.timer.doAfter(0.1, function()
                        hs.eventtap.event.newKeyEvent("SPACE", false):post()
     end)
     -- unpress run after 0.1s to keep moving while in the air
     hs.timer.doAfter(1, function()
                        hs.eventtap.event.newKeyEvent("w", false):post()
     end)
end

-- sends message to local chat
function say(message)
     -- open chat
     -- high level "RETURN" here for concision
     hs.eventtap.keyStroke({}, "RETURN")
     -- type "Zzzzz...", "/s" for local chat
     hs.eventtap.keyStrokes("/s " .. message)
     -- send the message after a delay
     -- low level "RETURN" here for hs.timer to work properly
     hs.timer.doAfter(1, function()
                        hs.eventtap.event.newKeyEvent("RETURN", true):post()
     end)
     hs.timer.doAfter(0.1, function()
                        hs.eventtap.event.newKeyEvent("RETURN", false):post()
     end)
end

function toggle_timer(timer)
     if (timer:running())
     then timer.stop()
          timer:setDelay(1)
     else timer.start()
     end
end

---QUOTES

tanner_quotes = { "Leather! Fresh leather! You bring me hides and I tan them for you!",
                  "Best tanner in Veloren will tan hides for you! Discount for rumors!",
                  "Come north of Elden to the tanning racks! Will give leather for hides! ",
                  "Thick leather! Light leather! Bring hides and I will tan them for you!"
}

--- LOGGERS
logger_delay = hs.logger.new("delay", "info")

--- TIMERS

-- calls snore() every 10-30 seconds
snoring = hs.timer.delayed.new(1, function()
     say("Zzzzz...")
     snoring:setDelay(math.random(10, 30))
     snoring.start()
end)

tanner = hs.timer.delayed.new(1, function()
     say(tanner_quotes[math.random(1,#(tanner_quotes))])
     tanner:setDelay(math.random(20, 40))
     tanner.start()
     logger_delay:i(tanner:nextTrigger())
end)

--- BINDINGS

-- 0.55-0.58 is around roll end for superjump on 0 roll skill
hs.hotkey.bind({"cmd"}, "`", function() rolljump(0.56) end)

-- toogles "snoring"
hs.hotkey.bind({"cmd"}, "l", function() toggle_timer(snoring) end)
-- toogles "tanner" quotes
hs.hotkey.bind({"cmd"}, "k", function() toggle_timer(tanner) end)
