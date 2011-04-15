class Lispy
  VERSION = '0.0.2'
  class Builder
    def _(&block)
      @output = []
      @scope = [@output]
      instance_exec(&block)
      @output
    end

    def method_missing(sym, *args, &block)
      args = (args.length == 1 ? args.first : args)
      @scope.last << [sym, args]
      if block
        @scope.last << []
        @scope.push(@scope.last.last)
        instance_exec(&block)
        @scope.pop
      end
    end
  end

  def to_data(&block)
    Builder.new._(&block)
  end
end
