#coding: utf-8

describe 'session' do
	before(:each) do
		user = FactoryGirl.create(:user)
	end

	it 'should login in success when session infomation is right' do
		visit '/sign_in'
		fill_in 'user[email]', :with => 'linq.lin@qq.com'
		fill_in 'user[password]', :with => '123456'
		click_button('登录')
		page.should have_content('登录成功')
	end

	it 'should login in failure when session infomation is error' do
		visit '/sign_in'
		fill_in 'user[email]', :with => 'linq@qq.com'
		fill_in 'user[password]', :with => '123456'
		click_button('登录')
		page.should have_content('帐号或密码错误')
	end
end