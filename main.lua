local ui = require 'charm'.new()

local beanMan = love.graphics.newImage 'bean man.png'

function love.draw()
	ui
		:new('image', beanMan, 50, 50)
			:scale(.5, .25)
			:color(1, 1, 1, .5)
		:new 'rectangle'
			:size(25, 25)
			:left(ui:get '@previous.right')
			:middle(ui:get '@previous.middle')
			:fillColor(.5, .5, .5)
		:draw()
	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb')
end
