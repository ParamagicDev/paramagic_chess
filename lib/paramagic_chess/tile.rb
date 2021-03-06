# frozen_string_literal: true

module ParamagicChess
  class Tile
    attr_accessor :background, :piece, :position

    def initialize(piece: nil, background: nil, position:)
      @piece = piece
      @background = background
      @position = position
    end

    def piece_type
      return nil if @piece.nil?
      return nil if @piece.type.nil?

      @piece.type
    end

    def side
      @piece.side
    end

    def contains_piece?
      return false if @piece.nil?

      true
    end

    def contains_blue_piece?
      return false if @piece.nil?
      return true if @piece.side == :blue

      false
    end

    def contains_red_piece?
      return false if @piece.nil?
      return true if @piece.side == :red

      false
    end

    def to_s
      blank_space = " \u265f "
      return blank_space.white.bg_white if @background == :white && @piece.nil?
      return blank_space.black.bg_black if @background == :black && @piece.nil?

      return @piece.to_s.bg_white if @background == :white
      return @piece.to_s.bg_black if @background == :black

      'Background not set'
    end
  end
end
