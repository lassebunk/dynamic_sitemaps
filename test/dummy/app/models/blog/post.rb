class Blog::Post < ActiveRecord::Base
  attr_accessible :title

  def to_param
  	title || id.to_s
  end
end
