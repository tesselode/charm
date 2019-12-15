local charm = {}

local function newElementClass(parent)
	local class = {
		get = setmetatable({}, {__index = parent and parent.get})
	}
	class.__index = class
	setmetatable(class, {__index = parent})
	return class
end

local Element = newElementClass()

function Element:new(x, y, width, height)
	self._x = x
	self._y = y
	self._width = width
	self._height = height
end

function Element.get:x(anchor)
	anchor = anchor or 0
	return (self._x or 0) + (self._width or 0) * anchor
end

function Element.get:left() return self.get.x(self, 0) end
function Element.get:center() return self.get.x(self, .5) end
function Element.get:right() return self.get.x(self, 1) end

function Element.get:y(anchor)
	anchor = anchor or 0
	return (self._y or 0) + (self._height or 0) * anchor
end

function Element.get:top() return self.get.y(self, 0) end
function Element.get:middle() return self.get.y(self, .5) end
function Element.get:bottom() return self.get.y(self, 1) end

function Element.get:width() return self._width or 0 end
function Element.get:height() return self._height or 0 end

function Element.get:size()
	return self.get.width(self), self.get.height(self)
end

function Element:x(x, anchor)
	anchor = anchor or 0
	self._anchorX = anchor
	self._x = x - self.get.width(self) * anchor
end

function Element:left(x) self:x(x, 0) end
function Element:center(x) self:x(x, .5) end
function Element:right(x) self:x(x, 1) end

function Element:y(y, anchor)
	anchor = anchor or 0
	self._anchorY = anchor
	self._y = y - self.get.height(self) * anchor
end

function Element:top(y) self:y(y, 0) end
function Element:middle(y) self:y(y, .5) end
function Element:bottom(y) self:y(y, 1) end

function Element:width(width)
	local anchor = self._anchorX or 0
	local x = self.get.x(self, anchor)
	self._width = width
	self:x(x, anchor)
end

function Element:height(height)
	local anchor = self._anchorY or 0
	local y = self.get.y(self, anchor)
	self._height = height
	self:y(y, anchor)
end

function Element:size(width, height)
	self:width(width)
	self:height(height)
end

charm.Element = Element

return charm
