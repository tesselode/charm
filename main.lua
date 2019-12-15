local charm = require 'charm'

local testElement = setmetatable({}, charm.Element)

testElement:x(love.graphics.getWidth()/2, .25)
testElement:y(love.graphics.getHeight()/2, .5)
testElement:size(600, 50)

function love.draw()
	love.graphics.rectangle('line', testElement._x, testElement._y,
		testElement._width, testElement._height)
end
