#:____________________________________________________
#  nimp  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:____________________________________________________
# std dependencies
import std/strscans  # For parsing the data without Regex
# ndk dependencies
import nmath
# Engine Dependencies
import ../types
# Module Dependencies
import ./blocks
from   ./patterns as p import nil


#______________________________
# Face

func parseFace(line :string) :Face= 
  if line.scanf( p.face, 
    result.p1.x, result.p1.y, result.p1.z,
    result.p2.x, result.p2.y, result.p2.z,
    result.p3.x, result.p3.y, result.p3.z,
    result.tex.name,
    result.tex.tm1.x, result.tex.tm1.y, result.tex.tm1.z, result.tex.tm1.offset,
    result.tex.tm2.x, result.tex.tm2.y, result.tex.tm2.z, result.tex.tm2.offset,
    result.tex.rot, result.tex.scale.x, result.tex.scale.y
    ): return
#______________________________
func isFace(line :string) :bool=  line.scanf(p.faceCheck)
func hasFace(b :Block) :bool=
  for line in b.content:
    if line.isFace: result = true; break
    else: result = false
#__________
proc clear(b :var Brush) :void=  b.id = -1; b.faces.setLen(0)
#______________________________


#______________________________
func parseBrushes *(buf :Block) :seq[Brush]=
  if not buf.hasFace: return @[]
  var bBuf     = buf.toMain  # Remove opening/closing brackets, if present
  var tmpBrush :Brush
  var typ      :string
  for lnum, line in bBuf.content:
    var idPrev     = (lnum-1).max(0)
    var idPrevprev = (lnum-2).max(0)
    var prev       = bBuf.content[idPrev]
    var prevprev   = bBuf.content[idPrevprev]
    var lineIsFace = line.isFace
    var prevIsFace = prev.isFace
    if lineIsFace and prev.isBOpen:                  # Starting a new brush block
      tmpBrush.clear                                 #   Clear the temp brush
      discard prevprev.scanf(p.id, typ, tmpBrush.id) #   Set tempbrush id with the Id 2lines above
    elif lineIsFace and prevIsFace:                  # Inside a brush block
      tmpBrush.faces.add(line.parseFace)             #   Add the face to the temp brush
    elif line.isBClose and prevIsFace:               # Finishing a brush block
      result.add(tmpBrush)                           #   Add the temp brush buffer to the result


