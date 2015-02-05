#!/Users/i027910/.rvm/rubies/ruby-2.1.2/bin/ruby
# TODO
# TCHAR			tmpStr[256]={0};
# if ...{
# }
# ++, --

# static function
# function def outside class SCOPE (global function)
# member var, global var
# process .h .cpp at one time running and by order
# local var vs constant
# if 0 => if false
# swtich case without break , 1. add "," 2. remove break in when
# class assgin in c++ is object clone, but in ruby is same instance.
# KEEP COMMENT
# 
require 'set'
load 'parse.rb'
load 'log.rb'
load 'rbeautify.rb'

# temp dict
class TempDict
    def initialize
        @dict={}
        @next_id=1
    end
    def add(s)
         k = @next_id.to_s
         @dict[k]=s
         @next_id += 1
         return k
    end
    def get(id)
        @dict[id.to_s]
    end
end
$td = TempDict.new
class Context
    def initialize
        @vars={}
    end
    def add_var(v)
        @vars[v]=1
    end
    def isVarExist?(v)
        return @vars[v] == 1
    end
end
def indent_block(src, n)
    ind = ""
    for i in 0..n-1
        ind += "\t"
    end
    return src.gsub(/^/im, ind)
end
# translate code block between {}
def translate_block(block)
    context = Context.new
    
    ret = ""
    lines = block.split(/;\s*$/m)
    lines.each{|l|
        ret += tranlate_line(context, l)
    }
    return ret
end
def translate_block_by_parse(block)
    parse(block, "Statements")
end
def isKeyword?(s)
    a = ["for", "if", "return", "false", "true"]
    return a.include?(s)
end
def translate_functioncall(line)
    return line.gsub(/(\w[\w\d_\*\)]*)\s*->([\w\d_]+)/im, '\1.\2')
end

def recover_src(s)
    p "recover #{s}"
    s.gsub(/_%#(\d+)#%_/){|s|
        p "-->#{$1}"
        $td.get($1)
    }
end

def isLiteral?(s)
    s = s.strip
    
    s =~ /^\d+$/
end

def isVariable?(s)
    s = s.strip
    return false if isLiteral?(s) || isKeyword?(s)
    
    s =~ /^[\*&]*[\w\d_]+$/
end
def translate_variable(context,varname)
    if context.isVarExist?(varname) == false
        varname = "@#{varname}"
    end
    return varname
end
def translate_primary(context, s)
    if isVariable?(s)
        return translate_variable(context, s)
    end
    return s
end

def tranlate_line(context, line)
    ret = line
    p "translate line #{line}"
    
    # var declaration
    # parse comma exp
    line = line.gsub(/(?<match>\(((\g<match>|[^\(\)]*))*\))/m){|s|
        k = $td.add(s)
        "_\%\##{k}#%_"
    }.gsub(/\".*?\"/){|s|
        k = $td.add(s)
        "_\%\##{k}#%_"
    }
    exps = line.split(",")
    _line = ""
    exps.each{|e|
        exp = recover_src(e)
        # var decl
        if exp=~/^\s*?([\w\d_&\*]*)\s+[&\*]*([\w\d_\*]+)(.*?)\s*$/m
            if exp=~ /^\s*?([\w\d_&\*]*)\s+[&\*]*([\w\d_\*]+)\s*$/m
                varname=$2
                varname = varname.gsub(/^\s*\*/,"")
                context.add_var(varname)
                next
            end
        
            if exp=~ /^\s*?([\w\d_&\*]*)\s+[&\*]*([\w\d_\*]+)\s*=(.*?)\s*$/m
                p "==>32-#{e}"
                p "==>33-#{$1}, #{$2}, #{$3}"
                p3 = translate_primary(context, $3)
                varname=$2
                varname = varname.gsub(/^\s*\*/,"")
                context.add_var(varname)
                _line += "#{varname}=#{p3}\n"
                p "==>line=#{_line}"
                next
            end
        # assignment
        elsif exp=~/^\s*([\w\d_\*]+)\s*=(.*?)\s*$/m
            varname=$1
            p3 = translate_primary(context, $2)
            varname = varname.gsub(/^\s*\*/,"")
            varname = translate_variable(context, varname)
            # p "exp=#{exp}, #{$1}, #{$2}"
           
            _line += "#{varname} = #{p3}"
        else
            _line += "#{exp}\n"
        end
        
        # e.scan(/^\s*?([\w\d_&\*]*)\s+[&\*]*([\w\d_\*]+)\s*=(.*?)\s*$/m){|m|
        #     next
        # }
    }
    # if e =~/^\s*?(\w[\w\d_\*]*)\s+[\w\d_\*,]+\s*?;\s*?$/ && !isKeyword?($1)
    #       p "-->decleration:#{line}"
    #   end
    #   
    #   if e =~/^\s*?(\w[\w\d_\*]*)\s+([\w\d_\*]+\s*=.*?);\s*?$/ && !isKeyword?($1)
    #       p "-->decleration assgin:#{line}"
    #       ret = "#{$2}\n"
    #       return translate_functioncall(ret)
    #   end
    return translate_functioncall(_line)
