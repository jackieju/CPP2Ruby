def read_file(fname)
    begin
        if FileTest::exists?(fname) 
            data= nil  
            open(fname, "r") {|f|
                   data = f.read
            }
            return data
        else
            p "file #{fname} not exists"
        end
    rescue Exception=>e
         # logger.error e
         p e.inspect
    end
    return nil
end