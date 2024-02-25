--!nocheck

local data = script.Parent.Data
local packages = script.Parent.Packages

return {
	Fusion = require(packages.dhpfox_fusion.fusion),

	AssetBook = require(data.AssetBook),
	Events = require(data.Events),
	Signals = require(data.Signals),
	StoryBook = require(data.StoryBook),

	Clock = require(packages["red-blox_clock"].clock),
	FastSpawn = require(packages["red-blox_spawn"].spawn)
}