end
def write_class(ruby_filename, class_template)
    # s = class_template
    s = RBeautify.beautify_string(class_template)
    begin
         aFile = File.new(ruby_filename, "w+")
         aFile.puts s
         aFile.close
     rescue Exception=>e
         p e
     end
     # RBeautify.beautify_file(ruby_filename)
     p "done"
 end

$class_list = {}
# return array of args
def translate_functioncall_argslist(args)
    
    args1= args.split(",")
     _args = []
     args1.each{|s|
         _ar = s.split(/\s/)
         arg = _ar[_ar.size-1]
         arg = arg.strip
         while arg[0] == "*" do
            arg = arg[1..arg.size-1]
         end
         while arg[0] == "&" do
            arg = arg[1..arg.size-1]
         end
         _args.push(arg)
     }
     return _args
end
def add_class_method_def(class_name, method_name, args, acc="public")
    _args = []
    
    _args = translate_functioncall_argslist(args) if args
    p "args=>#{_args}"
    
    if $class_list[class_name.to_s] == nil
           $class_list[class_name.to_s]={
               :methods=>{}
           }
    end
    method_sig = "#{method_name}\#\##{_args.size}"
    if $class_list[class_name.to_s][:methods][method_sig] == nil
        $class_list[class_name.to_s][:methods][method_sig]={
            :name=>method_name,
            :body=>nil,
            :args=>_args,
            :acc=>acc
        }
    else
        $class_list[class_name.to_s][:methods][method_sig][:args] = _args 
        $class_list[class_name.to_s][:methods][method_sig][:acc] = acc
    end
end
def add_class_method(class_name, method_name, args, body, acc="public")
    _args = []
    
    _args = translate_functioncall_argslist(args) if args
    p "args=>#{_args}"
    
      if $class_list[class_name.to_s] == nil
             $class_list[class_name.to_s]={
                 :methods=>{}
             }
         end
         method_sig = "#{method_name}\#\##{_args.size}"
         
         $class_list[class_name.to_s][:methods][method_sig]={
             :name=>method_name,
             :body=>body,
             :args=>_args,
             :acc=>acc
         }
end
# find and translate functiond impl in *.c *.cpp
def translate_function_impl(content)
    n =0 
    content.scan(/(\?<m1>\w+\s+)*?\*?(?<m2>\w+)::(?<m3>~?\w+)\s*\((?<m4>.*?)\)\s*(?<match>\{((\g<match>|[^\{\}]*))*\})/im){|m| 
         # p "=>result:#{m.inspect}"
         # p "rv=#{m[0]}, class_name=#{m[1]}"
         # p "size=#{m.size}"
         
         class_name = m[0]
         method_name = m[1]
         args = m[2]
         _body = m[3]
         p "body:#{_body}"
         body = ""
         # remove {}
         _body.scan(/\s*\{(.*)\}\s*/im){|mm|
             p "1==>#{mm.inspect}"
            body = mm[0]
        }
         
        add_class_method(class_name, method_name, args, body, "public")
         n+=1
         # break if n >10
    }
