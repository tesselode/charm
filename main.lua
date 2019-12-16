local charm = require 'charm'

local layout = charm.new()

local angle = 0

function love.update(dt)
	angle = angle + dt
end

function love.draw()
	layout
		:new 'transform'
			:angle(angle)
			:shear(1, 0)
			:beginChildren()
				:new('rectangle', 300, 300, 100, 50)
					:fillColor(.5, .5, .5)
			:endChildren()
		love.graphics.rectangle('line', layout:get('@current', 'x'), layout:get('@current', 'y'),
			layout:get('@current', 'width'), layout:get('@current', 'height'))
		layout:draw()

	love.graphics.print(string.format('Memory usage: %ikb', collectgarbage 'count'))
end
