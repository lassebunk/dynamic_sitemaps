class Product < ActiveRecord::Base
  attr_accessible :slug, :featured

  def to_param
  	slug || id.to_s
  end
end
