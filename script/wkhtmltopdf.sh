#!/bin/bash

# Ensure script is executable using c`hmod +x wkhtmltopdf.sh`
xvfb-run -a --server-args="-screen 0, 1024x768x24" /usr/bin/wkhtmltopdf -q $*
