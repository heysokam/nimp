#:____________________________________________________
#  nimp  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:____________________________________________________
# std Dependencies
import std/strscans  # For parsing the data without Regex
# ndk dependencies
import nstd/types as baseTypes
# Module Dependencies
import ../types
from   ./patterns as p import nil

#______________________________
func isBOpen  *(line :str) :bool=  line.scanf(p.blockOpen)
func isBClose *(line :str) :bool=  line.scanf(p.blockClose)

#______________________________
func toMain *(b :Block) :Block=
  result    = b
  let last  = b.content.high
  let first = 0
  if b.content[last].isBClose: result.content.delete(last)
  if b.content[first].isBOpen: result.content.delete(first)

#______________________________
proc parseBlocks *(lbuf :seq[str]) :seq[Block]= 
  var buf:seq[str]
  for line in lbuf: buf.add(line)
  var bCount = 0                       # Block count
  var level  = 0                       # Current Brackets level. Increases every {, decreases every }
  var titles :seq[str]                 # Comment lines buffer
  for id,line in buf:
    var thisLine :str
    if line.scanf(p.comment, thisLine): 
      if level == 0:                   # Add comment to titles only outside of a block
        titles.add(thisline)
        continue                       # Line is title, so skip adding it to content
    elif line.isBOpen:
      if level == 0: 
        bCount.inc                     # Increase total block count
        result.add(Block(title: "//" & titles[^1], content: @[])) # Add last found comment as title, and init block content
      level.inc                        # Increase bracket level
    elif line.isBClose:                # When we find a closing bracket
      level.dec                        # Reduce the bracket level / count
    result[bCount-1].content.add(line) # Add the line to the corresponding block
#______________________________
