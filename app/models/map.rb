# coding: utf-8
class Map < ActiveRecord::Base

	def self.get_places
		sql = """ select * from places """
		result = Map.connection.select_all(sql)
		p result
	end
end
