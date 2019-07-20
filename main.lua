local charm = require 'charm'

local ui = charm.new()

function love.draw()
	ui
		:rectangle(nil, 50, 100, 150)
			:center(400 + 100 * math.sin(love.timer.getTime()))
			:fillColor(.5, .5, .5)
			:name 'mainBox'
		:rectangle(nil, nil, 50, 50)
			:left(ui:getRight '@previous')
			:middle(ui:getMiddle '@previous')
			:fillColor(1, 0, 0)
		:rectangle(nil, nil, 10, 300)
			:center(ui:getCenter 'mainBox')
			:top(ui:getBottom 'mainBox')
			:fillColor(0, 1, 0)
		:draw()
end
