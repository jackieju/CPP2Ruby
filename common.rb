load 'rbeautify.rb'

def write_class(ruby_filename, class_template)
    # s = class_template
    p "write class to file #{ruby_filename}"
    s = RBeautify.beautify_string(class_template)
    p s
    
    begin
        FileUtils.makedirs(File.dirname(ruby_filename))
        
         aFile = File.new(ruby_filename, "w+")
         aFile.puts s[0]
         aFile.close
     rescue Exception=>e
         p e
     end
     # RBeautify.beautify_file(ruby_filename)
     p "done"
end