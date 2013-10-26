# -*- coding: utf-8 -*-

# 输出到sqlite上的集合性的拍摄顺序表
# 
class MachineShootSequence < ActiveRecord::Base
=begin
  belongs_to :shoot_sequence
  belongs_to :device_area

  has_many   :device_shoot_sequences, :dependent => :destroy
=end

=begin
  establish_connection( 
    :adapter => "sqlite3",
    :host => "",
    :username => "",
    :password => "",
    :database => "task_pkg.sqlite3"
  )
=end

  # using the task_pkg_db configuration in database.yml
  establish_connection :task_pkg_db

  default_scope :order => 'order_num'
end
