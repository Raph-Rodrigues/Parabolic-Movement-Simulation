local config = require("src.config")
local physics = require("src.physics")
local ground = require("src.ground")
local launcher = require("src.launcher")
local trajectory = require("src.trajectory")
local velocity = require("src.velocity")

local game = {}

local w, h
local groundObj
local launcherObj
local trajectoryObj
local ball
local iconMouse
local aiming
local dragging
local cameraX = 0

local function resetLauncher()
	aiming = true
	dragging = false
	cameraX = 0

	local anchor = launcherObj.anchor
	ball.x, ball.y = anchor.x, anchor.y
	ball.x0, ball.y0 = anchor.x, anchor.y
	ball.dx, ball.dy0, ball.t = 0, 0, 0
	ball.dy = 0

	trajectoryObj:reset(anchor.x, anchor.y)
end

local function startFlight()
	local anchor = launcherObj.anchor

	-- estilingue: a bola vai para o lado oposto da puxada
	ball.dx = (anchor.x - ball.x) * config.launchPower
	ball.dy0 = (anchor.y - ball.y) * config.launchPower

	ball.x0, ball.y0 = ball.x, ball.y
	ball.t = 0
	ball.dy = ball.dy0

	aiming = false
	dragging = false
	trajectoryObj:reset(ball.x, ball.y)
end

-- velocidade que deve aparecer na ilustração: a prevista enquanto mira,
-- a real durante o voo
local function currentVelocity()
	if aiming then
		local anchor = launcherObj.anchor
		return (anchor.x - ball.x) * config.launchPower,
			(anchor.y - ball.y) * config.launchPower
	end

	return ball.dx, ball.dy
end

-- Mantém a bola dentro de uma faixa da tela. Como o mundo não tem mais
-- limite lateral, a câmera acompanha a bola para ela não sumir.
local function updateCamera()
	local left = w * config.cameraLeft
	local right = w * config.cameraRight
	local screenX = ball.x - cameraX

	if screenX < left then
		cameraX = ball.x - left
	elseif screenX > right then
		cameraX = ball.x - right
	end
end

function game.load()
	w, h = love.graphics.getWidth(), love.graphics.getHeight()

	groundObj = ground.new(w, h)
	launcherObj = launcher.new(groundObj)

	ball = {
		radius = config.ballRadius,
		x0 = 0,
		y0 = 0,
		dx = 0,
		dy0 = 0,
		t = 0,
	}

	trajectoryObj = trajectory.new()
	iconMouse = { x = 0, y = 0, size = config.cursorSize }

	resetLauncher()
end

function game.update(dt)
	iconMouse.x = love.mouse.getX()
	iconMouse.y = love.mouse.getY()

	if aiming then
		-- Enquanto a bola está puxada, a previsão usa a velocidade
		-- que ela teria se fosse solta agora.
		local vx, vy = currentVelocity()
		trajectoryObj:updateAiming(ball, vx, vy, groundObj.y)
		return
	end

	physics.step(ball, dt, groundObj.y)
	trajectoryObj:updateFlying(ball, groundObj.y)
	updateCamera()
end

function game.draw()
	-- o chão é uma faixa fixa da tela, então fica fora da câmera
	ground.draw(groundObj)

	love.graphics.push()
	love.graphics.translate(-cameraX, 0)

	trajectoryObj:draw(aiming)
	launcher.draw(launcherObj, ball, aiming)

	-- bola
	love.graphics.setColor(1, 0.55, 0.1)
	love.graphics.circle("fill", ball.x, ball.y, ball.radius)

	-- ilustração do vetor velocidade
	local vx, vy = currentVelocity()
	velocity.draw(ball, vx, vy)

	love.graphics.pop()

	-- cursor (escondido durante o arrasto, pois a bola já segue o mouse)
	if not dragging then
		love.graphics.setColor(1, 1, 1, 0.5)
		love.graphics.circle("fill", iconMouse.x, iconMouse.y, iconMouse.size)
	end

	-- dica
	love.graphics.setColor(1, 1, 1, 0.7)
	local hint = aiming and "Clique e arraste a bola para lançar" or "Clique para recarregar (ou R)"
	love.graphics.print(hint, 10, 10)
end

function game.mousepressed(x, y, button)
	if button ~= 1 then return end

	-- durante o voo, qualquer clique recarrega e já permite arrastar de novo
	if not aiming then
		resetLauncher()
		dragging = true
		return
	end

	local dx, dy = x - ball.x, y - ball.y
	if dx * dx + dy * dy <= (ball.radius + 8) ^ 2 then
		dragging = true
	end
end

function game.mousemoved(x, y)
	if not dragging then return end

	local anchor = launcherObj.anchor
	local dx, dy = x - anchor.x, y - anchor.y
	local dist = math.sqrt(dx * dx + dy * dy)

	if dist > config.maxPull then
		dx = dx / dist * config.maxPull
		dy = dy / dist * config.maxPull
	end

	ball.x = math.max(ball.radius, math.min(w - ball.radius, anchor.x + dx))
	ball.y = math.max(ball.radius, math.min(groundObj.y - ball.radius, anchor.y + dy))
end

function game.mousereleased(x, y, button)
	if button ~= 1 or not dragging then return end
	dragging = false

	local anchor = launcherObj.anchor
	local dx, dy = anchor.x - ball.x, anchor.y - ball.y
	if dx * dx + dy * dy < 8 * 8 then
		-- puxada pequena: volta para o lançador sem lançar
		ball.x, ball.y = anchor.x, anchor.y
		return
	end

	startFlight()
end

function game.keypressed(key)
	if key == "r" then
		resetLauncher()
	end
end

function game.resize(neww, newh)
	w, h = neww, newh

	ground.resize(groundObj, neww, newh)
	launcher.resize(launcherObj, groundObj)

	if aiming and not dragging then
		local anchor = launcherObj.anchor
		ball.x, ball.y = anchor.x, anchor.y
		ball.x0, ball.y0 = anchor.x, anchor.y
	end
end

return game
