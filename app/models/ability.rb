class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # for Guest User (not logged in)
    if user.id == 1
      # System Administrator
      can :manage, :all
    else
      authorize_project(user)
      authorize_issue(user)
      authorize_comment(user)
    end
  end

  def authorize_project(user)
    can :read, Project do |project|
      project.visible?(user)
    end
    can :create, Project do |project|
      user.persisted? # logged in user
    end
    can :update, Project do |project|
      project.admin?(user)
    end
    cannot :destroy, Project
  end

  def authorize_issue(user)
    can :read, Issue do |issue|
      issue.project.visible?(user)
    end
    can [:create, :update], Issue do |issue|
      issue.project.member?(user)
    end
  end

  def authorize_comment(user)
    can :update, Comment do |comment|
      comment.issue.project.member?(user)
    end
  end
end
