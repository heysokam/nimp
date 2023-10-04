#:____________________________________________________
#  nimp  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:____________________________________________________
# std dependencies
import std/os
import std/paths
import std/strformat
import std/tables
# External dependencies
from pkg/chroma import Color, color
# n*dk dependencies
import nmath
import nstd/size
from ngltf as gltf import nil
from ngltf/validate import hasIndices, hasPositions, hasUVs, hasNormals, hasColors, hasMaterial
# n*imp dependencies
import ./types

#_______________________________________
# Types
#_____________________________
# Same as ngpu.Mesh
type Mesh * = ref object
  pos    *:seq[Vec3]
  color  *:seq[Color]
  uv     *:seq[Vec2]
  norm   *:seq[Vec3]
  inds   *:seq[U16Vec3]
  # mat    *:Material
#__________________
type Model * = seq[Mesh]

#_______________________________________
# Validation
#_____________________________
func onlyTriangles *(mesh :gltf.Mesh) :void=
  ## Checks that the given primitive contains Triangles. Raises an ImportError exception otherwise
  ## ngltf does not support non-Triangle data for Data objects.
  ## If you need other types of primitives, get the raw glTF object from the internal functions and extract the information from there.
  if not (mesh.mode == gltf.MeshType.Triangles): raise newException(ImportError, &"""\n
  Tried to get MeshData from a Mesh that contains non-Triangle primitives.
  nimp does not support non-Triangle data.
  Get the raw gltf object with ngltf and extract its contents directly if you need other types of primitives.""")
#_____________________________
func onlyTriangles *(mdl :gltf.Model) :void=
  ## Checks that all of the meshes in the given list contain only Triangles. Raises an ImportError exception otherwise.
  ## ngltf does not support non-Triangle data for Data objects.
  ## If you need other types of primitives, get the raw glTF object from the internal functions and extract the information from there.
  for mesh in mdl.meshes: mesh.onlyTriangles()
#_____________________________
func hasPositions *(mesh :gltf.Mesh)  :void=
  if not validate.hasAttr( mesh, gltf.MeshAttribute.pos ): raise newException(ImportError, "Tried to load a Mesh (spec.MeshPrimitive) that has no vertex position information.")
func hasPositions *(mdl  :gltf.Model) :void=
  for mesh in mdl.meshes:
    if not validate.hasAttr( mesh, gltf.MeshAttribute.pos ): raise newException(ImportError, "Tried to load a Model (spec.Mesh) that has no vertex position information in one or more of its meshes (spec.primitives).")


#_______________________________________
# Buffer: Data Access
#_____________________________
type SomeIntermediate = float32 | Vec2 | Vec3 | Vec4 | U16Vec3 | Color | Mat3 | Mat4
  ## Types allowed for access from glTF data buffers.
#__________________
func get *[T :typedesc[SomeIntermediate]](buf :gltf.Buffer; t :T; accs :gltf.Accessor; view :gltf.BufferView; size,id :SomeInteger) :t=
  ## Returns the `id`th T object pointed by the accessor from the given buffer.
  let start = gltf.offset(view)+gltf.offset(accs) + size*id  # Start byte to read
  copyMem(result.addr, buf.data.bytes[start].addr, size)
#_____________________________
func get *[T :typedesc[SomeIntermediate]](buf :gltf.Buffer; t :T; accs :gltf.Accessor; view :gltf.BufferView; id :SomeInteger) :t=
  ## Returns the `id`th T object pointed by the accessor from the given buffer.
  buf.get(t, accs, view, gltf.itemSize(accs), id)


#_______________________________________
# Mesh: Data Access
#_____________________________
from ngltf/types/accessor import AccessorComponentType, count
iterator indices *(f :gltf.GLTF; mesh :gltf.Mesh) :U16Vec3=
  # note: Currently only accepts triangles data with uint16 components
  let accs = f.accessors[ mesh.indices ]
  let view = f.bufferViews[accs.bufferView]
  let buff = f.buffers[ view.buffer ]
  case  accs.componentType
  of    AccessorComponentType.UnsignedShort: discard
  else: raise newException(ImportError, &"Loading Mesh Indices with format {$accs.componentType} is not supported.")
  for id in 0..<accs.count div 3: yield buff.get(U16Vec3, accs, view, gltf.itemSize(accs)*3, id)
#_____________________________
iterator positions *(f :gltf.GLTF; mesh :gltf.Mesh) :Vec3=
  let accs = f.accessors[ mesh.attributes[ $gltf.MeshAttribute.pos ] ]
  let view = f.bufferViews[accs.bufferView]
  let buff = f.buffers[ view.buffer ]
  for id in 0..<accs.count: yield buff.get(Vec3, accs, view, id)
