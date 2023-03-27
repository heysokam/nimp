#:____________________________________________________
#  nimp  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:____________________________________________________

#___________________
# Package
packageName   = "nimp"
version       = "0.0.0"
author        = "sOkam"
description   = "n* Resource Importer"
license       = "MIT"

#___________________
# Folders
srcDir           = "src"
binDir           = "bin"
let testsDir     = "tests"
let examplesDir  = "examples"
let docDir       = "doc"
skipdirs         = @[binDir, examplesDir, testsDir, docDir]


#___________________
# Build requirements
requires "nim >= 1.6.12"                         ## Latest stable version
requires "https://github.com/heysokam/nstd"      ## n* stdlib extension
requires "https://github.com/heysokam/nmath"     ## n* Math tools
requires "https://github.com/beef331/nimassimp"  ## Beef's fork of assimp. Seems to be the only maintained version


#________________________________________
# Helpers
#___________________
import std/os
import std/strformat
#___________________
let nimcr = &"nim c -r --outdir:{binDir}"
  ## Compile and run, outputting to binDir
proc runFile (file, dir :string) :void=  exec &"{nimcr} {dir/file}"
  ## Runs file from the given dir, using the nimcr command
proc runTest (file :string) :void=  file.runFile(testsDir)
  ## Runs the given test file. Assumes the file is stored in the default testsDir folder
proc runExample (file :string) :void=  file.runFile(examplesDir)
  ## Runs the given test file. Assumes the file is stored in the default testsDir folder

