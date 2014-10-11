require "gosu"

class Game
	attr_accessor :window

	def initialize window
		@window = window
		@player = Player.new self
		@bullets = []
	end

	def update
		@player.update

		if @window.button_down?(Gosu::KbSpace)
			@bullets.push(Bullet.new(self, 0, @player.y))
		end

		# update bullet and remove from array 'dead bullets'
		@bullets.each {|bullet| if bullet.live == true then bullet.update else @bullets.delete(bullet) end}
	end

	def draw
		@player.draw
		@bullets.each {|bullet| bullet.draw}
	end
end

class Player
	attr_accessor :x, :y, :game

	def initialize game
		@game = game
		@image = Gosu::Image.from_text @game.window, "E", Gosu.default_font_name, 50

		@x = 0
		@y = @game.window.height/2 - @image.height/2
	end

	def update
		@y += 10 if @game.window.button_down? Gosu::KbDown and @y <= @game.window.height - @image.height
		@y -= 10 if @game.window.button_down? Gosu::KbUp and @y >= 0
	end

	def draw
		@image.draw @x, @y, 0
	end
end

class Bullet
	attr_accessor :x, :y, :game, :live

	def initialize game, x, y
		@game = game
		@image = Gosu::Image.from_text @game.window, ">", Gosu.default_font_name, 30
		@x = x
		@y = y
		@live = true
	end

	def update
		if @x <= (@game.window.width - 20) and @live == true
			@x += 10 
		else
			@live = false
		end
	end

	def draw
		@image.draw @x, @y, 0 unless @live == false
	end
end

class Window < Gosu::Window
	def initialize width = 1200, height = 600, fullscreen = false
		super
		@game = Game.new self
	end

	def update
		@game.update
	end

	def draw
		@game.draw
	end
end

window = Window.new.show