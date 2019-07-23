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
		:beginGroup()
			:new('rectangle')
				:size(50, 50)
				:set('fillColor', 1, 0, 0)
		:endGroup(25)
			:x(200):y(200)
			:set('fillColor', 1/4, 1/4, 1/4)
		:beginGroup()
			:new('rectangle')
				:size(50, 50)
				:set('fillColor', 1, 0, 0)
		:endGroup(25)
			:x(400):y(400)
			:set('fillColor', 1/4, 1/4, 1/4)
		:draw()

	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb')
end
