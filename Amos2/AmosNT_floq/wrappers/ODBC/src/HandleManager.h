/*****************************************************************************
 * AMOS2
 * 
 * Author: (c) 1999 Timour Katchaounov, EDSLAB
 * $RCSfile: HandleManager.h,v $
 * $Revision: 1.1 $ $Date: 2003/05/19 12:24:46 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Generic HANDLE manager. Maps integers (handles) to pointers.
 *				It is NOT multithread safe!
 ****************************************************************************/


#ifndef _HandleManager_h
#define _HandleManager_h


#include <map>
#include <odbc++\connection.h>
#include <odbc++\types.h>

using namespace std;
using namespace odbc;
//using namespace amos;

namespace amos {

typedef int tHandle;

template <class T> class HandleManager : public std::map<tHandle, T*> {

public:
	enum {invalidHandle = -1};
	
private:
	HandleManager(const HandleManager&); // forbid
	HandleManager& operator=(const HandleManager&);	// forbid
	
public:
	explicit HandleManager() {}
	~HandleManager();
	
	tHandle	addHandle(T* pObject);
	T*		getHandle(tHandle handle);
	void	deleteHandle(tHandle handle);
	void	deleteAllHandles(void);
	
private:
	tHandle	newHandle();
};

/*****************************************************************************
* TODO: All these are rather simple implementations.
*****************************************************************************/

/*****************************************************************************
* 
*****************************************************************************/
template <class T> HandleManager<T>::~HandleManager() {
   //deleteAllHandles();
}

/*****************************************************************************
* Adds an object pointer in the HandleManager and returns a new handle for that
* object.
*****************************************************************************/
template <class T> tHandle HandleManager<T>::addHandle(T* pObject) {
	tHandle	handle;
	// do not add NULL pointers
	if (pObject == NULL) {
        throw SQLException("[OdbcAmos]: Trying to add NULL pointer to the HandleManager.");
    }
	handle = newHandle();
	this->insert(map<tHandle, T*>::value_type(handle, pObject));

	return handle;
}


/*****************************************************************************
* Returns a pointer to the object referenced by this handle
*****************************************************************************/
template <class T> T* HandleManager<T>::getHandle(tHandle handle) {
	map<tHandle, T*>::const_iterator i = this->find(handle);
	if (i == this->end()) {
		throw SQLException("[OdbcAmos]: Trying to get illegal handle: " + intToString(handle));
	}
	assert(((*i).second) != NULL);
	return (*i).second;
}


/*****************************************************************************
* Deletes the object referenceed by the handle and removes the entry from the
* handle table.
*****************************************************************************/
template <class T> void HandleManager<T>::deleteHandle(tHandle handle) {
	map<tHandle, T*>::iterator i = this->find(handle);
	if (i == this->end()) {
		throw SQLException("[OdbcAmos]: Trying to delete illegal handle: " + intToString(handle));
	}
	assert(((*i).second) != NULL);
	delete (*i).second;
	this->erase(i);
}

/*****************************************************************************
* Deletes all objects stored in the Handle manager, and removes all handles
* from the handle table.
*****************************************************************************/
template <class T> void HandleManager<T>::deleteAllHandles(void) {
	map<tHandle, T*>::iterator i;
	while (!this->empty()) {
		i = this->begin();
		assert(((*i).second) != NULL);
		delete (*i).second;
		this->erase(i);
	}
}


/*****************************************************************************
* Returns the next unused Connection handle
* TODO: Maybe recycle Connection Handles?
*****************************************************************************/
template <class T> tHandle	HandleManager<T>::newHandle() {
	static tHandle	handle = 0;
	return ++handle;
}

}




#endif