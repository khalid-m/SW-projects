/*
int is_sqllid2(char *sql)
{
  int flg;
  int length;

  length = strlen(sql);
  if(sql[0]=='<' && sql[length-1] == '>')
    flg = 0;
  else
    flg = 1;
  
  return flg;
}

void is_sqllid(a_callcontext cxt, a_tuple params)
{
  int flg;

  flg = is_sqllid2(getstring(a_getobjectelem(params, 0, FALSE)));
  a_setintelem(params,1,flg,FALSE);
  a_emit(cxt,params,FALSE);
}

void sqltouid(a_callcontext cxt, a_tuple params)
{
  char *uid;
  char *sql;
  int length;
  int csize;
  
  csize=sizeof(char);
  sql = getstring(a_getobjectelem(params, 0, FALSE));
  length = strlen(sql);
  if(is_sqllid2(sql) == 0){
    uid = malloc((length-2) * csize + csize);    
    sql++;
    strncpy(uid,sql,length-2);
    uid[length-2] = '\0';
    a_setstringelem(params, 1, uid, FALSE);    
    free(uid);
    a_emit(cxt, params, FALSE);    
  }
}
*/