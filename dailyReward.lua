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

            cassapi.AskForDisk();
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
            cassPassInfo = cassapi.ValidateCassPass();
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
        cassapi.SaveToDisk(cassPassInfo);
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