class AddFishingController < ApplicationController
	skip_before_action :verify_authenticity_token
	def index
    	@title="Новая рыбалка"
    	if !params[:start_date].blank?
    		p params
    	end

	end

	def get
		@result = Map.get_uniq(params[:type])
    	render json: @result
	end
	def add
		Map.add_fishing(params)
		@result = true
	end
end
