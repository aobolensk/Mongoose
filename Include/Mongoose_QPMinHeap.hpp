#pragma once

#include "Mongoose_Internal.hpp"

namespace Mongoose
{

void QPMinHeap_build
(
    Int *heap,                      /* on input, an unsorted set of elements */
    Int size,                       /* size of the heap */
    double *x
);

Int QPMinHeap_delete             /* return new size of heap */
(
    Int *heap,                   /* containing indices into x, 1..n on input */
    Int size,                    /* size of the heap */
    const double *x              /* not modified */
);

void QPMinHeapify
(
    Int p,                       /* start at node p in the heap */
    Int *heap,                   /* size n, containing indices into x */
    Int size,                    /* heap [ ... nheap] is in use */
    const double *x              /* not modified */
);

Int QPMinHeap_add
(
    Int leaf,   /* the new leaf */
    Int *heap,  /* size n, containing indices into x */
    const double *x,  /* not modified */
    Int size     /* number of elements in heap not counting new one */
);

void QPminheap_check
(
    Int *heap,  /* vector of size n+1 */
    double *x,  /* vector of size n */
    Int size,       /* # items in heap */
    Int n,
    Int p       /* start checking at heap [p] */
);

} // end namespace Mongoose

