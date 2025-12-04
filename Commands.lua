local GrindCompanion = _G.GrindCompanion

function GrindCompanion:StartTracking()
    if self.isTracking then
        self:PrintMessage("Already tracking. Use /gc stats to see the current run.")
        return
    end

    self.isTracking = true
    self:ResetStats()
    if self.displayFrame then
        self.displayFrame:Show()
    end
    self.elapsedSinceUpdate = 0
    self:RefreshDisplay()
    self:PrintMessage("Tracking started. Go grind some mobs!")
end

function GrindCompanion:StopTracking()
    if not self.isTracking then
        self:PrintMessage("Tracking is not running. Use /gc start first.")
        return
    end

    self.isTracking = false
    self.stopTime = GetTime()
    if self.displayFrame then
        self.displayFrame:Hide()
    end
    local snapshot, index = self:PersistSessionHistory()
    if snapshot then
        self:PrintSessionSaved(snapshot, index)
    end
end

function GrindCompanion:PrintStats()
    if not self.startTime then
        self:PrintMessage("No session data. Use /gc start to begin tracking.")
        return
    end

    local isMaxLevel = self:IsPlayerMaxLevel()
    local elapsed = self:GetElapsedTime()
    local xpPerKill = (self.killCount > 0 and math.floor(self.totalXP / self.killCount) or 0)
    local xpPerHour = (elapsed > 0 and math.floor((self.totalXP / elapsed) * 3600) or 0)
    local timeToLevel = self:CalculateTimeToLevel()
    local lootSummary = self:FormatQualitySummary(self.lootQualityCount)
    local potentialAH = self:FormatCoin(self.potentialAHCopper or 0)
    local grayValue = self:FormatCoin(self.grayCopper or 0)
    local totalValue = self:FormatCoin((self.currencyCopper or 0) + (self.potentialAHCopper or 0) + (self.grayCopper or 0))
    local hasLoot = false
    for _, amount in pairs(self.lootQualityCount or {}) do
        if (amount or 0) > 0 then
            hasLoot = true
            break
        end
    end

    if isMaxLevel then
        self:PrintMessage(string.format(
            "Elapsed: %s | Kills: %d | Coins: %s | Gray: %s | AH: %s | Total: %s",
            self:FormatTime(elapsed),
            self.killCount,
            self:FormatCoin(self.currencyCopper),
            grayValue,
            potentialAH,
            totalValue
        ))
        self:PrintMessage(string.format("Loot: %s", hasLoot and lootSummary or "No notable items yet"))
        return
    end

    self:PrintMessage(string.format(
        "Elapsed: %s | XP: %d | Kills: %d | XP/Kill: %d | XP/Hr: %d",
        self:FormatTime(elapsed),
        self.totalXP,
        self.killCount,
        xpPerKill,
        xpPerHour
    ))

    if timeToLevel then
        self:PrintMessage(string.format("Estimated time to level: %s", self:FormatTime(timeToLevel)))
    else
        self:PrintMessage("Need more data to estimate time to level.")
    end

    self:PrintMessage(string.format(
        "Coins: %s | Gray: %s | AH: %s | Total: %s | %s",
        self:FormatCoin(self.currencyCopper),
        grayValue,
        potentialAH,
        totalValue,
        lootSummary
    ))
end

function GrindCompanion:HandleSlashCommand(msg)
    msg = (msg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")

    if msg == "start" then
        self:StartTracking()
    elseif msg == "stop" then
        self:StopTracking()
    elseif msg == "stats" or msg == "" then
        self:PrintStats()
    elseif msg == "sessions" then
        self:ToggleSessionsWindow()
    elseif msg == "toggle" then
        self:ToggleDisplay()
    elseif msg == "toggle on" then
        self:ToggleDisplay(true)
    elseif msg == "toggle off" then
        self:ToggleDisplay(false)
    elseif msg == "debug" then
        self.debugPricing = not self.debugPricing
        self:PrintMessage(string.format("Pricing debug: %s", self.debugPricing and "ON" or "OFF"))
    elseif msg == "testah" then
        self:UpdatePricingProvider()
        if self.hasAuctionatorPricing then
            self:PrintMessage("Auctionator detected and available!")
            
            -- List available API methods
            if Auctionator and Auctionator.API and Auctionator.API.v1 then
                local api = Auctionator.API.v1
                self:PrintMessage("Available Auctionator API methods:")
                for key, value in pairs(api) do
                    if type(value) == "function" then
                        self:PrintMessage(string.format("  - %s", key))
                    end
                end
            end
        else
            self:PrintMessage("Auctionator NOT detected. Make sure it's installed and loaded.")
        end
    elseif msg == "minimap" then
        self:ToggleMinimapButton()
        if self.settings.hideMinimapButton then
            self:PrintMessage("Minimap button hidden.")
        else
            self:PrintMessage("Minimap button shown.")
        end
    elseif msg == "select-ah start" then
        self:StartAHSelectMode()
    elseif msg == "select-ah stop" then
        self:StopAHSelectMode()
    elseif msg == "ah-items" then
        self:ShowAHItemsStatus()
    else
        self:PrintMessage("Commands: /gc start, /gc stop, /gc stats, /gc sessions, /gc minimap, /gc toggle")
        self:PrintMessage("AH Tracking: /gc select-ah start/stop, /gc ah-items")
    end
end

function GrindCompanion:ShowAHItemsStatus()
    local count = self:GetTrackedAHItemCount()
    if count == 0 then
        self:PrintMessage("No items tracked for AH. Use /gc select-ah start or open options to add items.")
        return
    end
    
    self:PrintMessage(string.format("Tracking %d item%s for AH value:", count, count == 1 and "" or "s"))
    
    local items = {}
    if self.ahTracking and self.ahTracking.trackedItems then
        for _, item in pairs(self.ahTracking.trackedItems) do
            table.insert(items, item)
        end
    end
    
    table.sort(items, function(a, b)
        return (a.name or "") < (b.name or "")
    end)
    
    for _, item in ipairs(items) do
        self:PrintMessage(string.format("  %s", item.link or item.name))
    end
end

function GrindCompanion:ToggleDisplay(show)
    if not self.displayFrame then
        self:InitializeDisplayFrame()
    end
    
    if show == nil then
        -- Toggle behavior
        if self.displayFrame:IsShown() then
            self.displayFrame:Hide()
            self:PrintMessage("Grind summary window hidden.")
        else
            self.displayFrame:Show()
            self:RefreshDisplay()
            self:PrintMessage("Grind summary window shown.")
        end
    elseif show then
        -- Explicit show
        self.displayFrame:Show()
        self:RefreshDisplay()
        self:PrintMessage("Grind summary window shown.")
    else
        -- Explicit hide
        self.displayFrame:Hide()
        self:PrintMessage("Grind summary window hidden.")
    end
end
