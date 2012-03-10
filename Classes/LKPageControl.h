#import <Foundation/Foundation.h>
#import "ecl/ecl.h"

@interface LKPageControl : UIPageControl
{
    cl_object onChangeFun;
}

- (void) setOnChangeFun: (cl_object) fun;

@end
