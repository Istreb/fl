# coding: utf-8
class Map < ActiveRecord::Base

	def self.get_places
		sql = """ select * from places """
		result = Map.connection.select_all(sql)
		return result
	end

	def self.get_fishing_chart_data(fishing)
		results = {}
		sql = """
			select
			  f.name as fish_name,
			  cf.description,
			  cf.cnt,
			  cf.weight,
			  b.name as bait_name
			from 
			  catched_fishes cf
			left join
			  fishes f
			on
			  cf.fish_id = f.id
			left join
			  baits b
			on
			  cf.bait_id = b.id
			where
			  fishing_id = '" + fishing + "'
		"""
		results["fishes"] = Map.connection.select_all(sql)

		sql = """
			select 
			    b.name,
			    ub.description
			  from
			    used_baits ub
			  left join
			    baits b
			  on
			    ub.bait_id = b.id
			  where
			    ub.fishing_id = '" + fishing + "'
		"""
		results["baits"] = Map.connection.select_all(sql)


		# results = {}
		# sql = """
		# 	with ids as (
		# 	  select 
		# 	    id as fishing_id
		# 	  from
		# 	    fishings
		# 	  where
		# 	    id in (
		# 	      select 
		# 	        distinct fishing_id
		# 	      from 
		# 	        visited_places
		# 	      where 
		# 	        place_id=8
		# 	    )
		# 	)
		# 	select 
		# 	  fns.date_from,
		# 	  fns.date_to,
		# 	  fns.total_weight
		# 	from 
		# 	  (
		# 	    select
		# 	      id,
		# 	      date_from,
		# 	      date_to,
		# 	      total_weight
		# 	    from
		# 	      fishings f 
		# 	    where
		# 	      id in (select * from ids)
		# 	  ) fns 
		# """
		# results["weight"] = Map.connection.select_all(sql)

		# sql = """
		# 	with ids as (
		# 	  select 
		# 	    id as fishing_id
		# 	  from
		# 	    fishings
		# 	  where
		# 	    id in (
		# 	      select 
		# 	        distinct fishing_id
		# 	      from 
		# 	        visited_places
		# 	      where 
		# 	        place_id=8
		# 	    )
		# 	)
		# 	select 
		# 	  distinct fs.name,
		# 	sum(  fs.cnt) 

		# 	from 
		# 	  (
		# 	    select 
		# 	      cf.fishing_id,
		# 	      case 
		# 	        when cf.cnt is null then 1
		# 	        else cf.cnt 
		# 	      end as cnt,
		# 	      cf.weight,
		# 	      cf.bait_id,
		# 	      f.name,
		# 	      f.decsription
		# 	    from 
		# 	      catched_fishes cf
		# 	    left join
		# 	      fishes f
		# 	    on
		# 	      cf.fish_id = f.id
		# 	    where
		# 	      fishing_id in (select * from ids)
		# 	  ) fs
		# 	group by
		# 	  fs.name

		# """
		# results["fishes"] = Map.connection.select_all(sql)


		return results
	end

	def self.get_fishings
		results = {}
		sql = """ 
			select 
				pp.name,
				f.id as fishing_id,
				pp.id as place_id,
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
		results["places"] = Map.connection.select_all(sql)

		sql = """ 
			SELECT CAST ((julianday('2014-06-06') - julianday('2008-03-08')) / 30 AS integer)-13 AS cnt;
		"""
		results["dates"] = Map.connection.select_all(sql)
		return results
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

	def self.get_place_details(place)
		results = {}
		sql = """
			select 
				date_from,
				total_weight
			from
				fishings
			where
				id in (
			    	select fishing_id from visited_places where place_id="+place+"
				)
			order by
				date_from
		"""
		results["weight"] = Map.connection.select_all(sql)
		sql = """
			select 
			  f.date_from,
			  fs.name,
			  case when cf.cnt is null then 1 else cf.cnt end cnt
			from
			  fishings f
			left join
			  catched_fishes cf
			on
			  f.id = cf.fishing_id
			left join
			  fishes fs
			on
			 cf.fish_id = fs.id
			where
			  f.id in (
			     select fishing_id from visited_places where place_id="+place+"
			  )
			order by
			  f.date_from
		"""
		results["fish_date"] = Map.connection.select_all(sql)
		sql = """
			select 
			  distinct name,
			  sum(cnt) as cnt
			from
			(
			select 
			  b.name,
			  '1' as cnt
			from
			  fishings f
			left join
			  used_baits ub
			on
			  f.id = ub.fishing_id
			left join
			  baits b
			on
			 ub.bait_id = b.id
			where
			  f.id in (
			     select fishing_id from visited_places where place_id="+place+"
			  )
			)
			group by
			  name
		"""
		results["bait"] = Map.connection.select_all(sql)
		return results
	end

	def self.add_other(params)
		# проверить наличие рыб, если нет добавить
		types = Hash.new
		types["fishes"] = ["catched_fishes","fish_id"]
		types["baits"] = ["used_baits", "bait_id"]
		types["places"] = ["visited_places", "place_id"]
		order = 1
		types.each {|key, value| 
			if !params[key].nil?
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
			end
		}
		return true
	end

end
