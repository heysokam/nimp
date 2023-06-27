#:____________________________________________________
#  nimp  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:____________________________________________________
# Type conversions from Assimp into ndk  |
#:_______________________________________|
# External dependencies
import pkg/chroma
import nassimp as ai
# ndk dependencies
import nmath

#_____________________________
# ai.Matrix
proc toMat4 *(mat :ai.Matrix4) :Mat4=
  ## Converts an assimp.Mat4 to a nim.Mat4
  mat4(  mat[00], mat[01], mat[02], mat[03],
         mat[04], mat[05], mat[06], mat[07],
         mat[08], mat[09], mat[10], mat[11],
         mat[12], mat[13], mat[14], mat[15]  )
#_____________________________
proc toMat3 *(mat :ai.Matrix4) :Mat3=
  ## Converts an assimp.Mat3 to a nim.Mat3
  mat3(  mat[00], mat[01], mat[02],
         mat[03], mat[04], mat[05],
         mat[06], mat[07], mat[08]  )
#_____________________________
proc toVec2 *(v :ai.Vector2) :Vec2=  vec2( v.x.float32, v.y.float32 )
  ## Converts an assimp.Vec3 to a nim.Vec3
#_____________________________
proc toVec3 *(v :ai.Vector3) :Vec3=  vec3( v.x.float32, v.y.float32, v.z.float32 )
  ## Converts an assimp.Vec3 to a nim.Vec3
#_____________________________
proc toVec4 *(v :ai.Vector4) :Vec4=  vec4( v.x.float32, v.y.float32, v.z.float32, v.w.float32 )
  ## Converts an assimp.Vec4 to a nim.Vec4
#_____________________________
proc toColor *(c :ai.Color) :chroma.Color=  chroma.color( c.r.float32, c.g.float32, c.b.float32, c.a.float32 )
  ## Converts an assimp.Color to a nim.Color

