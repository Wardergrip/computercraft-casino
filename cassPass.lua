os.loadAPI("cassapi.lua");

function RegisterNewDisk(direction)
    term.clear();
    term.setCursorPos(1,1);
    term.setTextColor(colors.yellow);
    print("Found disk");
    term.setTextColor(colors.white);
    local name = nil;
    while name == nil do
        write("Enter name: ");
        name = read();
        if cassapi.IsNullOrEmpty(name) then
            term.clear();
            term.setCursorPos(1,1);
            term.setTextColor(colors.red);
            print("Invalid name");
            term.setTextColor(colors.white);
            name = nil;
        end
    end
    disk.setLabel(direction,name);
    local file = fs.open("disk/cassPass.data", "w");
    cassapi.ConfigureCassPass(file,name);
    file.close();
end

function Main()
    
    local diskDirection = nil;
    local isDiskPresent = false;

    term.clear();
    term.setTextColor(colors.red);
    print("Please insert blank disk to create a cassino pass");

    while true do
        
        for i = 1, #cassapi.Directions do
            if disk.isPresent(cassapi.Directions[i]) then
                isDiskPresent = true;
                diskDirection = cassapi.Directions[i];
                break;
            end
        end
        
        if isDiskPresent then
            break;
        end
        sleep(1); -- Necessary to not overload it.
    end

    local label = disk.getLabel(diskDirection);

    if label == nil then
        RegisterNewDisk(diskDirection);
        term.clear();
        term.setCursorPos(1,1);
        term.setTextColor(colors.green);
        print("Sucessfully registered your CassPass!")
        term.setTextColor(colors.yellow);
        print("Rebooting...")
        sleep(0.5);
        disk.eject(diskDirection);
        sleep(5);
        os.reboot();
    end

    term.clear();
    term.setTextColor(colors.yellow);
    term.setCursorPos(1,1);
    print("Disk present is already labeled, do you want to clear it?");
    term.setTextColor(colors.white);
    while true do
        local answer = cassapi.GetUserYesNo();

        if answer then
            disk.setLabel(diskDirection, nil);
            os.reboot();
            break;
        elseif answer == false then
            disk.eject(diskDirection);
            os.reboot();
            break;
        end
    end

end

Main();
