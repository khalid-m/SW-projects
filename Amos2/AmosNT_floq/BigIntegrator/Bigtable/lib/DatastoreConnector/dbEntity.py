from google.appengine.ext import db
from google.appengine.api import memcache
import pickle, logging

"""This module provides functionality to manage and access the ODDSE data dictionary.
DbEntity objects thereby describe entity types stored in the Datastore.
"""

class StaticDbEntityModel():
    """This class defines static methods for DbEntity."""
    
    types ={
            "BOOLEAN":    db.BooleanProperty,
            "STRING":     db.StringProperty,
            "CHARSTRING": db.StringProperty,   
            "INTEGER":    db.IntegerProperty,
            "REAL":       db.FloatProperty,
            "DOUBLE":     db.FloatProperty,
            "FLOAT":      db.FloatProperty,
            "LONG":       db.IntegerProperty,
            "SHORT":      db.IntegerProperty
        }
    
    amosTypes = {
            db.BooleanProperty  :   "Boolean",
            db.StringProperty   :   "Charstring",
            db.FloatProperty    :   "Real",
            db.IntegerProperty  :   "Integer",
            db.ReferenceProperty:   "Charstring"
        }
    
    # @staticmethod
    # def loadModelClass( typeName ):
        # # check from globals (1st cache level)
        # modelClass = globals().get( typeName )
        # if modelClass != None:
            # logging.debug("Found Class %s in GLOBALS (1st cache level)" % typeName)
        # else:
            # modelClass = StaticDbEntityModel._load( typeName ).toClass()
            # globals()[typeName] = modelClass
        # return  modelClass
	
    @staticmethod
    def loadModelClass( typeName ):
        return  StaticDbEntityModel._load( typeName ).toClass()

    # @staticmethod
    # def _load( typeName ):
        # """Load the entity type {cName} from the memcache or if necessary from the Datastore itself.
        
        # @type typeName: Basestring 
        # @param typeName: the type name to load
        # @rtype: DbEntity
        # @return: the requested entity type
        # """
        
        # # check from memcache (2nd cache level)
        # entityType = memcache.get("E_%s" % typeName)
        # if entityType != None:
            # logging.debug( "Found DbEntity %s in Memcache (2nd cache level)" % typeName )
        # else:
            # logging.debug( "Loading DbEntity %s from Datastore (cache failure)" % typeName )
            # # try to load from Datastore
            # entityType = DbEntity.get_by_key_name( typeName )
            # if entityType==None:
                # raise Exception, "Unknown entity '%s'! Unable to load entity from datastore." % typeName
            # # save entity to memcache, time: 1 day
            # memcache.set( "E_%s" % typeName, entityType, time=86400)
        
        # return entityType
		
    @staticmethod
    def _load( typeName ):
        """Load the entity type from the Datastore.
        @type typeName: string 
        @param typeName: the type name to load
        @rtype: DbEntity
        @return: the requested entity type
        """
        # load from Datastore
        entityType = DbEntity.get_by_key_name( typeName )
        if entityType==None:
            raise Exception, "Unknown entity '%s'! Unable to load entity from datastore." % typeName
        return entityType

    @staticmethod
    def reloadOnAttributeError( errorMsg ):
        """Reload the class representation if access fails. To retrieve the 
        class name the error message is parsed.
        
        @type errorMsg: Basestring 
        @param errorMsg: AttributeError message
        @rtype: Type
        @return: the requested class
        """
        from re import search
        # use regex to get typename from error msg
        res = search("'(\w+)'$", errorMsg)
        return StaticDbEntityModel.loadModelClass( res.group(1) )
    
    @staticmethod
    def getModelPropertyType( typeStr ):
        """Map an Amos2 type to the appropriate Datastore type.
        
        @type typeStr: Basestring
        @param typeStr: an Amos2 type name
        @rtype: a propertied class (subclass of db.Property)
        @return: the appropriate Datastore type
        """   
        typeStr = typeStr[ typeStr.rfind(".")+1: ].upper()
        try:
            return StaticDbEntityModel.types[typeStr]
        except Exception, (strerror,):
            raise Exception, "Unknown type '%s', couldn't find matching PropertyType!" % typeStr
    
    @staticmethod
    def getAmosPropertyType( propType ):
        """Map a Datastore type to the appropriate Amos2 type.
        
        @type propType: a propertied class (subclass of db.Property)
        @param propType: a Datastore type
        @rtype: Basestring
        @return: the appropriate Amos2 type name
        """ 
        try:
            return StaticDbEntityModel.amosTypes[propType]
        except Exception, (strerror,):
            raise Exception, "Unknown type '%s', couldn't find matching Amos type!" % propType

