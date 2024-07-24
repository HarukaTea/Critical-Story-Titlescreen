--!nocheck

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local char = script.Parent :: Model
local animations = ReplicatedStorage.Package.Animations.CharAnims :: Folder
local animator = char.Humanoid:WaitForChild("Animator") :: Animator

local ANIMS = {
	Idle = animator:LoadAnimation(animations.Idle),
}
local oldAnim: AnimationTrack

--// Private

local function startAnim(anim: AnimationTrack, transitionTime: number)
	if oldAnim ~= anim then
		if oldAnim then oldAnim:Stop(transitionTime) end
		if anim then anim:Play(transitionTime) end

		oldAnim = anim
	end
end

--// Setup
local function setup()
	local humanoid = char.Humanoid :: Humanoid

	startAnim(ANIMS.Idle, 0.1)

	humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
end
setup()

--// Clear
local function onDead()
	--// 256 limit still happens, idk
	for _, anim: AnimationTrack in ANIMS do
		anim:Stop(0)
		anim:Destroy()
	end
	local animTracks = animator:GetPlayingAnimationTracks()
	for _, track: AnimationTrack in animTracks do
		track:Stop(0)
		track:Destroy()
	end
end
char.Humanoid.Died:Once(onDead)
