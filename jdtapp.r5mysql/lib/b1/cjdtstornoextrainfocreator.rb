class CJDTStornoExtraInfoCreator
   def =(other)
      if self==other
         return self
      end

      @m_jdtBusinessObject=other.m_jdtBusinessObject
      return self
   end

   def GetJDTBusinessObject()
      return m_jdtBusinessObject
   end


end
