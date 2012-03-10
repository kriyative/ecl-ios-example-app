#ifndef _ECL_BOOT_H_
#define _ECL_BOOT_H_

#import "ecl/ecl.h"

int ecl_boot(const char *root_dir, int heap_size, int developer_mode);
void ecl_toplevel(const char *home);
void ecl_redraw(id view);

void register_callback(cl_object fun);
void remove_callback(cl_object fun);

#define INIT_CALLBACK(handler, value) \
  remove_callback(handler); handler = value; register_callback(handler);
#endif
