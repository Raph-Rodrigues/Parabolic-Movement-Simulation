return {
	gravity = 500, -- px/s² (positivo = para baixo)
	restitution = 0.8, -- 80% da energia volta no quique

	ballRadius = 20,

	groundHeight = 40,

	launcherX = 150,
	launcherWidth = 15,
	launcherHeight = 130,

	launchPower = 6, -- velocidade (px/s) por pixel de puxada
	maxPull = 120, -- puxada máxima, em pixels

	trailSpacing = 14,
	maxTrailNumbers = 1200,
	previewDt = 1 / 120,
	previewTime = 3,
	previewSpacing = 14,
	maxPreviewNumbers = 600,

	-- ilustração do vetor velocidade
	velocityScale = 0.06, -- px de desenho por px/s
	velocityOffsetY = 70, -- distância acima da bola

	-- câmera horizontal (o mundo não tem mais limite lateral)
	cameraLeft = 0.10, -- margem esquerda da tela
	cameraRight = 0.55, -- margem direita da tela

	cursorSize = 20,
}
