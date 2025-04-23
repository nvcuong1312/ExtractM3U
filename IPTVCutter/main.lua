local love = require("love")
local Config = require("config")
local Keyboard = require("keyboard")
local Font = require("font")
local Color = require("color")

local isKeyboarFocus = false
local keyboardText = ""

local downloadedData = {}

local cPage = 1
local cIdx = 1

function love.load()
    Font.Load()
    Keyboard:create()

    local searchCmd = "wget .. " .. Config.FILE_URL .. " .. -O data/fileData"
    os.execute(searchCmd)

    local file = io.open("data/fileData", "r")
    if file then
        local content = file:read("*a")
        downloadedData = {}
        for line in content:gmatch("[^\r\n]+") do
            table.insert(downloadedData, line)
        end
        file:close()
    end
end

function love.draw()
    love.graphics.setFont(Font.Normal())
    local idxStart = cPage * Config.GRID_PAGE_ITEM - Config.GRID_PAGE_ITEM + 1
    local idxEnd = cPage * Config.GRID_PAGE_ITEM
    local iPos = 0

    local total = table.getn(downloadedData)
    local xPos = 0
    local yPos = 0
    local widthItem = 640
    local heightItem = 20

    for i = idxStart, idxEnd do
        if i > total then break end
        local h = heightItem * (iPos) + iPos + 1
        love.graphics.setColor(1,1,1)
        love.graphics.print(downloadedData[i], xPos, yPos + h)

        if cIdx == iPos + 1 then
            love.graphics.setColor(0.3,0.3,0.3, 0.4)
            love.graphics.rectangle("fill", xPos, yPos + h, widthItem, heightItem)
        end

        iPos = iPos + 1
    end

    if isKeyboarFocus then
        love.graphics.setFont(Font.Normal())
        love.graphics.setColor(0.6, 0.6, 0.6)
        love.graphics.rectangle("fill", 160, 345, 300, 30)
        love.graphics.setColor(0,0,0)
        love.graphics.print(keyboardText, 162, 345)
    end

    love.graphics.setColor(1,1,1)
    Keyboard:draw(isKeyboarFocus)
end

function love.update(dt)

end

function love.gamepadpressed(joystick, button)
    local key = ""
    if button == "dpleft" then
        key = "left"
    end
    if button == "dpright" then
        key = "right"
    end
    if button == "dpup" then
        key = "up"
    end
    if button == "dpdown" then
        key = "down"
    end
    if button == "a" then
        key = "a"
    end
    if button == "b" then
        key = "b"
    end
    if button == "x" then
        key = "x"
    end
    if button == "y" then
        key = "y"
    end
    if button == "back" then
        key = "select"
    end
    if button == "start" then
        key = "start"
    end
    if button == "leftshoulder" then
        key = "l1"
    end
    if button == "rightshoulder" then
        key = "r1"
    end
    if button == "guide" then
        key = "guide"
    end

    OnKeyPress(key)
end

function love.keypressed(key)
    if key == "s" then
        OnKeyPress("start")
        return
    end
	OnKeyPress(key)
end

