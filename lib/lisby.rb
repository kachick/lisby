# coding: us-ascii
# Copyright (c) 2015 Kenichi Kamiya
#
# Lisby - Ported from Lispy(lis.py).
# See http://www.aoky.net/articles/peter_norvig/lispy.htm

require_relative 'lisby/version'
require_relative 'lisby/environment'

class Lisby
  def initialize
    @global_environment = Environment.new
  end
  
  def evaluate(x, env=@global_environment)
    case x
    when Symbol
      env.get_value x
    when Array
      case x.first
      when :quote # (quote exp)
        x.drop 1
      when :if # (if test conseq alt)
        test, conseq, alt = *x.drop(1)
        evaluate((evaluate(test, env) ? conseq : alt), env)
      when :set! # (set! var exp)
        var, exp = *x.drop(1)
        env.set_value var, evaluate(exp, env)
        nil
      when :define # (define var exp)
        var, exp = *x.drop(1)
        env.define var, evaluate(exp, env)
        nil
      when :lambda # (lambda (var*) exp)
        vars, exp = *x.drop(1)
        ->*args{ evaluate exp, Environment.new(vars: vars, args: args, outer: env) }
      when :begin # (begin exp*)
        val = nil
        x.drop(1).each do |_exp|
          val = evaluate _exp, env
        end
        val
      else # (proc exp*)
        exps = x.map{ |_exp| evaluate _exp, env }
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
