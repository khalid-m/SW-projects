/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 1999,2011 Tore Risch, UDBL
 * $RCSfile: BT.c,v $
 * $Revision: 1.2 $ $Date: 2012/01/16 13:08:44 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Stand alone memory B-tree implementation
 * ===========================================================================
 * $Log: BT.c,v $
 * Revision 1.2  2012/01/16 13:08:44  sobso953
 * tests removed from the begining of the executable
 *
 * Revision 1.1  2011/08/24 05:43:01  soba1559
 * Adding SCSQ-trie visual C project and source code files.
 *
 *
 * Revision 2.0  2011/08/23 23:36:00  sobhanb 
 * B-tree deletion added
 *
 * Revision 1.1  2011/04/15 08:20:41  torer
 * Stand-alone main memory B-tree
 *
 ****************************************************************************/

#include "BT.h"

int nodecnt = 0;

int compareBTdata(BTdata a,BTdata b)
{
  if(a<b) return -1;
  if(a>b) return 1;
  return 0;
}

BThead *newBThead(void)
{
  BThead *res = malloc(sizeof(*res));

  res->root = NULL;
  res->elements = 0;
  res->items=0;
  return res;
}


BTnode *newBTnode (void)
{
  BTnode *res = malloc(sizeof(*res));
  int i;

  res->m = 0;
  res->p0 = NULL;
  for(i=0; i<2*HALF_SIZE; i++)
    {
      res->e[i].p = NULL;
      //res->e[i].data.deleted = TRUE;
    }
  nodecnt++;
  return res;
}

int freeBTnode(BTnode *node)
{
  int i, cnt=0;

  if(node->p0 != NULL) cnt = cnt + freeBTnode(node->p0);
  for(i=0;i<node->m;i++)
    {
      BTitem bi = node->e[i];
	  BTitem* bip=&(node->e[i]);
	  
	  //added by Sobhan: free (in DB image) the underlying Amos object.
	  //printf("bi.data.value:%d \n",bip->data.value);
	  //tmp=bi.data.value;
	  //a_free(bip->data.value);
	  /////////////////////
	  if(bi.p!=NULL) 
          cnt = cnt + freeBTnode(bi.p);
      bi.p = NULL;
    }
  free(node);
  nodecnt--;
  return cnt+1;
}

int freeBThead(BThead *bt)
{
  int cnt;

  if(bt->root == NULL) return 0;
  cnt = freeBTnode(bt->root);
  free(bt);
  return cnt;  
}

