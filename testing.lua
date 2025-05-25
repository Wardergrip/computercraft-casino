os.loadAPI("cassapi.lua");

function Echo()
    print("[Echo mode]")
    local input = read();
    print(input)
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

function Main()
    PrintCassPass();
end

Main();
