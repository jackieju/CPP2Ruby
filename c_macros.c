// all define or other preprocessor directive will be deleted in preprocessor output file althought included successfully.
/* standard c routine */
#define strlen(s) s.size
/* END */

// compiler switcher
#define __cplusplus

// for clean and ignore
#define __CRTDECL
#define B1_OBSERVER_API
#define B1_COMMON_API
#define B1_SECURITY_COMMON_API
#define B1_ENGINE_API		
#define B1_UIENGINE_API	
#define B1_LICENCE_COMMON_API
#define B1_LICENCE_CONNECTOR_API
#define B1_SERVICES_METADATA_API
#define TRACE_METHOD

#define const
#define inline
#define TRUE true
#define FALSE false
#define NULL nil
#define _LOGMSG(a,b,c) 
#define IF_ERROR_RETURN(errorCode) if (errorCode) return errorCode
#define _TRACER(m) trace(m)

#define B1_ENGINE_API 
#define int32_t int
#define int64_t int
//#define DBM_ColumnType
//#define DBMTableColumn
#define __field_bcount(cbData)
//#define trace(m)
#define _STR_strlen(s) s.size
#define __declspec( dllimport ) 


typedef bool (*DBD_ProgressCallback) (void *userData, long curr, long max);
typedef bool (*DBD_FilterCallback) (PDAG pDag, long rec, void *param1, void *param2);
typedef SBOErr (*DBD_CondCallback) (void *form, DBD_Params *addedParams);


// SAL
//#define _In_	
//#define _In_opt_
//#define Inout_	
//#define _Inout_opt_
//#define	_Out_	
//#define _Out_opt_
//#define	_Outptr_opt_