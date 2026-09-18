import logging
from dbEntity import DbEntity
from google.appengine.ext import db  
from timeProfiling import *


def writeTypeLine(writeFunc, resultTuple, projection):
	"""Write type information for the following rows"""
	#logging.debug("projection is %s" % projection)
	writeFunc( "%s\n" % "||".join( [ DbEntity.getAmosPropertyType( type(resultTuple.properties()[k]) ) for k in projection ] ) )
	###logging.debug("this is writeTypeLine debug, writeTypeLine result is %s" % "||".join( [ DbEntity.getAmosPropertyType( type(resultTuple.properties()[k]) ) for k in projection ] ))

def writeResultTuple(writeFunc, resultTuple, projection):
    """Write a result tuple as row."""
    writeFunc( "%s\n" % "||".join( [ str( getattr(resultTuple,k) ) for k in projection ] ) )

def runInsertQuery(writeFunc, requestObj):
	"""receive parameters like table name, attribute name and attribute values from client 
	and insert the new entity into the table 
	@writeFunc: self.response.out.write
	@requestObj: Request class contains information about an incoming web request and 
	the request object carrying params like table name, column name and values
	"""

	from google.appengine.api.datastore import Put
    
	try:  
        # check if typename is set
		typename = requestObj.get("btTable").encode('utf8')
        # load model class (from DbEntity instance)
		ModelClass = DbEntity.loadModelClass( typename )
        # ModelClass = DbEntity.loadModelClass("CITY")
        # e.g properties = ["CITYNAME", "POPULATION", "STATE"]
		properties = [p.encode('utf8') for p in requestObj.get_all("gqlProj")]
       
        # get all inserted value
		# values = ["San Jose", 1100000, "CA"], e.g values[0] = "San Jose", values[1] = 1100000, values[2] = "CA"
		values = requestObj.get_all("v")
		
		logFlag = requestObj.get("logFlag")
		if logFlag == "on":
			logging.debug("here is runInsertQuery function, table name is %s" % typename)
			logging.debug("here is runInsertQuery function, properties is %s" % properties)
			logging.debug("here is runInsertQuery function, property values is %s" % values)
		
		propLen = len(properties)
		newEntityList = []
		params = {}                        
        # for each property
		for j in xrange(0, propLen):
            # value = values[ propLen + j ].encode('utf8')
            # value = values[ j ].encode('utf8')
			value = values[ j ]
            # convert type  e.g "1100000"->1100000  
			reqType = getattr( ModelClass, properties[j] ).data_type
			if not isinstance( value, reqType ):
				value  = reqType( value )
			params[ properties[j] ] = value
            
            # create new entity and append to entity list, so that it is possible to put more than one tuple in datastore
			newEntityList.append( ModelClass.createInstance(**params)._populate_internal_entity()) 
          
            # insert
			Put(newEntityList)
		writeFunc( "%s\n" % 'success' )
	except:
		writeFunc( "%s\n" % 'fail' )
		raise

# def resultActionEmit(writeFunc, resultSet, projection):
    # """Action to process the result set of runQuery"""
    # if len(resultSet) > 0:
        # #profiler = timeprofile()
        # #profiler.mark()
        # # add type information before first row
        # writeTypeLine(writeFunc, resultSet[0], projection )
        # #writeFunc( "%s||||\n" % cursor)
        # #writeFunc(resultSet[0])
        # # return rows
        # for row in resultSet:
            # writeResultTuple(writeFunc, row, projection )
           # #writeFunc(row)
           # #logging.debug("this is resultActionEmit debug, result tuple is %s:" % row)
        # #logging.debug("Get time is %s" % profiler.elapsed())
        # #logging.debug("time gap is %s" % profiler.timegap())
        # #logging.debug("max diff is %s" % profiler.maxdiff()) 
		
def resultActionEmit(writeFunc, resultSet, projection, cursor, signal):
	"""Action to process the result set of runQuery"""
	#resultset[0] is like <dbEntity.CITY object at 0xf020b578b1785370>
	#logging.debug("resultset[0] is %s" % resultSet[0])
	if len(resultSet) > 0:
		#profiler = timeprofile()
		#profiler.mark()
		# add type information before first row
		writeTypeLine(writeFunc, resultSet[0], projection )
		writeFunc( "%s||%s||%s\n" % (cursor,str(0),signal))
		#writeFunc(resultSet[0])
		# return rows
		for row in resultSet:
			writeResultTuple(writeFunc, row, projection )
	else:
		#writeTypeLine(writeFunc, resultSet[0], projection )
		writeFunc( "%s||%s||%s\n" % (str(0),str(0),signal))		
           #writeFunc(row)
           #logging.debug("this is resultActionEmit debug, result tuple is %s:" % row)
        #logging.debug("Get time is %s" % profiler.elapsed())
        #logging.debug("time gap is %s" % profiler.timegap())
        #logging.debug("max diff is %s" % profiler.maxdiff()) 
		