end
def translate_block_in_class_body(class_name, content, acc)
    # take out and translate function def
    n =0 
    content.scan(/(\?<m1>\w+\s+)*?\*?(?<m3>\w+)\s*\((?<m4>.*?)\)\s*(?<match>\{((\g<match>|[^\{\}]*))\})/im){|m| 
         # p "=>result:#{m.inspect}"
         # p "rv=#{m[0]}, class_name=#{m[1]}"
         # p "size=#{m.size}"
         
         method_name = m[0]
         args = m[1]
         _body = m[2]
         p "method_name:#{method_name}"
         p "body:#{_body}"
         body = ""
         # remove {}
         _body.scan(/\s*\{(.*)\}\s*/im){|mm|
             p "1==>#{mm.inspect}"
            body = mm[0]
        }
         
        add_class_method(class_name, method_name, args, body, acc)
        n+=1
         # break if n >10
    }
    # remove them
    content = content.gsub(/(\?<m1>\w+\s+)*?\*?(?<m3>\w+)\s*\((?<m4>.*?)\)\s*(?<match>\{((\g<match>|[^\{\}]*))*\})/im, "")
    
    lines = content.split(/;\s*$/m)
    p "--->lines in class #{class_name}/#{acc} #{lines.size}"
    lines.each{|line|
        translate_line_in_class_body(class_name, line, acc)
    }
end
# it's not actually line, can be multiline because c/c++ using ; as delimiter
def translate_line_in_class_body(class_name, line, acc)
    n =0 
    # if function declaration
    p "line:#{line}"
    if line =~ /^\s*([\w\d_]*)\s+\*?([\w\d_]+)\s*\((.*?)\)\s*$/m
         method_name = $2
         p "--->4method_name=#{method_name}"
         args = $3
         p "--->4args=#{args}"
         
         add_class_method_def(class_name, method_name, args, acc)
         n+=1
         # break if n >10
         return 
    end

end

def translate_classdef_body(class_name, body)
     array = body.split(/^\s*(public|private|protected)\s*:\s*$/m)
       
        p "=>>4,size=#{array.size}\n"
        i = 0
       
        while (i<array.size) do
             acc = nil
            p "#{i}:#{array[i]}"
            acc = array[i]
            if acc =~ /public|private|protected/
                i+=1
            else
                if acc==nil 
                    acc= "protected"
                end
            end
        
            src = array[i]
            translate_block_in_class_body(class_name, src, acc)
            i+=1
        end
    
end
# find and translate class definition
def translate_classdef(content)
    p "-->translate_classdef"
    n = 0
    # content.scan(/(\?<m1>^.*?)\s*?class\s+(?<m2>\w[\w\d_]*)\s*(:\s*(?<m3>\w[\w\d_,\s]*))*\s*(?<match>\{((\g<match>|[^\{\}]*))*\})/im){|m| 
    # classes with inherence definition
    content.scan(/^(.*?)class\s+(?<m2>\w[\w\d_]*)(\s*:\s*.*?)(?<match>\{((\g<match>|[^\{\}]*))*\})/im){|m| 
        n += 1
        p m.inspect
        class_name = m[0]
        # devide by access controll
        _body = m[1]
        body=""
        # remove {}
         _body.scan(/\s*\{(.*)\}\s*/im){|mm|
             # p "===>2"+mm.inspect
            body = mm[0]
        }
        p "==>body=#{body}"
        
       translate_classdef_body(class_name, body)
        
    }
    # class without inherence
    content.scan(/^(.*?)class\s+(?<m2>\w[\w\d_]*).*?(?<match>\{((\g<match>|[^\{\}]*))*\})/im){|m| 
          n += 1
        p m.inspect
         class_name = m[0]
            # devide by access controll
            _body = m[1]
            body=""
            # remove {}
             _body.scan(/\s*\{(.*)\}\s*/im){|mm|
                 # p "===>2"+mm.inspect
                body = mm[0]
            }
            p "==>body=#{body}"
        
            translate_classdef_body(class_name, body)
    }
    p "find #{n} classes"
