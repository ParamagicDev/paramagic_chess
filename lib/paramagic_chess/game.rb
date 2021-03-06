# frozen_string_literal: true

require 'yaml'

module ParamagicChess
  # Main class for paramagic_chess
  class Game
    SAFE_WORDS = %i[save load castle exit piece_info].freeze
    DIRNAME = 'saved_games/'
    DIRPATH = __dir__.split('lib').first + DIRNAME
    LOAD_PATH = Dir[DIRPATH + '*.yaml']

    attr_accessor :players
    attr_reader :board, :_test

    def initialize(_test: false)
      @game_started = false
      @_test = _test
      @players = []
    end

    # player1, player2, and input all added for testing purposes
    def add_players(player1: nil, player2: nil, input: nil)
      add_player(name: player1)
      add_computer_or_player(player: player2, input: input)
    end

    def add_board
      @board = Board.new
    end

    def setup_game
      # Asks the player if he would like to load a previous game
      return if load_game == :loaded

      add_board
      add_players
      randomize_sides
      @turn = :red
      @game_started = true
    end

    def play
      greeting_message
      setup_game if @game_started == false
      loop do
        break if game_over?

        update_pieces
        take_turn
      end

      Game.new.play if play_again? == true
      exit_game
    end

    def play_again?(input: nil)
      puts 'would you like to play again?'
      puts 'type yes to play again, anything else will exit.'
      input ||= gets.chomp.to_sym
      return false if input != :yes

      true
    end

    def randomize_sides
      @players.shuffle!
      @players[0].side = :red
      @players[1].side = :blue
    end

    def greeting_message
      system 'clear'
      print "Welcome to ParamagicChess. Theres nothing magical here Just Chess. \n"
      puts 'Would you like to load a previous game? (Y/N)'
    end

    def game_over?
      update_pieces(player: player_1)
      update_pieces(player: player_2)
      p1 = true if player_1.check_mate?(board: @board) == true
      p2 = true if player_2.check_mate?(board: @board) == true
      if p1 == true || p2 == true
        puts "CONGRATULATIONS! #{winner.name}, you have won!".highlight
        puts "Sorry, #{loser.name} you have lost.".highlight
        return true
      end
      false
    end

    def computer
      @players.each { |player| return player if player.computer? == true }
    end

    def player_1
      @players[0]
    end

    def player_2
      @players[1]
    end

    def piece_info_game(coords: nil)
      puts 'Enter the coordinates of the piece you wish to know the type of'
      loop do
        coords ||= gets.chomp.downcase
        if CHAR_TO_NUM.key?(coords[0].to_sym) && !(coords[1].to_i < 1 || coords[1].to_i > 8)
          piece = @board.piece(pos: coords.to_sym)
          return puts 'No piece found' if piece.nil?

          return puts piece.type.to_s
        end
        puts "#{coords} is not a coordinate. Please enter the coordinates of the piece whose type you would like to know".highlight
        coords = nil
      end
    end

    def get_input(input: nil)
      input ||= gets.chomp.downcase
      # checks for safewords
      return send((input + '_game').to_sym) if SAFE_WORDS.include?(input.to_sym)

      input = input.split(' to ')

      return if good_input(input: input).nil?

      [input[0].to_sym, input[1].to_sym]
    end

    def update_pieces(player: get_player_turn)
      player.pieces = []
      @board.board.each do |_coord, tile|
        next if tile.piece.nil?

        player.pieces << tile.piece if tile.piece.side == player.side
      end
    end

    def add_computer(side: nil)
      @players << Computer.new(side: side)
    end

    private

    def winner
      return player_2 if player_1.check_mate == true
      return player_1 if player_2.check_mate == true

      false
    end

    def loser
      return player_2 if winner == player_1
      return player_1 if winner == player_2

      false
    end

    def good_input(input:)
      # checks for if to is included
      error_msg = 'Please follow the example of a2 to a4'
      unless input.length == 2
        puts error_msg
        return nil
      end
      # checks for letters
      return puts error_msg unless CHAR_TO_NUM.include?(input[0][0].to_sym)
      return puts error_msg unless CHAR_TO_NUM.include?(input[1][0].to_sym)

      # checks for board size
      return nil if input[0][1].to_i < 1 || input[1][1].to_i < 1
      return nil if input[0][1].to_i > 8 || input[1][1].to_i > 8

      input
    end

    def exit_game
      exit!
    end

    def save_game
      @game_started = true
      Dir.mkdir(DIRPATH) unless Dir.exist?(DIRPATH)

      puts 'What would you like to name your file?'
      file_name = gets.chomp.downcase.to_s + '.yaml'
      Dir.chdir(DIRPATH) do
        if LOAD_PATH.include?(DIRPATH + file_name)
          puts "\nA file with that name already exists."
          loop do
            puts 'Would you like to overwrite it? (Y/N)'
            input = gets.chomp.to_sym
            break if input == :y

            puts "File not saved.\n"
            return nil if input == :n
          end
        end
        file = File.new(file_name, 'w+')
        YAML.dump(self, file)
      end
      exit_game
    end

    def load_game(input: nil)
      loop do
        input ||= gets.chomp.downcase.to_sym
        break if input == :y
        return nil if input == :n

        puts 'please enter Y or N to load a game.'
        input = nil
      end
      # Ensures the player has save files
      if LOAD_PATH.empty?
        puts 'You do not have any saved games.'
        return nil
      end
      puts 'You have the following save games:'
      LOAD_PATH.each { |file| puts File.basename(file, '.yaml').highlight }

      puts "\nWhich file would you like to load?"
      file_name = ''
      loop do
        file_name = gets.chomp + '.yaml'
        break if LOAD_PATH.include?(DIRPATH + file_name)

        puts 'Unable to locate that file. Please try again.'
      end

      # Makes sure the file being loaded has proper YAML
      begin
        Psych.load_file(File.new(DIRPATH + file_name, 'r+')).play
        return :success
      rescue Psych::SyntaxError => ex
        ex.file
        ex.message
        nil
      end
      nil
    end

    def print_game
      system 'clear'
      @board.print_board
      puts "\nsafe words are: #{Game::SAFE_WORDS}"
      puts 'To move a piece, enter the piece coordinate followed by destination'
      puts 'IE: a2 to a4; f7 to f5'
    end

    def print_turn
      player = get_player_turn
      print "\nIt is your turn #{player.name}".send(player.side)
      puts "\nYou are #{player.side}".send(player.side)
      player.check?(board: @board)
    end

    def take_turn
      player = get_player_turn
      @board.reset_pawn_double_move(side: player.side)

      move_piece(player: player)
      swap_turn
    end

    def move_piece(player:, input: nil)
      if player.class == Computer
        computer.make_random_move(board: @board)
        return true
      end

      print_game
      loop do
        print_turn
        input = get_input
        # if sanitized input return nil, invalid input, repeat
        next if input.nil?
        break if input == :castled

        moving_piece = @board.piece(pos: input[0])
        # checks to make sure its a valid piece
        if moving_piece.nil? || !player.pieces.include?(moving_piece)
          puts 'Please enter a valid piece to move'.highlight
          next
        end

        end_pos = input[1]
        move = moving_piece.move_to(pos: end_pos, board: @board)
        # if the move is not valid will repeat loop
        next if move.nil?

        break
      end
    end

    def get_player_turn
      return player_1 if @turn == :red
      return player_2 if @turn == :blue
    end

    def swap_turn
      return @turn = :red if @turn == :blue

      @turn = :blue
    end

    def add_player(name: nil)
      name ||= "testing" if @_test == true
      puts 'What is your name?' if @players.empty?
      puts "What is player2's name?" if @players.size == 1
      name ||= gets.chomp
      @players << Player.new(name: name)
    end

    def add_computer_or_player(player: nil, input: nil)
      input ||= :n if @_test == true

      unless input == :y || input == :n
        puts 'Would you like to play against a computer? (Y/N)'
        input = gets.chomp.to_sym
      end

      return add_computer if input == :y

      add_player(name: player)
    end


    def can_castle?(king:)
      return true if king.can_castle?(board: @board, direction: :left)

      return true if king.can_castle?(board: @board, direction: :right)

      false
    end

    def castle_game(direction: nil)
      player = get_player_turn
      if player.has_castled?
        puts 'You already castled once!'.highlight
        return nil
      end

      king = player.get_king

      if can_castle(king: king) == false
        puts 'You cannot castle right now'.highlight
        return nil
      end

      puts 'Which direction would you like to castle? left or right?'
      direction ||= gets.chomp.downcase.to_sym
      castled = king.castle(direction: direction, board: @board)

      return nil if castled.nil?

      player.has_castled = true
      :castled
    end
  end
end
