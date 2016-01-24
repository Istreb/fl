#!/bin/env ruby
# encoding: utf-8
class MapsController < ApplicationController
  def index
    @title="Home"
    @result = Map.get_places()
  end
end
