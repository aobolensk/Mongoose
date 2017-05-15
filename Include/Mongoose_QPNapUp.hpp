#ifndef Mongoose_QPNapUp_hpp
#define Mongoose_QPNapUp_hpp

#include "Mongoose_Internal.hpp"

namespace Mongoose
{

double QPnapup              /* return lambda */
(
    double *x,              /* holds y on input, not modified */
    Int n,                  /* size of x */
    double lambda,          /* initial guess for the shift */
    double *a,              /* input constraint vector */
    double b,               /* input constraint scalar */
    double *breakpts,       /* break points */
    Int *bound_heap,        /* work array */
    Int *free_heap          /* work array */
);

} // end namespace Mongoose

#endif
