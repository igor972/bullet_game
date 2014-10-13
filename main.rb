require "gosu"

class Game
	attr_accessor :window

	def initialize window
		@window = window
		@player = Player.new self
		@bullets = []

		
		@enemies = []

		@score = Score.new(self)
	end

	def update
		@player.update
		@enemies.each {|enemy| enemy.update}
		@score.update

		# generate some enemies
		@enemies.push(Enemy.new(self)) if Gosu.milliseconds % 5 == 0

		@enemies.each do |enemy|
			if Gosu.distance(@player.x, @player.y, enemy.x, enemy.y) <= 50 and @player.alive == true
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
			@bullets.push(Bullet.new(self, 0, @player.y + @player.height/2))
		end

		@bullets.each do |bullet|
			if bullet.alive
				bullet.update

				@enemies.each do |enemy|
					if Gosu.distance(enemy.x, enemy.y, bullet.x, bullet.y) <= 30
						enemy.hited!
						bullet.alive = false
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

		@game_over.draw 40, 0,1 unless @player.alive

		@enemies.each {|enemy| enemy.draw}
	end

end

class ObjectOnWindow
end


class Player < ObjectOnWindow
	attr_accessor :x, :y, :game, :alive
	attr_reader :height

	def initialize game
		@game = game

		@image = Gosu::Image.new(@game.window, "assets/player_image.png", false)
		
		@height = @image.height
		@x = 0
		@y = (@game.window.height/2 - @image.height/2) + 10

		@alive = true
	end

	def update
		@y += 10 if @game.window.button_down? Gosu::KbDown and @y <= @game.window.height - @image.height
		@y -= 10 if @game.window.button_down? Gosu::KbUp and @y > 0
	end

	def draw
		@image.draw @x, @y, 2 if @alive
	end

	def die!
		@alive = false
		Gosu::Sample.new(@game.window, "assets/player_die.wav").play
		Gosu::Sample.new(@game.window, "assets/you_lose_bitch.mp3").play
		$game_state = :new
	end
end

class Bullet < ObjectOnWindow
	attr_accessor :x, :y, :game, :alive

	def initialize game, x, y
		@game = game
		@image = Gosu::Image.new(@game.window, "assets/bullet.png", false)
		@x = x
		@y = y
		@alive = true
		Gosu::Sample.new(@game.window, "assets/bullet.mp3").play
	end

	def update
		if @x <= (@game.window.width - 20) and @alive == true
			@x += 20 
		else
			@alive = false
		end
	end

	def draw
		@image.draw @x, @y, 1 unless @alive == false
	end
end

class Enemy < ObjectOnWindow
	attr_accessor :x, :y, :game, :alive

	def initialize game
		@game = game

		@image = Gosu::Image.new(@game.window, "assets/asteroid.png", false)

		@x = @game.window.width
		@y = Random.new.rand(0..(@game.window.height - @image.height))
		@speed = Random.rand(5..20)

		@alive = true
	end
	
	def update
		if @x > 0 and @alive == true
			@x -= @speed
		else
			@alive = false
		end
	end

	def draw
		@image.draw @x, @y, 1
	end

	def hited!
		@alive = false
		Gosu::Sample.new(@game.window, "assets/enemy_die_1.mp3").play
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
	
	# Game State :new, ,:playing, :pause
	$game_state

	def initialize width = 1200, height = 600, fullscreen = false
		super
		@background = Gosu::Image.new(self, "assets/background.png", false)
		@music = Gosu::Song.new(self, "assets/bullet_game_1.mp3")
		
		@initial_message = Gosu::Image.from_text(self, "Press Enter to play/restart!", Gosu.default_font_name, 50)
		$game_state = :new
	end

	def button_down(id)
		if id == Gosu::KbReturn
			game_new
		end

		if id == Gosu::KbP
			game_pause
		end
	end

	def update
		@game.update if $game_state == :playing
	end

	def draw
		@game.draw if $game_state == :playing or $game_state == :pause
		@background.draw 0, 0, 0
		if $game_state == :new
			@initial_message.draw (self.width/2 - @initial_message.width/2), (self.height/2 - @initial_message.height/2), 2, 1, 1, Gosu::Color.argb(0xffff0000)
		end
	end

	def game_pause
		case($game_state)
		when :playing
			$game_state = :pause
			@music.pause
		when :pause
			$game_state = :playing
			@music.play(true)
		end
	end

	def game_new
		@game = Game.new self
		@music.play(true)
		$game_state = :playing
	end
end

window = Window.new.show