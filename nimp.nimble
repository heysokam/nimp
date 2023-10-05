#:____________________________________________________
#  nimp  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:____________________________________________________
import std/strformat
from   std/os import `/`

#______________
# Package     |
packageName   = "nimp"
version       = "0.1.2"
author        = "sOkam"
description   = "n* Resource Importer"
license       = "MIT"
let gitURL    = &"https://github.com/heysokam/{packageName}"

#_________________
# Folders        |
srcDir           = "src"
binDir           = "bin"
let testsDir     = "tests"
let resDir       = testsDir/"res"
let examplesDir  = "examples"
let cacheDir     = binDir/"cache"
let docDir       = "doc"
skipFiles        = @["nim.cfg"]


#______________________
# Build requirements  |
requires "nim >= 2.0.0"
requires "https://github.com/heysokam/nmath"     ## n* Math tools
requires "https://github.com/heysokam/ngltf"     ## n* glTF reader
requires "pixie"                                 ## PNG Image loading
requires "chroma"                                ## Color tools
requires "zippy"                                 ## Zip/Unzip tools
requires "yaml"                                  ## yaml tools (used for configuration files and similar)


#_________________
# Helpers        |
const vlevel = when defined(debug): 2 else: 1
const mode   = when defined(debug): "-d:debug" elif defined(release): "-d:release" elif defined(danger): "-d:danger" else: ""
let nimcr = &"nim c -r --verbosity:{vlevel} {mode} --hint:Conf:off --hint:Link:off --hint:Exec:off --nimcache:{cacheDir} --outdir:{binDir}"
  ## Compile and run, outputting to binDir
proc runFile (file, dir, args :string) :void=  exec &"{nimcr} {dir/file} {args}"
  ## Runs file from the given dir, using the nimcr command, and passing it the given args
proc runFile (file :string) :void=  file.runFile( "", "" )
  ## Runs file using the nimcr command
proc runTest (file :string) :void=  file.runFile(testsDir, "")
  ## Runs the given test file. Assumes the file is stored in the default testsDir folder
proc runExample (file :string) :void=  file.runFile(examplesDir, "")
  ## Runs the given test file. Assumes the file is stored in the default testsDir folder
template example (name :untyped; descr,file :static string)=
  ## Generates a task to build+run the given example
  let sname = astToStr(name)  # string name
  taskRequires sname, "SomePackage__123"  ## Doc
  task name, descr:
    runExample file


#_____________________________
# Tasks
#_________
# Tests  |
task tests, "Internal:  Builds and runs all tests in the testsDir folder.":
  # Tests requirements
  cpDir(resDir, binDir/"res")  ## Copy the test resources to the bin resources folder
  for file in testsDir.listFiles():
    if file.lastPathPart.startsWith('t'):
      try: runFile file
      except: echo &" └─ Failed to run one of the tests from  {file}"
#____________
# Internal  |
task push, "Internal:  Pushes the git repository, and orders to create a new git tag for the package, using the latest version.":
  ## Does nothing when local and remote versions are the same.
  requires "https://github.com/beef331/graffiti.git"
  exec "git push"  # Requires local auth
  exec &"graffiti ./{packageName}.nimble"
#__________
# docgen  |
task docgen, "Internal:  Generates documentation using Nim's docgen tools.":
  echo &"{packageName}: Starting docgen..."
  exec &"nim doc --project --index:on --git.url:{gitURL} --outdir:{docDir}/gen src/{packageName}.nim"
  echo &"{packageName}: Done with docgen."

