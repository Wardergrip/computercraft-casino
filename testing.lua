os.loadAPI("cassapi.lua");

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

function Main()
    PrintSub();
end

Main();
