#:____________________________________________________
#  nimp  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:____________________________________________________
#TODO

#_______________________________________
# type Camera * = ref object
#   name   *:string
#   pos    *:Vector3
#   up     *:Vector3
#   lookat *:Vector3
#   fovx   *:float32
#   near   *:float32
#   far    *:float32
#   ratio  *:float32
#   width  *:float32 # OrthographicWidth
#_______________________________________
# type Light * = ref object
#   kind                 *:ai.LightSource
#   name                 *:string
#   position             *:Vector3
#   direction            *:Vector3
#   attenuationConst     *:float32
#   attenuationLinear    *:float32
#   attenuationQuadratic *:float32
#   colorDiffuse         *:ColorRGB
#   colorSpecular        *:ColorRGB
#   colorAmbient         *:ColorRGB
#   innerCone            *:float32
#   outerCone            *:float32
#_______________________________________
type Scene * = ref object
#   models *:seq[Model]
#   cams   *:seq[Camera]
#   lights *:seq[Light]


#_____________________________________________________
proc jsonScene *(buffer :string; dir :Path) :Scene=
  ## Loads a Model object from the given string bytebuffer.
  var gltf = loadJson.gltf(buffer, dir)
proc jsonSceneMem *(buffer :string; dir :Path) :Scene=  buffer.jsonScene(dir)
  ## (alias) Loads a Model object from the given string bytebuffer.
#_____________________________________________________
proc jsonScene *(file :Path) :Scene=  file.readFile.jsonScene( file.splitFile.dir.Path )
  ## Loads a Model object from the given file path.
proc jsonSceneFile *(file :Path) :Scene=  file.jsonScene()
  ## (alias) Loads a Model object from the given file path.
#_____________________________________________________
proc binScene *(buffer :string; dir :Path) :Scene=
  ## Loads a Model object from the given string bytebuffer.
  var gltf = loadBinary.gltf(buffer, dir)
proc binSceneMem *(buffer :string; dir :Path) :Scene=  buffer.binScene(dir)
  ## (alias) Loads a Model object from the given string bytebuffer.
#_____________________________________________________
proc binScene *(file :Path) :Scene=  file.readFile.binScene( file.splitFile.dir.Path )
  ## Loads a Model object from the given file path.
proc binSceneFile *(file :Path) :Scene=  file.binScene()
  ## (alias) Loads a Model object from the given file path.

