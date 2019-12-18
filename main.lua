local charm = require 'charm'

local beanMan = love.graphics.newImage 'bean man.png'

local PictureFrame = charm.extend()

function PictureFrame:new()
	self._content = self._content or {}
	self._rendering = false
end

function PictureFrame:onAddChild(child)
	if self._rendering then
		self.parent.onAddChild(self, child)
	else
		table.insert(self._content, child)
	end
end

function PictureFrame:render(layout)
	self._rendering = true
	layout
		:new 'rectangle'
			:beginChildren()
				for i = 1, #self._content do
					layout:add(self._content[i])
				end
			layout:endChildren()
			:wrap(16)
			:centerX(0):centerY(0)
			:fillColor(1, 1, 1)
	self._rendering = false
end

local layout = charm.new()

function love.draw()
	layout
		:new(PictureFrame)
			:centerX(love.graphics.getWidth()/2)
			:centerY(love.graphics.getHeight()/2)
			:beginChildren()
				:new('image', beanMan)
					:scale(1/8)
			:endChildren()
		:draw()
end
