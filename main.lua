local charm = require 'charm'

local testFont = love.graphics.newFont(32)
local beanMan = love.graphics.newImage 'bean man.png'

local ui = charm.new()

function love.draw()
	ui
		:new('text', testFont, 'hello world!\nnewline', 50, 50)
			:set('color', .8, .8, .8)
			:set('shadowColor', 1, 0, 0)
			:set('shadowOffset', -5, 5)
		:new('image', beanMan)
			:set('scale', .5, .5)
			:center(ui:getCenter '@previous')
			:top(ui:getBottom '@previous')
		:draw()

	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb')
end
