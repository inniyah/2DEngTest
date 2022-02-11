#include "hub_core.h"

#ifdef __cplusplus
extern "C" {
#endif

static int singleton=42;

int get_singleton(void){
	return singleton;
}

void set_singleton(int new_val){
	singleton=new_val;
}

#ifdef __cplusplus
}
#endif
