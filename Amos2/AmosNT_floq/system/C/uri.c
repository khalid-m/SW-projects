/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2005 Johan Petrini, Tore Risch, UDBL
 *
 * Description:  Handling URIs
 * Language:     C
 * ===========================================================================
 * $Log: uri.c,v $
 * Revision 1.45  2014/01/12 16:28:24  torer
 * Apple cc v5.0 safe C code
 *
 * Revision 1.44  2013/08/30 19:20:23  silvias
 * decode_key allows reals as primary keys
 *
 * Revision 1.43  2011/04/14 08:24:18  torer
 * two off
 *
 * Revision 1.42  2011/03/16 13:37:44  silvias
 * decode_keyfn (added case for NIL values)
 *
 * Revision 1.41  2011/02/09 14:03:25  torer
 * New storage type URI
 *
 * Revision 1.40  2010/12/14 17:46:25  torer
 * Removed dead code
 *
 * Revision 1.39  2010/12/14 15:58:52  silvias
 * decode_keyfn edited ( added an "/" after the prefix pre)
 *
 ****************************************************************************/

#include "amos.h"
#include <stdio.h>

/*** Begin SWARD code for invertible rowid function ***/

#define MAX_NUMBER_LENGTH 25 //Maximum length of char array being created 
                             //from a number. 

int rowidErrorID;

//Forward rowid fn
void cbbf(a_callcontext cxt, a_tuple params) 
{
  char *uri;
  char *pre;
  char *str;
  char num[MAX_NUMBER_LENGTH];
  char *pre_tmp;
  char *pre_tmp_storage;
  char *uri_tmp_storage;
  int csize;
  int strflg;
  char buff[1];

  //Memory corrupt?
  //  a_setdemon(2822960,51843920);
  strflg = 0;
  csize = sizeof(char);

  //Add a '/' to pre. Defined by user as part of implementing the rowid fn.
  a_getstringelem(params, 0, buff, sizeof(buff), FALSE); //checking type
  pre_tmp = getstring(a_getobjectelem(params, 0, FALSE));

  pre_tmp_storage = malloc(strlen(pre_tmp) * csize + csize + csize);
  pre = strncat(strcpy(pre_tmp_storage,pre_tmp),"/",1);

  //The semantics:
  //1. If integer or real, data is printed to array of char, num, with fixed 
  //   size (could be dynamically allocated).
  //2. If not 1 or 2, data is treated as a charstring str
  switch(a_getelemtype(params, 1, FALSE)){
  case INTEGERTYPE:  
    sprintf(num, "%i", getinteger(a_getobjectelem(params, 1, FALSE)));    
    break;
  case REALTYPE:
    sprintf(num, "%.2f", getreal(a_getobjectelem(params, 1, FALSE)));    
    break;
  default:
    a_getstringelem(params, 1, buff, sizeof(buff), FALSE); // type check
    str = getstring(a_getobjectelem(params, 1, FALSE));
    strflg = 1;
    break;
  }
  
  if(strlen(pre) - 1 > 0 && strlen(str) > 0){ 
 
    if(strflg == 1){
      uri_tmp_storage = malloc(strlen(pre) * csize + strlen(str) 
			       * csize + csize);  
      uri = strcat(strcpy(uri_tmp_storage, pre), str);  
    }else{
      uri_tmp_storage = malloc(strlen(pre) * csize + strlen(num) 
			       * csize + csize);  
      uri = strcat(strcpy(uri_tmp_storage, pre), num);     
    }
  }

  {unwind_protect_begin;
    a_setstringelem(params, 2, uri, FALSE);
    a_emit(cxt, params, FALSE); 

    unwind_protect_catch;
    free(uri_tmp_storage);
    free(pre_tmp_storage);
    unwind_protect_end;}

}