def resultEmit(writeFunc, resultSet, projection):
	"""continue to emit the batch result tuples"""
	if len(resultSet) > 0:
			for row in resultSet:
				writeResultTuple(writeFunc, row, projection )
		
def resultActionDelete(writeFunc, resultSet, projection):
	"""Action to process the result set of runQuery"""
	from google.appengine.api.datastore import Delete
    # delete entities
	logging.debug("here is resultActionDelete function")
	if len(resultSet) > 0:
		Delete([entity.key() for entity in resultSet])
		writeFunc( "%s\n" % 'success' )
	else:
		writeFunc( "%s\n" % 'fail' )
		#raise Exception, "No such entity to delete!"
		# write response
		#writeFunc("Charstring\n%s" % "one tuple has been deleted")
	

def runQuery(writeFunc, requestObj, action=resultActionEmit):
	"""receive a query from client and pass it to datastore query interface. 
	The query result is written to the given output write function.
	@writeFunc: self.response.out.write
	@requestObj: Request class contains information about an incoming web request and 
	the request object carrying params like table name, column name and values
	@action: function to emit the query result from server
	"""    
	
	query = requestObj.get("gqlString")
	logFlag = requestObj.get("logFlag")
	resultChunkSize = int(requestObj.get("resultChunkSize"))
	if logFlag == "on":
		logging.debug("here is runQuery function, the query server received is %s" % query)
		logging.debug("here is runQuery function, server log flag is %s" % logFlag)
		logging.debug("here is runQuery function, resultChunkSize is %s" % resultChunkSize)
	a = query.split()    
	if len(query) > 0:
		typename = a[3]
		ModelClass = DbEntity.loadModelClass( typename )
		projection = ModelClass.getDbEntity().getDefaultProjection()
		queryResult = db.GqlQuery(query)
		cursor = requestObj.get("cursor")
		if logFlag == "on":
			logging.debug("here is runQuery function, the cursor value server received is %s" % cursor)
		signal = 'more'
		if cursor:
			queryResult.with_cursor(cursor)
			fetchRes = queryResult.fetch(resultChunkSize)
			cursor = queryResult.cursor()
			if len(fetchRes) < resultChunkSize:
				signal = 'NoMore' 
				cursor = ''
			if logFlag == "on":
				logging.debug("The query %s is sent to server more than once" % query)
				logging.debug("The received cursor information from client is %s" % cursor)
			#cursor = queryResult.cursor()
			action( writeFunc, fetchRes, projection, cursor, signal)
			if logFlag == "on":
				logging.debug("server generated query result size is %s" % len(fetchRes))			
				logging.debug("The cursor information server sends back to client is %s" % cursor)					
				logging.debug("The signal information server sends back to client is %s" % signal)	
		else:
			fetchRes = queryResult.fetch(resultChunkSize)
			cursor = queryResult.cursor()		
			if len(fetchRes) < resultChunkSize:
				signal = 'NoMore'
				cursor = ''
			action( writeFunc, fetchRes, projection, cursor, signal)
			if logFlag == "on":	
				logging.debug("The query %s is sent to server at the first time" % query)			
				logging.debug("server generated query result size is %s" % len(fetchRes))
				logging.debug("The cursor information server sends back to client is %s" % cursor)					
				logging.debug("The signal information server sends back to client is %s" % signal)			

# runQuery with get_all function	
# def runQuery(writeFunc, requestObj, action=resultActionEmit):
	# """receive a query from client and pass it to datastore query interface. 
	# The query result is written to the given output write function.
	# @writeFunc: self.response.out.write
	# @requestObj: Request class contains information about an incoming web request and 
	# the request object carrying params like table name, column name and values
	# @action: function to emit the query result from server
	# """    
	
	# queryList = requestObj.get_all("gqlString")
	# logFlagList = requestObj.get_all("logFlag")
	# resultChunkSizeList = requestObj.get_all("resultChunkSize")
	# resultChunkSize = int(resultChunkSizeList[0])
	# if logFlagList[0] == "on":
		# logging.debug("here is runQuery function, the query server received is %s" % queryList[0])
		# logging.debug("here is runQuery function, server log flag is %s" % logFlagList[0])
		# logging.debug("here is runQuery function, resultChunkSize is %s" % resultChunkSize)
	# a = queryList[0].split()    
	# if len(queryList) > 0:
		# typename = a[3]
		# ModelClass = DbEntity.loadModelClass( typename )
		# projection = ModelClass.getDbEntity().getDefaultProjection()
		# queryResult = db.GqlQuery(queryList[0])
		# cursorValue = requestObj.get_all("cursor")
		# cursor = cursorValue[0]
		# signal = 'more'
		# if cursor:
			# queryResult.with_cursor(cursor)
			# fetchRes = queryResult.fetch(resultChunkSize)
			# if len(fetchRes) < resultChunkSize:
				# signal = 'NoMore' 
			# if logFlagList[0] == "on":
				# logging.debug("The query %s is sent to server more than once" % queryList[0])
				# logging.debug("The received cursor information from client is %s" % cursor)
			# cursor = queryResult.cursor()
			# action( writeFunc, fetchRes, projection, cursor, signal)
			# if logFlagList[0] == "on":
				# logging.debug("server generated query result size is %s" % len(fetchRes))			
				# logging.debug("The cursor information server sends back to client is %s" % cursor)					
				# logging.debug("The signal information server sends back to client is %s" % signal)	
		# else:
			# fetchRes = queryResult.fetch(resultChunkSize)
			# cursor = queryResult.cursor()		
			# if len(fetchRes) < resultChunkSize:
				# signal = 'NoMore'
			# action( writeFunc, fetchRes, projection, cursor, signal)
			# if logFlagList[0] == "on":	
				# logging.debug("The query %s is sent to server at the first time" % queryList[0])			
				# logging.debug("server generated query result size is %s" % len(fetchRes))
				# logging.debug("The cursor information server sends back to client is %s" % cursor)					
				# logging.debug("The signal information server sends back to client is %s" % signal)			
				


