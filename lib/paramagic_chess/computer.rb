require_relative 'player.rb'

module ParamagicChess
  # AI for chess game
  class Computer < Player
    def initialize(name: 'computer', side: nil)
      super
    end

    def computer?
      true
    end

    def pick_random_piece
      @pieces.sample
    end

    def pick_random_pos(piece:)
      piece.possible_moves.sample
    end

    def make_random_move(board:)
      update_pieces(self)
      # update pieces selectable
      piece = pick_random_piece
      # update moves to select from possible moves
      piece.update_moves(board: board)
      # select end destination
      end_pos = pick_random_pos(piece: piece)
      # send to game
      puts "moving #{piece.starting_pos} to #{end_pos}"
      piece.move_to(board: board, pos: end_pos)
    end
  end
end
