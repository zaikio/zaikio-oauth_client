class PagesController < ApplicationController
  
  def show
    add_breadcrumb I18n.t("breadcrumbs.#{params[:scope]}.overview"), "/#{params[:scope]}"

    if params[:page]
      @page = params[:page]
      add_breadcrumb I18n.t("breadcrumbs.#{params[:scope]}.#{@page}"), "/#{params[:scope]}/#{@page}"
    else
      @page = 'index'
    end

    render template: "pages/#{params[:scope]}/#{@page}"
  end
end
