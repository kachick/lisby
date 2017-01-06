# coding: us-ascii
# Copyright (c) 2015 Kenichi Kamiya
#
# Lisby - Ported from Lispy(lis.py).
# See http://www.aoky.net/articles/peter_norvig/lispy.htm

require_relative 'lisby/version'
require_relative 'lisby/environment'

class Lisby
  class << self
    def load(code)
      interpreter = new
      ret = nil
      code.each_line do |line|
        ret = interpreter.evaluate(interpreter.parse(line))
      end
      ret
    end
  end
  
  def initialize
    @global_environment = Environment.global
  end
  
  def evaluate(x, env: @global_environment)
    puts x
    case x
    when Symbol
      env.get_value x
    when Array
      case x.first
      when :quote # (quote exp)
        raise unless x.length >= 2
        x.drop 1
      when :if # (if test conseq alt)
        raise unless x.length == 4
        test, conseq, alt = *x.drop(1)

        evaluate((evaluate(test, env: env) ? conseq : alt), env: env)
      when :set! # (set! var exp)
        raise unless x.length == 3
        var, exp = *x.drop(1)

        env.set_value var, evaluate(exp, env: env)
        nil
      when :define # (define var exp)
        raise unless x.length == 3
        var, exp = *x.drop(1)

        env.define var, evaluate(exp, env: env)
        nil
      when :lambda # (lambda (var*) exp)
        raise unless x.length == 3
        _, params, exp = *x

        ->*args{ evaluate exp, env: Environment.new(vars: params, args: args, outer: env) }
      when :begin # (begin exp*)
        val = nil
        x.drop(1).each do |_exp|
          val = evaluate _exp, env: env
        end
        val
      else # (proc exp*)
        exps = x.map{ |_exp| evaluate _exp, env: env }
        _proc = exps.shift
        _proc.call(*exps)
      end
    else
      x
    end
  end

  def parse(str)
    read_from tokenize(str)
  end

  def tokenize(str)
    str.gsub(/[()]/){ |paren| " #{paren} " }.split
  end
  
  def read_from(tokens)
    raise SyntaxError, 'unexpected EOF while reading' if tokens.empty?
    
    case token = tokens.shift
    when '('
      l = []
      until tokens.first == ')'
        l << read_from(tokens)
      end
      tokens.shift # pop off ')'
      return l
    when ')'
      raise SyntaxError, 'unexpected ")"'
    else
      atom token
    end
  end
  
  def atom(token)
    Integer token
  rescue ArgumentError
    begin
      Float token
    rescue ArgumentError
      token.to_sym
    end
  end
  
  def ruby_to_lisp(exp)
    case exp
    when Array
          "(#{exp.map { |e| ruby_to_lisp e }.join})"
    else
      exp.to_s
    end
  end
  
  def repl(prompt='lisby> ')
    loop do
      print prompt
      input = gets.chomp
      val = evaluate(parse input)
      puts ruby_to_lisp(val) if val
    end
  end
end
