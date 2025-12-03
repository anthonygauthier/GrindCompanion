local GrindCompanion = _G.GrindCompanion

-- ============================================================================
-- Trends Panel Initialization
-- ============================================================================

function GrindCompanion:InitializeTrendsPanel()
    if not self.sessionsFrame then
        return
    end
    
    local frame = self.sessionsFrame
    
    -- Create trends panel frame with InsetFrameTemplate3
    local trendsPanel = CreateFrame("Frame", nil, frame, "InsetFrameTemplate3")
    trendsPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -64)
    trendsPanel:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -64)
    trendsPanel:SetHeight(250)
    
    -- Create summary statistics frame at top of panel
    local summaryFrame = CreateFrame("Frame", nil, trendsPanel)
    summaryFrame:SetPoint("TOPLEFT", trendsPanel, "TOPLEFT", 10, -10)
    summaryFrame:SetPoint("TOPRIGHT", trendsPanel, "TOPRIGHT", -10, -10)
    summaryFrame:SetHeight(60)
    trendsPanel.summaryFrame = summaryFrame
    
    -- Add font strings for summary statistics
    -- Total sessions (top left)
    summaryFrame.totalSessionsText = summaryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    summaryFrame.totalSessionsText:SetPoint("TOPLEFT", summaryFrame, "TOPLEFT", 0, 0)
    summaryFrame.totalSessionsText:SetText("Total Sessions: 0")
    summaryFrame.totalSessionsText:SetJustifyH("LEFT")
    if HIGHLIGHT_FONT_COLOR then
        summaryFrame.totalSessionsText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    end
    
    -- Total time (top right)
    summaryFrame.totalTimeText = summaryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    summaryFrame.totalTimeText:SetPoint("TOPRIGHT", summaryFrame, "TOPRIGHT", 0, 0)
    summaryFrame.totalTimeText:SetText("Total Time: 0h")
    summaryFrame.totalTimeText:SetJustifyH("RIGHT")
    if HIGHLIGHT_FONT_COLOR then
        summaryFrame.totalTimeText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    end
    
    -- Average copper per hour (bottom left)
    summaryFrame.avgCopperPerHourText = summaryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    summaryFrame.avgCopperPerHourText:SetPoint("BOTTOMLEFT", summaryFrame, "BOTTOMLEFT", 0, 0)
    summaryFrame.avgCopperPerHourText:SetText("Avg: 0c/hr")
    summaryFrame.avgCopperPerHourText:SetJustifyH("LEFT")
    if HIGHLIGHT_FONT_COLOR then
        summaryFrame.avgCopperPerHourText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    end
    
    -- Best copper per hour (bottom right)
    summaryFrame.bestCopperPerHourText = summaryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    summaryFrame.bestCopperPerHourText:SetPoint("BOTTOMRIGHT", summaryFrame, "BOTTOMRIGHT", 0, 0)
    summaryFrame.bestCopperPerHourText:SetText("Best: 0c/hr")
    summaryFrame.bestCopperPerHourText:SetJustifyH("RIGHT")
    if HIGHLIGHT_FONT_COLOR then
        summaryFrame.bestCopperPerHourText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    end
    
    -- Create tab buttons container
    local tabContainer = CreateFrame("Frame", nil, trendsPanel)
    tabContainer:SetPoint("TOPLEFT", summaryFrame, "BOTTOMLEFT", 0, -10)
    tabContainer:SetPoint("TOPRIGHT", summaryFrame, "BOTTOMRIGHT", 0, -10)
    tabContainer:SetHeight(30)
    trendsPanel.tabContainer = tabContainer
    
    -- Create graph container frame (no scroll frame)
    local graphContainer = CreateFrame("Frame", nil, trendsPanel)
    graphContainer:SetPoint("TOPLEFT", tabContainer, "BOTTOMLEFT", 0, -5)
    graphContainer:SetPoint("BOTTOMRIGHT", trendsPanel, "BOTTOMRIGHT", -10, 10)
    trendsPanel.graphContainer = graphContainer
    
    -- Create tabs
    local tabs = {}
    local tabNames = {"Currency", "XP", "Loot Quality", "Kills/Min"}
    local tabWidth = 110
    
    for i, tabName in ipairs(tabNames) do
        local tab = CreateFrame("Button", nil, tabContainer, "UIPanelButtonTemplate")
        tab:SetSize(tabWidth, 24)
        tab:SetPoint("LEFT", tabContainer, "LEFT", (i - 1) * (tabWidth + 5), 0)
        tab:SetText(tabName)
        
        tab.tabIndex = i
        tab:SetScript("OnClick", function(self)
            GrindCompanion:SelectGraphTab(self.tabIndex)
        end)
        
        tabs[i] = tab
    end
    
    trendsPanel.tabs = tabs
    trendsPanel.activeTab = 1
    
    -- Set initial state
    tabs[1]:Disable()
    for i = 2, #tabs do
        tabs[i]:Enable()
    end
    
    -- Store reference in sessionsFrame
    frame.trendsPanel = trendsPanel
