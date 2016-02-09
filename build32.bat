@echo off
rem    Greenfish Icon Editor Pro
rem    Copyright (c) 2012-13 B. Szalkai

rem    This program is free software: you can redistribute it and/or modify
rem    it under the terms of the GNU General Public License as published by
rem    the Free Software Foundation, either version 3 of the License, or
rem    (at your option) any later version.

rem    This program is distributed in the hope that it will be useful,
rem    but WITHOUT ANY WARRANTY; without even the implied warranty of
rem    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
rem    GNU General Public License for more details.

rem    You should have received a copy of the GNU General Public License
rem    along with this program.  If not, see <http://www.gnu.org/licenses/>.

rem Set 32-bit Lazarus installation location here.
set lazarus32=c:\lazarus32
rem Set 32-bit Lazarus config path here.
set lazarus32config=%lazarus32%\__config

rem Modify output exe name
sed s/gfie64/gfie32/g gfie.lpi > __gfie32.lpi

copy gfie.ico __gfie32.ico
copy gfie.res __gfie32.res

"%lazarus32%\lazbuild" --primary-config-path="%lazarus32%\__config" --operating-system=win32 --cpu=i386 __gfie32.lpi
del __gfie32.lpi
del __gfie32.ico
del __gfie32.res
