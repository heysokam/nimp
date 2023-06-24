#:____________________________________________________
#  nimp  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:____________________________________________________
# std Dependencies
import std/os
import std/strformat
# ndk dependencies
import nstd/types as baseTypes
# Module Dependencies
import ./types
import ./parse


type Format {.pure.}= enum Valve
  ## Supported map formats. Their names are turned into literal strings as they are.

#______________________________
proc load *(src :str) :Map=
  ## Loads a `.map` file from the given src file
  if not src.fileExists: raise newException(OSError, &"File {src} does not exist")
  result = src.readMap
  case   result.format
  of     $Format.Valve:  discard
  of     "":             raise newException(OSError, &"File {src} : Format not found.")
  else:  raise newException(OSError, &"File {src} : Support for format {result.format} has not been implemented.")

