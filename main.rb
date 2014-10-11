require "gosu"

class Game
	attr_accessor :window

	def initialize window
		@window = window
		@player = Player.new self
		@bullets = []

		@enemy = Enemy.new self
	end

	def update
		@player.update
		@enemy.update

		# e_location = @enemy.where_am_i
		# p_location = @player.where_am_i

		# if (p_location[:x2].between?(e_location[:x1], e_location[:x2]) and 
		# 	p_location[:y2].between?(e_location[:y1], e_location[:y2])) ||
		# 	(p_location[:x2].between?(e_location[:x3], e_location[:x4]) and 
		# 	p_location[:y2].between?(e_location[:y3], e_location[:y4]))

		# 	@player.die!
		# 	@game_over = Gosu::Image.from_text @window, "GAME OVER", Gosu.default_font_name, 200
		# end

		if @window.button_down?(Gosu::KbSpace)
			@bullets.push(Bullet.new(self, 0, @player.y))
		end

		@bullets.each do |bullet|
			if bullet.live
				bullet.update
				if bullet.x == @enemy.x
					@enemy.hited!
				end
			else
				@bullets.delete(bullet)
			end
		end
	end

	def draw
		@player.draw
		@bullets.each {|bullet| bullet.draw}

		@enemy.draw

		# @game_over.draw 0,0,0 unless @player.alive
	end

end

class ObjectOnWindow

	# Object representation
	# x1/y1 ________ x2/y2
	#      |        |
	#      |        |
	# x3/y3|________|x4/y4
	
	# return location of object FIX
	def where_am_i
		x1 = @x - @image.width
		x2 = @x
		x3 = @x - @image.width
		x4 = @x
		
		y1 = @y - @image.height
		y2 = @y - @image.height
		y3 = @y
		y4 = @y

		return {x1: x1, x2: x2, x3: x3, x4: x4, y1: y1, y2: y2, y3: y3, y4: y4}
	end

end


class Player < ObjectOnWindow
	attr_accessor :x, :y, :game, :alive

	def initialize game
		@game = game
		@image = Gosu::Image.from_text @game.window, "E", Gosu.default_font_name, 50

		@x = 0
		@y = (@game.window.height/2 - @image.height/2) + 10

		@alive = true
	end

	def update
		@y += 10 if @game.window.button_down? Gosu::KbDown and @y <= @game.window.height - @image.height
		@y -= 10 if @game.window.button_down? Gosu::KbUp and @y > 0
	end

	def draw
		@image.draw @x, @y, 0 if @alive
	end

	def die!
		@alive = false
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

class Enemy < ObjectOnWindow
	attr_accessor :x, :y, :game, :live

	def initialize game
		@game = game
		
		@image = Gosu::Image.from_text @game.window, "E", Gosu.default_font_name, 50
		
		@x = @game.window.width
		@y = Random.new.rand(0..(@game.window.height - @image.height))

		@live = true
	end
	
	def update
		if @x > 0 and @live == true
			@x -= 1
		else
			@live = false
		end
	end

	def draw
		@image.draw @x, @y, 0, -1
	end

	def hited!
		# puts "ATINGIDO"
		@live = false
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