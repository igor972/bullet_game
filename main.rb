require "gosu"

class Game
	attr_accessor :window

	def initialize window
		@window = window
		@player = Player.new self
	end

	def update
		@player.update
	end

	def draw
		@player.draw
	end
end




class Player
	attr_accessor :x, :y, :game

	def initialize game
		@game = game
		@image = Gosu::Image.from_text @game.window, "E", Gosu.default_font_name, 100

		@x = 0
		@y = @game.window.height/2 - @image.height/2
	end

	def update
		@y += 10 if @game.window.button_down? Gosu::KbDown and @y <= 500
		@y -= 10 if @game.window.button_down? Gosu::KbUp and @y >= 0
	end

	def draw
		@image.draw @x, @y, 0
	end
end






class Window < Gosu::Window
	def initialize width = 800, height = 600, fullscreen = false
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