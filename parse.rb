load 'cp.rb'

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

def parse(s, preprocess = true)
    p "parse #{s}"
    scanner = CScanner.new(s, false)
    error = MyError.new("whaterver", scanner)
    parser = Parser.new(scanner, error)
    parser.Get
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
        parser.Get
    end
    p "===== start parsing ====="
    ret = parser.C
    error.PrintListing
    return ret
end

def preprocess(s)
    scanner = CScanner.new(s, false)
    error = MyError.new("whaterver", scanner)
    parser = Parser.new(scanner, error)
    content = parser.Preprocess
    begin
       aFile = File.new("pre.#{Time.now.to_i}", "w+")
       aFile.puts content
       aFile.close
    rescue Exception=>e
       p e
    end
    p "after preprocess:#{content}"
end

def preprocess_file(fname)
    s = read_file(fname)
    preprocess(s)
end

def parse_file(fname, preprocess = true)
    content = read_file(fname)
    parse(content, preprocess)
end

def test
    p parse_file("pre.1424096273", false)
end
test