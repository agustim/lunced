#!/bin/sh

INSTALLDIR="/usr/share/lunced"
LUALIB="/usr/lib/lua/lunced"
CGIDIR="/www/cgi-bin"
INITDIR="/etc/init.d"

mkdir -p $INSTALLDIR
cp *.lua $INSTALLDIR/

mkdir -p $LUALIB/lunced
cp lunced/*.lua $LUALIB/

mkdir -p $CGIDIR
cp cgi-bin/* $CGIDIR/

mkdir -p $INITDIR
cp init.d/* $INITDIR/


