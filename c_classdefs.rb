def add_class(class_name, parent=nil, modules=nil)
    clsdef = ClassDef.new(class_name)
    $g_classdefs = {} if $g_classdefs == nil
    $g_classdefs[class_name] = clsdef
end

add_class("SJournalKeys")
