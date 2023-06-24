#:____________________________________________________
#  nimp  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:____________________________________________________
# std Dependencies
import std/strutils
import std/sequtils
# ndk dependencies
import nstd/types as baseTypes
# Module Dependencies
import ./types
import ./parse/game
import ./parse/format
import ./parse/entities

#______________________________
proc parse (mapl :seq[str]) :Map=
  ## Parses a `.map` file from the given sequence of lines
  ## and outputs a Map object containing its data
  result.format  = mapl.parseFormat
  result.game    = mapl.parseGame
  (result.world,  result.ents) = mapl.parseEntities.getWorldAndOthers
  (result.lights, result.models, result.spawns, result.ents) = result.ents.categorize

#______________________________
proc readMap *(src :str) :Map=  src.lines.toSeq.parse
  ## Reads a .map file from the given src path
  ## and outputs a Map object containing its data
#______________________________
proc parse *(raw :str) :Map=  raw.splitLines.parse
  ## Parses a `.map` file from the given raw `.map` data in string form
  ## and outputs a Map object containing the data
