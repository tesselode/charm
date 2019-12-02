local charm = require 'charm'

local titleFont = love.graphics.newFont(24)

local Window = charm.extend()

function Window:new(title, x, y, width, height)
	self._title = title
	self.__parent.new(self, x, y, width, height)
end

function Window:onAddChild(element)
	self._content = self._content or {}
	table.insert(self._content, element)
end

function Window:beforeDraw()
	local titlebar = self.ui:create 'rectangle'
		:addChild(self.ui:create('text', titleFont, self._title))
		:wrap(4)
		:x(0):y(0)
		:width(self:get 'width')
		:fillColor(.2, .2, .2)
	self:addChild(titlebar)

	local contentContainer = self.ui:create 'rectangle'
		:top(titlebar:get 'bottom')
		:width(self:get 'width')
		:height(self:get 'height' - titlebar:get 'height')
		:fillColor(.1, .1, .1)
		:clip()
	for _, child in ipairs(self._content) do
		contentContainer:addChild(child)
	end
	self:addChild(contentContainer)
end

local ui = charm.new()

function love.draw()
	ui
		:new(Window, 'test window', 50, 50, 200, 200)
			:beginChildren()
				:new('rectangle', 50, 50, 200, 200)
					:fillColor(1, 0, 0)
			:endChildren()
		:draw()
end
