#:____________________________________________________
#  nimp  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:____________________________________________________
# std dependencies
import std/strutils
# External dependencies
import pkg/pixie ; export pixie
# ndk dependencies
import nstd/types as base


#_______________________________________
template notPNG *(file :str) :bool=  not file.normalize.endsWith(".png")
  ## Returns true if the file path is not a `.png` file.
template notJPG *(file :str) :bool=  not file.normalize.endsWith(".jpeg") and not file.normalize.endsWith(".jpg")
  ## Returns true if the file path is not a `.jpg` or `.jpeg` file.
proc notImg *(file :str) :bool=  file.notPNG and file.notJPG
  ## Returns true if the file path is not a recognized img file, based on its extension.
  ## Checks for png and jpg.