end
def translate(fname)
   
   # advanced regexp only availale when ruby version>=1.9.2
=begin
        a = "ddd{fdfas{dfasf}dafas}aaa" 
        a.scan(/(?<match>\{((\g<match>|[^\{\}]*))*\})/im){|m|
        p "===>#{m.inspect}"
        }
=end   
        b = fname.split('/')
        filename = b[b.size-1].gsub("-", "_")
        filename.sub!(".c", "")
        ruby_filename = filename + ".rb"
            
        p "filename=#{fname}"
        content = ""
        file=File.open(fname,"r")  
        t = nil      

        file.each_line do |line|
            line.gsub!(/^\s*\/\/.*$/, "")
            content += line
        end
        # p content
=begin        
        array =  content.split(/(?:\w+\s+)?\*?(\w+)::(~?\w+)\s*\((.*?)\)/im)
        p array.size
        i = 1
        begin
            p "i=#{i}"
            return_value = array[i]
            # p "return value #{return_value}"
            # i+=1
            class_name = array[i]
            p "class_name #{class_name}"
            
            i+=1
            method_name = array[i]
            p "method_name #{method_name}"
            
            i+=1
            args = array[i]
             p "args #{args}"
            i+=1
            method_body = array[i]
            p "method_body #{method_body}"
            p ">> def #{method_name}(#{args})"
            i+=1
        end while (i<array.size)
=end        
        # remove comments
        content = content.gsub(/^\s*\/\/.*?$/, "")
        content = content.gsub(/\s*\/\/(.*?)$/){|s|
            if $1.index("\"")
                s
            else
                ""
            end
        }
        # content = content.gsub(/(?<match>\/\*((\g<match>|[^\/\*\*\/]*))*\*\/)/m, "")
        # p content
        # translate class definition
        translate_classdef(content)
        
        # class method
        # CBusinessObject	*CTransactionJournalObject::CreateObject (const TCHAR *id, CBizEnv &env)
               
        # class_list = Set.new 
       translate_function_impl(content)
       


end
 # generate ruby file
def generate_ruby()
    log_msg("generate_ruby")
    $class_list.each{|kn,v|
            p "class #{kn}"
            log_msg("class #{kn}")
            methods = ""
            $class_list[kn][:methods].each{|k,v|
                p "method #{k}(#{v[:args].join(", ")})"
                log_msg ("method #{k}(#{v[:args].join(", ")})")
                tranlsate_body = ""
                if (v[:body])
                    # tranlsate_body = translate_block(v[:body]) 
                    log_msg("v_body:#{v[:body]}")
                    translate_body = translate_block_by_parse(v[:body])
                    log_msg("translate_body:#{translate_body}")
                else
                    p "!!class #{kn} method #{k} has not impl"
                end
                translate_body = indent_block(translate_body, 1)
method_template =<<HERE
def #{v[:name]}(#{v[:args].join(", ")})
#{translate_body}
end
    
HERE
    methods += method_template
    
            }
            p "==>methods:#{methods}"
            class_name = kn
            class_template = <<HERE
class #{class_name}
#{methods}
end
HERE

    wfname = "#{class_name.downcase}.rb"
    write_class(wfname, class_template)
        }
       
end
p $*.inspect
if $*.size >0
    for a in $*[0..$*.size-1]
        p a
        translate(a)
    end
    generate_ruby
else
    p "no file specified"
    p "usage: ruby generate_obj.rb <c source file>\n
    example: ruby generate_obj.rb xiaolu.c"
end