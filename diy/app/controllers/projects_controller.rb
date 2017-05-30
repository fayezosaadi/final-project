class ProjectsController < ApplicationController

  # This is not being used to render the page, but is still being used in certain situations (like searching by tag)
  def index
    if
      params[:tag]
      @projects = Project.tagged_with(params[:tag])
    else
      @projects = Project.includes(:reviews).all.order(created_at: :desc)
    end
  end

  def new
    @project = Project.new
    @project_upload = ProjectUpload.new
  end

  def scrape
    @page = MetaInspector.new(project_params[:url])
    @page_url = @page.url
    @page_title = @page.title
    @page_description = @page.description
    @page_image = @page.images.best

    render :json => { :url => @page_url, :title => @page_title, :description => @page_description,  :image => @page_image }
  end

  def create
    @project = current_user.projects.new(project_params)
    if @project.save
      redirect_to user_path(current_user)
    else
      render :new
    end
  end

  def show
    @project = Project.find params[:id]
    @project_uploads = @project.project_uploads
    @review = Review.new
    @project_status = ProjectStatus.where(project_id: @project.id).first_or_create
  end

  private

  def project_params
    params.require(:project).permit(
      :title,
      :summary,
      :instructions,
      :material,
      :time,
      :cost,
      :url,
      :image,
      :tag_list,
      project_uploads_attributes: [:id, :project_id, :image_url]
    )
  end
end