class String

  def quote open='`', close='\''
    open + self + close
  end

  def dquote
    quote '"', '"'
  end

  def squote
    quote "'", "'"
  end

  def normalize
    self && self.downcase.gsub(/[\W_]+/, '')
  end

  alias :flickrize :normalize
end
