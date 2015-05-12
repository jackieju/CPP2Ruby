# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20150512155051) do

  create_table "ojdts", :force => true do |t|
    t.integer  "BatchNum"
    t.integer  "TransId"
    t.string   "BtfStatus"
    t.string   "TransType"
    t.string   "BaseRef"
    t.date     "RefDate"
    t.string   "Memo"
    t.string   "Ref1"
    t.string   "Ref2"
    t.integer  "CreatedBy"
    t.float    "LocTotal"
    t.float    "FcTotal"
    t.float    "SysTotal"
    t.string   "TransCode"
    t.string   "OrignCurr"
    t.float    "TransRate"
    t.integer  "BtfLine"
    t.string   "TransCurr"
    t.string   "Project"
    t.date     "DueDate"
    t.date     "TaxDate"
    t.string   "PCAddition"
    t.integer  "FinncPriod"
    t.string   "DataSource"
    t.date     "UpdateDate"
    t.date     "CreateDate"
    t.integer  "UserSign"
    t.integer  "UserSign2"
    t.string   "RefndRprt"
    t.integer  "LogInstanc"
    t.string   "ObjType"
    t.string   "Indicator"
    t.string   "AdjTran"
    t.string   "RevSource"
    t.date     "StornoDate"
    t.integer  "StornoToTr"
    t.string   "AutoStorno"
    t.string   "Corisptivi"
    t.date     "VatDate"
    t.string   "StampTax"
    t.integer  "Series"
    t.integer  "Number"
    t.string   "AutoVAT"
    t.integer  "DocSeries"
    t.string   "FolioPref"
    t.integer  "FolioNum"
    t.integer  "CreateTime"
    t.string   "BlockDunn"
    t.string   "ReportEU"
    t.string   "Report347"
    t.string   "Printed"
    t.string   "DocType"
    t.integer  "AttNum"
    t.string   "GenRegNo"
    t.integer  "RG23APart2"
    t.integer  "RG23CPart2"
    t.integer  "MatType"
    t.string   "Creator"
    t.string   "Approver"
    t.integer  "Location"
    t.integer  "SeqCode"
    t.integer  "Serial"
    t.string   "SeriesStr"
    t.string   "SubStr"
    t.string   "AutoWT"
    t.float    "WTSum"
    t.float    "WTSumSC"
    t.float    "WTSumFC"
    t.float    "WTApplied"
    t.float    "WTAppliedS"
    t.float    "WTAppliedF"
    t.float    "BaseAmnt"
    t.float    "BaseAmntSC"
    t.float    "BaseAmntFC"
    t.float    "BaseVtAt"
    t.float    "BaseVtAtSC"
    t.float    "BaseVtAtFC"
    t.string   "VersionNum"
    t.integer  "BaseTrans"
    t.string   "ResidenNum"
    t.string   "OperatCode"
    t.string   "Ref3"
    t.string   "SSIExmpt"
    t.text     "SignMsg"
    t.text     "SignDigest"
    t.string   "CertifNum"
    t.integer  "KeyVersion"
    t.integer  "CUP"
    t.integer  "CIG"
    t.string   "SupplCode"
    t.integer  "SPSrcType"
    t.integer  "SPSrcID"
    t.integer  "SPSrcDLN"
    t.string   "DeferedTax"
    t.integer  "AgrNo"
    t.integer  "SeqNum"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tests", :force => true do |t|
    t.integer  "t1"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end