src_dir=/Users/i027910/p4root/BUSMB_B1/SBO/9.3_COR/Source
#ruby translate.rb -d output POJDT.c
ruby translate.rb -d output -I $src_dir/Client/Application/ObjMgr/Hdr /Client/Application/ObjMgr/Core/_Enviroment.cpp $src_dir/Client/Application/ObjMgr/POJDT.c $src_dir/Client/Application/ObjMgr/POJDT1.c 
