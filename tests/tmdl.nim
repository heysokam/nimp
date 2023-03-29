#:____________________________________________________
#  nimp  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:____________________________________________________
# std dependencies
import std/unittest
import std/strformat
# External dependencies
import pkg/print
# Library dependencies
import nimp


#_______________________________________
const bottleFile = "bottle/bottle.gltf"
test &"load {bottleFile}":
  let mdl = bottleFile.load()
  check mdl.len == 1
  check mdl[0].pos != newSeq[Vec3]()
  check mdl[0].pos[0] == vec3(-98.7689208984375, -253.5404205322266, 15.64341735839844)

#_______________________________________
const spheresFile = "mrSpheres/MetalRoughSpheres.gltf"
test &"load {spheresFile}":
  let mdl = spheresFile.load()
  check mdl.len == 5

