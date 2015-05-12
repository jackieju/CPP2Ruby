require 'bobject.rb'
require 'ctransactionjournalobject.rb'
class JdtController < ApplicationController
    def CreateJournalEntry
        context = {}
        tjObj = CTransactionJournalObject.new(context)
        tjObj.CompleteJdtLine()
        tjObj.save
    end
end
