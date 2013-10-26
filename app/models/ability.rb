# -*- coding: utf-8 -*-
class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
    # if user.blank?
    #   # 没登录, just a guest
    #   cannot :manage, :all
    # elsif user.has_role?( :admin )
    #   can :manage, :all
    # elsif user.has_role?( :manager )
    #   can :manage, User
    #   #VoltageLevel
    #   can :manage, VoltageLevel
    # else
    #   # User
    #   can :update, User, :id => user.id
    #   can :destroy, User, :id => user.id

    #   #VoltageLevel
    #   can :manage, VoltageLevel
    # end

    # guest_basic

    if user.blank?
      cannot :manage, :all
    end

    if user.has_role?( :admin )
      can :manage, :all
    end

    if user.has_role? ( :member )
      can :manage, :all
    end

  end

  protected
    def guest_basic
      #can :create, User
      #can :create, Session
    end
end
