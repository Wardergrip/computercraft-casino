os.loadAPI("cassapi.lua");

PromptPath = "prompts.data";
PromptPrefix = "@"
UserPrefix = "#";

LoadedCassPassInfo = nil;

local function ExtractPromptAuthors(prompts)
    local usernames = {}
    for _, prompt in ipairs(prompts) do
        local firstAt = string.find(prompt, "@", 1, true)
        local secondAt = string.find(prompt, "@", firstAt + 1, true)
        if firstAt and secondAt then
            local username = string.sub(prompt, firstAt + 1, secondAt - 1)
            table.insert(usernames, username)
        else
            table.insert(usernames, nil)
        end
    end
    return usernames
end

local function ExtractFormattedPrompts(prompts)
    local contents = {}
    for _, prompt in ipairs(prompts) do
        local secondAt = string.find(prompt, "@", string.find(prompt, "@", 1, true) + 1, true)
        if secondAt then
            local content = string.sub(prompt, secondAt + 1)
            table.insert(contents, content)
        else
            table.insert(contents, nil)
        end
    end
    return contents
end

function GetPromptsRaw()
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
            table.insert(prompts, line);
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
        local rawPrompts = GetPromptsRaw();
        if rawPrompts == nil then
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
            local answer = nil;
            local prompts = {};
            local users = {};
            while answer == nil do
                term.clear();
                term.setTextColor(colors.yellow);
                term.setCursorPos(1,1);
                print("Current prompts:");
                term.setTextColor(colors.lightBlue);
                prompts = ExtractFormattedPrompts(rawPrompts);
                users = ExtractPromptAuthors(rawPrompts);
                for i, prompt in ipairs(prompts) do
                    print("[" .. i .. "] " .. prompt .. "By " .. users[i]);
                end
                print(cassapi.EmptyString);
                term.setTextColor(colors.yellow);
                print("Reply Y to bet, reply N to make a prompt or fill in prompt result");
                answer = cassapi.GetUserYesNo();
            end

            if answer == false then
                local hasPrompt = false;
                for i, user in ipairs(users) do
                    if user == cassapi.GetCassPassName(LoadedCassPassInfo) then
                        hasPrompt = true;
                        break;
                    end
                end
                if hasPrompt == false then
                    CreatePrompt();
                else
                    -- TODO: Ask if user wants to set outcome or cancel
                    -- If outcome, remove entry from prompts.data
                    -- and write balances to balances.data
                    -- TODO: handle balances.data
                end
            else
                term.setTextColor(colors.yellow);
                print("Enter the number you want to make a bet on");
                -- TODO:
            end
        end
    end
end

function Main()
    while true do
        LoopFunc();
        sleep(1);
    end
end

Main();