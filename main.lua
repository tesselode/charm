local charm = require 'charm'

local loremIpsum = [[
	Eius id commodi minus cumque. Sit expedita fuga optio quidem.
	Excepturi explicabo rerum et non nostrum. Delectus tenetur
	voluptatem voluptas. Qui quo molestias omnis nihil et.
]]

local testFont = love.graphics.newFont(16)
local beanMan = love.graphics.newImage 'bean man.png'

local ui = charm.new()

function love.draw()
	ui
		:new('paragraph', testFont, loremIpsum, 500, 'left', 50, 50)
			:set('text', 'asdf')
			:set('scale', 2, 2)
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
