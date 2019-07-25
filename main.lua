local charm = require 'charm'

local beanMan = love.graphics.newImage 'bean man.png'

local ui = charm.new()

function love.draw()
	ui
		:new 'rectangle'
			:beginChildren()
				:new('rectangle', 50, 50, 50, 50)
					:set('fillColor', .5, .5, .5)
				:new('rectangle', 250, 250, 50, 50)
					:set('fillColor', .5, .5, .5)
			:endChildren()
			:wrap(25)
			:beginChildren()
				:new('image', beanMan)
					:size(ui:getSize '@parent')
					:set('color', 1, 1, 1, .1)
					--:z(-1)
			:endChildren()
			:set('fillColor', .25, .25, .25)
		:draw()

	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb')
end
