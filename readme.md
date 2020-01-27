Charm
=====
Charm is a library for LÖVE that makes it easier to arrange and draw graphics, such as shapes, images, and text. It excels at relative positioning, which can become cumbersome as a layout gets more complex. It also handles mouse events, so it can be used for basic UI tasks, like creating buttons.

This library is similar to [Boxer](https://github.com/tesselode/boxer), but it's **immediate mode**, which means that instead of creating objects that represent each graphic you want to draw, you simply tell Charm what you want to draw on each frame.

Example
-------
![](https://i.imgur.com/gPAE6Wa.gif)

```lua
function love.draw()
	layout
		:new 'transform'
			:beginChildren()
				:new('rectangle', 0, 0, 300, 250)
					:beginChildren()
						:new('paragraph', font, text, 280, 'left', 10, 10 - textScrollY)
							:color(0, 0, 0)
						textHeight = layout:get('@current', 'height')
					layout:endChildren()
					:fillColor(.8, .8, .8)
					:clip()
			:endChildren()
			:left(100):top(100)
			:scale(animationProgress)
			:angle((1 + animationProgress) * math.pi)
		:draw()
end
```

> This is a snippet from the [dialog](https://github.com/tesselode/charm/blob/master/demos/dialog.lua) demo.

Installation
------------
To use Charm, place charm.lua in your project, and then `require` it in each file where you need to use it:

```lua
local charm = require 'charm' -- if your charm.lua is in the root directory
local charm = require 'path.to.charm' -- if it's in subfolders
```

Demos
-----
To see a demo, run love on the charm folder with the name of a demo as an argument:
```
love . dialog
love . menu
```

Contributing
------------
Charm is in very early development. Feel free to ask questions, point out bugs, and even make some pull requests! If you use this library in a game, let me know how it goes.
