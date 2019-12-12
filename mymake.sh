#!/bin/sh
# This script builds GRASS GIS.

test -e ~/usr/grass/bin || mkdir ~/usr/grass/bin

cat<<'EOT'> ~/usr/grass/bin/python
#!/bin/sh
exec python3 "$@"
EOT

PATH="$HOME/usr/grass/bin:$PATH"

make > mymake.log 2>&1
