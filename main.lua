local charm = require 'charm'

local ui = charm.new()

ui:new('element', 50, 50, 100, 150)

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
end

function love.draw(params)
	ui:draw()
end
