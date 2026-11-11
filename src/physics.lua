local config = require("src.config")

local physics = {}

function physics.clone(s)
	return {
		radius = s.radius,
		x0 = s.x0,
		y0 = s.y0,
		dx = s.dx,
		dy0 = s.dy0,
		t = s.t,
		x = s.x,
		y = s.y,
		dy = s.dy,
	}
end

-- Avança um estado qualquer (a bola real ou uma cópia usada na previsão).
-- Não existe limite lateral: a bola pode seguir para o infinito.
function physics.step(s, dt, groundY)
	s.t = s.t + dt

	s.x = s.x0 + s.dx * s.t
	s.y = s.y0 + s.dy0 * s.t + 0.5 * config.gravity * s.t ^ 2
	s.dy = s.dy0 + config.gravity * s.t

	-- chão (a colisão é no topo da faixa, não na altura dela)
	if s.y + s.radius >= groundY then
		s.x0 = s.x
		s.y0 = groundY - s.radius
		s.dy0 = -s.dy * config.restitution
		s.y = s.y0
		s.t = 0
	end
end

return physics
