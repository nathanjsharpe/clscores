class String
  def pad(target_length)
    string = self.gsub(/\e\[(\d+)m/, '')
    if string.length > target_length
      self
    else
      self + (" " * (target_length - string.length)) 
    end
  end
end
