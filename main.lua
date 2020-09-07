local charm = require 'charm'

local element = charm.Rectangle(50, 50, 100, 150)
	:fillColor(.25, .25, .25)
	:outlineColor(1, 1, 1)
	:outlineWidth(5)
	:cornerRadius(10, 5)
	:add(charm.Rectangle(25, 25, 25, 25)
		:fillColor(1, 0, 0)
	)
	:on('enter', function(element) element:fillColor(.5, .5, .5) end)
	:on('exit', function(element) element:fillColor(.25, .25, .25) end)

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
end

function love.mousemoved(x, y, dx, dy, istouch)
	element:mousemoved(x, y, dx, dy)
end

function love.draw()
	element:draw()
end
