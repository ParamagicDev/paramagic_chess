# Initial require for the classes that inherit piece to be able to inherit
# Piece IE: Rook < Piece
require "paramagic_chess/pieces/piece"

# Expands the path of this particular file
lib_path = File.expand_path(File.dirname(__FILE__))
# Once expanded, it then finds the contents in the directory & iterates through
# The double ** followed by /* allows constant traversal down of directory
Dir[lib_path + "/paramagic_chess/**/*.rb"].each { |file| require file }



module ParamagicChess
  # Your code goes here...
end
game = ParamagicChess::Board.new
game.print_board

# game.board[:d4] = ParamagicChess::Queen.new(pos: :d4, side: :white)
# game.print_board