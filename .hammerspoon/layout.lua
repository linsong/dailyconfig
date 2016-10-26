local hyper = {"cmd", "alt"}

local dellScreen = "DELL U2414H"
local samsungScreen = "SMEX2220"

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

-- layout
local defaultLayout = {
  {"Google Chrome", nil, dellScreen, hs.layout.maximized,    nil, nil},
  {"iTerm",  nil,  samsungScreen, hs.layout.maximized,   nil, nil},
  {"MacVim", nil, dellScreen, hs.layout.maximized,    nil, nil},
}

hs.hotkey.bind(hyper, "l", function()
  hs.layout.apply(defaultLayout)
end)

-- window hints
-- turn on hints.style will make hints more and more slow to show up, there should be a bug
-- hs.hints.style = "vimperator"
function showHints()
  hs.hints.windowHints()
end
hs.hotkey.bind({"cmd", "ctrl"}, "i", showHints)

