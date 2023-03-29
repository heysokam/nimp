#:____________________________________________________
#  nimp  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:____________________________________________________
# std dependencies
import std/os
# External dependencies
import pkg/chroma
# ndk dependencies
import nstd/types  as base
import nmath/types as m
# Module dependencies
import ../types
import ./assimp
import ./material


#______________________________
template addPos (m :var Mesh; iter :iterable[Vec3]) :void=
  for vec in iter:  m.pos.add(vec)
#______________________________
template addColor (m :var Mesh; iter :iterable[Color]) :void=
  for color in iter:  m.color.add(color)
#______________________________
template addUV (m :var Mesh; iter :iterable[Vec2]) :void=
  for vec in iter:  m.uv.add(vec)
#______________________________
template addNorm (m :var Mesh; iter :iterable[Vec3]) :void=
  for vec in iter:  m.norm.add(vec)
#______________________________
proc addInds (m :var Mesh; src :PMesh) :void=
  ## Takes an assimp imported PMesh, and stores the indices into the target mesh
  m.inds = newSeqOfCap[UVec3](src.faceCount)
  # inds.data = newSeqOfCap[i32](m.faceCount * 3)   # TODO: This was the original. Does our version work ?? Confirm befored deleting
  for face in src.ifaces:
    doAssert face.indexCount == 3, "Only supporting triangulated models"
    let start = m.inds.len
    m.inds.setLen(start + face.indexCount)
    m.inds[start].addr.copyMem(face.indices, face.indexCount*cint.sizeof)
#______________________________
# proc new *[T](kind :Mat; file :str= ""; K :T= default(T); internalName :str= "") :Material[T]=
proc addMats (m :var Mesh; scene :PScene; matId :int; dir :str) :void=
  # TODO: Multi-texture materials (think: detail textures + color)
  m.mats.dif =  Diffuse.new(dir/scene.getDiffuse(matId,0), color(0,0,0))
  m.mats.spe = Specular.new(dir/scene.getSpecular(matId,0), 0'f32)
#______________________________
template hasMats (s :PScene) :bool=
  # TODO: Proper material importing system
  scene.materialCount > 0

#______________________________
proc load *(
    file   :str;
    altDir :str= getAppDir()/"res";
    flags  :set[ImportProcess]= {genSmoothNormals}
    ) :Model=
  ## Loads a model file into the library's data format, using assimp.
  ## Populates the vertex data and materials for each of the meshes in the model file.
  ## Searches for file as:
  ##   Relative to current executable dir
  ##   Relative to altDir if current dir check failed
  ##   `altDir` will be `currentAppDir/res` when omitted
  ## Searches for material textures in that same dir, based on the imported model texture information.
  ## Generates vertex normals by default, unless flags is set to empty or the model already has them.
  ## Faces are triangulated on import.
  var path = getAppDir()/file
  let ext  = file.splitFile.ext
  if ext == ".glb":  raise newException(IOError, ".glb files are not supported. Use .gltf+tex")
  var scene = aiImportFile(path.cstring, flags)
  if scene == nil:  # Backup search inside altDir, and exception if that also fails.
    path  = altDir/file
    scene = aiImportFile(path.cstring, {})
    if scene == nil: raise newException(IOError, path & " invalid model file")
  for mesh in scene.imeshes:
    if not mesh.hasPositions: continue  # Stop reading this mesh if no vertex, because all iterators use vert count for indexing
    var tmp :Mesh
    tmp.addPos(mesh.ivertex)
    tmp.addInds(mesh)
    if mesh.hasNormals:  tmp.addNorm(mesh.inormal)
    if mesh.hasUVs:      tmp.addUV(mesh.iuv)
    if mesh.hasColors:   tmp.addColor(mesh.icolor)
    if scene.hasMats:    tmp.addMats(scene, mesh.matId, path.splitFile.dir)
    result.add(tmp)
  aiReleaseImport(scene)

