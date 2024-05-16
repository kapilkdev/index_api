ActiveAdmin.register User, as: "Author" do
  actions :index,:edit,:update
  
  member_action :ban_author, method: :put do
    user = User.find_by(id: params[:id])
    if user
      user.update(ban: true)
    else
      return 
    end
    redirect_to admin_authors_path, notice: "Ban successfully"
    
  end

  member_action :un_ban,method: :put do
    user = User.find_by(id: params[:id])
    if user
      user.update(ban: false)
    else
      return 
    end
    redirect_to admin_authors_path, notice: "Un-Ban successfully"
  end


  index do
    selectable_column
    id_column
    column :first_name 
    column :last_name
    column :email
    column :ban
    
    actions
  end

  form do |f|
    f.inputs do
      table do
        tbody do
          tr do
            td do
              strong "Take action"
            end
            td do
              if f.object.ban == false
                div do
                  link_to 'Ban', ban_author_admin_author_path(f.object.id), method: :put
                end
              else
                div do
                  link_to 'Un-Ban', un_ban_admin_author_path(f.object.id), method: :put
                end
              end
            end
          end
        end
      end
    end
  end

  
  filter :first_name
  filter :last_name
  filter :ban
  filter :email
end

