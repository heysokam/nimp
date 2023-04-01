#:____________________________________________________
#  nimp  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:____________________________________________________
# External dependencies
import pkg/pixie
import pkg/chroma
# ndk dependencies
import nstd/types  as base
import nmath/types as m


#____________________
const NotInitialized * = "Uninitialized"  ## BaseName for uninitialized resource objects

#____________________
type Mat * = enum
  Diffuse, Specular, Shininess, Ambient, Emissive,
  Normals, Height, Displacement,
  Lightmap, Reflection
#____________________
type Material *[T] = object
  typ  *:Mat    ## Material type
  file *:str    ## File path of the material
  name *:str    ## Internal name of the material
  tex  *:Image  ## Material texture, contains a K value for each pixel individually
  K    *:T      ## Value property of the material, applied to the texture uniformly
#____________________
type Materials * = object
  dif  *:Material[Color]
  spe  *:Material[float32]

#____________________
# Mesh / Model
type Mesh * = object
  pos    *:seq[Vec3]
  color  *:seq[Color]
  uv     *:seq[Vec2]
  norm   *:seq[Vec3]
  inds   *:seq[UVec3]
  mats   *:Materials
#____________________
type Model * = seq[Mesh]

