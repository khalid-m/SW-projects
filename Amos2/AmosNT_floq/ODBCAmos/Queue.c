//////////////////////////////////////////////////////////////////////////
//
// FILE: queue.C
//


#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include "odbc_lib\sql.h"
#include "util.h"

/* ------------------------------------------------------------------------
           CREATE  A NEW QUEUE INITIALIZED TO  ZERO
------------------------------------------------------------------------*/
queue * newQueue(void)
{
 queue *aQueue =(queue *) calloc(1, sizeof(queue));
 if (aQueue ==NULL)
           {outOfStorage(); return NULL;}
 else
     return aQueue;
 }

/* ------------------------------------------------------------------------
           CREATE  A NEW MEMBER TO CONTAIN DATAVALUE
------------------------------------------------------------------------*/
member * newMember(const Conne *const dataValue)
{
member *result;
result =(member *) calloc(1, sizeof(member));
 if (result ==NULL)
            outOfStorage();
result->data =(Conne *)calloc(1,sizeof(Conne));
if (result->data ==NULL)
            outOfStorage();
*(result->data) = *dataValue;
     return result;
 }

/* ------------------------------------------------------------------------
           ADD A DATA VALUE TO BACK OF aQueue
------------------------------------------------------------------------*/

void add(const Conne *const dataValue, queue *const aQueue)
{
if(aQueue->number==0)
      aQueue->front=aQueue->back = newMember(dataValue);
else
  {
      aQueue->back->next = newMember(dataValue);
      aQueue->back = aQueue->back->next;
  }
  aQueue->number++;
}

/* ------------------------------------------------------------------------
           Exit tidily when out of storage
------------------------------------------------------------------------*/

void outOfStorage(void)
{
    fprintf(stderr, "Out of storage\n");
    exit(EXIT_FAILURE);
}
