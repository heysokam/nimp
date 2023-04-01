#:____________________________________________________
#  nimp  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:____________________________________________________
# std dependencies
import std/strformat
# ndk dependencies
import nstd/types as base
# Module dependencies
import ../img
import ../types

##[
#____________________
type Mat * = enum
  Diffuse, Specular, Shininess, Ambient, Emissive,
  Normals, Height, Displacement,
  Lightmap, Reflection
#____________________
type Material *[T] = object
  typ  *:Mat    ## Material type
  tex  *:Image  ## Material texture, contains a K value for each pixel individually
  K    *:T      ## Value property of the material, applied to the texture uniformly
#____________________
type Materials * = object
  dif  *:Material[Color]
  spe  *:Material[float32]
]##

#____________________
proc new *[T](kind :Mat; file :str= ""; K :T; internalName :str= "") :Material[T]=
  ## Generates a new Material.
  ## Assumes a pixie supported file format is stored in the given `file` input path.
  ## When omitting a parameter, defaults will be:
  ##   - file          : An empty Image (1x1) will be created.
  ##   - internalName  : Will use the file's filename without extension.
  # Load image
  if file == "" or file.notImg:  # Path was not given, or its not an image, so create an empty texture
    result.typ  = kind
    result.file = &"{NotInitialized}-{kind}Material_file"
    result.name = &"{NotInitialized}-{kind}"
    result.tex  = newImage(1,1)  # Pixie does not allow 0x0
    result.K    = K
    return
  # Assume supported format, and decode it
  result.typ  = kind
  result.file = file
  result.name = if internalName != "": internalName else: file.splitFile().name
  result.tex  = file.readImage
  result.tex.flipVertical   # Flip for OpenGL texture coordinates marking 0,0 at bottom left
  result.K    = K
