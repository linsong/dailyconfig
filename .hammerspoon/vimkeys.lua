-- define per-app hljk navigation keys  
local vimNormKey = hs.hotkey.modal.new('cmd-alt', 'v')
vimNormKey["entered"] = function()
  hs.alert.show('Vim Mode On')
end

-- define mode switch keys
vimNormKey:bind("", "q", "", function()
  vimNormKey:exit()
  hs.alert.show('Vim Mode Off')
end)

-- hotkey functions 
local downFunc = function()
  hs.eventtap.keyStroke({}, 'down')
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
local startOfLineFunc = function() 
  hs.eventtap.keyStroke({'cmd'}, 'left')
end
local endOfLineFunc = function() 
  hs.eventtap.keyStroke({'cmd'}, 'right')
end
local startOfWordFunc = function() 
  hs.eventtap.keyStroke({'alt'}, 'left')
end
local endOfWordFunc = function() 
  hs.eventtap.keyStroke({'alt'}, 'right')
end
local pageDownFunc = function() 
  hs.eventtap.keyStroke({}, "pagedown")
end
local pageUpFunc = function()
  hs.eventtap.keyStroke({}, "pageup")
end

local deleteCharFunc = function() 
  hs.eventtap.keyStroke({}, "delete") 
end

local deleteFunc = function()
  hs.eventtap.keyStroke({'cmd'}, "delete") 
end
local rightClickFunc = function() 
  hs.eventtap.rightClick(hs.mouse.getAbsolutePosition())
end

vimNormKey:bind("", "j", downFunc,  nil, downFunc)
vimNormKey:bind("", "k", upFunc,    nil, upFunc)
vimNormKey:bind("", "h", leftFunc,  nil, leftFunc)
vimNormKey:bind("", "l", rightFunc, nil, rightFunc)
vimNormKey:bind("", 0x5E, nil, startOfLineFunc, nil)
vimNormKey:bind("", "0", nil, endOfLineFunc, nil)
vimNormKey:bind("", "b", nil, startOfWordFunc, nil)
vimNormKey:bind("", "w", nil, endOfWordFunc, nil)
vimNormKey:bind("", "e", nil, endOfWordFunc, nil)
vimNormKey:bind({'shift'}, "d", nil, deleteFunc, nil)
vimNormKey:bind({"ctrl"}, "f", pageDownFunc, nil, pageDownFunc)
vimNormKey:bind({"ctrl"}, "b", pageUpFunc, nil, pageUpFunc)

vimNormKey:bind("", "g", "", function()
  hs.eventtap.keyStroke({}, "home")
end):bind("shift", "g", "", function()
  hs.eventtap.keyStroke({}, "end")
end)

vimNormKey:bind({"ctrl"}, "h", deleteCharFunc, nil, deleteCharFunc)

vimNormKey:bind({}, 'i', function()
  vimNormKey:exit()
  hs.alert.show('Vim Mode Off')
end)
vimNormKey:bind({"shift"}, 'i', function()
    hs.eventtap.keyStroke({"cmd"}, "Left")
    vimNormKey:exit()
    hs.alert.show('Vim Mode Off')
end)
vimNormKey:bind({}, 'a', function()
    hs.eventtap.keyStroke({}, "Right")
    vimNormKey:exit()
    hs.alert.show('Vim Mode Off')
end)
vimNormKey:bind({"shift"}, 'a', function()
    hs.eventtap.keyStroke({"cmd"}, "Right")
    vimNormKey:exit()
    hs.alert.show('Vim Mode Off')
end)
vimNormKey:bind({}, 'o', nil, function()
    local app = hs.application.frontmostApplication()
    if app:name() == "Finder" then
      hs.eventtap.keyStroke({"cmd"}, "o")
    else
      hs.eventtap.keyStroke({"cmd"}, "Right")
      vimNormKey:exit()
      hs.eventtap.keyStroke({}, "Return")
      hs.alert.show('Vim Mode Off')
    end
end)
vimNormKey:bind({"shift"}, 'o', nil, function()
    local app = hs.application.frontmostApplication()
    if app:name() == "Finder" then
      hs.eventtap.keyStroke({"cmd", "shift"}, "o")
    else
      hs.eventtap.keyStroke({"cmd"}, "Left")
      vimNormKey:exit()
      hs.eventtap.keyStroke({}, "Return")
      hs.eventtap.keyStroke({}, "Up")
      hs.alert.show('Vim Mode Off')
    end
end)

vimNormKey:bind({}, "m", rightClickFunc)

-- only enable the vimNormKey for "iBooks" or "Dash" application
local watcher = hs.application.watcher.new(function(name, event, app)
  if event == hs.application.watcher.deactivated or event == hs.application.watcher.hidden or event == hs.application.watcher.terminated then
    vimNormKey:exit()
  end

  -- auto start vim mode for below apps
  if name ~= "iBooks" and name ~= "Dash" and name ~= "Preview" then
    return 
  end
  
  if event == hs.application.watcher.activated or event == hs.application.watcher.launched or event == hs.application.watcher.unhidden then
    hs.timer.doAfter(0.1, function()
      vimNormKey:enter()
    end)
  end
end)

watcher:start()
