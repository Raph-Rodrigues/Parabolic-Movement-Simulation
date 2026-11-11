local config = require("src.config")

local velocity = {}

local VX_COLOR = { r = 0.25, g = 0.65, b = 1, a = 1 }
local VY_COLOR = { r = 1, g = 0.35, b = 0.3, a = 1 }
local RESULTANT_COLOR = { r = 0.4, g = 1, b = 0.55, a = 1 }
local LABEL_BG = { r = 0, g = 0, b = 0, a = 0.45 }
local LABEL_WIDTH = 150
local LABEL_HEIGHT = 52
local LABEL_GAP = 74

local function setColor(c)
	love.graphics.setColor(c.r, c.g, c.b, c.a)
end

-- Desenha uma seta de (x1, y1) até (x2, y2).
local function arrow(x1, y1, x2, y2)
	local dx, dy = x2 - x1, y2 - y1
	local len = math.sqrt(dx * dx + dy * dy)
	if len < 1 then
		return
	end

	love.graphics.setLineWidth(3)
	love.graphics.line(x1, y1, x2, y2)

	local ux, uy = dx / len, dy / len
	local head = math.min(9, len * 0.45)
	local px, py = -uy, ux

	love.graphics.line(x2, y2, x2 - ux * head + px * head * 0.55, y2 - uy * head + py * head * 0.55)
	love.graphics.line(x2, y2, x2 - ux * head - px * head * 0.55, y2 - uy * head - py * head * 0.55)

	love.graphics.setLineWidth(1)
end

-- Ilustra o vetor velocidade acima da bola: componente horizontal (azul),
-- componente vertical (vermelha), resultante (verde) e os módulos.
function velocity.draw(ball, vx, vy)
	local scale = config.velocityScale
	local ax = ball.x
	local offset = config.velocityOffsetY
	local ay = ball.y - ball.radius - offset
	local labelTop = ay - 46

	-- Perto do topo da tela não há espaço acima da bola; nesse caso a
	-- ilustração desce para baixo dela, em vez de sumir.
	if labelTop < 5 then
		ay = ball.y + ball.radius + offset
		labelTop = ay + 14
	end

	-- extremidade da componente horizontal e da vertical
	local x1 = ax + vx * scale
	local y1 = ay + vy * scale

	setColor(VX_COLOR)
	arrow(ax, ay, x1, ay)

	setColor(VY_COLOR)
	arrow(x1, ay, x1, y1)

	setColor(RESULTANT_COLOR)
	arrow(ax, ay, x1, y1)

	-- origem do vetor
	love.graphics.setColor(1, 1, 1, 0.8)
	love.graphics.circle("fill", ax, ay, 3, 10)

	-- leitura numérica
	local speed = math.sqrt(vx * vx + vy * vy)
	local lines = {
		{ text = string.format("|v| = %.0f px/s", speed), color = RESULTANT_COLOR },
		{ text = string.format("vx = %.0f px/s", vx), color = VX_COLOR },
		{ text = string.format("vy = %.0f px/s", vy), color = VY_COLOR },
	}

	local lx, ly = ax + LABEL_GAP, labelTop

	setColor(LABEL_BG)
	love.graphics.rectangle("fill", lx - 6, ly - 5, LABEL_WIDTH, LABEL_HEIGHT)

	for i = 1, #lines do
		setColor(lines[i].color)
		love.graphics.print(lines[i].text, lx, ly + (i - 1) * 15)
	end
end

return velocity
