-- vim: foldmethod=marker
-- settings
hs.window.animationDuration = 0

-- define screens {{{1
local dellScreen = "DELL U2414H"
local samsungScreen = "SMEX2220"
-- }}}1

-- hotkey prefix 
local hyper = {"cmd", "alt"}

-- define modal key {{{1
local modkey = hs.hotkey.modal.new('cmd-alt', 'h')
modkey:bind("", "escape", "", function()
  modkey:exit()
end)
modkey:bind({"ctrl"}, "[", "", function()
  modkey:exit()
end)

modkey:bind("", "R", "", function()
  hs.alert.show("Config loaded")
  hs.reload()
end)

hs.hotkey.bind({"cmd", "alt"}, "c", function()
  hs.openConsole(true)
end)
-- }}}1

-- define movements keys {{{1
-- deleted movements {{{2
-- function moveLeftTop()
--   local win = hs.window.focusedWindow()
--   local f = win:frame()
--
--   f.x = f.x - 10
--   f.y = f.y - 10
--   win:setFrame(f)
-- end
-- modkey:bind("", "Y", "", moveLeftTop, nil, moveLeftTop)
--
-- function moveUp()
--   local win = hs.window.focusedWindow()
--   local f = win:frame()
--
--   f.y = f.y - 10
--   win:setFrame(f)
-- end
-- modkey:bind("", "K", "", moveUp, nil, moveUp)
--
-- function moveRightTop()
--   local win = hs.window.focusedWindow()
--   local f = win:frame()
--
--   f.x = f.x + 10
--   f.y = f.y - 10
--   win:setFrame(f)
-- end
-- modkey:bind("", "U", "", moveRightTop, nil, moveRightTop);
--
-- function moveLeft()
--   local win = hs.window.focusedWindow()
--   local f = win:frame()
--
--   f.x = f.x - 10
--   win:setFrame(f)
-- end
-- modkey:bind("", "H", "", moveLeft, nil, moveLeft)
--
-- function moveRight()
--   local win = hs.window.focusedWindow()
--   local f = win:frame()
--
--   f.x = f.x + 10
--   win:setFrame(f)
-- end
-- modkey:bind("", "L", "", moveRight, nil, moveRight)
--
-- function moveLeftBottom()
--   local win = hs.window.focusedWindow()
--   local f = win:frame()
--
--   f.x = f.x - 10
--   f.y = f.y + 10
--   win:setFrame(f)
-- end
-- modkey:bind("", "B", "", moveLeftBottom, nil, moveLeftBottom)
--
-- function moveDown()
--   local win = hs.window.focusedWindow()
--   local f = win:frame()
--
--   f.y = f.y + 10
--   win:setFrame(f)
-- end
-- modkey:bind("", "J", "", moveDown, nil, moveDown)
--
-- function moveRightBottom()
--   local win = hs.window.focusedWindow()
--   local f = win:frame()
--
--   f.x = f.x + 10
--   f.y = f.y + 10
--   win:setFrame(f)
-- end
-- modkey:bind("", "N", "", moveRightBottom, nil, moveRightBottom)
-- }}}2

hs.hotkey.bind(hyper, "Left", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)

hs.hotkey.bind(hyper, "Right", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + (max.w / 2)
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)

hs.hotkey.bind(hyper, "Up", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w
  f.h = max.h / 2
  win:setFrame(f)
end)

hs.hotkey.bind(hyper, "Down", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y + (max.h / 2)
  f.w = max.w
  f.h = max.h / 2
  win:setFrame(f)
end)

hs.hotkey.bind(hyper, "f", function() 
  local win = hs.window.focusedWindow()
  if not win then
    return
  end
  
  local frame = win:frame()
  local id = win:id()

  -- init table to save window state
  savedwin = savedwin or {}
  savedwin[id] = savedwin[id] or {}

  if (savedwin[id].frame == nil) then
    savedwin[id].frame = frame
    win:maximize()
  else
    win:setFrame(savedwin[id].frame)
    savedwin[id] = nil
  end
end)

hs.grid.setGrid("5x4", dellScreen);
hs.grid.setGrid("6x4", samsungScreen);
hs.hotkey.bind(hyper, "g", hs.grid.show)
-- }}}1

