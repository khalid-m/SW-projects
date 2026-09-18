#ifndef _RDF_READER_H_
#define _RDF_READER_H_

/*Map URI reference or typed literal's data type URI to Integer*/
#define L_RES				(0)		/* URI reference	*/
#define L_PLAIN				(1)		/* Plain literal	*/	
#define L_INT				(2)		/* xsd:integer		*/
#define L_DEC				(3)		/* xsd:decimal		*/
#define L_DBL				(4)		/* xsd:double		*/
#define L_BOOL				(5)		/* xsd:boolean		*/
#define L_STR				(6)		/* xsd:string		*/

extern char *ltr_type[];

void rdf_set_amos_connection(void*);
void rdf_raptor_finish(void);

#endif
