# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    name 'linq.lin'
    email 'linq.lin@qq.com'
    password '123456'
    password_confirmation '123456'
    admin true
    # required if the Devise Confirmable module is used
    # confirmed_at Time.now
  end
end