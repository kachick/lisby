# coding: us-ascii

require_relative 'spec_helper'

describe Lisby do
  let!(:lisby) { Lisby.new }
  let!(:expression) { "(begin (define r 3) (* 3.141592653 (* r r)))" }
  let!(:tokens) { ["(", "begin", "(", "define", "r", "3", ")", "(", "*", "3.141592653", "(", "*", "r", "r", ")", ")", ")"] }
  let!(:parsed) { [:begin, [:define, :r, 3], [:'*', 3.141592653, [:'*', :r, :r]]] }
  let!(:result) { 28.274333877 }

  context 'basic methods' do
    describe '#tokenize' do
      it { expect(lisby.tokenize expression).to eq(tokens) }
    end
    
    describe '#parse' do
      it { expect(lisby.parse(expression)).to eq(parsed) }
    end
    
    describe '#evaluate' do
      it { expect(lisby.evaluate parsed).to eq(result) }
    end
  end
end
