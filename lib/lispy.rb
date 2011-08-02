class Lispy
  VERSION = '0.0.5'

  @@methods_to_keep = /^__/, /class/, /instance_/, /method_missing/, /object_id/

  instance_methods.each do |m|
    undef_method m unless @@methods_to_keep.find { |r| r.match m }
  end

  def method_missing(sym, *args, &block)
    args = args.length == 1 ? args.first : args
    if block
      if  @opts[:retain_blocks_for] && @opts[:retain_blocks_for].include?(sym)
        block_val = block
      else
        block_val = Lispy.new.to_data(@opts,&block)
      end
      @output <<  [sym, args,block_val]
    else
      @output <<  [sym, args]
    end
  end

  def to_data(opts = {}, &block)
    @opts = opts
    #@remember_blocks_starting_with =  ray(opts[:retain_blocks_for])
    @output = []
    instance_exec(&block)
    @output
  end
end
