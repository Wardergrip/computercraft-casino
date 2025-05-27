os.loadAPI("cassapi.lua");

PromptPrefix = "@"
UserPrefix = "#";

function GetPrompts()
    local exists = fs.exists("prompts.data");
    if exists == false or exists == nil then
        return nil;
    end
    local prompts = {};
    local file = fs.open("prompts.data", "r");
    local line = file.readLine();
    while line ~= nil do
        local token = string.sub(line,1,1);
        if token == PromptPrefix then
            prompts.insert(string.sub(line,2,string.len(line)));
        end
        line = file.readLine();
    end
    return prompts;
end

function LoopFunc()
    cassapi.AskForDisk();
    local diskDirection = cassapi.WaitForDisk();
    local label = disk.getLabel(diskDirection);
            
    if label == nil then
        disk.eject();
        term.clear();
        term.setTextColor(colors.red);
        term.setCursorPos(1,1);
        print("Invalid disk, no label");
        sleep(5);
        return;
    end
    local cassPassInfo = cassapi.ValidateCassPass();
    if cassPassInfo == nil then
        disk.eject(diskDirection);
        term.clear();
        term.setTextColor(colors.red);
        term.setCursorPos(1,1);
        label = nil;
        print("Invalid disk, not a valid casspass");
        sleep(5);
        return;
    elseif cassPassInfo == false then
        disk.eject(diskDirection);
        term.clear();
        term.setTextColor(colors.red);
        term.setCursorPos(1,1);
        label = nil;
        print("Invalid disk, outdated casspass");
        sleep(5);
        return;
    else
        --local prompts = GetPrompts();
    end
end

function Main()
    while true do
        LoopFunc();
    end
end

Main();