require 'pry'
class RecipesController < ApplicationController
  def index
    if current_user
      @recipes = Recipe.order(:id)
      render "index"
    else
      render 'sessions/new'
    end
    # render json: {recipes: recipes}, status: 200
  end

  def new
    @recipe = Recipe.new
  end

  def show
    @recipe = Recipe.find(params[:id])
    @ingredients = []
    recipe_ingredients = RecipeIngredient.where(recipe_id: params[:id])
    recipe_ingredients.each do |recipe_ingredient|
      ing = Ingredient.find(recipe_ingredient.ingredient_id)
      @ingredients << {
        count: recipe_ingredient[:count],
        unit: ing[:unit],
        name: ing[:name]
      }
    end
  end

  def create
    user = User.find(params[:user_id])
    @recipe = user.recipes.create(recipe_params.except(:ingredients))
    redirect_to recipe_path(@recipe)
  end

  def edit
    @recipe = Recipe.find(params[:id])
  end

  def update
    @recipe = Recipe.find(params[:id])
    if @recipe
        update_recipe_ingredients(@recipe, recipe_params[:ingredients]) if recipe_params[:ingredients]
        if @recipe.update(recipe_params.except(:ingredients))
          redirect_to recipe_path(@recipe), status: 302
        else
          flash[:alert] = 'unable to update recipe'
          render :edit, status: 400
        end
    else
      render json: {error: "unable to update recipe, recipe could not be found"}, status: 400
    end
  end

  def destroy
    binding.pry
    @recipe = Recipe.find(params[:id])
    @recipe.destroy

    redirect_to recipes_path, status: 300
  end

  private
    def recipe_params
      params.require(:recipe).permit(:id, :name, :link, :status, :notes, :user_id, :img_url, :is_favorited, {ingredients: [:name, :count, :unit]}, {weeks: []})
    end

    def format_ingredient(ingredient, recipe_id)
      {
        name: ingredient.name,
        unit: ingredient.unit,
        count: RecipeIngredient.where(
          ingredient_id: ingredient.id,
          recipe_id: recipe_id
        ).count
      }
    end

    def update_recipe_ingredients(recipe, new_ingredients)
      old_ingredients = RecipeIngredient.where({"recipe_id" => recipe[:id]})
      remove_ingredients(new_ingredients, old_ingredients)
      add_ingredients(new_ingredients, old_ingredients, recipe[:id])
    end

    def remove_ingredients(new_ingredients, old_ingredients)
      old_ingredients.each do |old_ingredient|
        unless new_ingredients.include?(old_ingredient)
          old_ingredient.destroy!
        end
      end
    end

    def add_ingredients(new_ingredients, old_ingredients, recipe_id)
      new_ingredients.each do |ingredient|
        unless old_ingredients.include?(ingredient)
          new_ingredient = Ingredient.find_or_create_by({"name"=> ingredient[:name], "unit" => ingredient[:unit]})
          if new_ingredient.valid?
            recipe_ingredient = RecipeIngredient.find_or_create_by({
              "recipe_id"=> recipe_id,
              "ingredient_id"=> new_ingredient[:id]
            })
            if recipe_ingredient[:count] && ingredient[:count]
              ing_count = recipe_ingredient[:count].to_i + ingredient[:count].to_i
            else
              ing_count = 1
            end
            recipe_ingredient.update(:count => ing_count)
          end
        end
      end
    end

end