# coding: utf-8
class Map < ActiveRecord::Base

	def self.get_places
		sql = """ select * from places """
		result = Map.connection.select_all(sql)
		return result
	end

	def self.get_fishings
		sql = """ 
			select 
				pp.name,
				f.date_from,
				f.date_to,
				f.total_fishes,
				f.total_weight,
				pp.latitude,
				pp.longitude,
				pp.locality
			from
				fishings as f
			left join
				visited_places as p
			on
				f.id = p.fishing_id
			left join
				places as pp
			on
				p.place_id = pp.id
		"""
		result = Map.connection.select_all(sql)
		return result
	end

	def self.get_uniq(table)

		sql = """ SELECT distinct name FROM """ + table
		result = Map.connection.select_all(sql)
		return result
	end

end
