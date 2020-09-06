local charm = require 'charm'

local element = charm.Element()
	:size(100, 150)
	:right(love.graphics.getWidth())
	:bottom(love.graphics.getHeight())

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
end

function love.draw()
	element:drawDebug()
end
