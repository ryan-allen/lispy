module Lispy
  VERSION = '0.0.5'

  METHODS_TO_KEEP = /^__/, /class/, /instance_/, /method_missing/, /object_id/

  instance_methods.each do |m|
    undef_method m unless METHODS_TO_KEEP.find { |r| r.match m }
  end

  def self.configure(opts = {})
    @@remember_blocks_starting_with = Array(opts[:retain_blocks_for])
    @@only = Array(opts[:only])
    @@exclude = Array(opts[:except])
  end

  def self.reset
    @@remember_blocks_starting_with = []
    @@only = []
    @@exclude = []
    @@output = []
  end

  def self.extended(mod)
    @@output ||= []
    mod.instance_eval do
      def output
        @@output
      end
    end
  end

  def method_missing(sym, *args, &block)
    unless @@only.empty? || @@only.include?(sym)
      fail(NoMethodError, sym.to_s) 
    end
    if !@@exclude.empty? && @@exclude.include?(sym)
      fail(NoMethodError, sym.to_s)
    end

    args = (args.length == 1 ? args.first : args)
    @scope ||= [@@output]
    @scope.last << [sym, args]
    if block
      # there is some simpler recursive way of doing this, will fix it shortly
      if @@remember_blocks_starting_with.include? sym
        @scope.last.last << block
      else
        nest(&block)
      end
    end
  end

  def to_data(opts = {}, &block)
    @@remember_blocks_starting_with =  Array(opts[:retain_blocks_for])
    @@only = Array(opts[:only])
    @@exclude = Array(opts[:except])
    _(&block)
    @@output
  end
  
private

  def nest(&block)
    @scope.last.last << []
    @scope.push(@scope.last.last.last)
    instance_exec(&block)
    @scope.pop
  end

  
  def _(&block)
    @@output ||= []
    @scope ||= [@@output]
    instance_exec(&block)
    @@output
  end
end
