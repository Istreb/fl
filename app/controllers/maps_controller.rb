#!/bin/env ruby
# encoding: utf-8
class MapsController < ApplicationController
  def index
    @title="Home"
  end

  def places
    @result = Map.get_places()
    render json: @result
  end
end
