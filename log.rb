require 'fileutils'
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
def class_exists?(class_name)   
  eval("defined?(#{class_name}) && #{class_name.class}.is_a?(Class)") == true  
end

def format_msg(msg, cat=nil, stack=0, showTime=true)
    _stack = stack + 1
    
    if cat == nil
        cat = ""
    else
        cat = cat.upcase
    end
    trace = ""
    ret = ""
    
    st = ""
    if showTime
        time = Time.now
        st =  "#{time.strftime("%Y-%m-%d %H:%M:%S")}.#{time.usec.to_s[0,2]}"
    end
    
    if stack >0
        begin
            raise Exception.new
        rescue Exception=>e
            if e.backtrace.size >=2 && stack >= 0
                _stack  += 1
                _stack = e.backtrace.size-1 if _stack >= e.backtrace.size
                trace = e.backtrace[2.._stack].join("\n") 
            end
        end    
    end
    
    m = msg
    if msg.is_a?(Exception)
        m = "!!!Exception:#{m.inspect}:\n#{m.backtrace[0..9].join("\n")}"
    end
    m_cat = ""
    m_cat = "\##{cat}" if cat && cat!=""
    
    if stack > 0
        ret = "#{$$}|#{st}#{m_cat}]#{m}(#{trace})"
    else
        ret = "#{$$}|#{st}#{m_cat}]#{m}"
    end

    return ret
end

def log_msg(m, cat="LOG", stack=0, showTime = true, dir="./")
    cat = cat.upcase
=begin
    trace = ""
    begin
        raise Exception.new
    rescue Exception=>e
        if e.backtrace.size >=2 && stack >= 0
            stack  += 1
            stack = e.backtrace.size-1 if stack >= e.backtrace.size
            trace = e.backtrace[1..stack].join("\n") 
        end
    end
    time = Time.now
    st =  "#{time.strftime("%Y-%m-%d %H:%M:%S")}.#{time.usec.to_s[0,2]}"
    
    if m.is_a?(Exception)
        m = "!!!Exception:#{m.inspect}:\n#{m.backtrace[0..9].join("\n")}"
    end
    msg = "#{st}\##{cat}]\##{m}(#{trace})"
=end
    msg=format_msg(m, cat, stack, showTime)
    
    time = Time.now
    st2 =  "#{time.strftime("%Y%m%d")}"
    
    # froot = dir
    # p "===>file root:#{froot}"
    # froot = "." if !froot
    # dir = "#{froot}/log"
    # p "--->dir:#{dir}"
    FileUtils.makedirs(dir)   
    fname = "#{dir}/#{cat}_#{st2}.sg"
    p "==>log msg #{fname}: #{msg}"
    append_file(fname, msg)    
end
def pe(e, deep =9)
    "!!!Exception:#{e.inspect}:\n#{e.backtrace[0..deep].join("\n")}"
end
def p_f(m)
    # p "|==>perf(#{$uid}):(#{Time.now.to_f}) #{m}" if $uid==1909
   # p "|==>perf(#{$uid}):(#{Time.now.to_f}) #{m}" if $uid==25579#  玩玩走走
end

$Hidden_log_files = []
def hide_p_in_file(file) # after call this the log performance will down
    # begin
    #     raise Exception.new
    # rescue Exception=>e
    #    
    #     if e.backtrace.size >=2
    #         trace = e.backtrace[2..e.backtrace.size-1].join("\n") 
    #         p trace
    #     end
    # end
   $Hidden_log_files.push(file) if file && file.strip !=""
end

def hide_log?
     begin
          raise Exception.new
      rescue Exception=>e
         # puts e.backtrace.inspect
          if e.backtrace.size >=2
              # trace = e.backtrace[2..e.backtrace.size-1].join("\n") 
              trace =  e.backtrace[2] # posistion 2 is where p was called
              # puts "logfromfile:"+trace.split(":")[0]
              # puts "$Hidden_log_files:#{$Hidden_log_files}"
              # puts "result:#{$Hidden_log_files.include?(trace.split(":")[0] )}"
              if $Hidden_log_files.include?(trace.split(":")[0] )
                  return true
              end
          end
      end
      return false
end
#### log on rails #####
def p(m, stack=0, showTime=false)
=begin
    if stack >0
         begin
            raise Exception.new
        rescue Exception=>e
            if e.backtrace.size >=2 
                stack  += 1
                stack = e.backtrace.size-1 if stack >= e.backtrace.size
                trace = e.backtrace[1..stack].join("\n") 
                m = "#{m}\n#{trace}"
            end
        end
    end
=end
    return if hide_log?()
    m = format_msg(m, "", stack, showTime)
    # puts m
    begin
    # if class_exists?("Rails.logger")
        Rails.logger.debug(m) 
    # else
        # print "#{m}\n"
    # end
    rescue Exception=>e
         print "#{m}\n"
    end
end
def warn(m)
    # Rails.logger.warn(m)
end
def err(m)
    if m.is_a?(Exception)
        m = "!!!Exception:#{m.inspect}:\n#{m.backtrace[0..9].join("\n")}"
    end
    begin
    # if class_exists?("Rails.logger")
        Rails.logger.error(m) 
    # else
        # print "#{m}\n"
    # end
    rescue Exception=>e
         print "#{m}\n"
    end
end
# hide_p_in_file("log.rb")
# p "aaaa"
# p __FILE__