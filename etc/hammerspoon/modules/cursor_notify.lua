local M = {}

local CURSOR_APP = "Cursor"
local DEFAULT_DURATION_SEC = 5

local function urlDecode(value)
  if not value or value == "" then
    return ""
  end
  return (value:gsub("%%(%x%x)", function(hex)
    return string.char(tonumber(hex, 16))
  end))
end

local function focusCursor()
  hs.application.launchOrFocus(CURSOR_APP)
end

local function onNotifyClick(notification)
  local activation = hs.notify.activationTypes[notification:activationType()]
  if activation == "contentsClicked" or activation == "actionButtonClicked" then
    focusCursor()
  end
end

function M.showDoneToast(params)
  local title = urlDecode(params.title) or "작업 완료"
  local msg = urlDecode(params.msg) or "에이전트 처리가 완료되었습니다."
  local duration = tonumber(params.duration) or DEFAULT_DURATION_SEC

  hs.notify.new(onNotifyClick, {
    title = title,
    informativeText = msg,
    withdrawAfter = duration,
  }):send()
end

return M
