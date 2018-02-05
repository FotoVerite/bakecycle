class VendorsController < ApplicationController

	before_action :set_vendor, only: %i[edit pricing update update_pricing destroy]

	def index
	  authorize Vendor
	  @vendors = policy_scope(Vendor)
	end

	def new
	  @vendor = policy_scope(Vendor)
	  authorize @vendor
	end

	def create
	  @vendor = policy_scope(Vendor).build(vendor_params)
	  authorize @vendor
	  if @vendor.save
	    flash[:notice] = "You have created #{@vendor.name}."
	    redirect_to edit_vendor_path(@vendor)
	  else
	    render "new"
	  end
	end

	def pricing
	    authorize @vendor, :show?
	    @ingredients = @vendor.ingredients
	end

	 def update_pricing
	    authorize @vendor, :edit?
		@vendor.bakery.update(ingredient_params)
		redirect_to vendor_pricing_path(@vendor)
	end

	def edit
	  authorize @vendor
	end

	def update
	  authorize @vendor
	  if @vendor.update(vendor_params)
	    flash[:notice] = "You have updated #{@vendor.name}."
	    redirect_to edit_vendor_path(@vendor)
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
	  	:conversion
	  )
	end

	def ingredient_params
    	params.require(:bakery).permit(
	      ingredients_attributes:
	          %i[id conversion cost current_amount cost_over_time_vendor_id dirty weight_unit]
	    )
  	end
	
end
