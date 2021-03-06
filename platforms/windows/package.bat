set DEVROOT=c:\dev2
@rem place c++ addons outside of node_modules for now
@rem to make it easier to remove/recreate node_modules
set DEST=node_modules
set MAPNIK_INSTALL=c:\mapnik-2.0
set NODEEXE="C:\Program Files (x86)\nodejs\node.exe"
set MAPNIK_DEST=%DEST%\mapnik\lib\mapnik
set MAPNIK_DATA_DEST=%DEST%\mapnik\lib\mapnik\share
mkdir %MAPNIK_DATA_DEST%

@rem make sure Python is on the PATH
set PATH=%PATH%;c:\Python27

@rem change into current directory
cd /d %~dp0
@rem then move to main tilemill folder
cd ..\..\
set TILEMILL_DIR=%CD%

@rem mkdir %DEST%

@rem nuke any failed c++ module installs
@rem rd /q /s node_modules\bones\node_modules\jquery\node_modules\jsdom\node_modules\contextify
@rem rd /q /s node_modules\sqlite3
rd /q /s node_modules\mapnik
rd /q /s node_modules\millstone\node_modules\srs
rd /q /s node_modules\millstone\node_modules\zipfile
rd /q /s node_modules\tilelive-mapnik\node_modules\eio

@rem remove then re-copy node-mapnik
xcopy /i /s /exclude:platforms\windows\excludes.txt %DEVROOT%\node-mapnik %DEST%\mapnik

@rem fixup paths to plugins making them relative 
@rem to future location of mapnik itself
cd %DEST%\mapnik
@rem - note, intentially not quoting the below
set MAPNIK_INPUT_PLUGINS=path.join(__dirname, 'mapnik/lib/mapnik/input')
set MAPNIK_FONTS=path.join(__dirname, 'mapnik/lib/mapnik/fonts')
python gen_settings.py
@rem augment the settings
echo var path = require('path'); module.exports.env = {'ICU_DATA': path.join(__dirname, 'mapnik/share/icu'), 'GDAL_DATA': path.join(__dirname, 'mapnik/share/gdal'),'PROJ_LIB': path.join(__dirname, 'mapnik/share/proj') }; >> lib/mapnik_settings.js


chdir /d %TILEMILL_DIR%
@rem symlink mapnik into main directory so npm is happy
@rem mklink /d /j node_modules/mapnik %DEST%/mapnik

@rem - handle mapnik itself
rd /q /s %MAPNIK_DEST%
xcopy /i /s /exclude:platforms\windows\excludes.txt %MAPNIK_INSTALL% %MAPNIK_DEST%

@rem - move all other C++ addons into place
rd /q /s %DEST%\zipfile
xcopy /i /s /exclude:platforms\windows\excludes.txt %DEVROOT%\node-zipfile %DEST%\zipfile
rd /q /s %DEST%\srs
xcopy /i /s /exclude:platforms\windows\excludes.txt %DEVROOT%\node-srs %DEST%\srs
@rem rd /q /s %DEST%\sqlite3
@rem xcopy /i /s /exclude:platforms\windows\excludes.txt %DEVROOT%\node-sqlite3 %DEST%\sqlite3
@rem rd /q /s %DEST%\contextify
@rem xcopy /i /s /exclude:platforms\windows\excludes.txt %DEVROOT%\contextify %DEST%\contextify

@rem - move icu, proj, and gdal data into node-mapnik folder
rd /q /s %MAPNIK_DATA_DEST%\proj
xcopy /i /s %DEVROOT%\proj\nad %MAPNIK_DATA_DEST%\proj
rd /q /s %MAPNIK_DATA_DEST%\gdal
xcopy /i /s %DEVROOT%\gdal\data %MAPNIK_DATA_DEST%\gdal

del /q node.exe
xcopy %NODEEXE% %TILEMILL_DIR%\node.exe
