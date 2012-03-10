#import "Foundation/Foundation.h"
#include <stdlib.h>
#include "ecl/ecl.h"
#include "ecl/gc/gc.h"
#include "ecl_boot.h"

#ifdef __cplusplus
#define ECL_CPP_TAG "C"
#else
#define ECL_CPP_TAG
#endif

extern ECL_CPP_TAG void init_lib_SERVE_EVENT(cl_object);
extern ECL_CPP_TAG void init_lib_SOCKETS(cl_object);
extern ECL_CPP_TAG void init_lib_PROFILE(cl_object);
extern ECL_CPP_TAG void init_lib_BYTECMP(cl_object);
extern ECL_CPP_TAG void init_lib_APP(cl_object);

#define compiler_data_text NULL
#define compiler_data_text_size 0
#define VV NULL
#define VM 0

static BOOL _dev_modep = NO;

void init_ECL_PROGRAM(cl_object cblock)
{
  static cl_object Cblock;
  if (!FIXNUMP(cblock)) {
    Cblock = cblock;
    cblock->cblock.data_text = compiler_data_text;
    cblock->cblock.data_text_size = compiler_data_text_size;
#ifndef ECL_DYNAMIC_VV
    cblock->cblock.data = VV;
#endif
    cblock->cblock.data_size = VM;
    return;
  }
#if defined(ECL_DYNAMIC_VV) && defined(ECL_SHARED_DATA)
  VV = Cblock->cblock.data;
#endif
	
  {
      cl_object current, next = Cblock;
      if (YES == _dev_modep) {
          current = read_VV(OBJNULL, init_lib_SOCKETS); current->cblock.next = next; next = current;
          current = read_VV(OBJNULL, init_lib_BYTECMP); current->cblock.next = next; next = current;
          current = read_VV(OBJNULL, init_lib_SERVE_EVENT); current->cblock.next = next; next = current;
      }
      current = read_VV(OBJNULL, init_lib_APP); current->cblock.next = next; next = current;
      Cblock->cblock.next = current;
  }
}

void ecl_toplevel(const char *home)
{
    si_safe_eval(3, c_string_to_object("(pushnew :iphone *features*)"), Cnil, OBJNULL);
#if TARGET_IPHONE_SIMULATOR
    si_safe_eval(3, c_string_to_object("(pushnew :iphone-simulator *features*)"), Cnil, OBJNULL);
#else
    si_safe_eval(3, c_string_to_object("(pushnew :iphone-os *features*)"), Cnil, OBJNULL);
#endif
}

cl_object ecl_callbacks = Cnil;
cl_object Xecl_callbacksX = Cnil;
void init_callbacks_registry()
{
  int internp;
  Xecl_callbacksX = ecl_intern(make_simple_base_string("*ECL-CALLBACKS*"),
                               ecl_find_package_nolock(ecl_make_keyword("SI")),
                               &internp);
  ecl_defvar(Xecl_callbacksX, ecl_callbacks);
  ecl_register_root(&ecl_callbacks);
}

void register_callback(cl_object fun)
{
    if (Cnil != fun && false == ecl_member_eq(fun, ecl_callbacks)) {
        ecl_callbacks = ecl_cons(fun, ecl_callbacks);
        cl_set(Xecl_callbacksX, ecl_callbacks);
    }
}

void remove_callback(cl_object fun)
{
    if (Cnil == fun) return;
    if (ecl_member_eq(fun, ecl_callbacks)) {
        ecl_callbacks = ecl_remove_eq(fun, ecl_callbacks);
        cl_set(Xecl_callbacksX, ecl_callbacks);
    }
}

int ecl_boot(const char *root_dir, int heap_size, int dev_modep)
{
    int argc = 1;
    char *argv[1];
    argv[0] = "ecl";

    struct GC_stack_base base; 
    GC_register_my_thread(&base);
    // GC_stackbottom = (void*)(argv+255);

    _dev_modep = dev_modep;
    setenv("ECLDIR", "", 1);
    if (dev_modep) { NSLog(@"before cl_boot()"); }
    ecl_set_option(ECL_OPT_HEAP_SIZE, heap_size);
    cl_boot(argc, argv);
    if (dev_modep) {
        NSLog(@"after cl_boot()");
        NSLog(@"before init_ECL_PROGRAM()");
    }
    // si_safe_eval(3, c_string_to_object("(setq si::*compiler-constants* #())"), Cnil, OBJNULL);
    read_VV(OBJNULL, init_ECL_PROGRAM);
    if (dev_modep) { NSLog(@"after init_ECL_PROGRAM()"); }
    char tmp[512];
    sprintf(tmp, "(setq *default-pathnames-defaults* #p\"%s\")", root_dir);
    si_safe_eval(3, c_string_to_object(tmp), Cnil, OBJNULL);
    init_callbacks_registry();
    ecl_toplevel(root_dir);
    return 0;
} 

void ecl_redraw(id view)
{
    [view performSelectorOnMainThread: @selector(setNeedsDisplay)
                           withObject: nil
                        waitUntilDone: YES];
}
