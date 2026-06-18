local bh_gui = {}

local webview = nil
local activeTask = nil

-- ~/bin 디렉토리에서 bh-* 파일 목록을 가져오는 함수 (bh-gui 제외)
local function getBhScripts()
    local binPath = os.getenv("HOME") .. "/bin"
    local scripts = {}
    
    -- hs.fs.dir을 사용해 디렉토리 내 파일 스캔
    for file in hs.fs.dir(binPath) do
        if file:match("^bh%-") and file ~= "bh-gui" then
            table.insert(scripts, file)
        end
    end
    
    table.sort(scripts)
    return scripts
end

-- GUI를 생성하고 화면에 띄우는 함수
function bh_gui.show()
    if webview then
        webview:show()
        webview:focus()
        -- 매번 열릴 때마다 스크립트 목록 새로고침하여 웹뷰에 전달
        local scripts = getBhScripts()
        local json = hs.json.encode(scripts)
        webview:evaluateJavaScript(string.format("setScripts(%s)", json))
        return
    end

    -- 화면 크기를 가져와서 적절한 중앙 위치 선정
    local mainScreen = hs.screen.mainScreen()
    local screenFrame = mainScreen:frame()
    local width = 850
    local height = 580
    local rect = hs.geometry.rect(
        screenFrame.x + (screenFrame.w - width) / 2,
        screenFrame.y + (screenFrame.h - height) / 2,
        width,
        height
    )

    -- 웹뷰 인스턴스 생성
    webview = hs.webview.new(rect, { developerExtrasEnabled = true })
    webview:windowStyle(hs.webview.windowMasks.titled | hs.webview.windowMasks.closable | hs.webview.windowMasks.resizable)
    webview:title("BH Workspace Script Console")
    
    -- HTML 로드
    local htmlPath = os.getenv("HOME") .. "/.hammerspoon/gui/index.html"
    webview:loadFile(htmlPath)

    -- 창이 닫힐 때 객체 정리
    webview:windowCallback(function(action)
        if action == "closing" then
            webview = nil
            if activeTask then
                activeTask:terminate()
                activeTask = nil
            end
        end
    end)

    -- 자바스크립트와의 통신 브릿지 설정
    local usercontent = webview:usercontent()
    usercontent:setCallback(function(message)
        local data = message.body
        
        if data.action == "loadScripts" then
            -- 웹뷰가 최초 로드되었을 때 스크립트 목록 전송
            local scripts = getBhScripts()
            local json = hs.json.encode(scripts)
            webview:evaluateJavaScript(string.format("setScripts(%s)", json))
            
        elseif data.action == "runScript" then
            -- 기존 실행 중인 테스크 중단
            if activeTask then
                activeTask:terminate()
                activeTask = nil
            end

            local scriptName = data.scriptName
            local scriptPath = os.getenv("HOME") .. "/bin/" .. scriptName
            
            -- 입력된 인자값 처리 (공백 기준으로 테이블로 분리)
            local args = {}
            if data.args and data.args ~= "" then
                for arg in string.gmatch(data.args, "[^%s]+") do
                    table.insert(args, arg)
                end
            end

            -- 실시간 쉘 스크립트 실행
            activeTask = hs.task.new(scriptPath, 
                -- 1) 완료 콜백
                function(exitCode, stdOut, stdErr)
                    activeTask = nil
                    webview:evaluateJavaScript(string.format("onScriptComplete(%d)", exitCode))
                end, 
                -- 2) 실시간 스트리밍 콜백
                function(task, stdOut, stdErr)
                    if stdOut and stdOut ~= "" then
                        local encoded = hs.json.encode(stdOut)
                        webview:evaluateJavaScript(string.format("appendLog(%s, 'stdout')", encoded))
                    end
                    if stdErr and stdErr ~= "" then
                        local encoded = hs.json.encode(stdErr)
                        webview:evaluateJavaScript(string.format("appendLog(%s, 'stderr')", encoded))
                    end
                    return true
                end, 
                args
            )

            if activeTask:start() then
                webview:evaluateJavaScript("appendLog('>> 스크립트 실행 시작...\\n', 'system')")
            else
                webview:evaluateJavaScript("appendLog('>> 에러: 스크립트 프로세스 시작 실패\\n', 'stderr')")
                webview:evaluateJavaScript("onScriptComplete(-1)")
                activeTask = nil
            end

        elseif data.action == "stopScript" then
            if activeTask then
                activeTask:terminate()
                activeTask = nil
                webview:evaluateJavaScript("appendLog('\\n>> 사용자에 의해 스크립트가 강제 중단되었습니다.\\n', 'system')")
                webview:evaluateJavaScript("onScriptComplete(-9)9")
            end
        end
    end)

    webview:show()
    webview:focus()
end

-- hammerspoon://bh-gui URL 이벤트 바인딩
hs.urlevent.bind("bh-gui", function(eventName, params)
    bh_gui.show()
end)

-- 단축키 바인딩 (Alt + Shift + G)
hs.hotkey.bind({"alt", "shift"}, "G", function()
    bh_gui.show()
end)

return bh_gui
