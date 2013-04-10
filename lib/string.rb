class Object
  def pad(target_length)
    string = self.to_s.gsub(/\e\[(\d+)m/, '')
    if string.length > target_length
      self.to_s
    else
      self.to_s + (" " * (target_length - string.length)) 
    end
  end
end
