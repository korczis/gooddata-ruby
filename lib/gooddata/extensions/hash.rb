# encoding: UTF-8

class Hash
  def deep_include?(sub_hash)
    sub_hash.keys.all? do |key|
      self.key?(key) && if sub_hash[key].is_a?(Hash)
                          self[key].is_a?(Hash) && self[key].deep_include?(sub_hash[key])
                        else
                          self[key] == sub_hash[key]
                        end
    end
  end
end
