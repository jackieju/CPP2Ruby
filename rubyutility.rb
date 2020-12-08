def generate_password(length=6)  
  chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ123456789'  
  password = ''  
  length.downto(1) { |i| password << chars[rand(chars.length - 1)] }  
  password  
end  
  
  
def i_to_ch(i)
    list = ["零", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]
    s = i.to_s
    ret = ""
   
    for k in 0..s.size-1
        n = s[k]-48
          str=""
         if n == 0
             str = "零" if s.size>=3 && k!=s.size-1 && k!=0 # not first and last
         else
         
            d = list[n]
            l = s.size-k-1
            case l
            when 0
                str=d
            when 1
                begin
                if n != 1
                    str += d
                end
                str +="十"
                end
            when 2
                 str += d+"百"
            when 3
                 str += d+"千"
            when 4
                 str += d+"万"
            when 5
                 str += d+"十万"
            when 6
                 str += d+"百万"
            when 7 
                str += d+"千万"
            when 8
                 str += d+"亿"
            when 9
                 str += d+"十亿"
            when 10
                 str += d+"百亿"
            when 11
                 str += d+"千亿"
            when 12
                 str += d+"万亿"
            end
        end
        if str[str.size-1..str.size-1] == '零' && str.size>1
            str = str[0..str.size-2]
        end
        ret += str
        
    end
    return ret
end

def rand_get_from_array(ar)
    return ar[rand(ar.size)]
end

def obj_is_number?(o)
    return o.is_a?(Numeric)
end
def str_is_number?(s)
    return s.to_i.to_s == s
end


def unrand(min, max, rate=2)
  s = max - min +1
  index = (rand(rate*s)+rand(rate*s))/rate
  index = s-1 if index == s
  index = s-index%s if index > s
  return index + min
end

=begin pastable code
begin
    raise Exception.new
rescue Exception=>e
    stack = 100
    if e.backtrace.size >=2 
        stack  += 1
        stack = e.backtrace.size-1 if stack >= e.backtrace.size
        p e.backtrace[1..stack].join("\n") 
    end
end
=end
def show_stack(stack = nil)
	stack = 99999 if stack == nil || stack <= 0
	begin
	    raise Exception.new
	rescue Exception=>e
	    if e.backtrace.size >=2 
	        stack  += 1
	        stack = e.backtrace.size-1 if stack >= e.backtrace.size
	        return e.backtrace[1..stack].join("\n") 
	    end
	end
	return ""
end
def util_get_prop(prop, k)
      js = prop
      if js.class == String
          js = JSON.parse(prop)
      end
      if js
          return js[k]
      else
          return nil
      end
end
def util_set_prop(prop,n,v)
      js = prop
      if js.class == String
          js = JSON.parse(prop)
      end
      if js == nil
          js =JSON.parse("{}")
      end

    js[n] = v
   return  js.to_json
end

# ==========================
#  File system
# ==========================
def append_file(fname, content)
     begin
         aFile = File.new(fname,"a")
         aFile.puts content
         aFile.close
     rescue Exception=>e
         # logger.error e
         p e.inspect
     end
end
def find_file(fname, dirs=nil, recursive=false)
    if dirs == nil
        dirs = []
        dirs.push(File.dirname(__FILE__))
    end
    
    i = 0
    while i < dirs.size
            dir = dirs[i]
      #  p "find file #{fname} under #{dir}"
        if recursive
            qs = "#{dir}/**/#{fname}"
        else
            qs = "#{dir}/#{fname}"
        end
     #   p "find file #{fname} using pattern #{qs}"
        Dir[qs].each { |f|
            p "found file #{f} under dir"
            return f
        }
        i+=1
    end
    
    p "file #{fname} not found under #{dirs.inspect}"
    return nil
end
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

def save_to_file(data, fname)
    dir = File.dirname(fname)
    FileUtils.makedirs(dir)
    begin
            open(fname, "w+") {|f|
                   f.write(data)
               }    
    rescue Exception=>e
         err e
         return false
    end
    return true
end
def append_to_file(data, fname)
    append(fname, data)
end
=begin
def test
  count = {}
  for a in 0..1000
    i = unrand(0, 10)
    if count[i] == nil
      count[i] = 0
    else
      count[i] += 1
    end
  end
  for a in 0..10
    p "#{a}:#{count[a]}"
  end
end
=end
# p i_to_ch(3)

def test
   s= File.open("ccc1.txt").read
   p s
end
#test
