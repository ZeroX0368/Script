-- ServerScriptService Script

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

local webhook = "https://discord.com/api/webhooks/1353511267889053767/AAHMBVG7vyD0SHEFK3pYf8sxsYS9_MEbQhINx_c1ASJbG_1fMrMlo8EvCaeGcF5wulcT"

local placeId = game.PlaceId
local jobId = game.JobId
local creatorId = game.CreatorId

-- Lấy tên game
local function getGameName()
	local success, result = pcall(function()
		return MarketplaceService:GetProductInfo(placeId).Name
	end)
	return success and result or "Unknown Game"
end

-- Lấy avatar thumbnail user
local function getUserThumbnail(userId)
	local thumbType = Enum.ThumbnailType.HeadShot
	local thumbSize = Enum.ThumbnailSize.Size420x420
	local content = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
	return content
end

-- Lấy thumbnail game
local function getGameThumbnail()
	local thumbType = Enum.ThumbnailType.Asset
	local thumbSize = Enum.ThumbnailSize.Size420x420
	local content = Players:GetUserThumbnailAsync(placeId, thumbType, thumbSize)
	return content
end

-- Lấy avatar owner
local function getOwnerAvatar()
	local thumbType = Enum.ThumbnailType.HeadShot
	local thumbSize = Enum.ThumbnailSize.Size180x180
	local content = Players:GetUserThumbnailAsync(creatorId, thumbType, thumbSize)
	return content
end

-- Lấy thời gian
local function getTime()
	return os.date("%Y-%m-%d %H:%M:%S")
end

local function sendUserEmbed(player, action)

	local isJoin = action == "Join"

	local embedData = {
		["embeds"] = {{
			["title"] = isJoin and "🟢 Player Joined Server" or "🔴 Player Left Server",
			["color"] = isJoin and 65280 or 16711680,

			["author"] = {
				["name"] = "Game Owner",
				["icon_url"] = getOwnerAvatar()
			},

			["thumbnail"] = {
				["url"] = getUserThumbnail(player.UserId)
			},

			["image"] = {
				["url"] = getGameThumbnail()
			},

			["fields"] = {
				{
					["name"] = "👤 Username",
					["value"] = player.Name,
					["inline"] = true
				},
				{
					["name"] = "🆔 User ID",
					["value"] = tostring(player.UserId),
					["inline"] = true
				},
				{
					["name"] = "🎮 Game Name",
					["value"] = getGameName(),
					["inline"] = false
				},
				{
					["name"] = "📍 Place ID",
					["value"] = tostring(placeId),
					["inline"] = true
				},
				{
					["name"] = "🖥 Server Job ID",
					["value"] = jobId,
					["inline"] = false
				},
				{
					["name"] = "⏰ Time",
					["value"] = getTime(),
					["inline"] = false
				},
				{
					["name"] = "📌 Status",
					["value"] = isJoin and "🟢 Join" or "🔴 Leave",
					["inline"] = false
				}
			},

			["footer"] = {
				["text"] = "🚀 Roblox Advanced Logger"
			}
		}}
	}

	local jsonData = HttpService:JSONEncode(embedData)

	pcall(function()
		HttpService:PostAsync(
			webhook,
			jsonData,
			Enum.HttpContentType.ApplicationJson
		)
	end)
end

Players.PlayerAdded:Connect(function(player)
	sendUserEmbed(player, "Join")
end)

Players.PlayerRemoving:Connect(function(player)
	sendUserEmbed(player, "Leave")
end)
