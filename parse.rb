load 'cp.rb'
load 'macro.rb'

def parse_block(s, method="FunctionBody")
    p "parse using #{method}, #{s}"
    scanner = CScanner.new(s, false)
    error = MyError.new("whaterver", scanner)
    parser = Parser.new(scanner, error)
    parser.Get
    ret = parser.send(method)
    error.PrintListing
    return ret
end


# parse string
# preprocess - true: do preprocess first, false: no do preprocess, just parse
def parse(s, preprocess = true, to_ruby=true)
    # p "parse #{s}"
    t_start = Time.now.to_f
    if preprocess
       s = preprocess(s)
    end
    
    
    scanner = CScanner.new(s, false)
    error = MyError.new("whaterver", scanner)
    parser = Parser.new(scanner, error, $g_classdefs)
=begin    
    # parser.Get
    if preprocess
        content = parser.Preprocess
            begin
                aFile = File.new("pre.#{Time.now.to_i}", "w+")
                aFile.puts content
                aFile.close
            rescue Exception=>e
                p e
            end
        
        scanner.Reset
        # parser.Get
    end
=end  
    p "===== start parsing ====="
    parser.Get
    ret = parser.C
    error.PrintListing
    p "===== end of parsing ====="
  
    parser.dump_classes_as_ruby if to_ruby
    # $classdefs = parser.classdefs
    # $classdefs.each{|k,v|
    #     p "class #{k}:"
    #     p "       class name: #{v.class_name}"
    #     p "       parent: #{v.parent}"
    #     p "       modules: #{v.modules}"
    #     p "       methods:"
    #     v.methods{|k,v|
    #         p "       methods signature:#{k}"
    #         p "       methods name:#{v[:name]}"
    #         p "       src:#{v[:src]}" 
    #     }      
    # }
    
    p "Took #{Time.now.to_f - t_start} seconds"
    return ret
end

def preprocess(s)
    scanner = CScanner.new(s, false)
    error = MyError.new("whaterver", scanner)
    parser = Preprocessor.new(scanner, error)
    content = parser.Preprocess
    begin
        fname = "pre.#{Time.now.to_i}"
       aFile = File.new(fname, "w+")
       aFile.puts content
       aFile.close
       p "Write preprocess result to file #{fname}"
    rescue Exception=>e
       p e
    end
    p "after preprocess:#{content}"
    p "===== Preprocess end with #{error.error_list.size} errors"
    
    return content
end

def preprocess_file(fname)
    s = read_file(fname)
    preprocess(s)
end

# parse file
# preprocess - true: do preprocess first, false: no do preprocess, just parse
def parse_file(fname, preprocess = true, to_ruby=true)
    content = read_file(fname)
    parse(content, preprocess, to_ruby)
end

def test
    # p parse_file("pre.1424096273", false)
    p parse_file("pre.1428906753", false)
end
# test