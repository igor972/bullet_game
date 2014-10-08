require "gosu"

class Game
	def initialize window
		@window = window
		
		@letter = Gosu::Image.from_text @window, "E", Gosu.default_font_name, 100
		@letter_x = 0
		@letter_y = @window.height/2 - @letter.height/2

		#Bullet
		@bullet = Gosu::Image.from_text @window, ">", Gosu.default_font_name, 50
		@bullet_x = 0
		@bullet_y = @letter_y
		@bullet_launched = false
	end

	def update
		if @window.button_down? Gosu::KbUp and @letter_y >= 0
			@letter_y -= 8	
		end

		if @window.button_down? Gosu::KbDown and @letter_y <= 500
			@letter_y += 8
		end

		if @window.button_down? Gosu::KbSpace 
			@bullet_launched = true
			if @bullet_x == 0
				@bullet_y = @letter_y
			end
		end

		if @bullet_x <= 500 and @bullet_launched == true
			@bullet_x +=10
		else
			@bullet_x = 0
			@bullet_launched = false
		end
	end

	def draw
		@letter.draw @letter_x, @letter_y, 0
		
		if @bullet_launched == true
			@bullet.draw @bullet_x, @bullet_y, 0
		end
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