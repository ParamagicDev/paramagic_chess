module ParamagicChess
  RSpec.describe Knight do
    let(:knight) { Knight.new(pos: :a2) }
    let(:red_knight) { Knight.new(pos: :a1, side: :red) }
    let(:blue_knight) { Knight.new(pos: :a3, side: :blue) }
    
    context '#initialize' do
      it 'creates a bishop w/ position given' do
        expect(knight).to be_an_instance_of Knight
      end
      
      it 'sets the @type to :knight' do
        expect(knight.type).to eq :knight
      end
    end
    
    context 'to_s' do
      it 'Returns a red knight unicode character' do
        expect(red_knight.to_s).to eq "\u265e".red
      end
      
      it 'Returns a blue knight unicode character' do
        expect(blue_knight.to_s).to eq "\u265e".blue
      end
      
      it "Returns 'Side not set' if no side given" do
        expect(knight.to_s).to eq 'Side not set'
      end
    end
  end
end