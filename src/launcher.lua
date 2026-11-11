local config = require("src.config")

local launcher = {}

local POST_COLOR = { r = 1, g = 0.04, b = 0.10, a = 1 }
local BAND_COLOR = { r = 0.55, g = 0.10, b = 0.10, a = 1 }
local BAND_WIDTH = 3

function launcher.new(g)
	local l = {
		x = config.launcherX,
		y = g.y - config.launcherHeight,
		width = config.launcherWidth,
		height = config.launcherHeight,
	}

	-- ponto de onde a bola é lançada (topo do lançador)
	l.anchor = {
		x = l.x + l.width / 2,
		y = l.y,
	}

	return l
end

function launcher.resize(l, g)
	l.y = g.y - l.height
	l.anchor.x = l.x + l.width / 2
	l.anchor.y = l.y
end

function launcher.draw(l, ball, aiming)
	love.graphics.setColor(POST_COLOR.r, POST_COLOR.g, POST_COLOR.b, POST_COLOR.a)
	love.graphics.rectangle("fill", l.x, l.y, l.width, l.height)

	-- elásticos do estilingue
	if aiming then
		love.graphics.setColor(BAND_COLOR.r, BAND_COLOR.g, BAND_COLOR.b, BAND_COLOR.a)
		love.graphics.setLineWidth(BAND_WIDTH)
		love.graphics.line(l.x, l.y, ball.x, ball.y)
		love.graphics.line(l.x + l.width, l.y, ball.x, ball.y)
		love.graphics.setLineWidth(1)
	end
end

return launcher
