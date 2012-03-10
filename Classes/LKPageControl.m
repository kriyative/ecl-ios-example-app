#import <UIKit/UIKit.h>
#import "LKPageControl.h"
#import "ecl/ecl.h"
#import "ecl_boot.h"

@implementation LKPageControl

- (id) initWithFrame: (CGRect) aFrame
{
    [super initWithFrame: aFrame];
    onChangeFun = Cnil;
    [self addTarget: self
          action: @selector(pageChange:)
          forControlEvents: UIControlEventTouchUpInside];
    return self;
}

- (void) setOnChangeFun: (cl_object) fun
{
    INIT_CALLBACK(onChangeFun, fun);
}

- (void) pageChange: (id) sender
{
    if (Cnil != onChangeFun) {
        cl_funcall(2, onChangeFun,
                   ecl_foreign_data_ref_elt(&self, ECL_FFI_POINTER_VOID));
    }
}

- (void) dealloc
{
    remove_callback(onChangeFun);
    [super dealloc];
}

@end