end

-- ============================================================================
-- Tab Selection
-- ============================================================================

function GrindCompanion:SelectGraphTab(tabIndex)
    if not self.sessionsFrame or not self.sessionsFrame.trendsPanel then
        return
    end
    
    local trendsPanel = self.sessionsFrame.trendsPanel
    trendsPanel.activeTab = tabIndex
    
    -- Update tab states
    for i, tab in ipairs(trendsPanel.tabs) do
        if i == tabIndex then
            tab:Disable()  -- Active tab is disabled (grayed out)
        else
            tab:Enable()   -- Inactive tabs are enabled (clickable)
        end
    end
    
    -- Show/hide graphs based on active tab
    local graphContainer = trendsPanel.graphContainer
    if graphContainer then
        if graphContainer.currencyGraph then
            if tabIndex == 1 then
                graphContainer.currencyGraph:Show()
            else
                graphContainer.currencyGraph:Hide()
            end
        end
        
        if graphContainer.xpGraph then
            if tabIndex == 2 then
                graphContainer.xpGraph:Show()
            else
                graphContainer.xpGraph:Hide()
            end
        end
        
        if graphContainer.lootChart then
            if tabIndex == 3 then
                graphContainer.lootChart:Show()
            else
                graphContainer.lootChart:Hide()
            end
        end
        
        if graphContainer.killsPerMinGraph then
            if tabIndex == 4 then
                graphContainer.killsPerMinGraph:Show()
            else
                graphContainer.killsPerMinGraph:Hide()
            end
        end
    end
end

-- ============================================================================
-- Graph Data Preparation
-- ============================================================================

-- OPTIMIZED: Pre-allocate and reduce allocations
function GrindCompanion:PrepareGraphData(sessions, metricFunc)
    if not sessions or #sessions == 0 then
        return {
            dataPoints = {},
            minValue = 0,
            maxValue = 0,
        }
    end
    
    -- Reuse dataPoints table
    local dataPoints = self._graphDataPointsCache or {}
    wipe(dataPoints)
    self._graphDataPointsCache = dataPoints
    
    local minValue = nil
    local maxValue = nil
    local count = 0
    
    -- Single-pass extraction with inline min/max tracking
    for i = 1, #sessions do
        local session = sessions[i]
        local value, shouldInclude = metricFunc(session, i)
        
        if shouldInclude then
            count = count + 1
            local timestamp = session.startedAt or 0
            
            -- Build label inline
            local label = "Session #" .. i
            if session.character and session.character.name then
                label = label .. " - " .. session.character.name
            end
            
            dataPoints[count] = {
                sessionIndex = i,
                value = value,
                timestamp = timestamp,
                label = label,
            }
            
            -- Inline min/max (faster than separate if blocks)
            minValue = (not minValue or value < minValue) and value or minValue
            maxValue = (not maxValue or value > maxValue) and value or maxValue
        end
    end
    
    -- Sort only if we have data
    if count > 0 then
        table.sort(dataPoints, function(a, b)
            return a.timestamp < b.timestamp
        end)
    else
        minValue = 0
        maxValue = 0
    end
    
    return {
        dataPoints = dataPoints,
        minValue = minValue or 0,
        maxValue = maxValue or 0,
    }
end

-- ============================================================================
-- Line Graph Creation and Rendering
-- ============================================================================