#_____________________________
iterator colors *(f :gltf.GLTF; mesh :gltf.Mesh) :Color=
  let accs = f.accessors[ mesh.attributes[ $gltf.MeshAttribute.color ] ]
  let view = f.bufferViews[accs.bufferView]
  let buff = f.buffers[ view.buffer ]
  for id in 0..<accs.count: yield buff.get(Color, accs, view, id)
#_____________________________
iterator uvs *(f :gltf.GLTF; mesh :gltf.Mesh) :Vec2=
  let accs = f.accessors[ mesh.attributes[ $gltf.MeshAttribute.uv ] ]
  let view = f.bufferViews[accs.bufferView]
  let buff = f.buffers[ view.buffer ]
  for id in 0..<accs.count: yield buff.get(Vec2, accs, view, id)
#_____________________________
iterator normals *(f :gltf.GLTF; mesh :gltf.Mesh) :Vec3=
  let accs = f.accessors[ mesh.attributes[ $gltf.MeshAttribute.norm ] ]
  let view = f.bufferViews[accs.bufferView]
  let buff = f.buffers[ view.buffer ]
  for id in 0..<accs.count: yield buff.get(Vec3, accs, view, id)

#_______________________________________
# Mesh: Convert gltf to Export type
#_____________________________
template dbg () :void {.dirty.}=
  for id,it in result.pairs: debugEcho id," ",it
  debugEcho result.len
  debugEcho "\nAccessors:"
  for name,val in accs.fieldPairs:
    debugEcho "  ",name," ",val
  debugEcho "\nBufferViews:"
  for name,val in view.fieldPairs:
    debugEcho "  ",name," ",val
#_____________________________
func getPositions *(f :gltf.GLTF; mesh :gltf.Mesh) :seq[Vec3]=
  let accs = f.accessors[ mesh.attributes[ $gltf.MeshAttribute.pos ] ]
  let view = f.bufferViews[accs.bufferView]
  validate.sameLength(accs, view)
  result = newSeqOfCap[result[0].type](accs.count)
  # for pos in f.positions(mesh): result.add pos
  for pos in f.positions(mesh): result.add vec3(pos.x, -pos.y, pos.z) # TEMP: invert Y axis, until coordinates are fixed
  # dbg
#_____________________________
func getIndices *(f :gltf.GLTF; mesh :gltf.Mesh) :seq[U16Vec3]=
  let accs = f.accessors[ mesh.indices ]
  let view = f.bufferViews[accs.bufferView]
  validate.sameLength(accs, view)
  result = newSeqOfCap[result[0].type](accs.count)
  for ind in f.indices(mesh): result.add ind
  # dbg
#_____________________________
func getColors *(f :gltf.GLTF; mesh :gltf.Mesh) :seq[Color]=
  let accs = f.accessors[ mesh.attributes[ $gltf.MeshAttribute.color ] ]
  let view = f.bufferViews[accs.bufferView]
  validate.sameLength(accs, view)
  result = newSeqOfCap[result[0].type](accs.count)
  for color in f.colors(mesh): result.add color
  # dbg
#_____________________________
func getUVs *(f :gltf.GLTF; mesh :gltf.Mesh) :seq[Vec2]=
  let accs = f.accessors[ mesh.attributes[ $gltf.MeshAttribute.uv ] ]
  let view = f.bufferViews[accs.bufferView]
  validate.sameLength(accs, view)
  result = newSeqOfCap[result[0].type](accs.count)
  for uv in f.uvs(mesh): result.add uv
  # dbg
#_____________________________
func getNormals *(f :gltf.GLTF; mesh :gltf.Mesh) :seq[Vec3]=
  let accs = f.accessors[ mesh.attributes[ $gltf.MeshAttribute.norm ] ]
  let view = f.bufferViews[accs.bufferView]
  validate.sameLength(accs, view)
  result = newSeqOfCap[result[0].type](accs.count)
  for norm in f.normals(mesh): result.add norm
  # dbg
#_____________________________
# func getMaterial  *(f :GLTF; mesh :Mesh) :Material=   discard # mesh.material

#_____________________________
func getData (f :gltf.GLTF; mesh :gltf.Mesh; name :string) :Mesh=
  ## Converts the given mesh into a MeshData object.
  new result
  onlyTriangles( mesh )
  hasPositions( mesh )
  # result.primitives = gltf.Triangles
  # result.name       = name
  result.pos        = f.getPositions(mesh)
  if mesh.hasIndices:  result.inds  = f.getIndices(mesh)
  if mesh.hasColors:   result.color = f.getColors(mesh)
  if mesh.hasUVs:      result.uv    = f.getUVs(mesh)
  if mesh.hasNormals:  result.norm  = f.getNormals(mesh)
  # if mesh.hasMaterial: result.mat   = f.getMaterial(mesh)
#_____________________________
func getData (f :gltf.GLTF; mdl :gltf.Model) :Model=
  ## Converts all meshes in the input model into a ModelData object (aka seq[MeshData])
  for id,mesh in mdl.meshes.pairs:  result.add f.getData(mesh, &"{mdl.name}_mesh{id}")
