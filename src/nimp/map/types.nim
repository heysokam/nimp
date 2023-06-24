#:____________________________________________________
#  nimp  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:____________________________________________________
# std Dependencies
import std/tables
# ndk dependencies
import nstd/types
import nmath/types as m

#______________________________
type Block * = object
  title    *:str
  content  *:seq[str]
#______________________________
type TexMap * = object
  x       *:f64
  y       *:f64
  z       *:f64
  offset  *:f64
#______________________________
type Texture * = object
  name   *:str
  tm1    *:TexMap
  tm2    *:TexMap
  rot    *:f64
  scale  *:DVec2
#______________________________
type Face * = object
  p1   *:DVec3
  p2   *:DVec3
  p3   *:DVec3
  tex  *:Texture
#______________________________
type Brush * = object
  id     *:int
  faces  *:seq[Face]
#____________________
type Properties * = Table[str,str]
#____________________
type Entity * = object
  ## Raw parsed entity, before categorization
  id          *:int
  typ         *:string
  properties  *:Properties
  brushes     *:seq[Brush]
#__________
type EntityWorld * = object
  brushes  *:seq[Brush]
#__________
type EntityBase * = ref object of RootObj
  ## Base entity type for all others (except world)
  id         *:int
  origin     *:DVec3
  angle      *:int
  properties *:Properties
#__________
type EntityOther * = ref object of EntityBase
  ## Unknown or to-be-implemented entity. Could be brush-entity or point-entity
  class      *:str
  brushes    *:seq[Brush]
#__________
type EntityLight * = ref object of EntityBase
  power      *:int
#__________
type EntityModel * = ref object of EntityBase
  file       *:str
#__________
type EntitySpawn * = ref object of EntityBase
#____________________
type Map * = object
  format   *:str
  game     *:str
  world    *:EntityWorld
  lights   *:seq[EntityLight]
  models   *:seq[EntityModel]
  spawns   *:seq[EntitySpawn]
  ents     *:seq[EntityOther]
  # properties *:Properties  #TODO

