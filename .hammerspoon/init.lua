-- vim: foldmethod=marker
-- settings
hs.window.animationDuration = 0

-- hotkey prefix 
local hyper = {"cmd", "alt"}

require "layout"
require "vimkeys"
-- require "remap_capslock"

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

