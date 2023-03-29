#:____________________________________________________
#  nimp  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:____________________________________________________
# External dependencies
import pkg/assimp  ; export assimp
import pkg/chroma
# ndk dependencies
import nmath

#________________________________________
# Assimp Extend
#___________________

#________________________________________
iterator ivertex *(m: PMesh) :Vec3=
  let vertices = cast[ptr UncheckedArray[TVector3d]](m.vertices)
  for vert in 0..<m.vertexCount:
    yield vec3(vertices[vert].x.float32, vertices[vert].y.float32, vertices[vert].z.float32)
#________________________________________
iterator inormal *(m :PMesh) :Vec3=
  let normals = cast[ptr UncheckedArray[TVector3d]](m.normals)
  for vert in 0..<m.vertexCount:
    yield vec3(normals[vert].x.float32, normals[vert].y.float32, normals[vert].z.float32)
#________________________________________
# UV channels in the context of assimp 
#   Materials can haave more than just one UV texture channel. Like a detail texture on top of your base texture
#   There are 2d uvs and 3d uvs, assimp has support for both
#   Example: Accessing the U component will be: texCoords[textureChannelIndex][vertexIndex].x
iterator iuv *(m :PMesh) :Vec2=
  let channel = 0  # TODO: Support for more channels if they exist
  let verts   = cast[ptr UncheckedArray[TVector3d]](m.texCoords[channel])
  for vert in 0..<m.vertexCount:
    yield vec2(verts[vert].x.float32, verts[vert].y.float32)
#________________________________________
iterator icolor *(m :PMesh) :Color=
  let colors = m.colors
  for vert in 0..<m.vertexCount:
    yield color(colors[vert].r.float32, colors[vert].g.float32, colors[vert].b.float32, colors[vert].a.float32)


#________________________________________
# Assimp Materials + Textures
#______________________________
# All materials are stored in an array of aiMaterial inside the aiScene.
# Each aiMesh refers to one material by its index in the array.
# Due to the vastly diverging definitions and usages of material parameters
# there is no hard definition of a material structure.
# Instead a material is defined by a set of properties accessible by their names.

# Textures are organized in stacks, 
# each stack being evaluated independently. 
# The final color value from a particular texture stack is used in the shading equation. 
# For example, the computed color value of the diffuse texture stack (aiTextureType_DIFFUSE) 
#   is multipled with the amount of incoming diffuse light
#   to obtain the final diffuse color of a pixel.
#______________________________
#[
type
  PMesh*          = ptr TMesh
  TMesh* {.pure.} = object
    materialIndex*: cint

  PScene*          = ptr TScene
  TScene* {.pure.} = object
    materialCount*: cint
    materials*: ptr UncheckedArray[PMaterial]
    textureCount*: cint
    textures*: ptr UncheckedArray[PTexture]

  PMaterial *          = ptr TMaterial
  TMaterial * {.pure.} = object
    properties     *:ptr PMaterialProperty
    propertyCount  *:cint
    numAllocated   *:cint

  PMaterialProperty * = ptr TMaterialProperty
  TMaterialProperty * = object
    key         *:AIstring
    semantic    *:cint
    index       *:cint
    dataLength  *:cint
    kind        *:TPropertyTypeInfo
    data        *:ptr char


#______________________________
proc getTextureCount*(mat     :PMaterial;
                      kind    :TTextureType)
                      :uint32 {.importc: "aiGetMaterialTextureCount", dynlib: LibName.}
#______________________________
proc getTexture     *(mat     :PMaterial;
                      kind    :TTextureType;
                      index   :cint;
                      path    :ptr AIstring;
                      mapping :ptr TTextureMapping = nil;
                      uvIndex :ptr cint = nil;
                      blend   :ptr cfloat = nil;
                      op      :ptr TTextureOp = nil;
                      mapMode :ptr TTextureMapMode = nil;  
                      flags   :ptr cint = nil)
                      :AIreturn {.importc: "aiGetMaterialTexture", dynlib: LibName.}
]#
#________________________________________
template matId *(m :PMesh) :cint=  m.materialIndex
  ## Alias for PMesh.materialIndex

#________________________________________
proc getTextureFile *(scene :PScene; matId :int; typ :TTextureType; texId :int= 0) :string=
  var tex :AIstring
  case scene.materials[matId].getTexture(typ, texId.cint, path = tex.addr, nil, nil, nil, nil, nil)
  of   ReturnOutOfMemory: result = ""
  of   ReturnFailure:     result = ""
  of   ReturnSuccess:     result = $tex
#______________________________
#[
  TTextureType* {.size: sizeof(cint).} = enum
    TexNone       =  0, TexDiffuse      =  1, TexSpecular =  2, TexAmbient   = 3,
    TexEmissive   =  4, TexHeight       =  5, TexNormals  =  6, TexShininess = 7,
    TexOpacity    =  8, TexDisplacement =  9, TexLightmap = 10,
    TexReflection = 11, TexUnknown      = 12
]#
#______________________________
template getAmbient  *(scene :PScene; matId :int; texId :int= 0) :string=
  scene.getTextureFile(matId, TTextureType.TexAmbient, texId)
#______________________________
template getDiffuse  *(scene :PScene; matId :int; texId :int= 0) :string=
  scene.getTextureFile(matId, TTextureType.TexDiffuse, texId)
#______________________________
template getSpecular *(scene :PScene; matId :int; texId :int= 0) :string=
  scene.getTextureFile(matId, TTextureType.TexSpecular, texId)
#______________________________
template getEmissive *(scene :PScene; matId :int; texId :int= 0) :string=
  scene.getTextureFile(matId, TTextureType.TexEmissive, texId)

# proc getTextureCount*(mat :PMaterial;  kind :TTextureType) :uint32 {.importc: "aiGetMaterialTextureCount", dynlib: LibName.}
template hasAmbient *(mat :PMaterial) :bool=
  getTextureCount(mat, TTextureType.TexAmbient) > 0

