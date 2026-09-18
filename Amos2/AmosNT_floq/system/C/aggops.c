/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2005 Tore Risch, Erik Zeitler, UDBL
 * $RCSfile: aggops.c,v $
 * $Revision: 1.20 $ $Date: 2013/11/20 22:15:31 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Aggregation operators in C
 *
 ****************************************************************************/

#include "amos.h"
#include "storagetypes.h"

/************************  makebag ******************************************/
/* Implements ObjectLog predicate
   makebag(fn,a1,...,an,b)
   It creates a transient bag object, b, represented as a
   'stream generator' of OSQL function fn applied to arguments a1,...,an.
*/

oidtype make_bag(a_callcontext cxt)
{
  oidtype bfn = a_arg(cxt, 1);
  int sz = a_arity(cxt), i;
  oidtype bt;
  oidtype types=nil;
  static oidtype arg_bagtype=NULLH,  bagtype=NULLH;

  if(arg_bagtype==NULLH)
    {
      arg_bagtype = mksymbol("arg-bagtype");
      bagtype = mksymbol("bagtype");
    }
  bt = getobjectfn(varstack, bfn, bagtype);
  if(bt==nil) bt = call_lisp(arg_bagtype, varstack, 1, bfn);
  for(i=sz-2;i>0;i--)
    {
      types = cons(a_arg(cxt,i+1),types);
    }
  a_bind(cxt, sz, make_generatorfn(varstack, bt, bfn, types));
  a_result(cxt);
  return nil;
}

/*************************  count *******************************************/

oidtype countBFmapper(a_callcontext cxt, int arity, oidtype *restpl, void *xa)
{
  int *cnt = (int *)xa;
  (*cnt)++;
  return nil;
}

oidtype countBF(a_callcontext cxt)
{
  int cnt=0;
  oidtype bag = a_arg(cxt,1);

  a_mapbag(cxt, bag, countBFmapper, (void *)&cnt);
  a_bind(cxt,2,mkinteger(cnt));
  a_result(cxt);
  return nil;
}

struct countclosure
{
  int fail;
  int cnt;
  int limit;
};

oidtype countBBmapper(a_callcontext cxt, int arity, oidtype *restpl, void *xa)
{
  struct countclosure *cc = (struct countclosure *)xa;

  cc->cnt++;
  if(cc->cnt > cc->limit)
    {
      cc->fail = TRUE;
      return resetfn(cxt->env);
    }
  else return nil;
}

oidtype countBB(a_callcontext cxt)
{
  struct countclosure cc;
  oidtype bag = a_arg(cxt,1);
  oidtype limit = a_arg(cxt, 2);

  cc.fail = FALSE;
  cc.cnt = 0;
  IntoInteger(limit,cc.limit,a_env(cxt));
  if (cc.limit<0) return nil;
  {unwind_protect_begin;
  a_mapbag(cxt, bag, countBBmapper, (void *)&cc);
  unwind_protect_catch;
  if(cc.fail) return nil;
  unwind_protect_end;}
  if(cc.limit==cc.cnt) a_result(cxt);
  return nil;
}

/*************************  sum  *******************************************/
struct sumclosure
{
  int isum;
  double dsum;
  int realflg;
};


oidtype sumBFmapper(a_callcontext cxt, int arity, oidtype *restpl, void *xa)
{
  struct sumclosure *sc;
  oidtype x = restpl[0];

  sc = (struct sumclosure *)xa;

  if(integerp(x))
    {
      long i = getinteger(x);

      if(PLUS_OVERFLOW(i,sc->isum))
	{
	  sc->dsum = sc->dsum + i;
	  sc->realflg = TRUE; 
	}
      else sc->isum = sc->isum + i;
    }
  else if(realp(x))
    {
      sc->dsum = sc->dsum + getreal(x);
      sc->realflg = TRUE;
    }
  else return nil;
  return nil;
}

oidtype sumBF(a_callcontext cxt)
{
  struct sumclosure sc;
  oidtype bag = a_arg(cxt,1);

  sc.isum=0;
  sc.dsum=0.0;
  sc.realflg=FALSE;
  a_mapbag(cxt, bag, sumBFmapper, (void *)&sc);
  if(sc.realflg)
  {
    a_bind(cxt,2,mkreal(sc.isum+sc.dsum));
  }
  else a_bind(cxt,2,mkinteger(sc.isum));
  a_result(cxt);
  return nil;
}

/************************** statistics ******************************/

