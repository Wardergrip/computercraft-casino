os.loadAPI("cassapi.lua");

-- Sample prompts table
local prompts = {
    "@user1@Hello world!",
    "@alice@This is a test prompt.",
    "@bob@Lua is fun.",
    "@charlie@Let's code something!"
}

-- Function to extract usernames from each prompt
local function extractUsernames(prompts)
    local usernames = {}
    for _, prompt in ipairs(prompts) do
        local firstAt = string.find(prompt, "@", 1, true)
        local secondAt = string.find(prompt, "@", firstAt + 1, true)
        if firstAt and secondAt then
            local username = string.sub(prompt, firstAt + 1, secondAt - 1)
            table.insert(usernames, username)
        else
            table.insert(usernames, nil) -- or handle error
        end
    end
    return usernames
end

-- Function to extract content after the second '@'
local function extractContents(prompts)
    local contents = {}
    for _, prompt in ipairs(prompts) do
        local secondAt = string.find(prompt, "@", string.find(prompt, "@", 1, true) + 1, true)
        if secondAt then
            local content = string.sub(prompt, secondAt + 1)
            table.insert(contents, content)
        else
            table.insert(contents, nil) -- or handle error
        end
    end
    return contents
end

function Echo()
    print("[Echo mode]")
    local input = read();
    print(input)
end

function PrintSub()
    print("PrintSub")
    write("String?")
    local str = read();
    write("StartIdx?")
    local idx = read();
    print(string.sub(str,idx,string.len(str)));
end

function PrintCassPass()
    local file = fs.open("disk/cassPass.data", "r");
    local cassPassInfo = cassapi.ValidateCassPass(file);
    file.close();
    if cassPassInfo == nil then
        print("Invalid")
    elseif cassPassInfo == false then
        print("Outdated");
    else
        cassapi.PrintAllCassPassInfo(cassPassInfo);
    end
end

function TryChatGPTStrParse()
    -- Example usage
    local usernames = extractUsernames(prompts)
    local contents = extractContents(prompts)

    -- Print results
    for i, name in ipairs(usernames) do
        print("Username:", name)
    end

    for i, content in ipairs(contents) do
        print("Content:", content)
    end
end

function Main()
    TryChatGPTStrParse();
end

Main();
