#!/bin/sh
src_dir=/Users/i027910/p4root/BUSMB_B1/SBO/9.3_COR/Source
#ruby translate.rb -d output POJDT.c
#ruby translate.rb -d output -I $src_dir/Client/Application/ObjMgr/Hdr $src_dir/Client/Application/ObjMgr/Core/_Enviroment.cpp $src_dir/Client/Application/ObjMgr/POJDT.c $src_dir/Client/Application/ObjMgr/POJDT1.c 
ruby translate.rb -d output -I $src_dir/Client/Application/ObjMgr/Hdr POJDT.c 

#ruby translate.rb -d output  -I /Users/i027910/p4root/BUSMB_B1/SBO/9.3_COR/Source/Client/Application/ObjMgr/Hdr /Users/i027910/p4root/BUSMB_B1/SBO/9.3_COR/Source/Client/Application/ObjMgr/POJDT.c

#ruby translate.rb -d output -I $src_dir/Client/Application/ObjMgr/Hdr t2.cpp