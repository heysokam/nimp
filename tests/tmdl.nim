#:____________________________________________________
#  nimp  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:____________________________________________________
# std dependencies
import std/os
import std/unittest
import std/strformat
# External dependencies
import pkg/pretty
# Library dependencies
import nimp


#_______________________________________
# Config
const resDir = currentSourcePath().parentDir()/"res"
#_____________________________


#_______________________________________
const bottleFile = resDir/"bottle/bottle.gltf"
test &"load {bottleFile}":
  let mdl = gltf.load(bottleFile)
  check mdl.models.len == 1
  # check mdl.models[0].pos != newSeq[Vec3]()
  # check mdl.models[0].pos[0] == vec3(-98.7689208984375, -253.5404205322266, 15.64341735839844)

#_______________________________________
const spheresFile = resDir/"mrSpheres/MetalRoughSpheres.gltf"
test &"load {spheresFile}":
  let mdl = gltf.load(spheresFile)
  check mdl.models.len == 5

