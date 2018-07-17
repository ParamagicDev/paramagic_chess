module ParamagicChess
  class Game
    SAFE_WORDS = [:save, :load, :castle]
    
    def initialize
      @board = Board.new
      @players = []
    end
    
    def add_players
      puts "What is your name? \n"
      player1 ||= gets.chomp
      @players << Player.new(player1)
      
      puts "Will you play against a computer or another player? (Y/N) \n"
      computer ||= gets.chomp.downcase.to_sym
      if computer == :y
        # @players << Computer.new
        # TODO: Add computer / AI
      elsif computer == :n
        puts "What is the name of the other player? \n"
        player2 ||= gets.chomp
        @players << Player.new(player2)
      end
    end
    
    def play
      greeting_message
      add_players
      # loop do
        
      # end
    end
    
    def check
    end
    
    def greeting_message
      system 'clear'
      puts "Welcome to ParamagicChess. Theres nothing magical here \n
            Just Chess."
    end
    
    private
    
    def check_mate
    end
    
    def castle
    end
    
    def input(input: gets.chomp)
      SAFE_WORDS.include?(input.to_sym)
    end
  end
end