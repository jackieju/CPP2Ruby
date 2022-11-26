// all define or other preprocessor directive will be deleted in preprocessor output file althought included successfully.
/* standard c routine */
#define strlen(s) s.size
/* END */

// for non-standard c/cpp keyword
// from L ## __FILE__
#define L__FILE__ __FILE__ 
#define inline
#define int32_t int
#define int64_t int
#define __declspec( dllimport ) 
#define mutable
#define volatile


// compiler switcher
#define __cplusplus

// for clean and ignore
#define __CRTDECL
#define __dllexport__

// for cpp11
// https://gist.github.com/hang-qi/5308284
// One shall use ON_SCOPE_EXIT() macro to create a anonymous ScopeGuard object.
// The anonymous function "callback" will be automatically called in the 
// deconstractor when the object is out of the scope.
// ...
// #define  SCOPE_GUARD_NAME_CANT(line)        _scope_guard_##line
// #define  MAKE_SCOPE_GUARD(callback, line)   utility::ScopeGuard SCOPE_GUARD_NAME_CANT(line)(callback)
//  
// #define  ON_SCOPE_EXIT(callback)            MAKE_SCOPE_GUARD(callback, __LINE__)
#define ON_SCOPE_EXIT(code) 

// for B1 special
#define B1_OBSERVER_API  __dllexport__ 
#define B1_COMMON_API
#define B1_SECURITY_COMMON_API
#define B1_ENGINE_API		
#define B1_UIENGINE_API	
#define B1_LICENCE_COMMON_API
#define B1_LICENCE_CONNECTOR_API
#define B1_SERVICES_METADATA_API
#define TRACE_METHOD

//#define const
#define TRUE true
#define FALSE false
#define NULL nil
#define _LOGMSG(a,b,c) 
#define IF_ERROR_RETURN(errorCode) if (errorCode) return errorCode
#define _TRACER(m) trace(m)

#define B1_ENGINE_API 

//#define DBM_ColumnType
//#define DBMTableColumn
#define __field_bcount(cbData)
//#define trace(m)
#define _STR_strlen(s) s.size


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

// only for JE app  
//#include "ScopeGuard.h"
//#include "_CacheBase.h"
#include "./macros.c" # same file in user's working dir