-- define per-app hljk navigation keys  {{{1
local vimModKey = hs.hotkey.modal.new('cmd-alt', 'v')

vimModKey:bind("", "escape", "", function()
  vimModKey:exit()
end)
vimModKey:bind({"ctrl"}, "[", "", function()
  vimModKey:exit()
end)

local downFunc = function()
  hs.eventtap.keyStroke({}, 'down')
  -- hs.eventtap.scrollWheel({0, -1})
end
local upFunc = function()
  hs.eventtap.keyStroke({}, 'up')
end
local leftFunc = function()
  hs.eventtap.keyStroke({}, 'left')
end
local rightFunc = function() 
  hs.eventtap.keyStroke({}, 'right')
end
local pageDownFunc = function() 
  hs.eventtap.keyStroke({}, "pagedown")
end
local pageUpFunc = function()
  hs.eventtap.keyStroke({}, "pageup")
end

vimModKey:bind("", "j", downFunc,  nil, downFunc)
vimModKey:bind("", "k", upFunc,    nil, upFunc)
vimModKey:bind("", "h", leftFunc,  nil, leftFunc)
vimModKey:bind("", "l", rightFunc, nil, rightFunc)
vimModKey:bind({"ctrl"}, "f", pageDownFunc, nil, pageDownFunc)
vimModKey:bind({"ctrl"}, "b", pageUpFunc, nil, pageUpFunc)

vimModKey:bind("", "g", "", function()
  hs.eventtap.keyStroke({}, "home")
end):bind("shift", "g", "", function()
  hs.eventtap.keyStroke({}, "end")
end)

-- only enable the vimModKey for "iBooks" or "Dash" application
local watcher = hs.application.watcher.new(function(name, event, app)
  if name ~= "iBooks" and name ~= "Dash" and name ~= "Preview" then
    return 
  end
  
  if event == hs.application.watcher.activated or event == hs.application.watcher.launched or event == hs.application.watcher.unhidden then
    hs.timer.doAfter(0.1, function()
      vimModKey:enter()
    end)
  elseif event == hs.application.watcher.deactivated or event == hs.application.watcher.hidden or event == hs.application.watcher.terminated then
    vimModKey:exit()
  end
end)

watcher:start()

-- }}}1

-- define layouts {{{1
local defaultLayout = {
  {"Google Chrome", nil, dellScreen, hs.layout.maximized,    nil, nil},
  {"iTerm",  nil,  samsungScreen, hs.layout.maximized,   nil, nil},
  {"MacVim", nil, dellScreen, hs.layout.maximized,    nil, nil},
}

hs.hotkey.bind(hyper, "l", function()
  hs.layout.apply(defaultLayout)
end)
--}}}1

-- window hints {{{1
-- turn on hints.style will make hints more and more slow to show up, there should be a bug
-- hs.hints.style = "vimperator"
function showHints()
  hs.hints.windowHints()
end
hs.hotkey.bind({"cmd", "ctrl"}, "i", showHints)
-- }}}1

-- wifi events 
-- turn off audio volumn when not at home {{{1
local wifiWatcher = nil
local homeSSID = "FlyInAir"
local lastSSID = hs.wifi.currentNetwork()

function ssidChangedCallback()
  newSSID = hs.wifi.currentNetwork()

  if newSSID == homeSSID and lastSSID ~= homeSSID then
    -- We just joined our home WiFi network
    hs.audiodevice.defaultOutputDevice():setVolume(25)
  elseif newSSID ~= homeSSID and lastSSID == homeSSID then
    -- We just departed our home WiFi network
    hs.audiodevice.defaultOutputDevice():setVolume(0)
  end

  lastSSID = newSSID
end

wifiWatcher = hs.wifi.watcher.new(ssidChangedCallback)
wifiWatcher:start()
-- }}}1

