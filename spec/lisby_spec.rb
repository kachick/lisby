# coding: us-ascii

require_relative 'spec_helper'

describe Lisby do
  before :each do
    @lisby = Lisby.new
    @program = "(begin (define r 3) (* 3.141592653 (* r r)))"
    @tokens = ["(", "begin", "(", "define", "r", "3", ")", "(", "*", "3.141592653", "(", "*", "r", "r", ")", ")", ")"]
    @parsed = [:begin, [:define, :r, 3], [:'*', 3.141592653, [:'*', :r, :r]]]
    @result = 28.274333877
  end
  
  describe '#tokenize' do
    it { expect(@lisby.tokenize @program).to eq(@tokens) }
  end
  
  describe '#parse' do
    it { expect(@lisby.parse(@program)).to eq(@parsed) }
  end
  
  describe '#evaluate' do
    it { expect(@lisby.evaluate @parsed).to eq(@result) }
  end
end
