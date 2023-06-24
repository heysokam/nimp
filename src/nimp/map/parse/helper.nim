#:____________________________________________________
#  nimp  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:____________________________________________________
# std Dependencies
import std/tables
# ndk dependencies
import nstd/types

#______________________________
func merge *(t1, t2 :Table[str, str]) :Table[str, str]=
  for key, val in t1: result[key] = val
  for key, val in t2: result[key] = val
