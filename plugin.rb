# name: discourse-delete-user-by-email
# about: Support delete user from group by using user email
# version: 0.1
# authors: Ming
# url: https://github.com/ming-relax/discourse-delete-user-by-email

after_initialize do
  class GroupsController
    def remove_member
      group = Group.find(params[:id])
      guardian.ensure_can_edit!(group)

      if params[:user_id].present?
        user = User.find(params[:user_id])
      elsif params[:username].present?
        user = User.find_by_username(params[:username])
      elsif params[:user_email].present?
        user = User.find_by_email(params[:user_email])
      else
        raise Discourse::InvalidParameters.new('user_id or username or user_email must be present')
      end

      user.primary_group_id = nil if user.primary_group_id == group.id

      group.users.delete(user.id)

      if group.save && user.save
        render json: success_json
      else
        render_json_error(group)
      end
    end
  end
end

