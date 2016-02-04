class AddFishingController < ApplicationController
	def index
    	@title="Новая рыбалка"
	end

	def get
		@result = Map.get_uniq(params[:type])
    	render json: @result
	end
end
