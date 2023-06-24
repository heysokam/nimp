#:____________________________________________________
#  nimp  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:____________________________________________________
# External dependencies
import pkg/zip/zipfiles

#__________
proc unzip *(file, trgDir :string) :void=
  var zip :ZipArchive
  var ok = zip.open(file)
  if not ok:
    echo "Opening ",file," failed"
    return
  zip.extractAll(trgDir)

