load 'cp.rb'

def parse(s, method="FunctionBody")
    scanner = CScanner.new(s, false)
    error = MyError.new("whaterver", scanner)
    parser = Parser.new(scanner, error)
    parser.Get
    parser.send(method)
end