ret = {}
path = "/Users/i027910/p4root/BUSMB_B1/SBO/9.3_COR/Source/**/*.h"
Dir[path].each { |f|
 #   print ("load #{f}\n")
    d = File.dirname(f)
    ret[d] = 1
 }
 
 print ret.keys.join(";")
