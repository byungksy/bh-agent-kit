-- 한/영 오로라
require("hs.ipc")
require('modules.inputsource_aurora')

local hyper = {"cmd", "ctrl", "shift", "alt"}

-- Window Management (방향키 멀티탭 기능 적용)
local doubleTapTime = 0.4 -- 연속 입력 허용 시간 (초)
local tapState = {
  up    = { count = 0, lastTime = 0 },
  left  = { count = 0, lastTime = 0 },
  right = { count = 0, lastTime = 0 }
}

-- [UP] 1번: 위쪽 절반 / 2번: 전체화면
hs.hotkey.bind(hyper, "up", function()
  local now = hs.timer.secondsSinceEpoch()
  local state = tapState.up
  if now - state.lastTime < doubleTapTime then
    state.count = state.count + 1
  else
    state.count = 1
  end
  state.lastTime = now

  local win = hs.window.focusedWindow()
  if not win then return end

  if state.count == 1 then
    win:moveToUnit({x=0, y=0, w=1, h=0.5})
  elseif state.count == 2 then
    win:moveToUnit({x=0, y=0, w=1, h=1})
    state.count = 0
  end
end)

-- [DOWN] 기존대로 아래쪽 절반
hs.hotkey.bind(hyper, "down", function()
  local win = hs.window.focusedWindow()
  if win then
    win:moveToUnit({x=0, y=0.5, w=1, h=0.5})
  end
end)

-- [LEFT] 1번: 왼쪽 절반 / 2번: 왼쪽 위 / 3번: 왼쪽 아래
hs.hotkey.bind(hyper, "left", function()
  local now = hs.timer.secondsSinceEpoch()
  local state = tapState.left
  if now - state.lastTime < doubleTapTime then
    state.count = state.count + 1
  else
    state.count = 1
  end
  state.lastTime = now

  local win = hs.window.focusedWindow()
  if not win then return end

  if state.count == 1 then
    win:moveToUnit({x=0, y=0, w=0.5, h=1})
  elseif state.count == 2 then
    win:moveToUnit({x=0, y=0, w=0.5, h=0.5})
  elseif state.count == 3 then
    win:moveToUnit({x=0, y=0.5, w=0.5, h=0.5})
    state.count = 0
  end
end)

-- [RIGHT] 1번: 오른쪽 절반 / 2번: 오른쪽 위 / 3번: 오른쪽 아래
hs.hotkey.bind(hyper, "right", function()
  local now = hs.timer.secondsSinceEpoch()
  local state = tapState.right
  if now - state.lastTime < doubleTapTime then
    state.count = state.count + 1
  else
    state.count = 1
  end
  state.lastTime = now

  local win = hs.window.focusedWindow()
  if not win then return end

  if state.count == 1 then
    win:moveToUnit({x=0.5, y=0, w=0.5, h=1})
  elseif state.count == 2 then
    win:moveToUnit({x=0.5, y=0, w=0.5, h=0.5})
  elseif state.count == 3 then
    win:moveToUnit({x=0.5, y=0.5, w=0.5, h=0.5})
    state.count = 0
  end
end)

-- [F] 전체화면 (보조 단축키 유지)
hs.hotkey.bind(hyper, "f", function()
  local win = hs.window.focusedWindow()
  if win then
    win:moveToUnit({x=0, y=0, w=1, h=1})
  end
end)

-- App Focus
local apps = {
  w = "WebStorm",
  c = "Cursor",
  t = "iTerm2",
  s = "Slack",
}

for key, app in pairs(apps) do
  hs.hotkey.bind(hyper, key, function()
    hs.application.launchOrFocus(app)
  end)
end

-- 앱별 자동 레이아웃
local appLayouts = {
  ["WebStorm"] = {x=0,   y=0, w=0.6, h=1},
  ["Cursor"]   = {x=0.6, y=0, w=0.4, h=1},
  ["Slack"]    = {x=0.7, y=0, w=0.3, h=1},
}

hs.application.watcher.new(function(name, event)
  if event == hs.application.watcher.activated then
    local pos = appLayouts[name]
    if pos then
      hs.window.focusedWindow():moveToUnit(pos)
    end
  end
end):start()

