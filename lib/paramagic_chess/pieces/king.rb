# frozen_string_literal: true

module ParamagicChess
  class King < Piece
    MOVE_SET = Box.new

    attr_reader :check, :check_mate

    def initialize(pos: nil, side: nil, moved: false)
      super
      @type = :king
      @check = false
      @check_mate = false
    end

    def positions_attacking_king(board:)
      positions = []
      board.board.each do |coord, tile|
        next if tile.piece.nil?

        piece = tile.piece
        # checks that it is from a different side
        next if piece.side == @side

        piece.update_moves(board: board)
        positions << coord if piece.possible_moves.include?(pos)
      end
      # returns array of pieces attacking the king
      positions
    end

    def cannot_save?(board:)
      threats = positions_attacking_king(board: board)
      board.board.each do |_coord, tile|
        next if tile.piece.nil?

        piece = tile.piece
        next if piece.side == @side

        piece.update_moves(board: board)
        threats.each do |pos|
          return false if piece.possible_moves.include?(pos)
        end
      end

      true
    end

    def check_mate?(board:)
      # will be called part of check? && cannot_save?
      update_moves(board: board)
      if check?(board: board, pos: @pos) == true && cannot_save?(board: board) == true
        if has_no_moves?(board: board) == true
          @check_mate = true
          return true
        end
      end

      @check_mate = false
      false
    end

    def to_s
      king = "\u265a"
      return king.blue if @side == :blue
      return king.red if @side == :red

      'Side not set'
    end

    def update_moves(board:)
      @possible_moves = []
      @possible_moves.concat(MOVE_SET.possible_moves(board: board, piece: self))
    end

    def has_no_moves?(board:)
      return false if @possible_moves.any? { |pos| check?(pos: pos, board: board) == false }

      true
    end

    def move_to(board:, pos:)
      update_moves(board: board)
      unless @possible_moves.include? pos
        puts ":#{pos} is an invalid move. Try again.".highlight
        return nil
      end

      if check?(board: board, pos: pos)
        puts 'Your king will be captured if you move there.'.highlight
        return nil
      end

      super
    end

    def check?(board:, pos: @pos)
      board.board.each do |_coord, tile|
        next if tile.piece.nil?

        piece = tile.piece
        next if piece.side == @side

        piece.update_moves(board: board)
        if piece.possible_moves.include?(pos)
          @check = true
          return true
        end
      end
      @check = false
      false
    end

    def rooks(board:)
      rook_array = []
      board.board.each do |_coord, tile|
        next if tile.piece.nil?
        next if tile.piece.type != :rook
        next if tile.piece.side != @side

        rook_array << tile.piece
      end

      rook_array
    end

    def rook_right(board:)
      # :e => 5, 5 + 3 = 8, 8 => :h
      # h1 for blue, h8 for red
      x_coord = CHAR_TO_NUM[@x] + 3
      rooks(board: board).each do |rook|
        return rook if rook.moved? == false && rook.x == NUM_TO_CHAR[x_coord]
      end
      nil
    end

    def rook_left(board:)
      x_coord = CHAR_TO_NUM[@x] - 4
      rooks(board: board).each do |rook|
        return rook if rook.moved? == false && rook.x == NUM_TO_CHAR[x_coord]
      end
      nil
    end

    def castle(board:, direction:)
      if can_castle?(board: board, direction: direction) == false
        puts "Unable to castle to the #{direction}"
        return nil
      end
      rook = send("rook_#{direction}".to_sym, board: board)
      rook_start_pos = rook.pos
      king_start_pos = pos
      update_king_and_rook_pos(board: board, direction: direction, rook: rook)

      # updates new positions
      board.board[rook.pos].piece = rook
      board.board[pos].piece = self

      # deletes old positions
      board.board[rook_start_pos].piece = nil
      board.board[king_start_pos].piece = nil

      # sets them to moved
      rook.moved = true
      @moved = true
      # true
    end

    def update_king_and_rook_pos(board:, direction:, rook:)
      amount = 2 if direction == :right
      amount = -2 if direction == :left

      king_x = move_x(amount: amount, x: @x).to_s
      # takes the string and converts it to sym
      king_end_pos = (king_x + @y.to_s).to_sym
      update_position(pos: king_end_pos)

      amount -= 1 if direction == :left
      # opposite direction of king
      rook_x = move_x(amount: -amount, x: rook.x)
      rook_end_pos = (rook_x.to_s + rook.y.to_s).to_sym
      rook.update_position(pos: rook_end_pos)
    end

    def can_castle?(board:, direction:)
      if direction != :right && direction != :left
        puts 'Direction must be either right or left.'.highlight
        return false
      end
      # rook_method_name = ("rook_" + direction.to_s).to_sym
      rook = send("rook_#{direction}".to_sym, board: board)

      # +Neither the king nor the chosen rook has previously moved.
      return false if @moved == true || rook.moved? == true
      # puts "made it past moved"
      # +The king is not currently in check.
      return false if @check == true

      # puts "made it past chess"

      tiles = send("#{direction}_tiles".to_sym, board: board)

      # There are no pieces between the king and the chosen rook.
      # p tiles_contain_a_piece?(tiles_array: tiles)
      return false if tiles_contain_a_piece?(tiles_array: tiles)
      # puts "made it past tiles contain a piece"
      # The king does not pass through a square that is attacked by an enemy piece.[4]
      return false if any_pieces_attacking_path?(board: board, tiles_array: tiles)
      # puts "made it past any pieces attacking path"
      # The king does not end up in check. (True of any legal move.)
      return false if end_path_results_in_check?(board: board, direction: direction)

      # puts "made it past end path results in check"
      true
    end

    private

    def end_path_results_in_check?(board:, direction:)
      end_x = CHAR_TO_NUM[@x]

      end_x += 2 if direction == :right
      end_x -= 2 if direction == :left

      end_pos = to_pos(x: NUM_TO_CHAR[end_x], y: @y)

      board.board.each do |_coord, tile|
        next if tile.piece.nil?
        next if tile.side == @side

        tile.piece.update_moves(board: board)
        return true if tile.piece.possible_moves.include?(end_pos)
      end
      false
    end

    def any_pieces_attacking_path?(board:, tiles_array:)
      board.board.each do |_coord, tile|
        # checks if it has a piece
        next if tile.piece.nil?
        # checks to see if its a friendly
        next if tile.piece.side == @side

        # runs through the tile array to see if its position is contained as part of another piece
        # of the opposite side
        tiles_array.each do |defending_tile|
          tile.piece.update_moves(board: board)
          if tile.piece.possible_moves.include?(defending_tile.position)
            return true
          end
        end
      end

      false
    end

    def tiles_contain_a_piece?(tiles_array:)
      tiles_array.any?(&:contains_piece?)
    end

    def right_tiles(board:)
      tiles = []
      acceptable_coords = %i[f g]
      board.board.each do |coord, tile|
        next if coord[1].to_i != @y

        coord_x = coord[0].to_sym

        next unless acceptable_coords.include?(coord_x)

        tiles << tile
      end
      tiles
    end

    def left_tiles(board:)
      tiles = []
      acceptable_coords = %i[d c b]
      board.board.each do |coord, tile|
        next if coord[1].to_i != @y

        coord_x = coord[0].to_sym
        next unless acceptable_coords.include?(coord_x)

        tiles << tile
      end

      tiles
    end
  end
end
