os.loadAPI("cassapi.lua");

local diskDirection = nil;
local dailyReward = 100;

local refreshLowerWindow = 6.0;
local refreshHigherWindow = 7.0;
local refreshReset = 8.0;

local dailyRedeemed = {};

function Main()

    local label = nil;
    local run = true;
    local cassPassInfo = {};
    local reset = false;
    while run do
        while label == nil do
            
            local currentTime = os.time();
            if reset == false then
                if currentTime > refreshLowerWindow and currentTime < refreshHigherWindow then
                    reset = true;
                    dailyRedeemed = {};
                end
            else
                if currentTime > refreshReset then
                    reset = false;
                end
            end

            term.clear();
            term.setTextColor(colors.yellow);
            term.setCursorPos(1,1);
            print("Please insert a disk");
            diskDirection = cassapi.WaitForDisk();
            label = disk.getLabel(diskDirection);
            
            if label == nil then
                disk.eject();
                term.clear();
                term.setTextColor(colors.red);
                term.setCursorPos(1,1);
                print("Invalid disk, no label");
                sleep(5);
                goto continue;
            end
            local file = fs.open("disk/cassPass.data", "r");
            cassPassInfo = cassapi.ValidateCassPass(file);
            file.close();
            if cassPassInfo == nil then
                disk.eject(diskDirection);
                term.clear();
                term.setTextColor(colors.red);
                term.setCursorPos(1,1);
                label = nil;
                print("Invalid disk, not a valid casspass");
                sleep(5);
            elseif cassPassInfo == false then
                disk.eject(diskDirection);
                term.clear();
                term.setTextColor(colors.red);
                term.setCursorPos(1,1);
                label = nil;
                print("Invalid disk, outdated casspass");
                sleep(5);
            else
                for index, value in next, dailyRedeemed do
                    if label == dailyRedeemed[index] then
                        disk.eject(diskDirection);
                        term.clear();
                        term.setTextColor(colors.red);
                        term.setCursorPos(1,1);
                        label = nil;
                        print("Already redeemed, refreshes at 6AM Minecraft time (in " .. 24 + (refreshLowerWindow - currentTime) .. "hrs)");
                        sleep(5);
                    end
                end
            end
            ::continue::
        end
        cassapi.AddCredits(cassPassInfo, dailyReward);
        local file = fs.open("disk/cassPass.data", "w");
        cassapi.SaveToDisk(cassPassInfo, file);
        file.close();
        table.insert(dailyRedeemed, label);
        label = nil;
        cassPassInfo = {};
        disk.eject(diskDirection);
        term.clear();
        term.setTextColor(colors.green);
        term.setCursorPos(1,1);
        label = nil;
        print("Redeemed " .. dailyReward .. " credits!");
        sleep(5);
    end
end

Main();