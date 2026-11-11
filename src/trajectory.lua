local config = require("src.config")
local physics = require("src.physics")

local trajectory = {}
trajectory.__index = trajectory

local PREVIEW_COLOR = { r = 0.45, g = 0.75, b = 1, a = 0.45 }
local TRAIL_COLOR = { r = 0.2, g = 0.9, b = 0.5, a = 0.9 }

function trajectory.new()
	return setmetatable({
		trail = {},
		preview = {},
		lastTrailX = nil,
		lastTrailY = nil,
	}, trajectory)
end

function trajectory:reset(x, y)
	self.trail = {}
	self.preview = {}
	self.lastTrailX = x
	self.lastTrailY = y
	self.trail[1], self.trail[2] = x, y
end

function trajectory:addTrail(x, y)
	local dx, dy = x - self.lastTrailX, y - self.lastTrailY
	if dx * dx + dy * dy < config.trailSpacing ^ 2 then
		return
	end

	self.trail[#self.trail + 1] = x
	self.trail[#self.trail + 1] = y

	while #self.trail > config.maxTrailNumbers do
		table.remove(self.trail, 1)
		table.remove(self.trail, 1)
	end

	self.lastTrailX, self.lastTrailY = x, y
end

function trajectory:buildPreview(source, groundY)
	local s = physics.clone(source)
	local points = {}
	local lastX, lastY = s.x, s.y
	local elapsed = 0

	while elapsed < config.previewTime and #points < config.maxPreviewNumbers do
		physics.step(s, config.previewDt, groundY)
		elapsed = elapsed + config.previewDt

		local dx, dy = s.x - lastX, s.y - lastY
		if dx * dx + dy * dy >= config.previewSpacing ^ 2 then
			points[#points + 1] = s.x
			points[#points + 1] = s.y
			lastX, lastY = s.x, s.y
		end
	end

	return points
end

function trajectory:updateAiming(ball, vx, vy, groundY)
	if vx * vx + vy * vy <= 0 then
		self.preview = {}
		return
	end

	self.preview = self:buildPreview({
		radius = ball.radius,
		x0 = ball.x,
		y0 = ball.y,
		dx = vx,
		dy0 = vy,
		t = 0,
		x = ball.x,
		y = ball.y,
		dy = vy,
	}, groundY)
end

function trajectory:updateFlying(ball, groundY)
	self:addTrail(ball.x, ball.y)
	self.preview = self:buildPreview(ball, groundY)
end

local function drawDots(points, radius)
	for i = 1, #points, 2 do
		love.graphics.circle("fill", points[i], points[i + 1], radius, 8)
	end
end

function trajectory:draw(aiming)
	love.graphics.setColor(PREVIEW_COLOR.r, PREVIEW_COLOR.g, PREVIEW_COLOR.b, PREVIEW_COLOR.a)
	drawDots(self.preview, 1.5)

	if not aiming then
		love.graphics.setColor(TRAIL_COLOR.r, TRAIL_COLOR.g, TRAIL_COLOR.b, TRAIL_COLOR.a)
		drawDots(self.trail, 2.5)
	end
end

return trajectory
