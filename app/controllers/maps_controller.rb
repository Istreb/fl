#!/bin/env ruby
# encoding: utf-8
class MapsController < ApplicationController
  def index
    @title="Home"
  end

  def get_places
    @result = Map.get_places()
    render json: @result
  end

  def get_fishings
  	@result = Map.get_fishings()
    render json: @result
  end
end