#with memcache
# def runQuery(writeFunc, requestObj, limit=1000000000, action=resultActionEmit):
   # """Construct and run a query based on the requestObj parameters. 
   # The result is written to the given output write function.

   # @type writeFunc: Function
   # @param writeFunc: output write function
   # @type requestObj: webapp.Request
   # @param requestObj: the request object providing access to the query GET params
   # @type isChunkCursor: Boolean
   # @param isChunkCursor: flag if to run a chunk cursor
   # @type limit: int
   # @param limit: optional max. number of rows to fetch
   # @type action: function
   # @param action: action to be applied on the result set
   # """
   
   # from google.appengine.api import memcache
       
   # query = requestObj.get("gqlString")
   # a = query.split()
   # typename = a[3]
   # ModelClass = DbEntity.loadModelClass( typename )
   # projection = ModelClass.getDbEntity().getDefaultProjection()
   # logging.debug("we come to projection, projection is: %s" % projection)   

   # fetchQueryResult = memcache.get(query)
   # logging.debug("query string is: %s" % query)
   # if fetchQueryResult is not None:
       # #fetchRes = memcache.get("fetchRes")
       # action( writeFunc, fetchQueryResult, projection )
       # #logging.info("this is logging.info, fetching query result from memcache")
       # logging.debug("this is logging debug, fetching query result from memcache")
   # else:
       # queryResult = db.GqlQuery(query)
       # fetchRes = queryResult.fetch(limit)
       # #memcache.set("gqlquery", query)
       # #memcache.set("fetchRes", fetchRes)
       # memcacheAdded = memcache.add(query, fetchRes, 600)
       # action( writeFunc, fetchRes, projection )
       # #logging.info("this is logging info, query result is added into memcache")
       # logging.debug("this is logging debug, query result is added into memcache")
       # if memcacheAdded is None:
           # logging.error("Memcache add failed.")

def runDeleteQuery(writeFunc, requestObj, limit=1000000000, action=resultActionDelete):
	"""receive parameters like table name and attribute values from client 
	and delete the existing entity from the table
    
	@writeFunc: self.response.out.write
	@requestObj: Request class contains information about an incoming web request and 
	the request object carrying params like table name, and primary key value
	@action: function to emit the success or fail message to client
	"""     
	query = requestObj.get("gqlString")
	logFlag = requestObj.get("logFlag")
	if logFlag == "on":
		logging.debug("here is runDeleteQuery function, query is %s" % query)
		logging.debug("here is runDeleteQuery function, logFlag is %s" % logFlag)	
	a = query.split()
	typename = a[3]
	ModelClass = DbEntity.loadModelClass( typename )
	projection = ModelClass.getDbEntity().getDefaultProjection()
	queryResult = db.GqlQuery(query)
	fetchRes = queryResult.fetch(limit)
	action( writeFunc, fetchRes, projection ) 

def gqlNLJResultEmit(writeFunc, resultSet, projection):
    """Action to process the result set of runQuery"""
    if len(resultSet) > 0:
        # add type information before first row
		#logging.debug("this is gqlNLJResultEmit debug, resultSet[0] is %s:" % resultSet[0])
		writeTypeLine(writeFunc, resultSet[0], projection )
        #writeFunc(resultSet[0])
        # return rows
		for row in resultSet:
			writeGqlNLJResultTuple(writeFunc, row, projection )
			#writeFunc(row)
			#logging.debug("this is resultActionEmit debug, result tuple is %s:" % row)

def writeGqlNLJResultTuple(writeFunc, resultTuple, projection):
	"""Write a result tuple as row."""
	#logging.debug("result of join strings is %s" % "||".join( [ str( getattr(resultTuple,k) ) for k in projection ] ))
	writeFunc( "%s\n" % "||".join( [ str( getattr(resultTuple,k) ) for k in projection ] ) )

