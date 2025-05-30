os.loadAPI("cassapi.lua");

PromptPath = "prompts.data";
PromptPrefix = "@"
UserPrefix = "#";

LoadedCassPassInfo = nil;

function GetPrompts()
    local exists = fs.exists(PromptPath);
    if exists == false or exists == nil then
        return nil;
    end
    local prompts = {};
    local file = fs.open(PromptPath, "r");
    local line = file.readLine();
    while line ~= nil do
        local token = string.sub(line,1,1);
        if token == PromptPrefix then
            table.insert(prompts, string.sub(line,2,string.len(line)));
        end
        line = file.readLine();
    end
    return prompts;
end

function CreatePrompt()
    local answer = nil;
    local question = nil;
    while answer == nil or answer == false do
        term.clear();
        term.setTextColor(colors.yellow);
        term.setCursorPos(1,1);
        print("Ask a yes or no question that people will be able to bet on, you excluded.")
        term.setTextColor(colors.white);
        question = read();
        if cassapi.IsNullOrEmpty(question) == false then
            term.setTextColor(colors.yellow);
            print("Confirm?")
            answer = cassapi.GetUserYesNo();
        else
            term.setTextColor(colors.red);
            print("Invalid question.")
            sleep(1);
        end
    end
    -- opens in write or append depending if it exists or not
    local file = fs.open(PromptPath, fs.exists(PromptPath) and "a" or "w");
    file.writeLine(PromptPrefix .. cassapi.GetCassPassName(LoadedCassPassInfo) .. PromptPrefix .. question);
    file.close();
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
    LoadedCassPassInfo = cassapi.ValidateCassPass();
    if LoadedCassPassInfo == nil then
        disk.eject(diskDirection);
        term.clear();
        term.setTextColor(colors.red);
        term.setCursorPos(1,1);
        label = nil;
        print("Invalid disk, not a valid casspass");
        sleep(5);
        return;
    elseif LoadedCassPassInfo == false then
        disk.eject(diskDirection);
        term.clear();
        term.setTextColor(colors.red);
        term.setCursorPos(1,1);
        label = nil;
        print("Invalid disk, outdated casspass");
        sleep(5);
        return;
    else
        local prompts = GetPrompts();
        if prompts == nil then
            local answer = nil;
            while answer == nil or answer == false do
                term.clear();
                term.setTextColor(colors.white);
                term.setCursorPos(1,1);
                print("No prompts to bet on.");
                term.setTextColor(colors.yellow);
                print("Create prompt?");
                answer = cassapi.GetUserYesNo();
            end
            CreatePrompt();
        else
            Crash(); -- If I hit this line all my code works for now
        end
    end
end

function Main()
    while true do
        LoopFunc();
    end
end

Main();