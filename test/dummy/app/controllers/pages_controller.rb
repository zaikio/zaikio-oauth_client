class PagesController < ApplicationController
  def show
    @page = params[:page] || 'index'
    render template: "pages/#{params[:scope]}/#{@page}"
  end
end
