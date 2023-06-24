#:____________________________________________________
#  nimp  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:____________________________________________________
# std Dependencies
import std/strformat
from   std/os import `/`

#______________
# Package     |
packageName   = "nimp"
version       = "0.0.0"
author        = "sOkam"
description   = "n* Resource Importer"
license       = "MIT"

#_________________
# Folders        |
srcDir           = "src"
binDir           = "bin"
let testsDir     = "tests"
let resDir       = testsDir/"res"
let examplesDir  = "examples"
let docDir       = "doc"


#______________________
# Build requirements  |
requires "nim >= 1.6.12"                         ## Latest stable version
requires "https://github.com/heysokam/nstd"      ## n* stdlib extension
requires "https://github.com/heysokam/nmath"     ## n* Math tools
requires "https://github.com/beef331/nimassimp"  ## Beef's fork of assimp. Seems to be the only maintained version
requires "pixie"                                 ## PNG Image loading
requires "chroma"                                ## Color tools


#_________________
# Helpers        |
let nimcr = &"nim c -r --outdir:{binDir}"
  ## Compile and run, outputting to binDir
proc runFile (file, dir :string) :void=  exec &"{nimcr} {dir/file}"
  ## Runs file from the given dir, using the nimcr command
proc runTest (file :string) :void=  file.runFile(testsDir)
  ## Runs the given test file. Assumes the file is stored in the default testsDir folder
proc runExample (file :string) :void=  file.runFile(examplesDir)
  ## Runs the given test file. Assumes the file is stored in the default testsDir folder

#_________________________________________________
task test, "Runs all tests in the `tests` folder":
  # Tests requirements
  requires "print"
  cpDir(resDir, binDir/"res")  ## Copy the test resources to the bin resources folder
  "tmdl".runTest

