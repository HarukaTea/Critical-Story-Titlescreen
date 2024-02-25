--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local data = SSS.Modules.Data
local packages = RepS.Modules.Packages
local utils = SSS.Modules.Utils

return {
	Fusion = require(packages.dhpfox_fusion.fusion),
	ServerUtil = require(utils.ServerUtil),
	SuphiDataStore = require(packages["5uphi_suphidatastore"].suphidatastore),

	Events = require(data.ServerEvents),

	FastSpawn = require(packages["red-blox_spawn"].spawn),
}