BTitem *BTinsert1(BThead *bh, BTdata k, BTdata v, BTnode *bn, int *h, 
                  BTitem *ui, BTcomparer fn)
     /* Search key k in B-tree with root bn; if found, return BTitem.
	Otherwise insert new item with key k. If an item is passed up,
	assign it to ui. h is flag indicating that tree has become higher */
{
  register unsigned int i, L, R;
  BTnode *newbn;
  BTitem u, *res;

  if(bn == NULL)
    {
      *h = TRUE; /* Not in tree */
      ui->data.key = k;
      ui->data.value = v;
//      ui->data.deleted = FALSE;
      bh->elements++;
      ui->p = NULL;
      (bh->items)++;
      return NULL;
    }
  else
    {
      register BTdata d;

      L = 1;
      R = bn->m + 1;  /* Binary search */
      while(L<R)
	{
          i = (L+R)/2;
          d = bn->e[i-1].data.key;
          if(COMPARE_BITEMS(d,k,fn) <= 0) L = i + 1;
          else R = i;
	}
      R--;
      d = bn->e[R-1].data.key;
      if(R>0 && COMPARE_BITEMS(d,k,fn)==0)
	{  
          /* Update old value */
          res = &(bn->e[R-1]);
          res->data.value=v;
		/*
		if(res->data.deleted)
	    {
	      res->data.deleted=FALSE;
	      bh->elements++;
        }
		*/
          *h = FALSE;
          return res;
	}
      else
	{
          /* BTitem not in this node */
          if(R == 0) res = BTinsert1(bh, k, v, bn->p0, h, &u, fn);
          else res = BTinsert1(bh, k, v, bn->e[R-1].p, h, &u, fn);
          if(*h) /* u is new item to insert */
	    {
	      /* Insert u to the right of e[R-1] */
	      if(bn->m < 2*HALF_SIZE)
		{
		  *h = FALSE; /* Move new item to bn->e[R] */
		  bn->m++;
		  memmove(&(bn->e[R+1]),&(bn->e[R]),
                          sizeof(BTitem)*(bn->m-R-1));
		  bn->e[R] = u; /* Assign BTitem */
		  if(res == NULL) res = &(bn->e[R]);
		}
	      else
		{
		  newbn = newBTnode();  /* overflow */
		  /* Split bn into bn, newbn and assign the middle 
                     BTitem to ui */
		  if(R <= HALF_SIZE)
		    {
		      if(R == HALF_SIZE) *ui = u;  /* Assign BTitem */
		      else
			{
			  *ui = bn->e[HALF_SIZE-1];
			  memmove(&(bn->e[R+1]),
				  &(bn->e[R]),sizeof(BTitem)*(HALF_SIZE-R-1));
			  bn->e[R] = u; /* Assign BTitem */
			  if(res == NULL)res = &(bn->e[R]);
			}
		      memcpy(newbn->e,
			     &(bn->e[HALF_SIZE]),
			     sizeof(BTitem)*HALF_SIZE);
		    }
		  else
		    {
		      /* Insert in right half */
		      R = R - HALF_SIZE;
		      *ui = bn->e[HALF_SIZE];
		      memcpy(newbn->e, 
			     &(bn->e[1+HALF_SIZE]),
			     sizeof(BTitem)*(R-1));
		      newbn->e[R-1] = u; /* Assign BTitem */
		      if(res == NULL) res = &(newbn->e[R-1]);
		      memcpy(&(newbn->e[R]),
			     &(bn->e[R+HALF_SIZE]),
			     sizeof(BTitem)*(HALF_SIZE-R));
		    }
		  bn->m = HALF_SIZE;
		  newbn->m = HALF_SIZE;
		  newbn->p0 = ui->p;
		  ui->p = newbn;
		}
	    }
          return res;
	}
    }
}

BTitem *BTinsert(BThead *bh, BTdata  k, BTdata v, BTcomparer fn)
{
  BTitem ui, *res;
  int flag;
  BTnode *root, *q;

  root = bh->root;
  res = BTinsert1(bh, k, v, root, &flag, &ui, fn);
  if(flag) /* Tree became higher */
    {
      q = root;
      root = newBTnode();
      root->m = 1;
      root->p0 = q;
      root->e[0] = ui;
      bh->root = root;
      if(res == NULL) return &(root->e[0]);
    }
  return res;
}

