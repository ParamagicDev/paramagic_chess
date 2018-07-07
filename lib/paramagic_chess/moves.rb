require_relative '../paramagic_chess/board.rb'

module ParamagicChess
  module Moves
    class Move
      MAX_INDEX = ParamagicChess::Board::MAX_INDEX
      MIN_INDEX = ParamagicChess::Board::MIN_INDEX
      def to_pos(x:, y:)
        (x.to_s + y.to_s).to_sym
      end
      
      def blocked_by_team?(board:, pos:, piece:)
        tile = board.board[pos]
        return false if tile.nil?
        return true if tile.contains_red_piece? && piece.side == :red
        return true if tile.contains_blue_piece? && piece.side == :blue
        false
      end
      
      def blocked_by_enemy?(board:, pos:, piece:)
        tile = board.board[pos]
        return false if tile.nil?
        return true if tile.contains_red_piece? && piece.side == :blue
        return true if tile.contains_blue_piece? && piece.side == :red
        false
      end
      
      def out_of_bounds?(x:, y:)
        return true if x > MAX_INDEX || x < MIN_INDEX
        return true if y > MAX_INDEX || y < MIN_INDEX
        false
      end
    end
    
    class Diagonal < Move
      # calls all 4 methods and then returns the array of all possible moves
      def possible_moves(board:, piece:)
        ary = []
        ary.concat(right_red_up_blue_down(board: board, piece: piece))
        ary.concat(right_red_down_blue_up(board: board, piece: piece))
        ary.concat(left_red_up_blue_down(board: board, piece: piece))
        ary.concat(left_red_down_blue_up(board: board, piece: piece))
        
        ary
      end
      
      private
      
      def right_red_up_blue_down(board:, piece:)
        x = CHAR_TO_NUM[piece.x]
        array = []
        1.upto(8) do |index|
          return array if out_of_bounds?(x: x + index, y: piece.y + index)
          pos = to_pos(x: NUM_TO_CHAR[x + index], y: piece.y + index)
          return array if blocked_by_team?(pos: pos, board: board, piece: piece)
          array << pos
          return array if blocked_by_enemy?(pos: pos, board: board, piece: piece)
        end
        
        array
      end
      
      def right_red_down_blue_up(board:, piece:)
        x = CHAR_TO_NUM[piece.x]
        array = []
        1.upto(8) do |index|
          return array if out_of_bounds?(x: x + index, y: piece.y - index)
          pos = to_pos(x: NUM_TO_CHAR[x + index], y: piece.y - index)
          return array if blocked_by_team?(pos: pos, board: board, piece: piece)
          array << pos
          return array if blocked_by_enemy?(pos: pos, board: board, piece: piece)
        end
        
        array
      end
      
      def left_red_up_blue_down(board:, piece:)
        x = CHAR_TO_NUM[piece.x]
        array = []
        1.upto(8) do |index|
          return array if out_of_bounds?(x: x - index, y: piece.y + index)
          pos = to_pos(x: NUM_TO_CHAR[x - index], y: piece.y + index)
          return array if blocked_by_team?(pos: pos, board: board, piece: piece)
          array << pos
          return array if blocked_by_enemy?(pos: pos, board: board, piece: piece)
        end
        
        array
      end
      
      def left_red_down_blue_up(board:, piece: piece)
        x = CHAR_TO_NUM[piece.x]
        array = []
        1.upto(8) do |index|
          return array if out_of_bounds?(x: x - index, y: piece.y - index)
          pos = to_pos(x: NUM_TO_CHAR[x - index], y: piece.y - index)
          return array if blocked_by_team?(pos: pos, board: board, piece: piece)
          array << pos
          return array if blocked_by_enemy?(pos: pos, board: board, piece: piece)
        end
        
        array
      end
    end
  end
end