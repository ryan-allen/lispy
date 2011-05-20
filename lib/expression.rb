class Expression < Struct(:symbol, :args, :line, :proc, :array)
  def each(&block)
    array.each(&block) if array
  end
end