function GrindCompanion:CreateLineGraph(parent, width, height, title, isCurrencyGraph)
    -- Create the main graph frame
    local graph = CreateFrame("Frame", nil, parent)
    graph:SetSize(width, height)
    graph.isCurrencyGraph = isCurrencyGraph or false
    
    -- Create title font string
    graph.title = graph:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    graph.title:SetPoint("TOP", graph, "TOP", 0, -5)
    graph.title:SetText(title or "Graph")
    if HIGHLIGHT_FONT_COLOR then
        graph.title:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    end
    
    -- Create canvas frame for drawing surface
    local canvas = CreateFrame("Frame", nil, graph)
    canvas:SetPoint("TOPLEFT", graph, "TOPLEFT", 30, -25)
    canvas:SetPoint("BOTTOMRIGHT", graph, "BOTTOMRIGHT", -10, 15)
    
    -- Add background to canvas
    canvas.bg = canvas:CreateTexture(nil, "BACKGROUND")
    canvas.bg:SetAllPoints(canvas)
    canvas.bg:SetColorTexture(0, 0, 0, 0.3)
    
    graph.canvas = canvas
    
    -- Create Y-axis label
    graph.yAxisLabel = graph:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    graph.yAxisLabel:SetPoint("BOTTOMLEFT", canvas, "TOPLEFT", -25, 5)
    graph.yAxisLabel:SetText("0")
    graph.yAxisLabel:SetJustifyH("RIGHT")
    
    -- Create X-axis label
    graph.xAxisLabel = graph:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    graph.xAxisLabel:SetPoint("BOTTOMLEFT", canvas, "BOTTOMLEFT", 0, -12)
    graph.xAxisLabel:SetText("")
    graph.xAxisLabel:SetJustifyH("LEFT")
    
    -- Initialize storage for textures and metadata
    graph.dataPointTextures = {}
    graph.lineTextures = {}
    graph.dataPointMetadata = {}
    
    return graph
end

function GrindCompanion:RenderLineGraph(graph, dataPoints, color)
    if not graph or not graph.canvas then
        return
    end
    
    -- OPTIMIZED: Properly release textures to prevent memory leak
    if graph.dataPointTextures then
        for _, texture in ipairs(graph.dataPointTextures) do
            texture:SetParent(nil)
            texture:Hide()
        end
    end
    if graph.lineTextures then
        for _, texture in ipairs(graph.lineTextures) do
            texture:SetParent(nil)
            texture:Hide()
        end
    end
    
    -- Reuse tables instead of creating new ones
    graph.dataPointTextures = graph.dataPointTextures or {}
    graph.lineTextures = graph.lineTextures or {}
    graph.dataPointMetadata = graph.dataPointMetadata or {}
    wipe(graph.dataPointTextures)
    wipe(graph.lineTextures)
    wipe(graph.dataPointMetadata)
    
    -- Handle empty data
    if not dataPoints or #dataPoints == 0 then
        if graph.yAxisLabel then
            graph.yAxisLabel:SetText("0")
        end
        if graph.xAxisLabel then
            graph.xAxisLabel:SetText("No data")
        end
        return
    end
    
    local canvas = graph.canvas
    local canvasWidth = canvas:GetWidth()
    local canvasHeight = canvas:GetHeight()
    
    -- Calculate max value for Y-axis scaling
    local maxValue = 0
    for _, point in ipairs(dataPoints) do
        if point.value > maxValue then
            maxValue = point.value
        end
    end
    
    -- Avoid division by zero
    if maxValue == 0 then
        maxValue = 1
    end
    
    -- Calculate Y-axis scale factor
    local yScale = canvasHeight / maxValue
    
    -- Calculate X-axis spacing
    local pointCount = #dataPoints
    local xSpacing = canvasWidth / math.max(pointCount - 1, 1)
    
    -- If only one point, center it
    if pointCount == 1 then
        xSpacing = canvasWidth / 2
    end
    
    -- Set default color if not provided
    local r, g, b = 1, 1, 1
    if color then
        r, g, b = color.r or 1, color.g or 1, color.b or 1
    end
    
    -- Render data points and connecting lines
    for i, point in ipairs(dataPoints) do
        -- Calculate position
        local x = (i == 1 and pointCount == 1) and (canvasWidth / 2) or ((i - 1) * xSpacing)
        local y = point.value * yScale
        
        -- Create data point texture (4x4 pixel colored square)
        local dotTexture = canvas:CreateTexture(nil, "ARTWORK")
        dotTexture:SetSize(4, 4)
        dotTexture:SetColorTexture(r, g, b, 1)
        dotTexture:SetPoint("BOTTOMLEFT", canvas, "BOTTOMLEFT", x - 2, y - 2)
        table.insert(graph.dataPointTextures, dotTexture)
        
        -- Store metadata for interaction handling
        graph.dataPointMetadata[i] = {
            sessionIndex = point.sessionIndex,
            value = point.value,
            label = point.label,
            x = x,
            y = y,
        }
        
        -- Create line to previous point
        if i > 1 then
            local prevPoint = dataPoints[i - 1]
            local prevX = (i == 2 and pointCount == 1) and (canvasWidth / 2) or ((i - 2) * xSpacing)
            local prevY = prevPoint.value * yScale
            
            -- Calculate line parameters
            local dx = x - prevX
            local dy = y - prevY
            local distance = math.sqrt(dx * dx + dy * dy)
            
            -- Create multiple small segments to approximate the line
            -- This works around WoW's lack of arbitrary texture rotation
            local segments = math.max(math.ceil(distance / 3), 1)
            
            for seg = 0, segments - 1 do
                local t = seg / segments
                local segX = prevX + (dx * t)
                local segY = prevY + (dy * t)
                
                local lineTexture = canvas:CreateTexture(nil, "ARTWORK")
                lineTexture:SetSize(3, 3)
                lineTexture:SetColorTexture(r, g, b, 0.7)
                lineTexture:SetPoint("BOTTOMLEFT", canvas, "BOTTOMLEFT", segX - 1.5, segY - 1.5)
                
                table.insert(graph.lineTextures, lineTexture)
            end
        end
    end
    
    -- Update Y-axis label with max value
    if graph.yAxisLabel then
        if graph.isCurrencyGraph then
            -- Convert copper to gold for currency graphs
            local goldValue = maxValue / 10000
            graph.yAxisLabel:SetText(string.format("%.0fg", goldValue))
        elseif graph.title and graph.title:GetText() == "Kills Per Minute" then
            -- Format as decimal for kills per minute
            graph.yAxisLabel:SetText(string.format("%.1f", maxValue))
        else
            graph.yAxisLabel:SetText(self:FormatNumber(maxValue))
        end
    end
    
    -- Update X-axis label
    if graph.xAxisLabel then
        if pointCount == 1 then
            graph.xAxisLabel:SetText("1 session")
        else
            graph.xAxisLabel:SetText(string.format("%d sessions", pointCount))
        end
    end
