local charm = require 'charm'

local ui = charm.new()

local parent = ui:createElement('element', 100, 150)
parent:addChild(ui:createElement('element', 20, 20), 50, 50)
ui:addChild(parent, 50, 50)

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
end

function love.draw(params)
	ui:draw()
end
