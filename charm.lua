local charm = {}

local function newElementClass(parent)
	local class = setmetatable({
		parent = parent,
		get = setmetatable({}, {
			__index = parent and parent.get,
			__call = function(_, self, propertyName, ...)
				return self.get[propertyName](self, ...)
			end,
		}),
	}, {__index = parent})
	class.__index = class
	return class
end

local Element = newElementClass()

function Element:new(x, y, width, height)
	self._x = x
	self._y = y
	self._width = width
	self._height = height
end

function Element.get:width()
	return self._width or 0
end

function Element.get:height()
	return self._height or 0
end

function Element.get:size()
	return self:get 'width', self:get 'height'
end

function Element.get:x(origin)
	origin = origin or 0
	return self._x + self:get 'width' * origin
end

function Element.get:y(origin)
	origin = origin or 0
	return self._y + self:get 'height' * origin
end

function Element.get:rectangle()
	return self:get 'x', self:get 'y', self:get 'size'
end

function Element:width(width)
	self._width = width
end

function Element:height(height)
	self._height = height
end

function Element:x(x, origin)
	origin = origin or 0
	self._x = x - self:get 'width' * origin
end

function Element:y(y, origin)
	origin = origin or 0
	self._y = y - self:get 'width' * origin
end

function Element:drawDebug()
	love.graphics.push 'all'
	love.graphics.setColor(1, 0, 0)
	love.graphics.rectangle('line', self:get 'rectangle')
	love.graphics.pop()
end

local elementClasses = {
	element = Element,
}

local Ui = {}

function Ui:__index(k)
	if Ui[k] then return Ui[k] end
	self._functionCache[k] = self._functionCache[k] or function(_, ...)
		self._selected[k](self._selected, ...)
		return self
	end
	return self._functionCache[k]
end

function Ui:_clear(element)
	for k, v in pairs(element) do
		if type(v) == 'table' then
			for kk in pairs(v) do
				v[kk] = nil
			end
		else
			element[k] = nil
		end
	end
end

function Ui:begin()
	for i in ipairs(self._tree) do
		self._tree[i] = nil
	end
	for _, element in ipairs(self._pool) do
		element.used = false
	end
	self._finished = false
end

function Ui:new(class, ...)
	-- if we just finished drawing, start a new frame
	if self._finished then self:begin() end
	-- get the element class if a name was provided
	if type(class) == 'string' then
		class = elementClasses[class]
	end
	-- reuse an existing element if possible
	local element
	for _, e in ipairs(self._pool) do
		if not e.used then
			element = e
			break
		end
	end
	-- otherwise, create a new one
	if not element then
		element = {}
		table.insert(self._pool, element)
	end
	-- clear out the element
	self:_clear(element)
	-- initialize the element
	element.used = true
	setmetatable(element, class)
	element:new(...)
	-- add the element to the tree
	table.insert(self._tree, element)
	-- select the element
	self._selected = element
	return self
end

function Ui:drawDebug()
	for _, element in ipairs(self._tree) do
		element:drawDebug()
	end
	self._finished = true
end

function charm.new()
	return setmetatable({
		_functionCache = {},
		_pool = {},
		_tree = {},
		_finished = false,
		_selected = nil,
	}, Ui)
end

return charm
