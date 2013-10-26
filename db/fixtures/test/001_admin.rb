admin = User.create(
  :email => "admin@local.host",
  :name => "admin",
  :password => "admin123456",
  :password_confirmation => "admin123456"
)

admin.admin = true
admin.save!

if admin.valid?
puts %q[
Administrator account created:

login.........admin@local.host
password......admin123456
]
end
