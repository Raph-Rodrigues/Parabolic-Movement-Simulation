local config = require("src.config")

local ground = {}

local COLOR = { r = 0.04, g = 0.25, b = 0.10, a = 1 }
local EDGE_COLOR = { r = 0.08, g = 0.45, b = 0.16, a = 1 }
local EDGE_HEIGHT = 3

function ground.new(w, h)
	return {
		x = 0,
		y = h - config.groundHeight,
		width = w,
		height = config.groundHeight,
	}
end

function ground.resize(g, w, h)
	g.width = w
	g.y = h - g.height
end

function ground.draw(g)
	love.graphics.setColor(COLOR.r, COLOR.g, COLOR.b, COLOR.a)
	love.graphics.rectangle("fill", g.x, g.y, g.width, g.height)

	love.graphics.setColor(EDGE_COLOR.r, EDGE_COLOR.g, EDGE_COLOR.b, EDGE_COLOR.a)
	love.graphics.rectangle("fill", g.x, g.y, g.width, EDGE_HEIGHT)
end

return ground
