module ParamagicChess
  class Pawn < Piece
    def initialize(pos:)
      super
      @type = :pawn
    end
  end
end