end

-- ============================================================================
-- Graph Interaction Functions
-- ============================================================================

function GrindCompanion:SetupGraphInteractions(graph, dataPoints)
    if not graph or not graph.canvas or not dataPoints then
        return
    end
    
    -- Clear existing interaction buttons
    if graph.interactionButtons then
        for _, btn in ipairs(graph.interactionButtons) do
            btn:Hide()
            btn:SetParent(nil)
        end
    end
    graph.interactionButtons = {}
    
    local canvas = graph.canvas
    
    -- Create invisible button frames over each data point
    for i, metadata in ipairs(graph.dataPointMetadata or {}) do
        local btn = CreateFrame("Button", nil, canvas)
        btn:SetSize(12, 12)  -- Larger clickable area than the 4x4 dot
        btn:SetPoint("BOTTOMLEFT", canvas, "BOTTOMLEFT", metadata.x - 6, metadata.y - 6)
        
        -- Set OnEnter script to show GameTooltip with session info
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(metadata.label, 1, 1, 1)
            
            -- Format the value based on graph type
            local valueText
            if graph.isCurrencyGraph then
                -- Show as gold with coin icons
                valueText = GrindCompanion:FormatCoinWithIcons(metadata.value)
            elseif graph.title and graph.title:GetText() == "Kills Per Minute" then
                -- Show as decimal for kills per minute
                valueText = string.format("%.2f kills/min", metadata.value)
            else
                valueText = GrindCompanion:FormatNumber(metadata.value)
            end
            GameTooltip:AddLine(valueText, nil, nil, nil, true)
            
            GameTooltip:Show()
        end)
        
        -- Set OnLeave script to hide GameTooltip
        btn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        
        -- Set OnClick script to select session in list and update detail panel
        btn:SetScript("OnClick", function()
            GrindCompanion:SelectSessionFromGraph(metadata.sessionIndex)
        end)
        
        table.insert(graph.interactionButtons, btn)
    end
end

function GrindCompanion:HighlightDataPoint(graph, sessionIndex)
    if not graph or not graph.dataPointTextures or not graph.dataPointMetadata then
        return
    end
    
    -- Reset all data points to normal size and alpha
    for i, texture in ipairs(graph.dataPointTextures) do
        texture:SetSize(4, 4)
        texture:SetAlpha(1.0)
    end
    
    -- Find and highlight the data point for the selected session
    for i, metadata in ipairs(graph.dataPointMetadata) do
        if metadata.sessionIndex == sessionIndex then
            local texture = graph.dataPointTextures[i]
            if texture then
                -- Make the selected point larger and brighter
                texture:SetSize(8, 8)
                texture:SetAlpha(1.0)
                -- Reposition to keep it centered
                texture:ClearAllPoints()
                texture:SetPoint("BOTTOMLEFT", graph.canvas, "BOTTOMLEFT", metadata.x - 4, metadata.y - 4)
            end
            break
        end
    end
