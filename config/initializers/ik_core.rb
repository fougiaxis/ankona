class Array
  def commatize
    if respond_to?(:empty?) && self.empty?
      ''
    else
      join ', '
    end
  end
end

class String
  def bold
    "<b>#{self}</b>"
  end
end

MetaWhere.operator_overload!

Ya = YAML.load_file(Rails.root.join("config/config.yml"))[Rails.env]
