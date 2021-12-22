--- FUNCTIONS
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

function snore()
     hs.timer.doAfter(1, function()
                        hs.eventtap.event.newKeyEvent("RETURN", true):post()
     end)
     hs.timer.doAfter(0.1, function()
                        hs.eventtap.event.newKeyEvent("RETURN", false):post()
     end)
     hs.eventtap.keyStrokes("/s Zzzzz...")
     hs.timer.doAfter(1, function()
                        hs.eventtap.event.newKeyEvent("RETURN", true):post()
     end)
     hs.timer.doAfter(0.1, function()
                        hs.eventtap.event.newKeyEvent("RETURN", false):post()
     end)
end

--- TIMERS
snoring = hs.timer.delayed.new(math.random(20, 60), function()
     snore()
     snoring.start()
end)

--- BINDINGS

-- 0.55-0.58 is around roll end for superjump on 0 roll skill
hs.hotkey.bind({"cmd"}, "`", function() rolljump(0.56) end)

hs.hotkey.bind({"cmd"}, "l", function()
          if (snoring:running())
          then snoring.stop()
          else snoring.start()
          end
end)