#def writeTypeLine(writeFunc, resultTuple, projection):
#    """Write type information for the following rows"""
#    writeFunc( "%s\n" % "||".join( [ DbEntity.getAmosPropertyType( type(resultTuple.properties()[k]) ) for k in projection ] ) )

#function to handle nested loop join in bigwrapper python server--without caching
def gqlNLJ(writeFunc, requestObj, limit=1000000000, action=gqlNLJResultEmit):
	"""receive set of query strings and join positions from incoming web request and 
	do the nested loop join in server.   
	"""
	
	# bigwrapper client passes string value representation of vector value to requestObj.get_all("gqlQueryStrings") 
	queryStrings = requestObj.get_all("gqlQueryStrings")
	joinPros = requestObj.get_all("gqlJoinPros")
	logFlagList = requestObj.get_all("logFlag")
	if logFlagList[0] == "on":
		logging.debug("here is gqlNLJ function, query Strings from client are %s" % queryStrings)
		logging.debug("here is gqlNLJ function, join position is %s" % joinPros)   
	# queryStrings[0] e.g "["select * from CITY where POPULATION > 800000", "select * from STATE where SHORTNAME > 'CA' and SHORTNAME = ?"]"
	# eval(queryStrings[0]) e.g ["select * from CITY where POPULATION > 800000", "select * from STATE where SHORTNAME > 'CA' and SHORTNAME = ?"]   
	queryStringsList = eval(queryStrings[0])
	# joinPros[0] e.g "[[0]]"
	# eval(joinPros[0]) e.g [[0]]
	joinProsList = eval(joinPros[0])
	#logging.debug("queryStringsList is %s" % queryStringsList)
	#logging.debug("queryStringsList[0] is %s" % queryStringsList[0])
	#logging.debug("joinProsList is %s" % joinProsList)
	outerTableName = queryStringsList[0].split()[3]
	outerTableModelClass = DbEntity.loadModelClass( outerTableName )
	outerTableProjection = outerTableModelClass.getDbEntity().getDefaultProjection()
	outerTableQueryResult = db.GqlQuery(queryStringsList[0])
	outerTableFetchResults = outerTableQueryResult.fetch(limit)
	writeFunc( "%s\n" % "Charstring||Charstring||Charstring||Charstring||Integer")
	for outerTableFetchResult in outerTableFetchResults:
		joinValue = getattr(outerTableFetchResult,outerTableProjection[joinProsList[0][0]])
		#joinValue is CA
		#logging.debug("joinValue is %s" % joinValue)
		#logging.debug("outerTableFetchResult is %s" % list(outerTableFetchResult))
		###logging.debug("outerTableFetchResult is %s" % outerTableFetchResult)
		#logging.debug(list(outerTableFetchResult))
		#logging.debug("outerTableProjection is %s" % outerTableProjection)
		# replace ? with joinValue for queryStringsList[1]
		newInnerQueryString = queryStringsList[1].replace('?', "'"+joinValue+"'")
		#logging.debug("newInnerQueryString is %s" % newInnerQueryString)
		innerTableName = newInnerQueryString.split()[3]
		innerTableModelClass = DbEntity.loadModelClass( innerTableName )
		innerTableProjection = innerTableModelClass.getDbEntity().getDefaultProjection()
		innerTableQueryResult = db.GqlQuery(newInnerQueryString)
		innerTableFetchResults = innerTableQueryResult.fetch(limit)
		#logging.debug("innerTableProjection is %s" % innerTableProjection)
		outerResult = "||".join( [ str( getattr(outerTableFetchResult,k) ) for k in outerTableProjection ] )
		###logging.debug( "outerResult is %s\n" % outerResult )
		if len(innerTableFetchResults) > 0:
		#	writeFunc( "%s\n" % "Charstring||Charstring||Integer||Charstring||Charstring:")
		#	writeFunc( "%s\n" % "Charstring||Charstring")
			for innerTableFetchResult in innerTableFetchResults:
				#logging.debug("result of outer join strings is %s" % "||".join( [ str( getattr(outerTableFetchResult,k) ) for k in outerTableProjection ] ))
				#logging.debug("result of inner join strings is %s" % "||".join( [ str( getattr(innerTableFetchResult,k) ) for k in innerTableProjection ] ))	
				innerResult = "||".join( [ str( getattr(innerTableFetchResult,k) ) for k in innerTableProjection ] )
				joinTuple = outerResult+"||"+innerResult
				writeFunc( "%s\n" % joinTuple)

