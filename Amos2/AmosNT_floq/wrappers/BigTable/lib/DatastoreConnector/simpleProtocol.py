from google.appengine.ext import webapp
from google.appengine.ext.webapp.util import run_wsgi_app
from resumeLayer import runResumable
import logging
from dbEntity import DbEntity
from timeProfiling import *

class GqlQueryHandler(webapp.RequestHandler):
  def post(self):
    from queryProcessing import runQuery
    ###profiler = timeprofile()
    ###profiler.mark()
    runResumable( func = runQuery, writeFunc = self.response.out.write, requestObj = self.request )
    ###logging.debug("time gap is %s" % profiler.timegap())
    ###logging.debug("max diff is %s" % profiler.maxdiff())
	
class InsertQueryHandler(webapp.RequestHandler):
  def post(self):
    from queryProcessing import runInsertQuery
    runResumable( func = runInsertQuery, writeFunc = self.response.out.write, requestObj = self.request )

class DeleteHandler(webapp.RequestHandler):
  def post(self):
    from queryProcessing import runDeleteQuery, resultActionDelete
    runResumable( func = runDeleteQuery, writeFunc = self.response.out.write, requestObj = self.request,
                  action = resultActionDelete )
				  
class GqlNLJHandler(webapp.RequestHandler):
  def post(self):
    from queryProcessing import gqlNLJ
    runResumable( func = gqlNLJ, writeFunc = self.response.out.write, requestObj = self.request )
	
class GqlNLJNewHandler(webapp.RequestHandler):
  def post(self):
    from queryProcessing import gqlNLJNew
    ###profiler = timeprofile()
    ###profiler.mark()
    runResumable( func = gqlNLJNew, writeFunc = self.response.out.write, requestObj = self.request )
    ###logging.debug("time gap is %s" % profiler.timegap())
    ###logging.debug("max diff is %s" % profiler.maxdiff())
	
class GqlSMJHandler(webapp.RequestHandler):
  def post(self):
    from queryProcessing import gqlSMJ
    ###profiler = timeprofile()
    ###profiler.mark()
    gqlSMJ(writeFunc = self.response.out.write, requestObj = self.request )
    ###logging.debug("time gap is %s" % profiler.timegap())
    ###logging.debug("max diff is %s" % profiler.maxdiff())
	
class GqlHJHandler(webapp.RequestHandler):
  def post(self):
    from queryProcessing import gqlHJ
    ###profiler = timeprofile()
    ###profiler.mark()
    runResumable( func = gqlHJ, writeFunc = self.response.out.write, requestObj = self.request )
    ###logging.debug("time gap is %s" % profiler.timegap())
    ###logging.debug("max diff is %s" % profiler.maxdiff())

class GetSchemaHandler(webapp.RequestHandler):
  def post(self):
    from schemaProcessing import getSchema
    runResumable( func = getSchema, writeFunc = self.response.out.write, requestObj = self.request )

class SetSchemaHandler(webapp.RequestHandler):
  def post(self):
    from schemaProcessing import setSchema
    runResumable( func = setSchema, writeFunc = self.response.out.write, requestObj = self.request )
	
class GetStatisticHandler(webapp.RequestHandler):
  def post(self):
	from getStatistic import getStatistic
	runResumable( func = getStatistic, writeFunc = self.response.out.write, requestObj = self.request )

class FlushHandler(webapp.RequestHandler):
  def get(self):
    from google.appengine.api import memcache
    self.response.out.write( memcache.flush_all() )

application = webapp.WSGIApplication(
                                     [
                                      ('/simpleprotocol/GqlQuery',      GqlQueryHandler),
                                      ('/simpleprotocol/InsertTuple',   InsertQueryHandler),
                                      ('/simpleprotocol/DeleteQuery',   DeleteHandler),
                                      ('/simpleprotocol/gqlNLJ',   GqlNLJHandler),
									  ('/simpleprotocol/gqlNLJNew',   GqlNLJNewHandler),
									  ('/simpleprotocol/gqlSMJ',   GqlSMJHandler),
									  ('/simpleprotocol/gqlHJ',   GqlHJHandler),
                                      ('/simpleprotocol/setSchema',     SetSchemaHandler),
                                      ('/simpleprotocol/getSchema',     GetSchemaHandler),						  
									  # gathering statistic
                                      ('/simpleprotocol/getStatistic',  GetStatisticHandler),
                                      ('/simpleprotocol/flushMemcache', FlushHandler)
                                      ],
                                     debug=True)

# provide main to enable caching
def main():
    #logging.getLogger().setLevel(logging.WARN)
    logging.getLogger().setLevel(logging.DEBUG)
    run_wsgi_app(application)

if __name__ == "__main__":
    main()
    #from timeit import Timer
    #t = Timer("gqlNLJNew", "logging for execution time");
    #logging.debug("logging for execution time %d:" % t) 	