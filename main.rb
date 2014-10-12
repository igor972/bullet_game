require "gosu"

class Game
	attr_accessor :window

	def initialize window
		@window = window
		@player = Player.new self
		@bullets = []

		
		@enemies = []
		@music = Gosu::Song.new(@window, "bullet_game_1.mp3").play(true)
	end

	def update
		@player.update
		@enemies.each {|enemy| enemy.update}

		# generate some enemies
		if Gosu.milliseconds % 25 == 0
			@enemies.push(Enemy.new(self))
		end

		@enemies.each do |enemy|
			if Gosu.distance(@player.x, @player.y, enemy.x, enemy.y) <= 30 and @player.alive == true
				@player.die!
				@game_over = Gosu::Image.from_text @window, "GAME OVER", Gosu.default_font_name, 200
			end

			# remove dead enemies
			@enemies.delete(enemy) if enemy.alive == false
		end

		if @window.button_down?(Gosu::KbSpace)
			@bullets.push(Bullet.new(self, 0, @player.y))
		end

		@bullets.each do |bullet|
			if bullet.live
				bullet.update

				@enemies.each {|enemy| if bullet.x == enemy.x then enemy.hited!end}
			else
				@bullets.delete(bullet)
			end
		end

	end

	def draw
		@player.draw
		@bullets.each {|bullet| bullet.draw}

		@game_over.draw 0,0,0 unless @player.alive

		@enemies.each {|enemy| enemy.draw}
	end

end

class ObjectOnWindow
end


class Player < ObjectOnWindow
	attr_accessor :x, :y, :game, :alive

	def initialize game
		@game = game
		@image = Gosu::Image.from_text @game.window, "E", Gosu.default_font_name, 50

		@x = 0
		@y = (@game.window.height/2 - @image.height/2) + 10

		@alive = true

		@sample = Gosu::Sample.new(@game.window, "you_lose_bitch.mp3")
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
		@sample.play
	end
end

class Bullet < ObjectOnWindow
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
	attr_accessor :x, :y, :game, :alive

	def initialize game
		@game = game
		
		@image = Gosu::Image.from_text @game.window, "H", Gosu.default_font_name, 50
		
		@x = @game.window.width
		@y = Random.new.rand(0..(@game.window.height - @image.height))

		@alive = true
	end
	
	def update
		if @x > 0 and @alive == true
			@x -= 10
		else
			@alive = false
		end
	end

	def draw
		@image.draw @x, @y, 0, -1
	end

	def hited!
		@alive = false
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