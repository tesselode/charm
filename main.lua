local charm = require 'charm'

local ui = charm.new()

function love.draw()
	if love.keyboard.isDown 'space' then
		ui
			:rectangle(50, 50, 100, 150)
			:fillColor(.5, .5, .5)
	end
	ui
		:rectangle(200, 200, 10, 10)
		:fillColor(1, 0, 0)
	ui:draw()
end
