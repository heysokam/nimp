#:____________________________________________________
#  nimp  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:____________________________________________________
import std/strformat
from   std/os import `/`

#______________
# Package     |
packageName   = "nimp"
version       = "0.1.0"
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
requires "nim >= 1.9.5"
requires "https://github.com/heysokam/nstd"      ## n* stdlib extension
requires "https://github.com/heysokam/nmath"     ## n* Math tools
requires "https://github.com/heysokam/ngltf"     ## n* glTF reader
requires "pixie"                                 ## PNG Image loading
requires "chroma"                                ## Color tools
requires "zippy"                                 ## Zip/Unzip tools
requires "yaml"                                  ## yaml tools (used for configuration files and similar)


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

#_____________________________
# Tasks
#_________
# Tests  |
task test, "Runs all tests in the `tests` folder":
  # Tests requirements
  requires "pretty"
  cpDir(resDir, binDir/"res")  ## Copy the test resources to the bin resources folder
  "tmdl".runTest
#____________
# Internal  |
task push, "Internal:  Pushes the git repository, and orders to create a new git tag for the package, using the latest version.":
  ## Does nothing when local and remote versions are the same.
  requires "https://github.com/beef331/graffiti.git"
  exec "git push"  # Requires local auth
  exec &"graffiti ./{packageName}.nimble"