function OnKeyboarCallBack(value, isDelete)
    if isDelete then
        if #keyboardText > 0 then
            keyboardText = string.sub(keyboardText, 1, #keyboardText - 1)
        end
    else
        if #keyboardText < 30 then
            keyboardText = keyboardText .. value
        end
    end
end

function OnKeyPress(key)
    if isLoading then return end

    if key == "l1" or key == "l" then
        isKeyboarFocus = not isKeyboarFocus
    end

    if isKeyboarFocus then
        if key == "b" then
            isKeyboarFocus = false
            return
        end

        if key == "start" then
            if #keyboardText > 0 then
                local pos = (cPage - 1) * Config.GRID_PAGE_ITEM + cIdx
                if table.getn(downloadedData) >= pos  then
                    local filePath = Config.SAVE_PATH .. keyboardText .. ".m3u"
                    local file = io.open(filePath, "r")
                    if file then
                        file:close()
                        os.remove(filePath)
                    end

                    local file = io.open(filePath, "a")
                    if file then
                        file:write(downloadedData[pos])
                        file:close()
                    end
                end
            end

            keyboardText = ""
            isKeyboarFocus = false
            return
        end

        Keyboard.keypressed(key, OnKeyboarCallBack)
        return
    end

    if key == "a" then
        isKeyboarFocus = true
    end

    if table.getn(downloadedData) > 0 then
        if key == "up" then
            GridKeyUp(downloadedData, cPage, cIdx, Config.GRID_PAGE_ITEM,
                function(idx) cIdx = idx end,
                function(page) cPage = page end)
        end

        if key == "down" then
            GridKeyDown(downloadedData, cPage, cIdx, Config.GRID_PAGE_ITEM,
                function(idx) cIdx = idx end,
                function(page) cPage = page end)
        end

        if key == "left" then
            GridKeyLeft(downloadedData, cPage, cIdx, Config.GRID_PAGE_ITEM,
                function(idx) cIdx = idx end,
                function(page) cPage = page end)
        end

        if key == "right" then
            GridKeyRight(downloadedData, cPage, cIdx, Config.GRID_PAGE_ITEM,
                function(idx) cIdx = idx end,
                function(page) cPage = page end)
        end
    end
end

 function GridKeyUp(list,currPage, idxCurr, maxPageItem, callBackSetIdx, callBackChangeCurrPage)
    local total = table.getn(list)
    if total < 1 or total == 1 then return end
    local isMultiplePage = total > maxPageItem
    if isMultiplePage then
        local remainder = total % maxPageItem
        local totalPage = 1
        local q, _ = math.modf(total / maxPageItem)
        if remainder > 0 then
            totalPage =  q + 1
        else
            totalPage = q
            remainder = maxPageItem
        end

        if currPage > 1 then
            if idxCurr > 1 then
                callBackSetIdx(idxCurr - 1)
            else
                if callBackChangeCurrPage then callBackChangeCurrPage(currPage - 1) end
                callBackSetIdx(maxPageItem)
            end
        else
            if idxCurr > 1 then
                callBackSetIdx(idxCurr - 1)
            else
                if callBackChangeCurrPage then callBackChangeCurrPage(totalPage) end
                callBackSetIdx(remainder)
            end
        end
    else
        if idxCurr > 1 then
            callBackSetIdx(idxCurr - 1)
        else
            callBackSetIdx(total)
        end
    end
end

function GridKeyDown(list, currPage, idxCurr, maxPageItem, callBackSetIdx, callBackChangeCurrPage)
    local total = table.getn(list)
    if total < 1 or total == 1 then return end
    local isMultiplePage = total > maxPageItem
    if isMultiplePage then
        local remainder = total % maxPageItem
        local totalPage = 1
        local q, _ = math.modf(total / maxPageItem)
        if remainder > 0 then
            totalPage =  q + 1
        else
            totalPage = q
            remainder = maxPageItem
        end

        if currPage < totalPage then
            if idxCurr < maxPageItem then
                callBackSetIdx(idxCurr + 1)
            else
                if callBackChangeCurrPage then callBackChangeCurrPage(currPage + 1) end
                callBackSetIdx(1)
            end
        else
            if  idxCurr < remainder then
                callBackSetIdx(idxCurr + 1)
            else
                if callBackChangeCurrPage then callBackChangeCurrPage(1) end
                callBackSetIdx(1)
            end
        end
    else
        if idxCurr < total then
            callBackSetIdx(idxCurr + 1)
        else
            callBackSetIdx(1)
        end
    end
end

function GridKeyLeft(list, currPage, idxCurr, maxPageItem, callBackSetIdx, callBackChangeCurrPage)
    local total = table.getn(list)
    if total < 1 or total == 1 then return end
    local isMultiplePage = total > maxPageItem
    if isMultiplePage then
        local remainder = total % maxPageItem
        local totalPage = 1
        local q, _ = math.modf(total / maxPageItem)
        if remainder > 0 then
            totalPage =  q + 1
        else
            totalPage = q
            remainder = maxPageItem
        end

        if currPage > 1 then
            callBackChangeCurrPage(currPage - 1)
            callBackSetIdx(1)
        end
    end
end

function GridKeyRight(list, currPage, idxCurr, maxPageItem, callBackSetIdx, callBackChangeCurrPage)
    local total = table.getn(list)
    if total < 1 or total == 1 then return end
    local isMultiplePage = total > maxPageItem
    if isMultiplePage then
        local remainder = total % maxPageItem
        local totalPage = 1
        local q, _ = math.modf(total / maxPageItem)
        if remainder > 0 then
            totalPage =  q + 1
        else
            totalPage = q
            remainder = maxPageItem
        end

        if currPage < totalPage then
            callBackChangeCurrPage(currPage + 1)
            callBackSetIdx(1)
        end
    end
end