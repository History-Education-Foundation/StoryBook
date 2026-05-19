class PostPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.present?
  end

  def new?
    create?
  end

  def update?
    user.present? && record.user_id == user.id
  end

  def edit?
    update?
  end

  def destroy?
    update?
  end

  class Scope < Scope
    def resolve
      if user.present?
        scope.where(user_id: user.id).or(scope.published)
      else
        scope.published
      end
    end
  end
end
