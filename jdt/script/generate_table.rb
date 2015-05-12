#!/usr/bin/env ruby
# require 'common.rb'



def translate(fname)
    
      b = fname.split('/')
      b = b[b.size-1].gsub("-", "_")
      b = b.gsub(".xml", "")
      # table_name = b
      p "filename=#{fname}"
      
        # p "table_name = #{table_name}"
        content = ""
        file=File.open(fname,"r")  
        t = nil      

        file.each_line do |line|
            content += line
        end
        # p content
        table_name = nil
        content.scan(/<table.*?<id>(.*?)<\/id>/im){|m|
            table_name = m[0].strip
        }
        p "table_name = #{table_name}"
        raise "cannot find table name" if !table_name
        
        columns = []
        # get room dname
         content.scan(/<column>\s*?(<id>.*?)<\/column>/m){|m| 
             # p "=>result:#{m[0]}"
             field_name= nil
              m[0].scan(/<id>(.*?)<\/id>/m){|mm|
                  # p "=>id:#{mm[0]}"
                  field_name = mm[0].strip
              }
              raise "cannot find field_name" if !field_name
              db_type = nil
              m[0].scan(/<db_type>(.*?)<\/db_type>/m){|mm|
                  # p "=>db_type:#{mm[0]}"
                  db_type = mm[0].strip
                  db_type = db_type.downcase
                    case db_type
                    when "integer":
                    when "alphanumeric":
                        db_type = "string"
                    when "date"
                    when "float"
                    when "text"
                    else
                        raise "Unkown db_type #{db_type}"
                    end
              } 
              raise "cannot find db_type" if !db_type
              
              default_value = nil
              m[0].scan(/<default_value>(.*?)<\/default_value>/m){|mm|
                  # p "=>default_value:#{mm[0]}"
                  default_value = mm[0].strip
              } 
              # raise "cannot find default_value" if !default_value
              
              new_field = {
                  :name=>field_name,
                  :type=>db_type,
               
              }
              if default_value
                  new_field[:default_value] = default_value
              end
            
            columns.push(new_field)    
        }
            
        s = "script/generate scafold #{table_name} "    
        columns.each{|c|
            p "#{c[:name]}:#{c[:type]}(default_value:#{c[:default_value]})"
            s += "#{c[:name]}:#{c[:type]} "
        }
        p s
       return

       
        
        # generate ruby file
        
        template = <<HERE
        require 'objects/npc/clonablenpchuman.rb'
        module Game::Room::#{baseDir[0,1].upcase+baseDir[1,baseDir.size]}::Npc
class #{room_class} < Game::Objects::Npc::Clonablenpchuman

   def name
       "#{room_name}"
   end
   
   def desc
       "#{room_desc}"
   end
   def setup
       super
       #{set_title}
   end
   
    def setup_temp
        
       @temp ={
           :exp =>0,
           :level => #{level},
           :hp => #{hp},
           :maxhp =>#{hp},
           :neili =>#{neili},
           :maxnl=>#{neili}
           :stam    =>100,
           :maxst   =>100,
           :jingli => #{jingli},
           :max_jl =>#{jingli},
           :str     =>#{str},
           :dext    =>#{dext},
           :luck    =>40,
           :fame    =>0,
           :race    =>"#{race}",
           :pot     =>0,
           :it      =>#{it},
           :shen =>20
       }
    end
      def setup_skill 
        #{setup_skills}
      end
       def setup_equipment
      #{setup_objs}
   end
    
end
end
HERE

        begin
         
             aFile = File.new(room_ruby_filename, "w+")
             aFile.puts template
             aFile.close
         rescue Exception=>e
             logger.error e
         end
        
end
p $*.inspect
if $*.size >0
    for a in $*[0..$*.size-1]
        translate(a)
    end
else
    p "no file specified"
    p "usage: ruby generate_table.rb <filename>\n
    example: ruby generate_table.rb OJDT.xml"
end