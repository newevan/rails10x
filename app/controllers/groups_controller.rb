class GroupsController < ApplicationController
  before_action :authenticate_user! , only: [:new, :create, :edit, :destroy, :update]
  before_action :find_group_and_permission, only: [:edit, :update, :destroy]

def index
  @groups = Group.all
end

def new
  @group = Group.new
end

def show
  @group = Group.find(params[:id])
  @posts = @group.posts.recent.paginate(:page => params[:page], :per_page => 5)
end

def edit
end

def update
  if @group.update(group_params)
    redirect_to groups_path, notice: "电影信息更新成功"
  else
    render :edit
  end
end

def create
  @group = Group.new(group_params)
  @group.user = current_user

  if @group.save
    redirect_to groups_path
  else
    render :new
  end
end

def destroy
  @group.destroy
    redirect_to groups_path, flash[:alert] = "电影删除成功"
end

def join
  @group = Group.find(params[:id])

  if !current_user.is_member_of?(@group)
    current_user.join!(@group)
    flash[:notice] = "成功成为该电影的粉丝啦！"
  else
    flash[:warning] = "你已经是该电影的粉丝了"
  end

  redirect_to group_path(@group)
end

def quit
  @group = Group.find(params[:id])

  if current_user.is_member_of?(@group)
    current_user.quit!(@group)
    flash[:alert] = "粉转黑成功"
  else
    flash[:warning] = "本身就不是这部电影的粉丝，谈何脱粉呢？"
  end

  redirect_to group_path(@group)
end



private

def find_group_and_permission
  @group = Group.find(params[:id])

    if current_user != @group.user
      redirect_to root_path, alert: "You have no permission."
    end
end

def group_params
  params.require(:group).permit(:title, :description)
end
end
