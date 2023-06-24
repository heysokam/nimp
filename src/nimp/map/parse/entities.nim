#:____________________________________________________
#  nimp  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:____________________________________________________
# std Dependencies
import std/strscans  # For parsing the data without Regex
import std/tables
import std/strutils
# ndk dependencies
import nstd/types  as baseTypes
import nmath
# Module Dependencies
import ../types
import ./helper
import ./blocks
import ./brushes
from   ./patterns as p import nil

#____________________
# Entity keys
const kClassname      = "classname"          ## Classname property key
const kWorldspawn     = "worldspawn"         ## World entity classname
const kOrigin         = "origin"             ## Name of the entity position vector
const kAngle          = "angle"              ## Name of Y rotation property (stored in degrees as a single number).
const kLight          = "light"              ## Classname for lights, but also used as their brightness property name.
const DefLightPower * = 300                  ## Light power that is stored when the property is missing (default = 300)
const kModel          = "misc_model"         ## Model classname property
const kModelFile      = "model"              ## Model file property
const DefModel        = "dbg/cube.gltf"      ## Default model to load when missing
const kSpawn          = "info_player_start"  ## Entity classname that will considered a Spawn

#____________________
func getClass(ent :Entity) :str= 
  for key, val in ent.properties:
    if key in [kClassname]: result = val; break

#____________________
func parseOrigin(val :str) :DVec3=
  if val.scanf(p.origin, result.x, result.y, result.z): return
#__________
func getOrigin(ent :Entity) :DVec3=
  for key, val in ent.properties:
    if key in [kOrigin]: result = val.parseOrigin; break

#____________________
func getAngle(ent :Entity) :int=
  for key, val in ent.properties:
    if key in [kAngle]: result = val.parseInt; break

#____________________
func toOther(ent :Entity) :EntityOther=
  ## Converts the given shapeless entity to the EntityOther format.
  # Create properties buffer, and remove object duplicates
  var prp = ent.properties
  prp.del(kClassname)
  prp.del(kOrigin)
  # Add all fields
  new result
  result.id         = ent.id
  result.class      = ent.getClass
  result.origin     = ent.getOrigin
  result.angle      = ent.getAngle
  result.properties = prp
  result.brushes    = ent.brushes
#____________________
func getWorldAndOthers *(ent :seq[Entity]) :tuple=
  ## Categorizes the given list of Entities,
  ## and returns a tuple containing world and other entities as separate lists of entities.
  var world :EntityWorld
  var other :seq[EntityOther]
  for it in ent:
    if it.getClass in [kWorldspawn]:
      world.brushes.add(it.brushes)
    else: 
      other.add(it.toOther)
  return (world, other)
#____________________
func toLight *(ent :EntityOther) :EntityLight=
  ## Converts the given EntityOther to the EntityLight format.
  if ent.class != kLight: raise newException(OSError, "Tried to convert an entity that's not a light to the EntityLight format.")
  new result
  result.id         = ent.id
  result.origin     = ent.origin
  result.angle      = ent.angle
  result.properties = ent.properties
  if result.properties.hasKey(kLight):
    result.power = result.properties[kLight].parseInt
    result.properties.del(kLight)
  else:
    result.power = DefLightpower
#____________________
func toModel *(ent :EntityOther) :EntityModel=
  ## Converts the given EntityOther to the EntityLight format.
  if ent.class != kModel: raise newException(OSError, "Tried to convert an entity that's not a model to the EntityModel format.")
  new result
  result.id         = ent.id
  result.origin     = ent.origin
  result.angle      = ent.angle
  result.properties = ent.properties
  if result.properties.hasKey(kModelFile):
    result.file = result.properties[kModelFile]
    result.properties.del(kModelFile)
  else:
    result.file = DefModel
#____________________
func toSpawn *(ent :EntityOther) :EntitySpawn=
  ## Converts the given EntityOther to the EntitySpawn format.
  if ent.class != kSpawn: raise newException(OSError, "Tried to convert an entity that's not a spawn to the EntitySpawn format.")
  new result
  result.id         = ent.id
  result.origin     = ent.origin
  result.angle      = ent.angle
  result.properties = ent.properties

#______________________________
func categorize *(ents :seq[EntityOther]) :tuple=
  ## Categorizes the given list of EntityOther,
  ## and returns a tuple with each of its categories as a separate list of entities.
  var lights :seq[EntityLight]
  var models :seq[EntityModel]
  var spawns :seq[EntitySpawn]
  var others :seq[EntityOther]
  for ent in ents:
    case ent.class
    of kLight:  lights.add(ent.toLight)
    of kModel:  models.add(ent.toModel)
    of kSpawn:  spawns.add(ent.toSpawn)
    else:       others.add(ent)
  return (lights, models, spawns, others)

#______________________________
func getAllBrushes *(ent :seq[Entity]) :seq[Brush]=
  var world :EntityWorld
  var other :seq[EntityOther]
  (world, other) = getWorldAndOthers(ent)
  result &= world.brushes
  for it in other: result &= it.brushes

#____________________
# Entity ID
func parseId (b :Block) :tuple=
  var id  :int
  var typ :str
  if b.title.scanf(p.id, typ, id): return (id, typ)
#______________________________

#______________________________
# Entity Properties
func parseProperty (line :str) :Properties=
  var key, val :str
  if line.scanf(p.properties, key, val): result[key] = val
#__________
func parseProperties (buf :Block) :Properties=
  for line in buf.content:  result = result.merge(line.parseProperty)
#______________________________


#______________________________
func parseEnt (buf :Block) :Entity= 
  var id  :int    = 0
  var typ :string = ""
  var prp :Properties
  var brs :seq[Brush]
  # Get the id, type, properties and brushes
  (id, typ) = buf.parseId
  prp       = buf.parseProperties
  brs       = buf.parseBrushes
  # Add the fields
  result.id         = id
  result.typ        = typ
  result.properties = prp
  result.brushes    = brs
#______________________________
proc parseEntities *(lbuf :seq[str]) :seq[Entity]= 
  let blocks = parseBlocks(lbuf)
  for it in blocks:
    result.add(parseEnt(it))
#______________________________


