require "gosu"

class Game
	def initialize window
		@window = window
		
		@letter = Gosu::Image.from_text @window, "E", Gosu.default_font_name, 100
		@letter_x = 0
		@letter_y = @window.height/2 - @letter.height/2
	end

	def update
		if @window.button_down? Gosu::KbUp
			@letter_y -= 8	
		end

		if @window.button_down? Gosu::KbDown
			@letter_y += 8
		end
	end

	def draw
		@letter.draw @letter_x, @letter_y, 0
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