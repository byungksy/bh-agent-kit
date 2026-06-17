-- bh-agent-kit: cursor-agent-notify (append to ~/.hammerspoon/init.lua)
-- URL: hammerspoon://cursor-done?title=...&msg=...&duration=5

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

hs.urlevent.bind("cursor-done", function(_eventName, params)
  local ok, err = xpcall(showCursorDoneToast, debug.traceback, params)
  if not ok then
    hs.printf("cursor-done ERROR: %s", err)
    hs.alert.show("cursor-done 오류:\n" .. tostring(err), 8)
  end
end)
