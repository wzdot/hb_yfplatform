class Vender < ActiveRecord::Base
  attr_accessible :name, :tel
  has_many :model_styles
end
