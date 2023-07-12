#:____________________________________________________
#  nimp  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:____________________________________________________
# External dependencies
import pkg/zippy/ziparchives

#__________
proc unzip *(file, trgDir :string) :void=
  file.extractAll(trgDir)