class DbEntity( db.Model, StaticDbEntityModel ):
    """The type DbEntity describes elements of the internal data dictionary used in bigwrapper.
    It supports inheritance and composite keys.
    For optimization purpose DbEntity objects are cached in the AppEngine's Memcache for
    fast access."""
    
    name = db.StringProperty(required=True)
    parentEntity = db.SelfReference()
    structure = db.BlobProperty()
    isSubclassed = db.BooleanProperty(default=False)
    # unpickled property dictionary
    _propDict = None
    _keyMembers = None
        
    def createEntity(self, ModelClass, **kwds):
        """This factory creates an entity based on the given metadata.
        This is done using the internal class representation of this type.
        Keys are added automatically, in case of a composite key a additional
        column for a surrogate key is added.
        
        @rtype: DbEntity.toClass()
        @return: a instance of the class representation of this DbEntity
        """
        
        try:
            # if surrogate key required, set value
            if len( self.getKeyMembers() ) > 1:
                kwds["SURROGATE_KEY"] = "%".join( [ str( kwds[k] ) for k in self.getKeyMembers() ])
                kwds["key_name"] = "%s-%s" % (self.name, kwds["SURROGATE_KEY"] )
            else:
                kwds["key_name"] = "%s-%s" % (self.name, kwds[self.getKeyMembers()[0] ] )
            
            # check if key already exists
            # if self.toClass().get_by_key_name(kwds["key_name"]) != None:
            #   raise Exception, "Key '%s' already exists!" % kwds["key_name"]
            
            # create using default constructor    
            return ModelClass(**kwds)
        except:
            logging.warning("Couldn't process entity properties: "+kwds.__str__())
            raise
    
    def getDsKey(self):
        """Get the internal DataStore key column. This is either a single 
        key column or in case of a composite key a surrogate key column.
        
        @rtype: Basestring
        @return: the key column name
        """
        if len(self.getKeyMembers()) == 1:
            return self.getKeyMembers()[0]
        else:
            return "SURROGATE_KEY"
    
    def toClass(self):
        """Convert the type metadata of this DbEntity instance to a class 
        subtyping db.Model. Such a class provides the same functionality 
        such as traditional classes, e.g.:
        
            class Customer(db.Model):
                name = db.StringProperty(required=True)
                age = db.IntegerProperty()
        
        The returned ModelClass provides two additional instance function giving access to it's DbEntity:
            
            def getDbEntity(self):
                return self._dbEntity
            
            def createInstance(self, **kwds):
                return self._dbEntity.createEntity(self, **kwds)
        
        @rtype: Type
        @return: a entity class
        """
        
        # convert name
        typeName = self.name.encode("ASCII")
        
        # load properties
        self.loadPropDict()
        # create class dictionary
        classDict = dict( [ ( key, propTpl[0](**propTpl[1]) ) for key, propTpl in self._propDict.iteritems() ] )

        # load parent class
        if self.parentEntity != None:
            parentClass = self.parentEntity.toClass()
            # combine dictionaries if inherited
            self.getPropDict().update( self.parentEntity.getPropDict() )
        elif self.isSubclassed:
            from google.appengine.ext.db import polymodel
            parentClass = polymodel.PolyModel
        else:
            parentClass = db.Model           
        
        # check for composite key
        if len(self.getKeyMembers()) > 1:
            classDict["SURROGATE_KEY"] = db.StringProperty(required=True)
        
        # create class using type and set DbEntity reference
        entityClass = type( typeName, (parentClass, ), classDict)
        entityClass._dbEntity = self
        from types import MethodType
        # add instance method to access DbEntity
        entityClass.getDbEntity = MethodType(lambda self: self._dbEntity, entityClass)
        # add instance method to create new instances
        entityClass.createInstance = MethodType(lambda self, **kwds: self._dbEntity.createEntity(self, **kwds), entityClass)
        
        # make globally available
        globals()[typeName] = entityClass
        # return Model class
        return entityClass
    
    def getDefaultProjection(self):
        """Get the default projection of this type consisting of all properties.
        
        @rtype: List
        @return: a list of all columns
        """
        
        self.loadPropDict()
        return self._propDict.keys()

    def getKeyMembers(self):
        """Get the key of this type.
        
        @rtype: List
        @return: a list of all key members
        """
        
        if self._keyMembers == None:
            self.loadPropDict()
            # select key members from dictionary
            self._keyMembers = [ key for key, propTpl in self._propDict.iteritems() if propTpl[2] != None ]
            # get key order
            self._keyMembers.sort( key = lambda k: self._propDict[k][2] )
            
        if(len(self._keyMembers)==0):
            logging.warning("No key defined in property dictionary: "+self._propDict.__str__())
        return self._keyMembers
    
    def loadPropDict(self):
        """Unprickle the property dictionary and store it internally."""
        
        if self._propDict == None:
            self._propDict = pickle.loads( self.structure )
            #self._propDict = self.structure 
            #while not isinstance(self._propDict, dict):
            #    # unpickle property dictionary
            #    self._propDict = pickle.loads( self._propDict )
            #
            #self.structure = db.Blob( pickle.dumps( self._propDict ) )
            #self.put()
    
    def getPropDict(self):
        """Get the property dictionary describing the properties of this type.
        The dictionary is of the following structure:
            { column: (db.Property, **params, keyIndex | None ) }
        
        @rtype: Dict
        @return: the dictionary of properties
        """
        
        self.loadPropDict()
        return self._propDict