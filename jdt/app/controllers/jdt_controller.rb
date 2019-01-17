require 'bobject.rb'
require 'ctransactionjournalobject.rb'
class JdtController < ApplicationController
    def CreateJournalEntry
        context = {}
        # context = build_context(params)
        tjObj = CTransactionJournalObject.new(context)
        tjObj.CompleteJdtLine()
        tjObj.save
        
        render :text=>"ok"
    end
end