//Inverse rowid fn
void cffb(a_callcontext cxt, a_tuple params) 
{
  char *uri;
  char *data;
  char pre[1000];
  int csize;
  char buff[10];
  char* dl;
  int ul;
  int datal;
  int prel;
  int dll;

  csize = sizeof(char);
  a_getstringelem(params, 2, buff, sizeof(buff), FALSE); //type check
  uri = getstring(a_getobjectelem(params, 2, FALSE));
  ul = strlen(uri);
  dl = strrchr(uri,47);  

  if(dl != NULL){

    dll = strlen(dl);
    datal = dll - 1;
    prel = ul - dll;

    if(prel > 0 && datal > 0){

      data = dl + csize;
      strncpy(pre,uri,prel);
      pre[prel]='\0';   

      //The semantics:
      //0 for neither integer or real
      //1 for integer
      //2 for real
      switch(a_isnumeric(data)){
      case 0:
	a_setstringelem(params, 1, data, FALSE);
	break;
      case 1:
	a_setintelem(params, 1, atoi(data), FALSE);
	break;
      case 2:
	a_setdoubleelem(params, 1, atof(data), FALSE); 
	break;
      }
      a_setstringelem(params, 0, pre, FALSE);
      a_emit(cxt, params, FALSE);
      
    }
  }  
}

/*** End of SWARD code ***/

oidtype decode_keyfn(bindtype env, oidtype prefix, oidtype v)
{
  struct arraycell *dv;
  oidtype res;
  int len=0, pos=0, i, plen;
  struct stringcell *dstr;
  char *resstr, *tstr;

  OfType(prefix, STRINGTYPE, env);
  OfType(v, ARRAYTYPE, env);
  plen = strlen(getstring(prefix));
  dv = dr(v, arraycell);
  for(i=0;i<dv->size;i++)
    {
      dstr = dr(dv->cont[i],stringcell);
      switch(typetag(dstr))
	{
	case STRINGTYPE: 
	  len = len + dstringlen(dstr);
	  break;
        case INTEGERTYPE:
	  {
            char *istr = 
	      IntegerToString(((struct integercell *)dstr)->integer);
            len = len + strlen(istr);
            break;
          }
	  //TO DO: Quick fix, it should be made better
	  case REALTYPE:
	  {
			int val =(int)dstr;
            char *istr = 
	       IntegerToString(((struct integercell *)val)->integer);
            len = len + strlen(istr);
            break;
          }
	
	case SYMBOLTYPE:
	  return nil;
	  break;
        default: 
          return lerror(ILLEGAL_ARGUMENT, dv->cont[i], env);
	}
    }
  res = new_string(plen+len+3,"");
  resstr = getstring(res);
  memcpy(resstr, getstring(prefix), plen);
  pos = plen;
  resstr[pos]='/';
  pos=pos + 1;
  for(i=0;i<dv->size;i++)
    {
      dstr = dr(dv->cont[i],stringcell);
      switch(typetag(dstr))
	{
	case STRINGTYPE: 
          tstr = dgetstring(dstr);
	  break;
        case INTEGERTYPE:
	  {
            tstr = IntegerToString(((struct integercell *)dstr)->integer);
            break;
          }
	  	  //TO DO: Quick fix, it should be made better
	   case REALTYPE:
	  {
			int val =(int)dstr;
			 tstr = IntegerToString(((struct integercell *)val)->integer);
            break;

	  }
	case SYMBOLTYPE:
	  return nil;
	  break;
        default: 
          return lerror(ILLEGAL_ARGUMENT, dv->cont[i], env);
	}
      resstr[pos] = '_';
      len = strlen(tstr);
      memcpy(resstr+pos+1, tstr, len);
      pos = pos + len + 1;
    }
  resstr[pos]='\0';
  return res;
}

oidtype decode_keyBBF(a_callcontext cxt)
{
   oidtype pre = a_arg(cxt, 1);
   oidtype k = a_arg(cxt,2);

   OfType(pre, STRINGTYPE, cxt->env);
   OfType(k, ARRAYTYPE, cxt->env);
   a_bind(cxt, 3, decode_keyfn(cxt->env, pre, k));
   a_result(cxt);
   return nil;
}

void register_old_rdf(void) 
{
  /* SWARD's invertible rowid function */
  a_extfunction("CBBF",cbbf);
  a_extfunction("CFFB",cffb);
  rowidErrorID = a_register_error("rowID error");

  extfunction2("decode-key", decode_keyfn);
  a_extimpl("decode-key--+", decode_keyBBF);
}
