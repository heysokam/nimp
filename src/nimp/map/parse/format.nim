#:____________________________________________________
#  nimp  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:____________________________________________________
# std Dependencies
import std/strscans  # For parsing the data without Regex
# ndk dependencies
import nstd/types
# Module Dependencies
from   ./patterns as p import nil

#______________________________
proc parseFormat *(lbuf :seq[str]) :str= 
  for line in lbuf:
    if line.scanf(p.format, result): return
#______________________________