//handels the aftermath of deletion in case a node underflows
void BTunderflow(BTnode* c, BTnode* a, int s, int* h,BThead* bh)
{
	/*
	a = underflowing node
	c = ancestor node
	s = index of deleted entry in c
	h = underflow flag, set to 1 if underflow propagates upward
	bh= root node of b-tree
	*/
	BTnode* b=NULL;
	int i=0,k=0;
	int N=HALF_SIZE;

	/*h & (a.m = N-1) & (c.e[s-1].p = a) */

	if (s<c->m)/*b := page to the right of a*/
	{
		b=c->e[s].p; 
		k= (b->m-N+1)/2;/*k = nof items available on page b*/
		a->e[N-1]=c->e[s]; a->e[N-1].p=b->p0;//move one element from c to a
		if(k>0)/*balance by moving k-1 items from b to a, one from b to c*/
		{
			memcpy(&a->e[N],&b->e[0],(k-1)*sizeof(BTitem));//moving k-1 items from b to a
			c->e[s]=b->e[k-1]; b->p0= c->e[s].p;//one from b to c
			c->e[s].p= b; b->m=b->m-k;
			memmove(&b->e[0],&b->e[k],b->m*sizeof(BTitem));//Left shift elements of b
			a->m=N-1+k; *h = 0;
		}
		else /*merge pages a and b, discard b*/
		{
			memcpy(&a->e[N],&b->e[0],N*sizeof(BTitem));//move all items (N) in b to a 
			c->m--;
			memmove(&c->e[s],&c->e[s+1],(c->m-s)*sizeof(BTitem));//Left shift elements of c
			a->m = 2*N; *h = (c->m < N);
			free(b);
			if (c->m==0)//only in case root node has become empty
			{
				bh->root=a;
				free(c);
			}
		}
	}
	else/*b := page to the left of a*/
	{
		s--;//s has to point to previous element in the node c
		if(s==0) b=c->p0;else b = c->e[s-1].p;
		k=(b->m-N+1)/2; /*k = nof items available on page b*/
		if (k>0)
		{
			//Right shift elements in a to make space for migrating elements coming from b
			memmove(&a->e[k],&a->e[0],(N-1)*sizeof(BTitem));
			a->e[k-1]=c->e[s];a->e[k-1].p=a->p0;
			/*move k-1 items from b to a, one to c*/
			b->m=b->m-k;
			memcpy(&a->e[0],&b->e[b->m+1],(k-1)*sizeof(BTitem));
			c->e[s] = b->e[b->m]; a->p0=c->e[s].p;
			c->e[s].p= a; a->m=N-1+k; *h=0;
		}
		else /*merge pages a and b, discard a*/
		{
			c->e[s].p=a->p0; b->e[N]=c->e[s];
			memcpy(&b->e[N+1],&a->e[0],(N-1)*sizeof(BTitem));//move N-1 elements from a to b
			b->m=2*N; c->m--; *h = (c->m < N);
			if (c->m==0)//only in case root node has become empty
			{
				bh->root=b;
				free(c);
			}
			free(a);
		}
	}
	return;
}

//removes an element from internal nodes
//The replacement is found by following the right most pointers of the left child.
void BTdel(BTnode* p,BTnode* a, int* R,int* h,BThead *bh)
{
	/*
	p= where the replacement exists (eventually)
	a= internal node that contains the element to be deleted/replaced
	R= The index of node to be deleted/replaced in a
	h = underflow flag, set to 1 if underflow happens
	bh= root node of b-tree
	*/
	int k;
	int N=HALF_SIZE;
	BTnode* q;//points to next node to be investigated as the one that contains replacement

	k=p->m-1;//k points to the right most child, i.e looking for the biggest key in left sub-tree
	q=p->e[k].p;
	if (q!=NULL)
	{
		BTdel(q,a,R,h,bh);
		if (*h)
			BTunderflow(p,q,p->m,h,bh);//Debug: Changed from p->m to p->m-1??Wrong!! changed back
	}
	else//p is a leaf node, no need to follow up more.
	{
		//Move the biggest key item in P to the intermediate node
		p->e[k].p=a->e[*R].p;
		a->e[*R]=p->e[k];
		p->m--;
		*h= (p->m < N);//signals if p underflows after borrowing an element
	}
	return;
}

//removs key x from sub-tree a in btree bh
//return the value that used to be associated with key x, if x does not exist, return 0 
BTdata BTdelete0(BTdata x, BTnode* a,int* h,BThead *bh, BTcomparer fn)
{
	/*
	x= the key to be removed
	a= sub tree in which key x is supposed to be
	h = underflow flag, set to 1 if underflow happens
	bh= root node of b-tree
	*/
	int i,L,R;
	BTnode* q;//child node to look for x, in case x is not found in a
	int N=HALF_SIZE;
	BTdata value=0;


	if(a!=NULL)
	{
		L=0;R=a->m;
		while(L<R)/*binary search in node a*/
		{
			i=(L+R)/2;
			if(COMPARE_BITEMS(x,a->e[i].data.key,fn)!=1)//before applying the comparefn the condition was:x <= a->e[i].data.key
				R=i;
			else
				L=i+1;
		}
		if(R==0)
			q=a->p0;
		else
			q=a->e[R-1].p;
		if((R < a->m) && (COMPARE_BITEMS(a->e[R].data.key,x,fn)==0))/*found*////before applying the comparefn the condition was (R < a->m) && (a->e[R].data.key==x)
		{
			value=a->e[R].data.value;
			if(q==NULL)/*a is leaf page*/
			{
				a->m--;
				*h=(a->m<N);
				memmove(&a->e[R],&a->e[R+1],(a->m-R)*sizeof(BTitem));//Left shift items in a 
			}
			else/*a is an internal node*/
			{
				BTdel(q,a,&R,h,bh);
				if(*h)
					BTunderflow(a, q, R, h,bh);
			}
		}
		else/*x not found in a, continue by searching q*/
		{
			value=BTdelete0(x, q, h,bh,compareBTdata);
			if(*h)
				BTunderflow(a, q, R, h,bh);
		}
	}
	return value;
}

