# coding: us-ascii

require 'forwardable'

class Lisby
  class Environment
    extend Forwardable
    
    DEFAULT = {
      '+': -> x, y { x + y },
      '-': -> x, y { x - y },
      '*': -> x, y { x * y },
      '/': -> x, y { x / y },
      'not': -> x { !!!x },
      '>': -> x, y { x > y },
      '<': -> x, y { x < y },
      '>=': -> x, y { x >= y },
      '<=': -> x, y { x <= y },
      '=': -> x, y { x == y },
      equal?: -> x, y { x == y },
      eq?: -> x, y { x.equal? y },
      length: -> x { x.length },
      cons: -> x, y { [x, y] },
      car: -> x { x.first },
      cdr: -> x { x.drop 1 },
      append: -> x, y { x + y },
      list: -> *x { x },
      list?: -> x { x.instance_of? Array },
      null?: -> x { x.empty? },
      symbol?: -> x { x.instance_of? Symbol }
    }.freeze
    
    class << self
      def global
        new base: DEFAULT
      end
    end

    def_delegators :@hash, :fetch, :[]=
    
    def initialize(vars: [], args: [], outer: nil, base: {})
      @hash = base.merge vars.zip(args).to_h
      @outer = outer
    end
    
    def get_env(variable)
      if @hash.key?(variable)
        self
      else
        if @outer
          @outer.get_env(variable)
        else
          raise "variable: `#{variable}' is not defined"
        end
      end
    end
    
    def get_value(variable)
      get_env(variable).fetch variable
    end
    
    def set_value(variable, value)
      get_env(variable)[variable] = value
    end
    
    alias_method :define, :[]=
    protected :[]=
  end
end
