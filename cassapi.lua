Directions = {"top","bot","left","right","front","back"};

YesOptions = {"y", "yes"};
NoOptions = {"n","no"};

CurrentVersion = 0;

NameIndex = 0;
CreditsIndex = 1;
ScoreIndex = 2;

function GetUserYesNo()
    write("y/n: ");
    local input = read();
    local inputLower = string.lower(input);
    for i = 1, #YesOptions do
        if YesOptions[i] == inputLower then
            return true;
        end
    end
    for i = 1, #NoOptions do
        if NoOptions[i] == inputLower then
            return false;
        end
    end
    return nil;
end

function IsNullOrEmpty(s)
    return s == nil or s == "";
end

-- Open for write before calling
function ConfigureCassPass(file, name)
    file.write("v" .. CurrentVersion .. "\n");
    file.write("CASSPASS#");
    file.write(name);
    file.write("\n");
    file.write("C#0\n");
    file.write("P#0");
end

-- Open for read before calling
function ValidateCassPass(file)
    -- Make sure the file has the amount of lines we expect
    local versionText = file.readLine();
    if versionText == nil then
        return nil;
    end
    local identifier = file.readLine();
    if identifier == nil then
        return nil;
    end
    local credits = file.readLine();
    if credits == nil then
        return nil;
    end
    local points = file.readLine();
    if points == nil then
        return nil;
    end
    -- Validate content of those lines
    local versionParsed = string.sub(versionText,2,string.len(versionText));
    local version = tonumber(versionParsed);
    if version ~= CurrentVersion then
        return false;
    end

    local cassPassInfo = {};
    cassPassInfo[NameIndex] = string.sub(identifier,10,string.len(identifier));

    cassPassInfo[CreditsIndex] = tonumber(string.sub(credits,3,string.len(credits)));

    cassPassInfo[ScoreIndex] = tonumber(string.sub(points,3,string.len(points)));

    return cassPassInfo;
end

function GetCassPassName(cassPassInfo)
    return cassPassInfo[NameIndex];
end

function GetCassPassCredits(cassPassInfo)
    return cassPassInfo[CreditsIndex];
end

function GetCassPassScore(cassPassInfo)
    return cassPassInfo[ScoreIndex];
end

function PrintAllCassPassInfo(cassPassInfo)
    for i = 0, #cassPassInfo do
        print(cassPassInfo[i]);
    end
end

function AddCredits(cassPassInfo, amount)
    local first = cassPassInfo[CreditsIndex];
    local total = first + amount;
    cassPassInfo[CreditsIndex] = total;
    return cassPassInfo;
end

function SaveToDisk(cassPassInfo, file)
    file.write("v" .. CurrentVersion .. "\n");
    file.write("CASSPASS#" .. cassPassInfo[NameIndex]);
    file.write("\n");
    file.write("C#" .. cassPassInfo[CreditsIndex] .. "\n");
    file.write("P#" .. cassPassInfo[ScoreIndex] .. "\n");
end