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

	def self.add_fishing(params)
		start_date = params['start_date'][6,4] + '-' + params['start_date'][3,2] + '-' + params['start_date'][0,2]
		end_date = params['end_date'][6,4] + '-' + params['end_date'][3,2] + '-' + params['end_date'][0,2]

		sql = """ 
			insert into fishings(date_from,date_to,total_weight)
			values (date('" + start_date + "'), date('" + end_date + "'), " + params['total_weight'] + ")
		"""
		id = Map.connection.insert(sql)
		return id
	end

	def self.add_other(params)
		# проверить наличие рыб, если нет добавить
		types = Hash.new
		types["fishes"] = ["catched_fishes","fish_id"]
		types["baits"] = ["used_baits", "bait_id"]
		types["places"] = ["visited_places", "place_id"]
		order = 1
		types.each {|key, value| 
			params[key].each {|x|
				sql = """ 
					select 1 from "+ key +"
					where name = '" + x + "'"
				result = Map.connection.select_all(sql)
				if result.length() == 0
					sql = """ 
						insert into "+ key +"(name)
						values ('" + x + "')
					"""
					id = Map.connection.insert(sql)
				end

				if (defined? id)
					if key != 'places'
						sql = """ 
							insert into "+ value[0] +"("+ value[1] +", fishing_id)
							select id, '" + params['fishing_id'] + "' as fishing_id from "+ key +"
							where
							name='" + x + "'
						"""
					else
						sql = """ 
							insert into "+ value[0] +"("+ value[1] +", fishing_id, [order])
							select id, '" + params['fishing_id'] + "' as fishing_id, '#{order}' as [order] from "+ key +"
							where
							name='" + x + "'
						"""
						order+=1
					end
					Map.connection.insert(sql)
				else
					if key != 'places'
						sql = """ 
							insert into "+ value[0] +"("+ value[1] +", fishing_id) 
							values ('" + id + "','" + params['fishing_id'] + "')
							"""
					else
						sql = """ 
							insert into "+ value[0] +"("+ value[1] +", fishing_id, [order]) 
							values ('" + id + "','" + params['fishing_id'] + "','#{order}')
							"""
						order+=1
					end
					Map.connection.insert(sql)
				end
			}
		}
		return true
	end

end
