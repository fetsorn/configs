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

-- sends "Zzzzz..." to local chat
function snore()
     -- open chat
     -- high level "RETURN" here for concision
     hs.eventtap.keyStroke({}, "RETURN")
     -- type "Zzzzz...", "/s" for local chat
     hs.eventtap.keyStrokes("/s Zzzzz...")
     -- send the message after a delay
     -- low level "RETURN" here for hs.timer to work properly
     hs.timer.doAfter(1, function()
                        hs.eventtap.event.newKeyEvent("RETURN", true):post()
     end)
     hs.timer.doAfter(0.1, function()
                        hs.eventtap.event.newKeyEvent("RETURN", false):post()
     end)
end

--- TIMERS
-- calls snore() every 10-30 seconds
snoring = hs.timer.delayed.new(1, function()
     snore()
     snoring:setDelay(math.random(10, 30))
     snoring.start()
end)

--- BINDINGS

-- 0.55-0.58 is around roll end for superjump on 0 roll skill
hs.hotkey.bind({"cmd"}, "`", function() rolljump(0.56) end)

-- toogles the "snoring" timer
hs.hotkey.bind({"cmd"}, "l", function()
          if (snoring:running())
          then snoring.stop()
               snoring:setDelay(1)
          else snoring.start()
          end
end)