//deletes key x from Btree bh
//if key is found returns the value associated with key x, otherwise returns 0 signalling that key x did not exist.
BTdata BTdelete(BTdata x,BThead *bh)
{
	int h=0;
	return BTdelete0(x,bh->root,&h,bh,compareBTdata);
}




int BTmap0(BTnode *bt, BTdata lower, BTdata upper, 
	   BTmapper fn, BTcomparer cfn, void *xa)
{
  int  i;

  if(bt == NULL) return TRUE;
  else
    {
      register int leftdone=FALSE, cmp;
      BTdata dk;

      i=1;
      /* Code for binary searching for lower */
     { 
	unsigned int L, R;

	cmp = COMPARE_BITEMS(lower,bt->e[0].data.key,cfn);
	if(cmp>0)
	  {
	    L = 1;
	    R = bt->m + 1;
	    while(L<R)
	      {
		i = (L+R)/2;
		cmp = COMPARE_BITEMS(lower,bt->e[i-1].data.key, cfn);
		if(cmp == 0) break;
		if(cmp > 0) L = i + 1;
		else R = i;
	      }
	  }
	  }
      for(i=i-1;i<bt->m;i++) /* Scan forward until passed upper */
	{
	  dk = bt->e[i].data.key;
	  cmp = COMPARE_BITEMS(lower,dk,cfn);
	  if(cmp<=0)
	    {
	      if(!leftdone)
		{
		  if(cmp==0);
		  else if(i==0)
		    {
		      if(!BTmap0(bt->p0,lower,upper,fn,cfn,xa))
			return FALSE;
		    }
		  else
		    {
		      if(!BTmap0(bt->e[i-1].p,lower,upper,fn,cfn,xa))
			return FALSE;
		    }
		  leftdone = TRUE;
		}
	      dk = bt->e[i].data.key;
	      if(COMPARE_BITEMS(dk,upper,cfn)>0)
		{
		  if(!BTmap0(bt->e[i].p,lower,upper,fn,cfn,xa))
		    return FALSE;
		  break;
		}
	      else
		{
		  /*printf("Key:%d\n",bt->e[i].key); */
		  if(!((*fn)(&(bt->e[i]),xa))) return FALSE;
		  if(!BTmap0(bt->e[i].p,lower,upper,fn,cfn,xa))
		    return FALSE;
		}
	    }
	  else
	    if(i==bt->m-1) return BTmap0(bt->e[i].p,lower,upper,fn,cfn,xa);
	}
    }
  return TRUE;
}

int BTgetMapper(BTitem *bi, void *xa)
{
  *((BTitem **)xa) = bi;
  return FALSE;
}

BTitem *BTget(BThead *bh, BTdata key)
{
  BTitem *res=NULL;
 
  BTmap0(bh->root,key,key,BTgetMapper,NULL,(void *)&res);
  if(res==NULL) return NULL;
  return res;
}


//Mapper function that implements BTnext
int BTnextMapper(BTitem *bi, void *xa)
{
	if (bi==NULL)//the key itself is not found, continue forwards until the next key
		return TRUE;
	else
	{//'Next' is found,return it and stop traversing the tree.
		*((BTitem **)xa) = bi;
		return FALSE;
	}
}
//returns the smallest BTitem bti such that bti.data.key>=key
//automatically increments the key so that it could be used iteratively to perform a range search
BTitem *BTnext(BThead *bh, BTdata *key)
{
  BTitem *res=NULL;
 //TBD: define MAXKEYVAL somewhere global...
  BTmap0(bh->root,*key,4294967295,BTnextMapper,compareBTdata,(void *)&res);
  if(res==NULL) return NULL;
  *key=res->data.key+1;
  return res;
}

