-- rolls, does not jump
hs.hotkey.bind({"cmd"}, "`", function()
     hs.eventtap.event.newKeyEvent("w", true):post()
     hs.eventtap.event.newKeyEvent("q", true):post()
     hs.timer.doAfter(0.1, function()
                        hs.eventtap.event.newKeyEvent("q", false):post()
     end)
     hs.timer.doAfter(0.3, function()
                        hs.eventtap.event.newKeyEvent("SPACE", true):post()
                        hs.timer.usleep(200000)
                        hs.eventtap.event.newKeyEvent("SPACE", false):post()
     end)
     hs.timer.doAfter(0.1, function()
                        hs.eventtap.event.newKeyEvent("w", false):post()
     end)
end)

-- rolls, jumps, stops moving, keeps jumping
hs.hotkey.bind({"cmd"}, "`", function()
     hs.eventtap.event.newKeyEvent("w", true):post()
     hs.eventtap.event.newKeyEvent("q", true):post()
     hs.timer.doAfter(0.1, function()
                        hs.eventtap.event.newKeyEvent("q", false):post()
     end)
     hs.timer.doAfter(0.1, function()
                        hs.eventtap.event.newKeyEvent("SPACE", true):post()
     end)
     hs.timer.doAfter(0.1, function()
                        hs.eventtap.event.newKeyEvent("SPACE", false):post()
     end)
     hs.timer.doAfter(1, function()
                        hs.eventtap.event.newKeyEvent("w", false):post()
     end)
     hs.eventtap.event.newKeyEvent("SPACE", false):post()
end)

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
     -- short jump again to stop jumping
end
  -- 0.55-0.58 is around roll end for superjump
hs.hotkey.bind({"cmd"}, "`", function() rolljump(0.56) end)
