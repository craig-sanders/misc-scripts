#! /bin/bash

dmigrep.pl ddr3 dimm | grep -E '^Handle|Size|Bank|Type:|Speed:|^$'