# #function to handle nested loop join in bigwrapper python server--with caching
# def gqlNLJ(writeFunc, requestObj, limit=1000000000, action=gqlNLJResultEmit):
   # """Construct and run a query based on the requestObj parameters. 
   # The result is written to the given output write function.

   # @type writeFunc: Function
   # @param writeFunc: output write function
   # @type requestObj: webapp.Request
   # @param requestObj: the request object providing access to the query GET params
   # @type isChunkCursor: Boolean
   # @param isChunkCursor: flag if to run a chunk cursor
   # @type limit: int
   # @param limit: optional max. number of rows to fetch
   # @type action: function
   # @param action: action to be applied on the result set
   # """
   
   # from google.appengine.api import memcache
   
   # # bigwrapper client passes string value representation of vector value to requestObj.get_all("gqlQueryStrings") 
   # queryStrings = requestObj.get_all("gqlQueryStrings")
   # joinPros = requestObj.get_all("gqlJoinPros")
   
   # # queryStrings[0] e.g "["select * from CITY where POPULATION > 800000", "select * from STATE where SHORTNAME > 'CA' and SHORTNAME = ?"]"
   # # eval(queryStrings[0]) e.g ["select * from CITY where POPULATION > 800000", "select * from STATE where SHORTNAME > 'CA' and SHORTNAME = ?"]   
   # queryStringsList = eval(queryStrings[0])
   # # joinPros[0] e.g "[[0]]"
   # # eval(joinPros[0]) e.g [[0]]
   # joinProsList = eval(joinPros[0])
   # #logging.debug("queryStringsList is %s" % queryStringsList)
   # #logging.debug("queryStringsList[0] is %s" % queryStringsList[0])
   # #logging.debug("joinProsList is %s" % joinProsList)
   # outerTableName = queryStringsList[0].split()[3]
   # outerTableModelClass = DbEntity.loadModelClass( outerTableName )
   # outerTableProjection = outerTableModelClass.getDbEntity().getDefaultProjection()
   
   # outerTempResults = memcache.get(queryStringsList[0])
   
   # if outerTempResults is not None:
		# outerTableFetchResults = outerTempResults
   # else:
	# outerTableQueryResult = db.GqlQuery(queryStringsList[0])
	# outerTableFetchResults = outerTableQueryResult.fetch(limit)
	# memcache.add(queryStringsList[0], outerTableFetchResults, 1200)
   # writeFunc( "%s\n" % "Charstring||Charstring||Charstring||Charstring||Integer")
   # for outerTableFetchResult in outerTableFetchResults:
	# joinValue = getattr(outerTableFetchResult,outerTableProjection[joinProsList[0][0]])
	# #joinValue is CA
	# #logging.debug("joinValue is %s" % joinValue)
	# #logging.debug("outerTableFetchResult is %s" % outerTableFetchResult)
	# #logging.debug("outerTableProjection is %s" % outerTableProjection)
	   # # replace ? with joinValue for queryStringsList[1]
	# newInnerQueryString = queryStringsList[1].replace('?', "'"+joinValue+"'")
	# #logging.debug("newInnerQueryString is %s" % newInnerQueryString)
	# innerTableName = newInnerQueryString.split()[3]
	# innerTableModelClass = DbEntity.loadModelClass( innerTableName )
	# innerTableProjection = innerTableModelClass.getDbEntity().getDefaultProjection()
	
	# innerTempResults = memcache.get(newInnerQueryString)
	
	# if innerTempResults  is not None:
		# innerTableFetchResults = innerTempResults
	# else:
		# innerTableQueryResult = db.GqlQuery(newInnerQueryString)
		# innerTableFetchResults = innerTableQueryResult.fetch(limit)
		# memcache.add(newInnerQueryString, innerTableFetchResults, 1200)
	# #logging.debug("innerTableProjection is %s" % innerTableProjection)
	# outerResult = "||".join( [ str( getattr(outerTableFetchResult,k) ) for k in outerTableProjection ] )
	# #writeFunc( "%s\n" % outerResult )
	# if len(innerTableFetchResults) > 0:
	# #	writeFunc( "%s\n" % "Charstring||Charstring||Integer||Charstring||Charstring:")
	# #	writeFunc( "%s\n" % "Charstring||Charstring")
		# for innerTableFetchResult in innerTableFetchResults:	
	# #		logging.debug("result of outer join strings is %s" % "||".join( [ str( getattr(outerTableFetchResult,k) ) for k in outerTableProjection ] ))
	# #		logging.debug("result of inner join strings is %s" % "||".join( [ str( getattr(innerTableFetchResult,k) ) for k in innerTableProjection ] ))		
			# innerResult = "||".join( [ str( getattr(innerTableFetchResult,k) ) for k in innerTableProjection ] )
			# joinTuple = outerResult+"||"+innerResult
			# writeFunc( "%s\n" % joinTuple)
	# #		writeFunc( "%s\n" % "TX||Dallas||3000000||TX||Texas" )
		# #action( writeFunc, innerTableFetchResults, innerTableProjection )
		# #action( writeFunc, outerTableFetchResults, outerTableProjection )
		# #action( writeFunc, innerTableFetchResults, ['FULLNAME', 'STATE', 'CITYNAME', 'POPULATION'])	
			
	# #		writeFunc( "%s\n" % innerResult )

