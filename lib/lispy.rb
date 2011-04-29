class Lispy
  VERSION = '0.0.5'

  @@methods_to_keep = /^__/, /class/, /instance_/, /method_missing/, /object_id/

  instance_methods.each do |m|
    undef_method m unless @@methods_to_keep.find { |r| r.match m }
  end

  def method_missing(sym, *args, &block)
    args = (args.length == 1 ? args.first : args)
    @scope.last << [sym, args]
    if block
      # there is some simpler recursive way of doing this, will fix it shortly
      if @remember_blocks_starting_with.include? sym
        @scope.last.last << block
      else
        @scope.last.last << []
        @scope.push(@scope.last.last.last)
        instance_exec(&block)
        @scope.pop
      end
    end
  end

  def to_data(opts = {}, &block)
    @remember_blocks_starting_with =  Array(opts[:retain_blocks_for])
    _(&block)
    @output
  end
  
private
  
  def _(&block)
    @output = []
    @scope = [@output]
    instance_exec(&block)
    @output
  end
end
