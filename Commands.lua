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
    elseif msg == "debug" then
        self.debugPricing = not self.debugPricing
        self:PrintMessage(string.format("Pricing debug: %s", self.debugPricing and "ON" or "OFF"))
    elseif msg == "testah" then
        self:UpdatePricingProvider()
        if self.hasAuctionatorPricing then
            self:PrintMessage("Auctionator detected and available!")
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
    else
        self:PrintMessage("Commands: /gc start, /gc stop, /gc stats, /gc sessions, /gc minimap")
    end
end
