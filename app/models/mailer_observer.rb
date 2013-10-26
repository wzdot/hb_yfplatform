class MailerObserver < ActiveRecord::Observer
  observe :user
  cattr_accessor :current_user

  def after_create(model)
    new_issue(model) if model.kind_of?(Issue)
    new_user(model) if model.kind_of?(User)
    new_note(model) if model.kind_of?(Note)
    new_merge_request(model) if model.kind_of?(MergeRequest)
  end

  def after_update(model)
    changed_merge_request(model) if model.kind_of?(MergeRequest)
    changed_issue(model) if model.kind_of?(Issue)
  end

  protected

  def new_user(user)
    Notify.new_user_email(user.id, user.password).deliver
  end
end