end

function GrindCompanion:SelectSessionFromGraph(sessionIndex)
    if not self.sessionsFrame then
        return
    end
    
    -- Ensure saved variables exist
    self:EnsureSavedVariables()
    local sessions = GrindCompanionDB.sessions or {}
    
    if sessionIndex < 1 or sessionIndex > #sessions then
        return
    end
    
    local session = sessions[sessionIndex]
    
    -- Display session details
    self:DisplaySessionDetails(sessionIndex, session)
    
    -- Update session list selection visual
    local listChild = self.sessionsFrame.listChild
    if listChild and listChild.sessionButtons then
        for _, btn in ipairs(listChild.sessionButtons) do
            if btn.Background then
                btn.Background:SetColorTexture(0.1, 0.1, 0.1, 0.5)
            end
        end
        
        -- Find the button for this session (sessions are displayed in reverse order)
        local buttonIndex = #sessions - sessionIndex + 1
        local selectedBtn = listChild.sessionButtons[buttonIndex]
        if selectedBtn and selectedBtn.Background then
            selectedBtn.Background:SetColorTexture(0.2, 0.4, 0.6, 0.7)
        end
    end
    
    -- Highlight data points on all graphs
    local graphContainer = self.sessionsFrame.trendsPanel and self.sessionsFrame.trendsPanel.graphContainer
    if graphContainer then
        if graphContainer.currencyGraph then
            self:HighlightDataPoint(graphContainer.currencyGraph, sessionIndex)
        end
        if graphContainer.xpGraph then
            self:HighlightDataPoint(graphContainer.xpGraph, sessionIndex)
        end
    end
end

-- ============================================================================
-- Bar Chart Creation and Rendering
-- ============================================================================

function GrindCompanion:CreateBarChart(parent, width, height, title)
    -- Create the main chart frame
    local chart = CreateFrame("Frame", nil, parent)
    chart:SetSize(width, height)
    
    -- Create title font string
    chart.title = chart:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    chart.title:SetPoint("TOP", chart, "TOP", 0, -5)
    chart.title:SetText(title or "Chart")
    if HIGHLIGHT_FONT_COLOR then
        chart.title:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    end
    
    -- Create canvas frame for drawing surface
    local canvas = CreateFrame("Frame", nil, chart)
    canvas:SetPoint("TOPLEFT", chart, "TOPLEFT", 30, -25)
    canvas:SetPoint("BOTTOMRIGHT", chart, "BOTTOMRIGHT", -10, 15)
    
    -- Add background to canvas
    canvas.bg = canvas:CreateTexture(nil, "BACKGROUND")
    canvas.bg:SetAllPoints(canvas)
    canvas.bg:SetColorTexture(0, 0, 0, 0.3)
    
    chart.canvas = canvas
    
    -- Initialize storage for bar segments and metadata
    chart.barSegments = {}
    chart.sessionMetadata = {}
    
    return chart
end

