#:____________________________________________________
#  nimp  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:____________________________________________________
# std dependencies
import std/os
import std/unittest
import std/strformat
# Library dependencies
import nimp


#_______________________________________
# Config
const resDir = currentSourcePath().parentDir()/"res"
#_____________________________


#_______________________________________
const bottleFile = resDir/"bottle/bottle.gltf"
test &"load {bottleFile}":
  let mdl = mdl.load(bottleFile)
  check mdl.len == 1
  check mdl[0].pos != newSeq[Vec3]()
  check mdl[0].pos[0] == vec3(-98.7689208984375, -253.5404205322266, 15.64341735839844)

#_______________________________________
const spheresFile = resDir/"mrSpheres/MetalRoughSpheres.gltf"
# test &"load {spheresFile}":
#   let mdl = mdl.load(spheresFile)
#   check mdl.len == 5

