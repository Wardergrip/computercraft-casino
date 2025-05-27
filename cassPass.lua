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
    cassapi.ConfigureCassPass(name);
end

function Main()
    local diskDirection = nil;

    term.clear();
    term.setTextColor(colors.red);
    print("Please insert blank disk to create a cassino pass");

    diskDirection = cassapi.WaitForDisk();

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
