require 'lib/rubyutility'
require 'fileutils'
$g_TRACE_ENABLED = false

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
    
    
    ret = "#{$$}|#{st}#{m_cat}]#{m}(#{trace})"

    return ret
end
    
def log_msg(m, cat="LOG", stack=0, showTime = true)
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
    

  
    fname = get_logfile_path(cat)
     p "==>log msg #{fname}: #{msg}"
    append_file(fname, msg)    
end
def get_logfile_path(cat = "LOG", time = nil)
    time = Time.now if time == nil
    st2 =  "#{time.strftime("%Y%m%d")}"

    froot = g_FILEROOT
    # p "===>file root:#{froot}"
    froot = "." if !froot
    dir = "#{froot}/log"
    # p "--->dir:#{dir}"
    FileUtils.makedirs(dir)   
    fname = "#{dir}/#{cat}_#{st2}.sg"

    return fname
end
def exp_to_s(e, deep=9)
    "!!!Exception:#{e.inspect}:\n#{e.backtrace[0..deep].join("\n")}"
end
def pe(e, deep =9)
    p "!!!Exception:#{e.inspect}:\n#{e.backtrace[0..deep].join("\n")}"
end
def p_f(m)
    # p "|==>perf(#{$uid}):(#{Time.now.to_f}) #{m}" if $uid==1909
   # p "|==>perf(#{$uid}):(#{Time.now.to_f}) #{m}" if $uid==25579#  玩玩走走
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
        m = "!!!Exception:#{m.inspect}:\n#{m.backtrace[0..m.backtrace.size-1].join("\n")}"
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

def trc(m)
    if $g_TRACE_ENABLED
        m = format_msg(m, "trc")
        p m
    end
end
def trace(m)
    trc(m)
end
class SlowLog
    @@th = 1 #threshhold
    
    # stack level is where the log caller located
    def _in(stack = 2)
        @trc = ""
        begin
            raise Exception.new
        rescue Exception=>e
            @trc = e.backtrace[stack]
        end
        
        @last_log_tf = @t = Time.now.to_f
       
        @buf = ""
        
        @log_num = 0
    end
    def self.in(stack = 2)
        h = SlowLog.new
        
        h._in(stack)
        # h.log
        
        return h
    end
    def _out
        t2 = Time.now.to_f
        # if true
        span = t2 - @t
        if span > @@th 
            # p @buf
            # p @buf = "========= END slow log ========\n"
            # @buf += "Span #{span}\n"
            # @buf += "========= END slow log ========\n"
            m = <<__END1__
            \n========= slow log ========
            pid: #{$$}
            file: #{@trc}
            time: #{@t}
            span:#{span}
#{@buf}
========= END slow log ========          
__END1__
            p "m=#{m}"
            log_msg(m, "SLOWLOG")
        end
    end
    def self.out(h)
        h._out
    end
    def self.out1(h)
        h._out
    end
    def log(m="", stack=2)
        __last_tf = @last_log_tf
        __tnowf = Time.now.to_f
        @last_log_tf = __tnowf
        delta_tf = __tnowf - __last_tf
        
        trc = ""
        begin
            raise Exception.new
        rescue Exception=>e
            trc = e.backtrace[stack]
            # trc2 = e.backtrace.join("\r\n") 
        end
                
        @buf += "[#{$$}\##{@log_num}@#{__tnowf}+#{delta_tf}] #{m} (#{trc})\n"
        # @buf += trc2
        @log_num += 1
    end
    
    def self.set_timeout(t)
        @@th = t
    end
    
end

# for easy use
def __logf_start__
    $slow_log = SlowLog.in(3)
end
def __logf_end__
    if $slow_log 
        SlowLog.out($slow_log)
        $slow_log = nil
    end
end
def __logf__(m="")
    $slow_log.log(m, 2) if $slow_log
end
def __logf(m="")
    __logf__(m)
end

# def test_slowlog
#     _hh = SlowLog.in
#     _hh.log("sff")
#     sleep(2)
#     _hh.log
#     _hh.log
#     SlowLog.out(_hh)
# end


# test_slowlog