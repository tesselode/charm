local ui = require 'charm'.new()

local font = love.graphics.newFont(24)

function love.draw()
	ui
		:new('text', font, 'hello world!', 50, 50)
			:scale(2, 3)
			:color(1, 1, 1, .5)
		:new 'rectangle'
			:size(25, 25)
			:left(ui:get '@previous.right')
			:middle(ui:get '@previous.middle')
			:fillColor(.5, .5, .5)
		:draw()
	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb')
end
