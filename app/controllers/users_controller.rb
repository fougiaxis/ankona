class UsersController < ApplicationController

  #before_filter :require_no_user, only: [:new, :create]
  #before_filter :require_user, only: [:show, :edit, :update, :destroy]
  #before_filter :require_admin, only: [:index]

  load_and_authorize_resource :only => [:index, :show]
  before_filter :authenticate_user!

# --------------------------------------------------------------------------
  def index
    @users = User.all
  end
# --------------------------------------------------------------------------
  def new
    @user = User.new
  end
# --------------------------------------------------------------------------
  def create
    @user = User.new(params[:user])
    name = params[:name_handle].split(',')[0]
    case
    when name.blank?
      flash[:error] = "Name is blank."
      render action: :new
      return
    when name =~ /^CREATE_(.+)$/
      @user.build_author name: $1
      @user.name = $1
      flash[:notice] = "Account registered, new name recorded."
    when author = Author.where(code: name).first
      @user.author = author
      @user.name = author.name
      flash[:notice] = "Your account registered, #{author.name}."
    else  
      flash[:error] = "Malformed name."
      render action: :new
      return
    end
    if @user.save
      redirect_back_or_default account_url
    else
      flash[:error] = "Error registering new account."
      render action: :new
    end
  end

# --------------------------------------------------------------------------
  def show
    @user = is_admin? && params[:id].present? ? User.find(params[:id]) : @current_user
  end
# --------------------------------------------------------------------------
  def edit
    @user = is_admin? && params[:id].present? ? User.find(params[:id]) : @current_user
    @author_json = ''
    if @user.author.present?
      @author_json = [@user.author].map{|a| {id: a.id, name: a.name}}.to_json
    end
  end
# --------------------------------------------------------------------------
  def update
    @user = is_admin? && params[:id].present? ? User.find(params[:id]) : @current_user
    handle = params[:name_handle]
    if handle.present?
      name = handle.split(',')[0]
      author = Author.where(:code >> name | :id >> name)
      if author.present?
        @user.author = author[0] if author.present?
        @user.name = author[0].name
      else
        @user.build_author name: name
        @user.name = name
      end    
    end
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to user_path @user
    else
      flash[:error] = "Error occurred"
      render :action => :edit
    end
  end
# --------------------------------------------------------------------------
  def destroy
    @user = is_admin? && params[:id].present? ? User.find(params[:id]) : @current_user
    
    unless is_admin?
      @user.destroy
      flash[:notice] = "Account deleted."
    else
      flash[:error] = "Cant delete admin user."
    end
    redirect_to '/'
  end
end
