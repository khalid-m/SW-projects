from google.appengine.ext import db
from dbEntity import DbEntity
from dbEntity import StaticDbEntityModel
from dbEntity import *
from google.appengine.ext.db import stats
import logging


def getStatistic(writeFunc, requestObj):
    # load entities from datastore
	entities = DbEntity.all()
    
    # add type information before first line 
	writeFunc( "Charstring||Charstring||Charstring\n" )

    #entities, e.g {CITY, STATE}
	for entity in entities:
        # e.g cMetadata is equal to entity.getPropDict()
        # {'state': ('charstring', {}, 'cityName'), 'cityname': ('charstring', {}, 'cityNa
        # me'), 'population': ('charstring', {}, 'cityName')}
		tableName = entity.name
		ModelClass = DbEntity.loadModelClass( tableName )
		projection = ModelClass.getDbEntity().getDefaultProjection()	
		queryResults = db.GqlQuery("select * from " + tableName)
		fetchResults = queryResults.fetch(10000000)
		writeFunc( "%s||||\n" % entity.name)
		for key, propTpl in entity.getPropDict().iteritems():
            # each entry in propDict is a triple (db.Property,params,keyIndex/None)
            # print out of for key, propTpl in entity.getPropDict().iteritems():
			#key is STATE and propTpl[0] is <class 'google.appengine.ext.db.StringProperty'> and propTpl[2] is None
			#key is CITYNAME and propTpl[0] is <class 'google.appengine.ext.db.StringProperty'> and propTpl[2] is 0
			#key is POPULATION and propTpl[0] is <class 'google.appengine.ext.db.IntegerProperty'> and propTpl[2] is None
			#key is FULLNAME and propTpl[0] is <class 'google.appengine.ext.db.StringProperty'> and propTpl[2] is None
			#key is SHORTNAME and propTpl[0] is <class 'google.appengine.ext.db.StringProperty'> and propTpl[2] is 0
			# if attribute is string type, then return number of different values for that attribute
			###logging.debug("key is %s and propTpl[0] is %s and propTpl[2] is %s" % (key, propTpl[0],propTpl[2]))
			atype = DbEntity.getAmosPropertyType(propTpl[0])
			###logging.debug("atype is %s" % atype)

			if atype == 'Charstring':
				unique_results = []		
				for res in fetchResults:
					colVal=getattr(res, key)
					if colVal not in unique_results:
						unique_results.append(colVal)
				#logging.debug("unique_results list is %s" % unique_results)
				numOfDiffVals = len(unique_results)
				#logging.debug("numOfDiffVals is %d" % numOfDiffVals)
				writeFunc( "%s||%s||%s\n" % (key, atype, numOfDiffVals) )
				#writeFunc( "%s||%s||%s\n" % (key, atype, str(600)) )
			elif atype == 'Integer':
				###logging.debug("select * from " + tableName + " order by " + key + " desc")
				#max_val = db.GqlQuery("select * from " + tableName + " order by " + key + " desc").get().key
				#max_val = ModelClass.all().order("-"+key).get().key
				#max_val = CITY.all().order("-"+POPULATION).get().POPULATION
				queryResult_max = db.GqlQuery("select * from " + tableName + " order by " + key + " desc")
				fetchResults_max = queryResult_max.fetch(1)
				for res_max in fetchResults_max:
					max_val=getattr(res_max,key)
				#max_val = DbEntity.loadModelClass(tableName).gql("order by " + key + " desc").get().key
				###logging.debug("max value is %s" % str(max_val))
				writeFunc( "%s||%s||%s\n" % (key, atype, str(max_val)) )
				#max_val = db.GqlQuery("select * from CITY order by POPULATION desc").get().key
				#min_val = db.GqlQuery("select * from " + tableName + " order by " + key + " asc").get().key
				#logging.debug("min value is %s" % str(min_val))
				queryResult_min = db.GqlQuery("select * from " + tableName + " order by " + key + " asc")
				fetchResults_min = queryResult_min.fetch(1)
				for res_min in fetchResults_min:
					min_val=getattr(res_min,key)
				writeFunc( "%s||%s||%s\n" % (key, atype, str(min_val)) )
			# (state, "charstring", "cityName")
            # (cityname, "charstring", "cityName")
            # (population, "charstring", "cityName")
        
        # write empty line to mark end of entity
		writeFunc("\n")
        
