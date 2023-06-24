#:____________________________________________________
#  nimp  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:____________________________________________________
# ndk dependencies
import nstd/types as baseTypes
# Module Dependencies
import ./types

#______________________________
func `$` *(e :EntityWorld) :str= discard

#______________________________
func `$` *(m :Map) :str=
  for name, value in m.fieldPairs:
    when name in ["format"]: result.add("Format:\t" & value & "\n")
    when name in ["game"]:   result.add("Game:\t" & value & "\n")
    when name in ["brushes"]:
      for it in value.brushes: result.add($it)
    when name in ["ents"]:
      for it in value: result.add($it)