-- ────────────────────────────────────────────────────────────
-- Morning Brief: 회사 Wi-Fi 연결 시 자동 실행
-- launcher가 중복 방지(lock file)와 시간 범위(05~11시)를 처리함
-- ────────────────────────────────────────────────────────────
local OFFICE_SSID = "11st-office"
local BRIEF_CMD   = os.getenv("HOME") .. "/.agents/scripts/bh-morning-brief-launcher"

local wifiWatcher = hs.wifi.watcher.new(function()
  local ssid = hs.wifi.currentNetwork()
  if ssid == OFFICE_SSID then
    hs.task.new(BRIEF_CMD, function(exitCode, _, stderr)
      if exitCode ~= 0 and stderr ~= "" then
        hs.notify.new({
          title    = "Morning Brief 오류",
          informativeText = stderr:sub(1, 120),
        }):send()
      end
    end):start()
  end
end)
wifiWatcher:start()

-- cmd+shift+O: 클립보드 내용에 따라 자동 분기
--   https?:// → Chrome
--   파일 경로 + .md/.ts/.js 등 → Cursor
--   파일 경로 + 그 외 → WebStorm
hs.hotkey.bind({"cmd", "shift"}, "O", function()
  hs.eventtap.keyStroke({"cmd"}, "c")
  hs.timer.doAfter(0.1, function()
    local clip = hs.pasteboard.getContents()
    if not clip then return end

    if clip:match("^https?://") then
      hs.urlevent.openURLWithBundle(clip, "com.google.Chrome")
    elseif clip:match("^/") or clip:match("^~") then
      local path = clip:gsub("^~", os.getenv("HOME"))
      local ext = path:match("%.([^%.]+)$") or ""
      local cursorExts = { md=1, txt=1, ts=1, tsx=1, js=1, jsx=1, json=1,
                           lua=1, py=1, sh=1, yaml=1, yml=1, toml=1, css=1, html=1 }
      if ext == "md" then
        hs.task.new(os.getenv("HOME") .. "/bin/bh-edit-md", nil, {path}):start()
      elseif cursorExts[ext] then
        hs.task.new("/usr/local/bin/cursor", nil, {"--goto", path}):start()
      else
        hs.task.new("/Applications/WebStorm.app/Contents/MacOS/webstorm", nil, {path}):start()
      end
    end
  end)
end)

-- BH Workspace GUI Console 연동
require('modules.bh_gui')

local function urlDecode(value)
  if not value or value == "" then
    return ""
  end
  return (value:gsub("%%(%x%x)", function(hex)
    return string.char(tonumber(hex, 16))
  end))
end

local function showCursorDoneToast(params)
  hs.printf("cursor-done params: %s", hs.inspect(params))

  local title = urlDecode(params.title or params["title"] or "")
  if title == "" then
    title = "작업 완료"
  end

  local msg = urlDecode(params.msg or params["msg"] or "")
  if msg == "" then
    msg = "에이전트 처리가 완료되었습니다. 클릭하면 Cursor로 이동합니다."
  end

  local duration = tonumber(params.duration or params["duration"]) or 5

  hs.notify.new(function(_notification)
    hs.application.launchOrFocus("Cursor")
  end, {
    title = title,
    informativeText = msg,
    withdrawAfter = duration,
  }):send()

  hs.printf("cursor-done notify sent (withdrawAfter=%s)", tostring(duration))
end

-- 쉘 스크립트 연동을 위한 Custom URL Scheme 리스너
hs.urlevent.bind("alert", function(eventName, params)
  if params["msg"] then
    hs.alert.show(params["msg"])
  end
end)

hs.urlevent.bind("notify", function(eventName, params)
  hs.notify.new({
    title = params["title"] or "Hammerspoon",
    subtitle = params["subtitle"] or "",
    informativeText = params["msg"] or ""
  }):send()
end)

hs.urlevent.bind("cursor-done", function(_eventName, params)
  local ok, err = xpcall(showCursorDoneToast, debug.traceback, params)
  if not ok then
    hs.printf("cursor-done ERROR: %s", err)
    hs.alert.show("cursor-done 오류:\n" .. tostring(err), 8)
  end
end)

-- Reload 직후 알림 권한 스모크 테스트 (Console에 'reload smoke test sent' 확인)
hs.timer.doAfter(1, function()
  hs.notify.new({
    title = "Hammerspoon Reload OK",
    informativeText = "이 알림이 보이면 hs.notify 정상입니다.",
    withdrawAfter = 5,
  }):send()
  hs.printf("reload smoke test sent")
end)
