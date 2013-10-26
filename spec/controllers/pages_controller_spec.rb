# -*- coding: utf-8 -*-
require 'spec_helper'

describe PagesController do

  before (:each) do
    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  describe "GET 'welcome'" do

    it "should be successful" do
      get :welcome
      response.should be_success
    end

  end

  describe "GET 'about'" do

    it "should be successful" do
      get :about
      response.should be_success
    end

  end

end
