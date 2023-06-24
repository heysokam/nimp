#:____________________________________________________
#  nimp  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:____________________________________________________


#_______________________________________
# Patterns to match with std/strscans   |
# during `.map` file parsing            |
#_______________________________________|


#____________________
# Map blocks
const comment    * = "$s//$*" ## Comment line. Modern apps also use it to differentiate brush/entity and store its id number
const blockOpen  * = "$s{$s"  ## Block or sub-block starts
const blockClose * = "$s}$s"  ## Block or sub-block ends

#____________________
# Map Type Info
# // Game: Quake
const game   * = "$s//$sGame:$s$*$."
# // Format: Valve
const format * = "$s//$sFormat:$s$*$."

#____________________
# Entities
const id         * = "$s//$w$s$i$s"           ## Entity/brush id number
const origin     * = "$s$f$s$f$s$f"           ## Entity/brush origin vector
const properties * = "$s\"$w\"$s\"$+\"$s$."   ## Entity properties

#____________________
# Brushes
const faceCheck * = "$s($s"  ## When it matches, this line is a face
const face      * = """
$s($s$f$s$f$s$f$s)$s($s$f$s$f$s$f$s)$s($s$f$s$f$s$f$s)$s$* [$s$f$s$f$s$f$s$f$s]$s[$s$f$s$f$s$f$s$f$s]$s$f$s$f$s$f"""
# (  x1  y1  z1  )  (  x2  y2  z2  )  (  x3  y3  z3  ) TEXTURE [ Tx1 Ty1 Tz1 Toffset1 ] [ Tx2 Ty2 Tz2 Toffset2 ] rotation Xscale Yscale

