class VendorsController < ApplicationController
  before_action :set_vendor, only: %i[edit pricing update update_pricing destroy]

  def index
    authorize Vendor
    @vendors = policy_scope(Vendor)
  end

  def new
    @vendor = policy_scope(Vendor).build
    authorize @vendor
  end

  def create
    @vendor = policy_scope(Vendor).build(vendor_params)
    authorize @vendor
    if @vendor.save
      flash[:notice] = "You have created #{@vendor.name}."
      redirect_to vendors_path
    else
      render :new
    end
  end

  def pricing
    authorize @vendor, :show?
    @ingredients = @vendor.ingredients
  end

  def update_pricing
    authorize @vendor, :edit?
    updated_ingredients = ingredient_params
    scrubbed_keys = []
    updated_ingredients["ingredients_attributes"].each do |k, v|
      scrubbed_keys.push(k) if v["dirty"] != "true"
    end
    updated_ingredients["ingredients_attributes"] = updated_ingredients["ingredients_attributes"].except(*scrubbed_keys)
    @vendor.bakery.update(updated_ingredients)
    redirect_to pricing_vendor_path(@vendor)
  end

  def edit
    authorize @vendor
  end

  def update
    authorize @vendor
    if @vendor.update(vendor_params)
      flash[:notice] = "You have updated #{@vendor.name}."
      redirect_to vendors_path(@vendor)
    else
      render "edit"
    end
  end

  def destroy
    authorize @vendor
    if @vendor.destroy
      flash[:notice] = "You have deleted #{@vendor.name}"
      redirect_to vendors_path
    else
      render "edit"
    end
  end

  private

  def set_vendor
    @vendor = policy_scope(Vendor).find(params[:id])
  end

  def vendor_params
    params.require(:vendor).permit(
      :contact,
      :email,
      :name,
      :phone
    )
  end

  def ingredient_params
    params.require(:bakery).permit(
         ingredients_attributes:
             %i[id conversion cost current_amount cost_over_time_vendor_id dirty weight_unit updated_at]
    )
  end
end