function GrindCompanion:RenderBarChart(chart, sessions)
    if not chart or not chart.canvas then
        return
    end
    
    -- OPTIMIZED: Properly release textures and reuse tables
    if chart.barSegments then
        for _, segment in ipairs(chart.barSegments) do
            segment:SetParent(nil)
            segment:Hide()
        end
    end
    
    chart.barSegments = chart.barSegments or {}
    chart.sessionMetadata = chart.sessionMetadata or {}
    wipe(chart.barSegments)
    wipe(chart.sessionMetadata)
    
    -- Handle empty sessions
    if not sessions or #sessions == 0 then
        return
    end
    
    local canvas = chart.canvas
    local canvasWidth = canvas:GetWidth()
    local canvasHeight = canvas:GetHeight()
    
    -- Calculate max total loot count for Y-axis scaling
    local maxTotalLoot = 0
    for _, session in ipairs(sessions) do
        if session.loot then
            local total = (session.loot[2] or 0) + (session.loot[3] or 0) + (session.loot[4] or 0)
            if total > maxTotalLoot then
                maxTotalLoot = total
            end
        end
    end
    
    -- Avoid division by zero
    if maxTotalLoot == 0 then
        maxTotalLoot = 1
    end
    
    -- Calculate bar width based on session count and available space
    local sessionCount = #sessions
    local barSpacing = 2
    local totalSpacing = barSpacing * (sessionCount + 1)
    local availableWidth = canvasWidth - totalSpacing
    local barWidth = math.max(math.floor(availableWidth / sessionCount), 1)
    
    -- Get quality colors from WoW's ITEM_QUALITY_COLORS
    local qualityColors = ITEM_QUALITY_COLORS or {}
    local greenColor = qualityColors[2] or { r = 0.12, g = 1.0, b = 0.0 }
    local blueColor = qualityColors[3] or { r = 0.0, g = 0.44, b = 0.87 }
    local purpleColor = qualityColors[4] or { r = 0.64, g = 0.21, b = 0.93 }
    
    -- Render bars for each session
    for i, session in ipairs(sessions) do
        local loot = session.loot or {}
        local greenCount = loot[2] or 0
        local blueCount = loot[3] or 0
        local purpleCount = loot[4] or 0
        local totalLoot = greenCount + blueCount + purpleCount
        
        -- Calculate bar position
        local barX = barSpacing + ((i - 1) * (barWidth + barSpacing))
        
        -- Store session metadata for interaction handling
        chart.sessionMetadata[i] = {
            sessionIndex = i,
            session = session,
            x = barX,
            width = barWidth,
            greenCount = greenCount,
            blueCount = blueCount,
            purpleCount = purpleCount,
        }
        
        -- Only render if there's loot to display
        if totalLoot > 0 then
            local currentY = 0
            
            -- Create stacked bar segments (green, blue, purple from bottom to top)
            -- Green segment (bottom)
            if greenCount > 0 then
                local segmentHeight = (greenCount / maxTotalLoot) * canvasHeight
                local greenSegment = canvas:CreateTexture(nil, "ARTWORK")
                greenSegment:SetSize(barWidth, segmentHeight)
                greenSegment:SetColorTexture(greenColor.r, greenColor.g, greenColor.b, 0.8)
                greenSegment:SetPoint("BOTTOMLEFT", canvas, "BOTTOMLEFT", barX, currentY)
                table.insert(chart.barSegments, greenSegment)
                currentY = currentY + segmentHeight
            end
            
            -- Blue segment (middle)
            if blueCount > 0 then
                local segmentHeight = (blueCount / maxTotalLoot) * canvasHeight
                local blueSegment = canvas:CreateTexture(nil, "ARTWORK")
                blueSegment:SetSize(barWidth, segmentHeight)
                blueSegment:SetColorTexture(blueColor.r, blueColor.g, blueColor.b, 0.8)
                blueSegment:SetPoint("BOTTOMLEFT", canvas, "BOTTOMLEFT", barX, currentY)
                table.insert(chart.barSegments, blueSegment)
                currentY = currentY + segmentHeight
            end
            
            -- Purple segment (top)
            if purpleCount > 0 then
                local segmentHeight = (purpleCount / maxTotalLoot) * canvasHeight
                local purpleSegment = canvas:CreateTexture(nil, "ARTWORK")
                purpleSegment:SetSize(barWidth, segmentHeight)
                purpleSegment:SetColorTexture(purpleColor.r, purpleColor.g, purpleColor.b, 0.8)
                purpleSegment:SetPoint("BOTTOMLEFT", canvas, "BOTTOMLEFT", barX, currentY)
                table.insert(chart.barSegments, purpleSegment)
            end
        end
    end
end

-- ============================================================================
-- Trends Panel Refresh and Filtering
-- ============================================================================

-- OPTIMIZED: Cache filtered results and use efficient filtering
function GrindCompanion:GetFilteredSessions()
    self:EnsureSavedVariables()
    local sessions = GrindCompanionDB.sessions or {}
    
    if not self.sessionsFrame then
        return sessions
    end
    
    local filterText = self.sessionsFrame.filterText or ""
    local filterClass = self.sessionsFrame.filterClass or "All"
    local filterRace = self.sessionsFrame.filterRace or "All"
    local filterRealm = self.sessionsFrame.filterRealm or "All"
    
    -- Early exit if no filters
    if filterText == "" and filterClass == "All" and filterRace == "All" and filterRealm == "All" then
        return sessions
    end
    
    -- Reuse filter table to avoid allocations
    local filtered = self._filteredSessionsCache or {}
    wipe(filtered)
    self._filteredSessionsCache = filtered
    
    local filterTextLower = filterText ~= "" and filterText or nil
    local count = 0
    
    -- Single-pass filtering with early exits (Lua 5.1 compatible)
    for i = 1, #sessions do
        local session = sessions[i]
        local char = session.character
        local shouldInclude = true
        
        -- Quick class/race/realm checks first (cheaper than string operations)
        if shouldInclude and filterClass ~= "All" then
            shouldInclude = char and char.class == filterClass
        end
        if shouldInclude and filterRace ~= "All" then
            shouldInclude = char and char.race == filterRace
        end
        if shouldInclude and filterRealm ~= "All" then
            shouldInclude = char and char.realm == filterRealm
        end
        
        -- Text search last (most expensive)
        if shouldInclude and filterTextLower then
            local charName = char and char.name or "Unknown"
            shouldInclude = charName:lower():find(filterTextLower, 1, true) ~= nil
        end
        
        if shouldInclude then
            count = count + 1
            filtered[count] = session
        end
    end
    
    return filtered