def gqlNLJNew(writeFunc, requestObj, limit=1000000000):
	"""receive set of query strings and join positions from incoming web request and 
	do the nested loop join in server.
	"""
	import operator
	# bigwrapper client passes string value representation of vector value to requestObj.get_all("gqlQueryStrings") 
	queryStrings = requestObj.get_all("gqlQueryStrings")
	joinPros = requestObj.get_all("gqlJoinPros")
	logFlagList = requestObj.get_all("logFlag")
	if logFlagList[0] == "on":
		logging.debug("here is gqlNLJNew function, query Strings from client are %s" % queryStrings)
		logging.debug("here is gqlNLJNew function, join position is %s" % joinPros)
   
	# queryStrings[0] e.g "["select * from CITY where POPULATION > 800000", "select * from STATE where SHORTNAME > 'CA' and SHORTNAME = ?"]"
	# eval(queryStrings[0]) e.g ["select * from CITY where POPULATION > 800000", "select * from STATE where SHORTNAME > 'CA' and SHORTNAME = ?"]   
	queryStringsList = eval(queryStrings[0])
	# joinPros[0] e.g "[[0]]"
	# eval(joinPros[0]) e.g [[0]]
	joinProsList = eval(joinPros[0])
	#logging.debug("queryStringsList is %s" % queryStringsList)
	#logging.debug("queryStringsList[0] is %s" % queryStringsList[0])
	###logging.debug("joinProsList is %s" % joinProsList)
	outerTableName = queryStringsList[0].split()[3]
	outerTableModelClass = DbEntity.loadModelClass( outerTableName )
	outerTableProjection = outerTableModelClass.getDbEntity().getDefaultProjection()
	outerJoinAttribute = outerTableProjection[joinProsList[0][0]]
	###logging.debug("outerJoinAttribute is %s" % outerJoinAttribute)
	outerTableQueryResult = db.GqlQuery(queryStringsList[0])
	###logging.debug("queryStringsList[0] is %s" % queryStringsList[0])
	outerTableFetchResults = outerTableQueryResult.fetch(limit)
	outerResType = "||".join( [ DbEntity.getAmosPropertyType( type(outerTableFetchResults[0].properties()[k]) ) for k in outerTableProjection ] )
	innerTableName = queryStringsList[1].split()[3]
	innerTableModelClass = DbEntity.loadModelClass( innerTableName )
	innerTableProjection = innerTableModelClass.getDbEntity().getDefaultProjection()
	innerJoinAttribute = innerTableProjection[joinProsList[0][1]]
	###logging.debug("innerJoinAttribute is %s" % innerJoinAttribute)
	innerTableQueryResult = db.GqlQuery(queryStringsList[1])
	innerTableFetchResults = innerTableQueryResult.fetch(limit)
	innerResType = "||".join( [ DbEntity.getAmosPropertyType( type(innerTableFetchResults[0].properties()[k]) ) for k in innerTableProjection ] )
	#writeFunc( "%s\n" % "Charstring||Charstring||Charstring||Charstring||Integer")
	writeFunc( "%s\n" % (outerResType+"||"+innerResType))
	for s in outerTableFetchResults:
		transformed_s = [str( getattr(s,k) ) for k in outerTableProjection ]
		###logging.debug("transformed_s is %s" % transformed_s)
		outerJoinVal = joinAttribute(transformed_s, joinProsList[0][0])
		###logging.debug("joinAttribute value is %s" % joinAttribute(transformed_s, joinProsList[0][0]))
		for r in innerTableFetchResults:
			transformed_r = [str( getattr(r,k) ) for k in innerTableProjection ]
			innerJoinVal = joinAttribute(transformed_r, joinProsList[0][1])
			#for ns in hashed.get(joinAttribute(transformed_r, joinProsList[0][1]),()):
			if operator.eq(outerJoinVal, innerJoinVal):
				joinTuple = "||".join(transformed_s + transformed_r)
				writeFunc( "%s\n" % joinTuple)

def gqlSMJResultEmit(writeFunc, resultSet, projection):
    """Action to process the result set of runQuery"""
    if len(resultSet) > 0:
        # add type information before first row
		#logging.debug("this is gqlNLJResultEmit debug, resultSet[0] is %s:" % resultSet[0])
		writeTypeLine(writeFunc, resultSet[0], projection )
        #writeFunc(resultSet[0])
        # return rows
		for row in resultSet:
			writeGqlSMJResultTuple(writeFunc, row, projection )
			#writeFunc(row)
			###logging.debug("this is resultActionEmit debug, result tuple is %s:" % row)

def writeGqlSMJResultTuple(writeFunc, resultTuple, projection):
	"""Write a result tuple as row."""
	###logging.debug("result of join strings is %s" % "||".join( [ str( getattr(resultTuple,k) ) for k in projection ] ))
	writeFunc( "%s\n" % "||".join( [ str( getattr(resultTuple,k) ) for k in projection ] ) )

def joinAttribute(x, pos):
	return x[pos]

