require "gosu"

class Game
	attr_accessor :window

	def initialize window
		@window = window
		@player = Player.new self
		@bullets = []

		
		@enemies = []
		@music = Gosu::Song.new(@window, "bullet_game_1.mp3").play(true)

		@score = Score.new(self)
	end

	def update
		@player.update
		@enemies.each {|enemy| enemy.update}
		@score.update

		# generate some enemies
		if Gosu.milliseconds % 25 == 0
			@enemies.push(Enemy.new(self))
		end

		@enemies.each do |enemy|
			if Gosu.distance(@player.x, @player.y, enemy.x, enemy.y) <= 30 and @player.alive == true
				@player.die!
				@game_over = Gosu::Image.from_text @window, "GAME OVER", Gosu.default_font_name, 200
				@score.x = @window.width/2 - 150
				@score.y = 300
				@score.font_size = 100
			end

			# delete dead enemies
			@enemies.delete(enemy) if enemy.alive == false
		end

		if @window.button_down?(Gosu::KbSpace) and @player.alive == true
			@bullets.push(Bullet.new(self, 0, @player.y))
		end

		@bullets.each do |bullet|
			if bullet.alive
				bullet.update

				@enemies.each do |enemy|
					if Gosu.distance(enemy.x, enemy.y, bullet.x, bullet.y) <= 30
						enemy.hited!
						@score.deaths += 1
					end
				end
			else
				@bullets.delete(bullet)
			end
		end

	end

	def draw
		@player.draw
		@bullets.each {|bullet| bullet.draw}
		@score.draw

		@game_over.draw 40, 0,0 unless @player.alive

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
		Gosu::Sample.new(@game.window, "player_die.wav").play
		Gosu::Sample.new(@game.window, "you_lose_bitch.mp3").play
	end
end

class Bullet < ObjectOnWindow
	attr_accessor :x, :y, :game, :alive

	def initialize game, x, y
		@game = game
		@image = Gosu::Image.from_text @game.window, ">", Gosu.default_font_name, 30
		@x = x
		@y = y
		@alive = true
		Gosu::Sample.new(@game.window, "bullet.mp3").play
	end

	def update
		if @x <= (@game.window.width - 20) and @alive == true
			@x += 10 
		else
			@alive = false
		end
	end

	def draw
		@image.draw @x, @y, 0 unless @alive == false
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
		Gosu::Sample.new(@game.window, "enemy_die_1.mp3").play
	end

end

class Score
	attr_accessor :deaths, :x, :y, :font_size
	attr_reader :width

	def initialize game
		@game = game
		@x = 20
		@y = 20

		@deaths = 0
		@font_size = 25
	end

	def update
		string_value = ("%05d" % (@deaths * 10)).to_s
		@image = Gosu::Image.from_text @game.window, string_value, Gosu.default_font_name, @font_size
		@width = @image.width
	end

	def draw
		@image.draw @x, @y, 1
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