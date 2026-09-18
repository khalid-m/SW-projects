import logging, traceback, sys

APP_ERROR       = "AppEngine Error"
TIMEOUT_ERROR   = "Timeout Error"
MISSING_INDEX   = "Index Error"
INEQUALITY_ORDER= "Order Error"
QUOTA_ERROR     = "Quota Error"
CURSOR_ERROR    = "Cursor Error"
UNRESUMABLE     = "Unresumable Error"

def sendMsg(type, msg, logFunc=logging.exception):
    logFunc( traceback.format_exc() )
    # return error message
    return "!ERROR!%s:%s" % (type, msg.replace("\n","|") )

def runResumable(func, writeFunc, **params):
    """
    @func: the function to be run according to client's request
    @writeFunc: the output write function
    @params: Dictionary of function parameters
    """
    
    from google.appengine.api.datastore_errors import Error, Timeout, NeedIndexError, BadArgumentError, InternalError
    from google.appengine.runtime import apiproxy_errors, DeadlineExceededError
    
    try:
        # run the given function wrapped by try/catch 
        func(writeFunc, **params)
    
    except Timeout, (strerror,):
        """The datastore operation timed out. This can happen when you attempt to
          put, get, or delete too many entities or an entity with too many properties,
          or if the datastore is overloaded or having trouble.
          """
        writeFunc( sendMsg( TIMEOUT_ERROR, strerror, logging.info ) )
    
    except apiproxy_errors.DeadlineExceededError, (strerror,):
        """Raised by APIProxy calls if the call took too long to respond."""
        writeFunc( sendMsg( TIMEOUT_ERROR, strerror, logging.info ) )
      
    except DeadlineExceededError:
        """Exception raised when the request reaches its overall time limit.
          Not to be confused with runtime.apiproxy_errors.DeadlineExceededError.
          That one is raised when individual API calls take too long.
          """
        writeFunc( sendMsg( TIMEOUT_ERROR, "Request reached its overall time limit", logging.info ) )
    
    except apiproxy_errors.OverQuotaError, (strerror,):
        """Raised by APIProxy calls when they have been blocked due to a lack of
          available quota."""
        writeFunc( sendMsg( QUOTA_ERROR, strerror, logging.info ) )
    
    except CursorException, (strerror,):
        """Cursor unavailable in Memcache or not yet ready"""
        # return error message
        writeFunc( sendMsg( CURSOR_ERROR, strerror, logging.info ) )
    
    except NeedIndexError, (strerror,):
        # return error message
        writeFunc( sendMsg( MISSING_INDEX, strerror) )
    
    except BadArgumentError, (strerror,):
        if(strerror.startswith("First ordering property")):
            # return error message
            writeFunc( sendMsg( INEQUALITY_ORDER, strerror) )
        else:
            # return error message
            writeFunc( sendMsg( APP_ERROR, strerror) )
            
    except InternalError, (strerror,):
        """ Reason unclear, treat as quota error that is wait and resume """
        writeFunc( sendMsg( QUOTA_ERROR, strerror ) )
        
    except Error, (strerror,):
        """Base datastore error type. No reason given. Treat as quota error that is wait and resume"""
        writeFunc( sendMsg( QUOTA_ERROR, strerror ) )
        
    except UnresumableRequest, (strerror,):
        """Query request is unresumable as there is no way to narrow the query down"""
        writeFunc( sendMsg( UNRESUMABLE, strerror ) )
    
    except Exception, (strerror,):
        # return error message
        writeFunc( sendMsg( APP_ERROR, strerror) )

class CursorException(Exception):
  """CursorException on memcache failure."""

class UnresumableRequest(Exception):
    """Query request is unresumable as there is no way to narrow the query down"""
