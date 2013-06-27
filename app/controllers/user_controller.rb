class UsersController < ApplicationController

  before_filter :authenticate_user!, :except => [:new]
  load_and_authorize_resource, :except => [:new]

    def index
        @users = User.all
        respond_to do |format|
          format.json { render :json => @users }
          format.html
        end
    end

    def show
        @user = User.find(params[:id])
        respond_to do |format|
            format.html 
            format.json { render :json => @user }       
        end
    end

    def edit
        @user = User.find(params[:id])
        respond_to do |format|
            format.html
            format.json { render :json => @user }   
        end
    end

    def update
        @user = User.find(params[:id])

        respond_to do |format|
          if @user.update_attributes(params[:user])
            if !params [:user][:email]
                notice = 'Success! Your changes have been saved'
            else 
                notice = 'Success! Your changes have been saved. You must confirm your email address before it will register in the system. Please check your email now for a confirmation link.'
            end
            format.html { redirect_to @user, notice: 'User was successfully updated.' }
            format.json { head :no_content }
          else
            format.html { render action: "edit", :flash => { :error => "There was an error when attempting to update your login details." } }
          end
        end
    end

    def destroy
        @user = User.find(params[:id])
        @user.destroy!

        respond_to do |format|
            format.html
            format.json { respond_to_destroy(:ajax) }     
        end
    end
end