end

function GrindCompanion:ApplySessionFilters()
    self:RefreshSessionsList()
    self:RefreshTrendsPanel()
end

function GrindCompanion:RefreshTrendsPanel()
    if not self.sessionsFrame or not self.sessionsFrame.trendsPanel then
        return
    end
    
    local trendsPanel = self.sessionsFrame.trendsPanel
    local summaryFrame = trendsPanel.summaryFrame
    local graphContainer = trendsPanel.graphContainer
    
    -- Get filtered sessions
    local sessions = self:GetFilteredSessions()
    
    -- Handle empty sessions case
    if #sessions == 0 then
        -- Update summary statistics to show "No data available"
        if summaryFrame.totalSessionsText then
            summaryFrame.totalSessionsText:SetText("No data available")
        end
        if summaryFrame.totalTimeText then
            summaryFrame.totalTimeText:SetText("")
        end
        if summaryFrame.avgCopperPerHourText then
            summaryFrame.avgCopperPerHourText:SetText("")
        end
        if summaryFrame.bestCopperPerHourText then
            summaryFrame.bestCopperPerHourText:SetText("")
        end
        
        -- Hide all graphs and tabs
        if graphContainer.currencyGraph then
            graphContainer.currencyGraph:Hide()
        end
        if graphContainer.xpGraph then
            graphContainer.xpGraph:Hide()
        end
        if graphContainer.lootChart then
            graphContainer.lootChart:Hide()
        end
        
        -- Hide tabs when no data
        if self.sessionsFrame.trendsPanel.tabContainer then
            self.sessionsFrame.trendsPanel.tabContainer:Hide()
        end
        
        return
    end
    
    -- Show tabs when there is data
    if self.sessionsFrame.trendsPanel.tabContainer then
        self.sessionsFrame.trendsPanel.tabContainer:Show()
    end
    
    -- Call CalculateTrendStatistics with filtered sessions
    local stats = self:CalculateTrendStatistics(sessions)
    
    -- Update summary statistics font strings with formatted values
    if summaryFrame.totalSessionsText then
        summaryFrame.totalSessionsText:SetText(string.format("Total Sessions: %d", stats.totalSessions))
    end
    
    if summaryFrame.totalTimeText then
        summaryFrame.totalTimeText:SetText(string.format("Total Time: %s", self:FormatTime(stats.totalDuration)))
    end
    
    if summaryFrame.avgCopperPerHourText then
        local avgText = self:FormatCoinWithIcons(stats.avgCopperPerHour) .. "/hr"
        summaryFrame.avgCopperPerHourText:SetText("Avg: " .. avgText)
    end
    
    if summaryFrame.bestCopperPerHourText then
        local bestText = self:FormatCoinWithIcons(stats.bestCopperPerHour) .. "/hr"
        summaryFrame.bestCopperPerHourText:SetText("Best: " .. bestText)
    end
    
    -- Prepare and render currency per hour graph
    local currencyMetricFunc = function(session, index)
        local duration = session.duration or 0
        if duration == 0 then
            return 0, false  -- Exclude sessions with zero duration
        end
        
        local currency = (session.currencyCopper or 0) + (session.grayCopper or 0) + (session.potentialAHCopper or 0)
        local durationHours = duration / 3600
        local copperPerHour = currency / durationHours
        
        return copperPerHour, true
    end
    
    local currencyGraphData = self:PrepareGraphData(sessions, currencyMetricFunc)
    
    -- Create currency graph if it doesn't exist
    if not graphContainer.currencyGraph then
        local graphWidth = graphContainer:GetWidth() - 20
        local graphHeight = graphContainer:GetHeight() - 20
        graphContainer.currencyGraph = self:CreateLineGraph(graphContainer, graphWidth, graphHeight, "Currency Per Hour", true)
        graphContainer.currencyGraph:SetPoint("TOPLEFT", graphContainer, "TOPLEFT", 10, -10)
        graphContainer.currencyGraph:SetPoint("BOTTOMRIGHT", graphContainer, "BOTTOMRIGHT", -10, 10)
    end
    
    -- Render currency graph
    local currencyColor = { r = 1, g = 0.82, b = 0 }  -- Gold color
    self:RenderLineGraph(graphContainer.currencyGraph, currencyGraphData.dataPoints, currencyColor)
    self:SetupGraphInteractions(graphContainer.currencyGraph, currencyGraphData.dataPoints)
    
    -- Prepare and render XP per hour graph (filtered for non-max-level sessions)
    local xpMetricFunc = function(session, index)
        -- Filter out max-level sessions
        if session.wasMaxLevel then
            return 0, false
        end
        
        local duration = session.duration or 0
        if duration == 0 then
            return 0, false  -- Exclude sessions with zero duration
        end
        
        local xp = session.totalXP or 0
        local durationHours = duration / 3600
        local xpPerHour = xp / durationHours
        
        return xpPerHour, true
    end
    
    local xpGraphData = self:PrepareGraphData(sessions, xpMetricFunc)
    
    -- Create XP graph if it doesn't exist
    if not graphContainer.xpGraph then
        local graphWidth = graphContainer:GetWidth() - 20
        local graphHeight = graphContainer:GetHeight() - 20
        graphContainer.xpGraph = self:CreateLineGraph(graphContainer, graphWidth, graphHeight, "XP Per Hour")
        graphContainer.xpGraph:SetPoint("TOPLEFT", graphContainer, "TOPLEFT", 10, -10)
        graphContainer.xpGraph:SetPoint("BOTTOMRIGHT", graphContainer, "BOTTOMRIGHT", -10, 10)
    end
    
    -- Render XP graph
    local xpColor = { r = 0.5, g = 0.5, b = 1 }  -- Blue color
    self:RenderLineGraph(graphContainer.xpGraph, xpGraphData.dataPoints, xpColor)
    self:SetupGraphInteractions(graphContainer.xpGraph, xpGraphData.dataPoints)
    
    -- Create loot quality chart if it doesn't exist
    if not graphContainer.lootChart then
        local chartWidth = graphContainer:GetWidth() - 20
        local chartHeight = graphContainer:GetHeight() - 20
        graphContainer.lootChart = self:CreateBarChart(graphContainer, chartWidth, chartHeight, "Loot Quality by Session")
        graphContainer.lootChart:SetPoint("TOPLEFT", graphContainer, "TOPLEFT", 10, -10)
        graphContainer.lootChart:SetPoint("BOTTOMRIGHT", graphContainer, "BOTTOMRIGHT", -10, 10)
    end
    
    -- Render loot quality chart
    self:RenderBarChart(graphContainer.lootChart, sessions)
    
    -- Prepare and render kills per minute graph
    local killsPerMinMetricFunc = function(session, index)
        local duration = session.duration or 0
        if duration == 0 then
            return 0, false  -- Exclude sessions with zero duration
        end
        
        local kills = session.killCount or 0
        local durationMinutes = duration / 60
        local killsPerMin = kills / durationMinutes
        
        return killsPerMin, true
    end
    
    local killsPerMinGraphData = self:PrepareGraphData(sessions, killsPerMinMetricFunc)
    
    -- Create kills per minute graph if it doesn't exist
    if not graphContainer.killsPerMinGraph then
        local graphWidth = graphContainer:GetWidth() - 20
        local graphHeight = graphContainer:GetHeight() - 20
        graphContainer.killsPerMinGraph = self:CreateLineGraph(graphContainer, graphWidth, graphHeight, "Kills Per Minute")
        graphContainer.killsPerMinGraph:SetPoint("TOPLEFT", graphContainer, "TOPLEFT", 10, -10)
        graphContainer.killsPerMinGraph:SetPoint("BOTTOMRIGHT", graphContainer, "BOTTOMRIGHT", -10, 10)
    end
    
    -- Render kills per minute graph
    local killsColor = { r = 1, g = 0.3, b = 0.3 }  -- Red color
    self:RenderLineGraph(graphContainer.killsPerMinGraph, killsPerMinGraphData.dataPoints, killsColor)
    self:SetupGraphInteractions(graphContainer.killsPerMinGraph, killsPerMinGraphData.dataPoints)
    
    -- Show only the active tab's graph
    self:SelectGraphTab(self.sessionsFrame.trendsPanel.activeTab or 1)
end