# #function to handle sort merge join in bigwrapper python server--without caching
def gqlSMJ(writeFunc, requestObj, limit=1000000000, action=gqlSMJResultEmit):
	"""receive set of query strings and join positions from incoming web request and 
	do the sort merge join in server.
	"""
	import operator
	from itertools import groupby
	# bigwrapper client passes string value representation of vector value to requestObj.get_all("gqlQueryStrings") 
	queryStrings = requestObj.get_all("gqlQueryStrings")
	joinPros = requestObj.get_all("gqlJoinPros")
	logFlagList = requestObj.get_all("logFlag")
	if logFlagList[0] == "on":
		logging.debug("here is gqlSMJ function, query Strings from client are %s" % queryStrings)
		logging.debug("here is gqlSMJ function, join position is %s" % joinPros)
	#advancer function generates iterator object of join value and join row
	def advancer(Xp):
		#logging.debug("here is XP %s" % Xp)
		#logging.debug("here is joinPos %d" % joinPos)
		for k, g in groupby(Xp, key=operator.itemgetter(0)):
			yield k, list(g)
		
	# queryStrings[0] e.g "["select * from CITY where POPULATION > 800000", "select * from STATE where SHORTNAME > 'CA' and SHORTNAME = ?"]"
	# eval(queryStrings[0]) e.g ["select * from CITY where POPULATION > 800000", "select * from STATE where SHORTNAME > 'CA' and SHORTNAME = ?"]   
	queryStringsList = eval(queryStrings[0])
	# joinPros[0] e.g "[[0]]"
	# eval(joinPros[0]) e.g [[0]]
	joinProsList = eval(joinPros[0])
	#logging.debug("queryStringsList is %s" % queryStringsList)
	#logging.debug("queryStringsList[0] is %s" % queryStringsList[0])
	###logging.debug("joinProsList is %s" % joinProsList)
	outerTableName = queryStringsList[0].split()[3]
	outerTableModelClass = DbEntity.loadModelClass( outerTableName )
	outerTableProjection = outerTableModelClass.getDbEntity().getDefaultProjection()
	outerJoinAttribute = outerTableProjection[joinProsList[0][0]]
	###logging.debug("outerJoinAttribute is %s" % outerJoinAttribute)
	outerTableQueryResult = db.GqlQuery(queryStringsList[0])
	###logging.debug("queryStringsList[0] is %s" % queryStringsList[0])
	outerTableFetchResults = outerTableQueryResult.fetch(limit)
	outerResType = "||".join( [ DbEntity.getAmosPropertyType( type(outerTableFetchResults[0].properties()[k]) ) for k in outerTableProjection ] )
	outerResList = []
	#sortedOuterTableRes = sorted(outerTableFetchResults, key=lambda x: x.SHORTNAME)
	#logging.debug("sortedOuterTableRes length is %d" % len(sortedOuterTableRes))
	for tupleRes in outerTableFetchResults:
		outerResList.append([ str( getattr(tupleRes,k) ) for k in outerTableProjection ])
		#outerResult = ",".join( [ str( getattr(tupleRes,k) ) for k in outerTableProjection ] )
	#logging.debug( "outerResList is %s" % outerResList)
	#logging.debug( "length of outerResList is %d" % len(outerResList))
	innerTableName = queryStringsList[1].split()[3]
	innerTableModelClass = DbEntity.loadModelClass( innerTableName )
	innerTableProjection = innerTableModelClass.getDbEntity().getDefaultProjection()
	innerJoinAttribute = innerTableProjection[joinProsList[0][1]]
	###logging.debug("innerJoinAttribute is %s" % innerJoinAttribute)
	# newInnerQueryString = queryStringsList[1]
	# #logging.debug("newInnerQueryString is %s" % newInnerQueryString)
	innerTableQueryResult = db.GqlQuery(queryStringsList[1])
	innerTableFetchResults = innerTableQueryResult.fetch(limit)
	innerResType = "||".join( [ DbEntity.getAmosPropertyType( type(innerTableFetchResults[0].properties()[k]) ) for k in innerTableProjection ] )
	writeFunc( "%s\n" % (outerResType+"||"+innerResType))
	innerResList = []
	for innerTupleRes in innerTableFetchResults:
		innerResList.append([ str( getattr(innerTupleRes,k) ) for k in innerTableProjection ])
	#logging.debug( "innerResList is %s" % innerResList)
	#logging.debug( "length of innerResList is %d" % len(innerResList))
	R_grouped = advancer(sorted((joinAttribute(r, joinProsList[0][0]), r) for r in outerResList))
	S_grouped = advancer(sorted((joinAttribute(s, joinProsList[0][1]), s) for s in innerResList))
	#logging.debug("here is R_grouped %s" % list(R_grouped))
	#logging.debug("here is S_grouped %s" % list(S_grouped))
	#At the beginning, assigning first row of stream R_grouped and S_grouped to rk, R_matched and sk, S_matched
	rk, R_matched = R_grouped.next()
	sk, S_matched = S_grouped.next()
	while R_grouped and S_grouped:
		comparison = cmp(rk, sk)
		###logging.debug("comparison value is %d" % comparison)
		###logging.debug("rk value is %s" % rk)
		###logging.debug("sk value is %s" % sk)
		if comparison == 0:
			#rp is join attribute value, r is the corresponding tuple
			for rp, r in R_matched:
				###logging.debug("here is rp %s" % rp)
				###logging.debug("here is r %s" % r)
				for sp, s in S_matched:
					joinTuple = "||".join(r+s)
					writeFunc( "%s\n" % joinTuple)
					#logging.debug("here is sp %s" % sp)
					#logging.debug("here is s %s" % s)
					#writeFunc( "%s\n" % "Texas||TX||TX||Dallas||3000000" )
			try:
				rk, R_matched = R_grouped.next()
				sk, S_matched = S_grouped.next()
			except StopIteration:
				break
		elif comparison > 0:
			sk, S_matched = S_grouped.next()
		else:
			rk, R_matched = R_grouped.next()

