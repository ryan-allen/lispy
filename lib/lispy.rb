module Lispy
  class Scope < Struct.new(:expressions); end
  class Expression < Struct.new(:symbol, :args, :lineno, :proc, :scope); end
  class Output < Struct.new(:file, :expressions); end

  VERSION = '0.2.0'

  METHODS_TO_KEEP = /^__/, /class/, /instance_/, /method_missing/, /object_id/

  instance_methods.each do |m|
    undef_method m unless METHODS_TO_KEEP.find { |r| r.match m }
  end

  def acts_lispy(opts = {})
    @@remember_blocks_starting_with = Array(opts[:retain_blocks_for])
    @@only = Array(opts[:only])
    @@exclude = Array(opts[:except])
    @@output = Output.new
    @@file = nil
    @stack = []
  end

  def output
    @@output.expressions = @current_scope.expressions
    @@output
  end

  def file=(file)
    unless @@file
      @@file = file
      @@output.file = @@file
    end
  end

  def method_missing(sym, *args, &block)
    caller[0] =~ (/(.*):(.*):in?/)
    file, lineno = $1, $2
    self.file = file

    if !@@only.empty? && !@@only.include?(sym)
      fail(NoMethodError, sym.to_s)
    end
    if !@@exclude.empty? && @@exclude.include?(sym)
      fail(NoMethodError, sym.to_s)
    end

    args = (args.length == 1 ? args.first : args)
    @current_scope ||= Scope.new([])
    @current_scope.expressions << Expression.new(sym, args, lineno)
    if block
      # there is some simpler recursive way of doing this, will fix it shortly
      if @@remember_blocks_starting_with.include? sym
        @current_scope.expressions.last.proc = block
      else
        nest(&block)
      end
    end
  end

private
  def nest(&block)
    @stack.push @current_scope

    new_scope = Scope.new([])
    @current_scope.expressions.last.scope = new_scope
    @current_scope = new_scope

    instance_exec(&block)

    @current_scope = @stack.pop
  end
end
