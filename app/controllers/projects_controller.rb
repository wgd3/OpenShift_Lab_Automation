class ProjectsController < ApplicationController

  def index
    @projects = Project.all
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(new_project_params)
    if @project.save
      flash[:success] = "Project successfully created."
      redirect_to project_path(@project)
    else
      errors = @project.errors.full_messages
      flash[:error] = errors.join(", ")
      redirect_to :back
    end
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])
    if @project.update_attributes(edit_project_params)
      flash[:success] = "Project successfully updated."
      redirect_to project_path(@project)
    else
      errors = @project.errors.full_messages
      flash[:error] = errors.join(", ")
      redirect_to :back
    end
  end

  def show
    @project = Project.find(params[:id])
    @images = @project.images
    @floating_ips = @project.floating_ips
    @flavors = @project.flavors
    @ready, @reason = @project.ready?
    
  end

  def destroy
    @project = Project.find(params[:id])
    if @project.destroy
      flash[:success] = "Project successfully removed."
      redirect_to project_path(@project)
    else
      flash[:error] = "Project could not be removed."
      redirect_to :back
    end
  end

  def start_all
    @project = Project.find(params[:id])
    @project.start_all
    flash[:success] = "Project queued to start."
    redirect_to project_path(@project)
  end

  def stop_all
    @project = Project.find(params[:id])
    @project.stop_all
    flash[:success] = "Project stopped."
    redirect_to project_path(@project)
  end
  
  def restart_all
    @project = Project.find(params[:id])
    if @project.stop_all
      @project.start_all
      flash[:success] = "Project destroyed and queued to start."
      redirect_to project_path(@project)
    else
      flash[:error] = "Project could not be restarted."
      redirect_to project_path(@project)
    end
  end

  def check_out
    user_id = current_user(true).id
    @project = Project.find(params[:id])
    if @project.checked_out?
      user = User.find(@project.checked_out_by)
      flash[:error] = "Project is already checked out to #{user.name}"
      redirect_to project_path(@project)
    else
      if @project.check_out(user_id)
        flash[:success] = "Project checked out."
        redirect_to project_path(@project)  
      else
        flash[:error] = "Could not check out project, contact administrator."
        redirect_to project_path(@project)
      end
    end
  end

  def uncheck_out
    user_id = current_user.id
    @project = Project.find(params[:id])
    if @project.checked_out?
      if @project.uncheck_out
        flash[:success] = "Project is now available for check out."
        redirect_to project_path(@project)  
      else
        flash[:error] = "Could not free project, contact administrator."
        redirect_to project_path(@project)
      end
    else
      flash[:error] = "Project is not checked out, cannot turn the project in."
      redirect_to project_path(@project)
    end
  end

private

  def new_project_params
    params.require(:project).permit!
  end

  def edit_project_params
    params.require(:project).permit!
  end

end