/*General mapper functions added by Sobhan*/
/////////////////////////////////////////


int BTSumMapper(BTitem *bi, void *xa)
{
  *(int *) xa+= (int) bi->data.value;
  return TRUE;
}

int BTCountMapper(BTitem *bi, void *xa)
{
  *(int *) xa=*(int *) xa+1;
  return TRUE;
}

int BTAvgMapper(BTitem *bi, void *xa)
{
  static int cnt=0;
  *(double *) xa= ((*(double *) xa)*cnt+(double)bi->data.value)/(cnt+1);
  cnt++;
  return TRUE;
}

int BTSum(BThead *bh, BTdata low,BTdata high)

{
  int res=0;
 
  BTmap0(bh->root,low,high,BTSumMapper,compareBTdata,(void *)&res);
  return res;
}

int BTCount(BThead *bh, BTdata low,BTdata high)

{
  int *res=NULL;
 
  BTmap0(bh->root,low,high,BTCountMapper,compareBTdata,(void *)&res);
  if(res==NULL) return 0;
  return (int) res;
}

double BTAvg(BThead *bh, BTdata low,BTdata high)

{
  double res=0;
  BTmap0(bh->root,low,high,BTAvgMapper,compareBTdata,(void *)&res);
  return res;
}

/***** printing *****/

void printBTkv(BTnode *p)
{
  int i;

  for(i=1;i<=p->m;i++)
	  printf("(%I64d %I64d) ", p->e[i-1].data.key, p->e[i-1].data.value);
  printf("\n");
}

void printBTsubtree(BTnode *p, int level)
{
  int i;

  if(p!=NULL)
    {
      for(i=1;i<=level;i++)
	printf("    ");
      printBTkv(p);
      printBTsubtree(p->p0,level+1);
      for(i=1;i<=p->m;i++)
	printBTsubtree(p->e[i-1].p,level+1);
    }
}

void printBTtree(BThead *bh)
{
  printBTsubtree(bh->root, 0);
}
/*calculating the number of nodes in B-tree*/
//returns the number of nodes in a B-tree p
int BTCountNode(BTnode *p)
{
	int i,s=0;
	if(p->p0==NULL)//this is a leaf node
		return 1;
	else
	{
		s+=BTCountNode(p->p0);
		for(i=1;i<=p->m;i++)
			s+=BTCountNode(p->e[i-1].p);
		s++;//count the current node!
	}
	return s;
}

/***** testing *****/

static unsigned long int rand_seed=13465241;

unsigned int randgen(int i) /* returns a random integer 0..i-1 */
{
  rand_seed = rand_seed * 1103515245 + 12345;
  if (i == 0) return 0;
  return (unsigned int)(rand_seed % i);
}

void BTtest(int size)
{
  int i, cnt;
  clock_t cl;
  double time;
  BThead *bh;
  BTdata k;
  int upkey; 
  int k1, ac=1000000;
  
  bh = newBThead();
  upkey = 7*size+3;
  printf("[Building BT with %g rows ... ", size*1.0);
  cl = clock();
  for(i=0;i<size;i++)
    {
      k = randgen(upkey);
      if(i==1) k1 = (int)k;
      BTinsert(bh,k,i,NULL);
    }
  time = (clock() - cl)*1.0/CLOCKS_PER_SEC;
  printf("%d nodes, %g s]\n",nodecnt,time);
  //printBTtree(bh);
  printf("Should be 1: %d\n", BTget(bh, k1)->data.value);
  printf("[Accessing BT with %g rows %d times ... ", size*1.0, ac);
  cl = clock();
  for(i=0;i<ac;i++)
    BTget(bh,randgen(upkey));
  time = (clock() - cl)*1.0/CLOCKS_PER_SEC;
  printf("%g s]\n",time);  
  cl = clock();
  printf("[Deleting BT with %g rows ... ", size*1.0);
  cnt = freeBThead(bh);
  time = (clock() - cl)*1.0/CLOCKS_PER_SEC;
  printf("%d nodes deleted, %g s]\n",cnt,time);  
}
/*
int main(int argc, char**argv)
{
  BTtest(DB_SIZE);
}
*/