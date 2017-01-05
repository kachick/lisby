# coding: us-ascii

require_relative 'spec_helper'

describe Lisby do
  let!(:lisby) { Lisby.new }

  context 'basic methods' do
    let!(:expression) { "(begin (define r 3) (* 3.141592653 (* r r)))" }
    let!(:tokens) { ["(", "begin", "(", "define", "r", "3", ")", "(", "*", "3.141592653", "(", "*", "r", "r", ")", ")", ")"] }
    let!(:parsed) { [:begin, [:define, :r, 3], [:'*', 3.141592653, [:'*', :r, :r]]] }
    let!(:result) { 28.274333877 }

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

  context 'example from http://www.aoky.net/articles/peter_norvig/lispy.htm' do
    subject(:run) { Lisby.load(code) }

    context '1st' do
      let!(:code) {
        <<~CODE
          (define area (lambda (r) (* 3.141592653 (* r r))))
          (area 3)
        CODE
      }

      it { expect(run).to eq(28.274333877) }
    end

    context '2nd' do
      let!(:code) {
        <<~CODE
          (define fact (lambda (n) (if (<= n 1) 1 (* n (fact (- n 1))))))
          (fact 10)
        CODE
      }

      it { expect(run).to eq(3628800) }
    end

    context '2nd with another example' do
      let!(:code) {
        <<~CODE
          (define fact (lambda (n) (if (<= n 1) 1 (* n (fact (- n 1))))))
          (fact 100)
        CODE
      }

      it { expect(run).to eq(93326215443944152681699238856266700490715968264381621468592963895217599993229915608941463976156518286253697920827223758251185210916864000000000000000000000000) }
    end

    context 'mixed 1st and 2nd' do
      let!(:code) {
        <<~CODE
          (define area (lambda (r) (* 3.141592653 (* r r))))
          (define fact (lambda (n) (if (<= n 1) 1 (* n (fact (- n 1))))))
          (area (fact 10))
        CODE
      }

      it { expect(run).to eq(41369087198016.19) } # The origin said `4.1369087198e+13`
    end

    context '3rd' do
      let!(:code) {
        <<~CODE
          (define first car)
          (define rest cdr)
          (define count (lambda (item L) (if L (+ (equal? item (first L)) (count item (rest L))) 0)))
          (count 0 (list 0 1 2 3 0 0))
        CODE
      }

      it { expect(run).to eq(3) }
    end
  end
end