#_____________________________
func getData (f :gltf.GLTF; mdls :gltf.Models) :Model=
  ## Converts all meshes in the input model list into a single object
  ## Completely ignores the structure of the gltf file, and assumes every mesh in the file is part of a single model.
  for mdl in mdls:
    for id,mesh in mdl.meshes.pairs:  result.add f.getData(mesh, &"{mdl.name}_mesh{id}")

#_____________________________________________________
proc load *(input :string|Path) :Model=
  ## Loads a gltf file and returns a Model object.
  let gltf = gltf.load(input)
  result   = gltf.getData(gltf.models)






##[ nimp: Before
#____________________
type Mat * = enum
  Diffuse, Specular, Shininess, Ambient, Emissive,
  Normals, Height, Displacement,
  Lightmap, Reflection
#____________________
type Material *[T] = object
  kind  *:Mat    ## Material type
  file  *:str    ## File path of the material
  name  *:str    ## Internal name of the material
  tex   *:Image  ## Material texture, contains a K value for each pixel individually
  K     *:T      ## Value property of the material, applied to the texture uniformly
#____________________
type Materials * = object
  dif  *:Material[Color]
  spe  *:Material[float32]

#____________________
# Mesh / Model
type Mesh * = object
  # pos    *:seq[Vec3]
  # color  *:seq[Color]
  # uv     *:seq[Vec2]
  # norm   *:seq[Vec3]
  # inds   *:seq[UVec3]
  mats   *:Materials
#____________________
# type Model * = seq[Mesh]
]##


##[ ngltf: Data types
# Textures
type TextureType *{.pure.}= enum
  none
  diffuse, specular, ambient, emissive,
  height, normals, shininess, opacity,
  displacement, lightmap, reflection, unknown
type Texture * = ref object
  format  *:string
  size    *:UVector2
  pixels  *:seq[Pixel]
#_______________________________________
type TextureInfo * = ref object
  path  *:string
  data  *:Texture
type TextureList * = array[TextureType, seq[TextureInfo]]

#_______________________________________
# Materials
type MaterialData * = ref object
  id   *:int
  tex  *:TextureList

#_______________________________________
# Meshes and Models
type Mesh * = ref object
  primitives  *:MeshType          ## Types of primitives contained in the mesh
  name        *:string            ## Mesh name
  inds        *:seq[U16Vector3]   ## Face indices
  pos         *:seq[Vector3]      ## Vertex Positions
  colors      *:seq[Color]        ## Vertex colors
  uvs         *:seq[Vector2]      ## Texture coordinates
  norms       *:seq[Vector3]      ## Normal vectors
  # tans        *:seq[Vector3]      ## Tangents
  # bitans      *:seq[Vector3]      ## Bitangents
  material    *:MaterialData
#_______________________________________
type Model * = seq[Mesh]  # Models are a list of meshes
]##


##[ ngltf: Other
type MeshData * = ref object
  # name        *:string            ## Mesh name
  # inds        *:seq[UVector3]     ## Face indices
  # pos         *:seq[Vector3]      ## Vertex Positions
  # colors      *:seq[Color]        ## Vertex colors
  # uvs         *:seq[Vector2]      ## Texture coordinates
  # norms       *:seq[Vector3]      ## Normal vectors
  tans        *:seq[Vector3]      ## Tangents
  bitans      *:seq[Vector3]      ## Bitangents
  material    *:MaterialData
#_______________________________________
# type ModelData * = seq[MeshData]  # Models are a list of meshes

#_______________________________________
# type MeshAttributes * = Table[string, GltfId]

type MeshPrimitive * = object
  ## Geometry to be rendered with the given material.
  # attributes  *:MeshAttributes     ## Table where each key corresponds to a mesh attribute semantic and each value is the index of the accessor containing attribute's data.
  # indices     *:GltfId             ## The index of the accessor that contains the vertex indices.
  material    *:GltfId             ## The index of the material to apply to this primitive when rendering.
  # mode        *:MeshType           ## The topology type of primitives to render.
  targets     *:JsonStringList     ## An array of morph targets.
  # extensions  *:Extension          ## JSON object with extension-specific objects.
  # extras      *:Extras             ## Application-specific data.
type MeshPrimitives * = seq[MeshPrimitive]

type Mesh * = object
  ## A set of primitives to be rendered.  Its global transform is defined by a node that references it.
  # primitives  *:MeshPrimitives     ## An array of primitives, each defining geometry to be rendered.
  weights     *:seq[float64]       ## Array of weights to be applied to the morph targets. The number of array elements **MUST** match the number of morph targets.
  # name        *:string             ## The user-defined name of this object.
  # extensions  *:Extension          ## JSON object with extension-specific objects.
  # extras      *:Extras             ## Application-specific data.
# type Meshes * = seq[Mesh]

]##

