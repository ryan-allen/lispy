class Lispy
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

output = Lispy.new.to_data do 
  setup :workers => 30, :connections => 1024
  http :access_log => :off do
    server :listen => 80 do
      location '/' do
        doc_root '/var/www/website'
      end
      location '~ .php$' do
        fcgi :port => 8877
        script_root '/var/www/website'
      end
    end
  end
end