oidtype vavgstdevBFF(a_callcontext cxt) 
{
  /* Compute average and standard deviation. 
     - Empty vectors  -> <nil,nil>
     - Only one value -> <avg,nil>
     - More than one value -> <avg,stdev> */
  oidtype v = nil, el=nil;
  double sum=0.0, sum2=0.0, elem, cnt, oneovercnt, n_oneovercnt;
  int count=0, i;
	
  v = a_arg(cxt,1);
  count = a_arraysize(v);
  if (0 == count) 
    {
      a_bind(cxt, 2, nil);
      a_bind(cxt, 3, nil);
      a_result(cxt);
    } 
  else 
    {		
      cnt = (double) count;
      oneovercnt = 1.0/cnt;
      if (count > 1) n_oneovercnt = 1.0/(cnt-1.0);
      for (i=0; i<count; i++) 
	{
	  el = a_elt(v,i);
	  if (realp(el)) elem = getreal(el);
	  else if (integerp(el)) elem = (double)getinteger(el);
	  sum += elem;
	  sum2 += elem*elem;
	}
      a_bind(cxt, 2, mkreal(sum*oneovercnt));
      if (count > 1) 
	{
	  a_bind(cxt, 3, 
		 mkreal(sqrt((sum2-sum*sum*oneovercnt)*n_oneovercnt)));
	} 
      else 
	{
	  a_bind(cxt, 3, nil);
	}
      a_result(cxt);
    }
  return nil;
}
/********************** partial aggregate functions **************************/
oidtype someBmapper(a_callcontext cxt, int arity, oidtype *restpl, void *xa)
{
  a_map_done(cxt,t);
  return nil;
}

oidtype someB(a_callcontext cxt)
{
  if(nil!=a_mapbag(cxt, a_arg(cxt,1), someBmapper, NULL)) a_result(cxt);
  return nil;
}

oidtype notanyB(a_callcontext cxt)
{
  if(nil==a_mapbag(cxt, a_arg(cxt,1), someBmapper, NULL)) a_result(cxt);
  return nil;
}

oidtype firstBmapper(a_callcontext cxt, int arity, oidtype *restpl, void *xa)
{
  int i;

  for(i=0;i<arity;i++)
    a_bind(cxt,i+2,restpl[i]);
  a_result(cxt);
  a_map_done(cxt, t);
  return nil;
}

oidtype firstBF(a_callcontext cxt)
{
  a_mapbag(cxt, a_arg(cxt, 1), firstBmapper, NULL);
  return nil;
}

struct sectionBBFvars
{
  int cnt;
  int start;
  int stop;
};

oidtype sectionBBBFmapper(a_callcontext cxt, int arity, oidtype *restpl, 
                          void *xa)
{
  struct sectionBBFvars *vars = (struct sectionBBFvars *)xa;
  int i;

  if(vars->cnt >= vars->stop) a_map_done(cxt, t);
  (vars->cnt)++;
  if(vars->cnt < vars->start) return nil;
  for(i=0; i<arity; i++)
    {
      a_bind(cxt, i+4, restpl[i]);
    }
  a_result(cxt);
  return nil;
}

oidtype sectionBBBF(a_callcontext cxt)
{
  oidtype b = a_arg(cxt, 1);
  oidtype start = a_arg(cxt, 2);
  oidtype stop = a_arg(cxt, 3);
  struct sectionBBFvars vars;

  vars.cnt = 0;
  IntoInteger(start,vars.start,cxt->env);
  IntoInteger(stop,vars.stop,cxt->env);
  a_mapbag(cxt, b, sectionBBBFmapper, (void *)&vars);
  return nil;
}

oidtype remove_nullBFmapper(a_callcontext cxt, int arity, oidtype *restpl, 
                            void *xa)
{
  int i;

  for(i=0; i<arity; i++)
    {
      if(restpl[i]==nil) return nil;
    }
  for(i=0; i<arity; i++)
    {
      a_bind(cxt, i+2, restpl[i]);
    }
  a_result(cxt);
  return nil;
}

oidtype remove_nullBF(a_callcontext cxt)
{
  oidtype b = a_arg(cxt, 1);

  a_mapbag(cxt, b, remove_nullBFmapper, NULL);
  return nil;
}

/************************** symbol registration ******************************/
void register_aggops(void)
{
  a_extimpl("make-bag",make_bag);
  a_extimpl("count-+",countBF);
  a_extimpl("count--",countBB);
  a_extimpl("sum-+",sumBF);
  a_extimpl("vavgstdevBFF", vavgstdevBFF);
  a_extimpl("some-", someB);
  a_extimpl("notany-", notanyB);
  a_extimpl("first-+", firstBF);
  a_extimpl("section---+", sectionBBBF);
  a_extimpl("remove-null-+", remove_nullBF);
}
