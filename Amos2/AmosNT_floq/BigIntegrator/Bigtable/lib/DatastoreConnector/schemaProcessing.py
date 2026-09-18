from dbEntity import DbEntity
from google.appengine.ext.db import stats
import pickle
import logging

#App engine response:
#App Engine collects all of the data the request handler script writes to the standard output stream, then waits for the script to exit. 
#When the script exits, all of the output data is sent to the user.

def getSchema(writeFunc, requestObj):
    # load tables from datastore
	entities = DbEntity.all()
    
    # send type information as the first line in the standard output stream
	writeFunc( "Charstring||Charstring||Charstring\n" )

    #entities, e.g {CITY, STATE}
	for entity in entities:
		if entity.parentEntity == None:
			parentName = ""
		else:
			parentName = entity.parentEntity.name
        # get table size
		kind_stats = stats.KindStat().all().filter("kind_name =", entity.name).get()
        #count = entity.count()		
		if kind_stats == None:		
			count = 0
		else:
			count = kind_stats.count

        # send entity name, parent entity, number of rows of the entity to the standard output stream 
		if parentName == "":
			writeFunc( "%s||%s||%s\n" % (entity.name, str(1), str(count)) )
		else:
			writeFunc( "%s||%s||%s\n" % (entity.name, parentName, str(count)) )

        # e.g cMetadata is equal to entity.getPropDict()
        # {'state': ('charstring', {}, 'cityName'), 'cityname': ('charstring', {}, 'cityNa
        # me'), 'population': ('charstring', {}, 'cityName')}
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
			# send attribute name, type and an integer (indicating whether it is a key attribute) to the standard output stream
			writeFunc( "%s||%s||%s\n" % (key, DbEntity.getAmosPropertyType(propTpl[0]), propTpl[2]) )
			#writeFunc( "%s||%s||%s\n" % (entity.name, key, str(600)) )
            # (state, "charstring", "cityName")
            # (cityname, "charstring", "cityName")
            # (population, "charstring", "cityName")
        
        # write empty line to mark end of entity
		writeFunc("\n")
        
def setSchema(writeFunc, requestObj):
    from google.appengine.ext.db import Blob
    
    # get metadata from client
    typeName    = requestObj.get("entity").encode('utf8')
    parentType  = requestObj.get("parentEntity").encode('utf8')
    keyMembers  = requestObj.get("keyList").encode('utf8').split(",")
    properties  = requestObj.get_all("property")
    types       = requestObj.get_all("type")
    
    # debug message
    # logging.debug("Creating type %s(%s), key: %s, properties: %s, types: %s" % (cName,parentCName,keyList,properties,types))
    # collect class metadata
    cMetadata = {}
	# zip( properties, types ) e.g [('cityname', string), ('state', string), ('population', integer)]	
    for propName, propType in zip( properties, types ):
        propName = propName.encode('utf8')
        try:
            keyProp = keyMembers.index(propName)
        except Exception:
            keyProp = None
        # each entry in propDict is a triple (db.Property,params,keyIndex/None)
        # e.g cMetadata
        # {'state': ('string', {}, 'cityName'), 'cityname': ('string', {}, 'cityNa
        # me'), 'population': ('integer', {}, 'cityName')}
        cMetadata[propName] = ( DbEntity.getModelPropertyType( propType ), {}, keyProp )        
    
    # check inheritance
    if parentType != "":
        # load super class and adapt
        parentType = DbEntity.loadModelClass(parentType).getDbEntity()
        parentType.isSubclassed = True
        newType = DbEntity( key_name=typeName, name=typeName, parentEntity=parentType, structure=Blob(pickle.dumps(cMetadata)) )
        # insert or update both, new class and superclass
        insertList = [parentType._populate_internal_entity(), newType._populate_internal_entity()]
        from google.appengine.api.datastore import Put
        Put(insertList)
    else:
        # normal insert
        newType = DbEntity( key_name=typeName, name=typeName, structure=Blob(pickle.dumps(cMetadata)) )
        newType.put()
    
    writeFunc( "Boolean\ntrue" )
