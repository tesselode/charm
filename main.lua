local charm = require 'charm'

local beanMan = love.graphics.newImage 'bean man.png'

local ui = charm.new()

function love.draw()
	ui
		:new('image', beanMan, 50, 50)
			:set('scale', .5, .5)
		:new 'rectangle'
			:size(50, 50)
			:left(ui:getRight '@previous')
			:middle(ui:getMiddle '@previous')
			:set('fillColor', .5, .5, .5)
		:draw()

	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb')
end
