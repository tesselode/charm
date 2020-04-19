# Extending Charm
While Charm's built-in elements are useful, they can't cover all situations. Charm lets you create your own **element classes** that can extend and replace behavior from the built-in classes.

## How UIs manage elements
Before you create your element class, it's important to understand how UI objects deal with element instances.

Charm is immediate mode, so the user is recreating the element tree every frame. To keep this process memory-efficient, the UI object clears out and reuses old element instances whenever possible.

When clearing out element instances:

- Tables are cleared, leaving an empty table
- All other values are niled out

Therefore, when writing element classes, you should keep in mind that:

- Values you set on an element instance will not be remembered after the next `draw`
- Empty tables may be left behind from previous element trees

If you don't want a certain value to be cleared out, you can add a variable name to the `clearMode` table on your element class.

## How element classes work
Most of the time, when you call a function on a `Ui`, you're really calling a function on an element class.

For example, here's the constructor for `Image`s:
```lua
function Image:new(image, x, y)
	-- not pictured: some error checking code
	self._image = image
	self._x = x
	self._y = y
	self._width, self._height = image:getDimensions()
end
```
When you call `ui:new('image', image, x, y)`, every argument after the first one is passed to `Image.new` to initialize it.

In fact, if you call any function on a `Ui` that isn't already defined on the `Ui` class, it calls the corresponding function on the class of the currently selected element. Functions like `left`, `fillColor`, and `wrap` all live on the base element class.

`ui.get` works similarly: it calls the function `ElementClass.get[propertyName]`. So `ui:get('@current', 'x', .5)` is calling this function defined in the base element class:
```lua
function Element.get:x(origin)
	origin = origin or 0
	return (self._x or 0) + self:get 'width' * origin
end
```

Because most functionality lives on the element classes, you have a lot of power to reshape how Charm works.

## Creating new classes
To create a new class, use `charm.extend`.

## Callbacks
Here's the important callbacks that you may want to define:

- `new`: accepts arguments from `ui.new` and initializes the element
- `drawBottom`: draws things below the element's children
- `drawTop`: draws things above the element's children
- `stencil`: draws the stencil that's used to clip children to the visible area of the element (when clipping is enabled)
- `onAddChild`: called when an child is added to this element. You don't actually have to add it to the internal children list; you can do whatever you want!

If you want to get real fancy, you can redefine the `draw` callback. This callback has a decent amount of non-trivial code, and I tried to set things up so you wouldn't need to change this. But I can't stop you!

## Useful utilities
The base element class comes with some useful utilities for custom classes:

- `hasChildren`: returns whether the element has any children
- `isColorSet`: returns whether a value is a valid color
- `setColor`: sets a variable with the specified name to the given color. This can take either 4 number arguments or 1 table argument.

Sometimes, you may want to call a property getter from within an element class. Because the property getter functions live inside `ElementClass.get`, calling them is a bit cumbersome:
```lua
self.get.myCoolProperty(self, ...)
```
To make this a little more pleasant, you can call `ElementClass.get` as a function instead:
```lua
self:get('myCoolProperty', ...)
```
