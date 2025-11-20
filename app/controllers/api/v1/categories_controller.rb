class Api::V1::CategoriesController < ApplicationController
  def index
    categories = Category.all.order(:name)
    render json: categories, status: :ok
  end

  def show
    category = Category.find(params[:id])
    render json: category.as_json(include: :jobs), status: :ok
  end
end

