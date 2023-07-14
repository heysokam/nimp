#:____________________________________________________
#  nimp  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:____________________________________________________
# External dependencies
import pkg/pixie
import pkg/chroma
# ndk dependencies
import nstd/types  as base
import nmath/types as m

#____________________
type ImportError * = object of IOError

#____________________
const NotInitialized * = "Uninitialized"  ## BaseName for uninitialized resource objects

