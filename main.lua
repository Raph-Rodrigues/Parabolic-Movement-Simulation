_G.love = require("love")

local game = require("src.game")

function love.load()
	game.load()
end

function love.update(dt)
	game.update(dt)
end

function love.draw()
	game.draw()
end

function love.mousepressed(x, y, button)
	game.mousepressed(x, y, button)
end

function love.mousemoved(x, y)
	game.mousemoved(x, y)
end

function love.mousereleased(x, y, button)
	game.mousereleased(x, y, button)
end

function love.keypressed(key)
	game.keypressed(key)
end

function love.resize(w, h)
	game.resize(w, h)
end