def gqlHJ(writeFunc, requestObj, limit=1000000000):
	"""
	receive set of query strings and join positions from incoming web request and 
	do the hash join in server.
	"""
	from collections import defaultdict
	# bigwrapper client passes string value representation of vector value to requestObj.get_all("gqlQueryStrings") 
	queryStrings = requestObj.get_all("gqlQueryStrings")
	joinPros = requestObj.get_all("gqlJoinPros") 
	logFlagList = requestObj.get_all("logFlag")
	if logFlagList[0] == "on":
		logging.debug("here is gqlHJ function, query Strings from client are %s" % queryStrings)
		logging.debug("here is gqlHJ function, join position is %s" % joinPros)
	# queryStrings[0] e.g "["select * from CITY where POPULATION > 800000", "select * from STATE where SHORTNAME > 'CA' and SHORTNAME = ?"]"
	# eval(queryStrings[0]) e.g ["select * from CITY where POPULATION > 800000", "select * from STATE where SHORTNAME > 'CA' and SHORTNAME = ?"]   
	queryStringsList = eval(queryStrings[0])
	# joinPros[0] e.g "[[0]]"
	# eval(joinPros[0]) e.g [[0]]
	joinProsList = eval(joinPros[0])
	#logging.debug("queryStringsList is %s" % queryStringsList)
	#logging.debug("queryStringsList[0] is %s" % queryStringsList[0])
	###logging.debug("joinProsList is %s" % joinProsList)
	outerTableName = queryStringsList[0].split()[3]
	outerTableModelClass = DbEntity.loadModelClass( outerTableName )
	outerTableProjection = outerTableModelClass.getDbEntity().getDefaultProjection()
	outerJoinAttribute = outerTableProjection[joinProsList[0][0]]
	###logging.debug("outerJoinAttribute is %s" % outerJoinAttribute)
	outerTableQueryResult = db.GqlQuery(queryStringsList[0])
	###logging.debug("queryStringsList[0] is %s" % queryStringsList[0])
	outerTableFetchResults = outerTableQueryResult.fetch(limit)
	outerResType = "||".join( [ DbEntity.getAmosPropertyType( type(outerTableFetchResults[0].properties()[k]) ) for k in outerTableProjection ] )
	innerTableName = queryStringsList[1].split()[3]
	innerTableModelClass = DbEntity.loadModelClass( innerTableName )
	innerTableProjection = innerTableModelClass.getDbEntity().getDefaultProjection()
	innerJoinAttribute = innerTableProjection[joinProsList[0][1]]
	###logging.debug("innerJoinAttribute is %s" % innerJoinAttribute)
	innerTableQueryResult = db.GqlQuery(queryStringsList[1])
	innerTableFetchResults = innerTableQueryResult.fetch(limit)
	innerResType = "||".join( [ DbEntity.getAmosPropertyType( type(innerTableFetchResults[0].properties()[k]) ) for k in innerTableProjection ] )
	#writeFunc( "%s\n" % "Charstring||Charstring||Charstring||Charstring||Integer")
	writeFunc( "%s\n" % (outerResType+"||"+innerResType))
	hashed = defaultdict(list)
	for s in outerTableFetchResults:
		transformed_s = [str( getattr(s,k) ) for k in outerTableProjection ]
		###logging.debug("transformed_s is %s" % transformed_s)
		hashed[joinAttribute(transformed_s, joinProsList[0][0])].append(transformed_s)
		###logging.debug("joinAttribute value is %s" % joinAttribute(transformed_s, joinProsList[0][0]))
	###logging.debug("hash table is %s" % hashed.items())
	for r in innerTableFetchResults:
		transformed_r = [str( getattr(r,k) ) for k in innerTableProjection ]
		for ns in hashed.get(joinAttribute(transformed_r, joinProsList[0][1]),()):
			joinTuple = "||".join(ns + transformed_r)
			writeFunc( "%s\n" % joinTuple)