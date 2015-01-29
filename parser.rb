# This file is generated. DO NOT MODIFY!


require 'Sets'
# require 'module-hack'

class Parser
	private; MaxT = 39

	private; T = true
	private; X = false
	
	@token=nil			# last recognized token
	@t=nil				# lookahead token

	private; @@ident = 0
	private; @@string = 1
	private; @@genScanner = nil

	private; def Parser.SemErr(n)
		Scanner.err.SemErr(n, @t.line, @t.col)
	end
	
	private; def Parser.SetDDT(s)
		for i in 1..(s.length-1)
		  ch = s[i]
		  if (ch >= ?0 && ch <= ?9) then
		    Tab.ddt[ch - ?0] = true
		  end
		end
	end
	
	private; def Parser.FixString(s)
		a=s # TODO: remove a
		len = a.length
		if (len == 2) then
		  SemErr(29)
		end
		dbl = false
		for i in 1..(len-1)
		  if (a[i]=='"') then
		    dbl = true
		  elsif (a[i]==' ') then
		    SemErr(24)
		  end
		end
		if (!dbl) then
		  a[0] = '"'
		  a[len-1] = '"'
		end

		return a.clone
	end
	
# -------------------------------------------------------------------------



	private; def Parser.Error(n)
		Scanner.err.ParsErr(n, @t.line, @t.col)
	end
	
	private; def Parser.Get
		while true
			@token = @t
			@t = Scanner.Scan
			return if (@t.kind<=MaxT)
		if (@t.kind==40) then
			SetDDT(@t.val) 
		end

			@t = @token
		end
	end
	
	private; def Parser.Expect(n)
		if (@t.kind==n) then
		  Get()
		else
		  Error(n)
		end
	end
	
	private; def Parser.StartOf(s)
		return @@set[s][@t.kind]
	end
	
	private; def Parser.ExpectWeak(n, follow)
		if (@t.kind == n)
		  Get()
		else
		  Error(n);
		  while (!StartOf(follow))
		    Get();
		  end
		end
	end
	
	private; def Parser.WeakSeparator(n, syFol, repFol)
		s = []
		if (@t.kind==n) then
		  Get()
		  return true
		elsif (StartOf(repFol))
		  return false
		else
			for i in 0..MaxT
				s[i] = @@set[syFol][i] || @@set[repFol][i] || @@set[0][i]
			end
			Error(n)
			while (!s[@t.kind])
			  Get()
			end
			return StartOf(syFol)
		end
	end
	
	private; def self.AttrRest(n)
		beg = col = 0 
		beg = @t.pos
				   col = @t.col
				 
		while (StartOf(1))
			Get()
		end
		Expect(28)
		if (@token.pos > beg) then
                                     n.pos = Position.new(beg, @token.pos - beg, col)
                                   end
				
	end

	private; def self.TokenFactor()
		name = s = nil
				   kind = c = 0
				 
		g = Graph.new 
		if (@t.kind==2 || @t.kind==3) then
			name, kind = self.Symbol()
			if (kind==@@ident) then
                                     c = CharClass.Find(name)
                                     if c.nil? then
                                       SemErr(15)
                                       c = CharClass.new(name)
                                     end
                                     g.l = Node.new(Node::Clas, c.n, 0)
                                     g.r = g.l
                                   else # string
				     g = Graph.StrToGraph(name)
				   end
				
		elsif (@t.kind==22) then
			Get()
			g = self.TokenExpr()
			Expect(23)
		elsif (@t.kind==31) then
			Get()
			g = self.TokenExpr()
			Expect(32)
			Graph.Option(g) 
		elsif (@t.kind==33) then
			Get()
			g = self.TokenExpr()
			Expect(34)
			Graph.Iteration(g) 
		else Error(40)
end
		return g
	end

	private; def self.TokenTerm()
		g2 = nil 
		g = self.TokenFactor()
		while (StartOf(2))
			g2 = self.TokenFactor()
			Graph.Sequence(g, g2) 
		end
		if (@t.kind==36) then
			Get()
			Expect(22)
			g2 = self.TokenExpr()
			Graph.SetContextTrans(g2.l)
				   Graph.Sequence(g, g2)
				 
			Expect(23)
		end
		return g
	end

	private; def self.Attribs(n)
		beg = col = 0; buf = [] 
		Expect(25)
		if (@t.kind==26) then
			Get()
			beg = @t.pos 
			while (StartOf(3))
				Get()
			end
			buf << ParserGen.GetString(beg, @t.pos) 
			while (@t.kind==27)
				Get()
				Expect(26)
				beg = @t.pos 
				while (StartOf(3))
					Get()
				end
				buf << ParserGen.GetString(beg, @t.pos) 
			end
			if (@t.kind==27) then
				Get()
				self.AttrRest(n)
			elsif (@t.kind==28) then
				Get()
			else Error(41)
end
			n.retVar = buf.join(', ') if ! buf.empty? 
		elsif (StartOf(4)) then
			self.AttrRest(n)
		else Error(42)
end
	end

	private; def self.Factor()
		n = s = sym = pos = set = nil
				   sp = typ = 0
				   undefined = weak = false
				 
		g = Graph.new()
				   weak = false
				 
		case (@t.kind)
		when 2, 3, 30 then

			if (@t.kind==30) then
				Get()
				weak = true 
			end
			name, kind = self.Symbol()
			sp = Sym.Find(name)
				   undefined = sp==Sym::NoSym
                                   if (undefined) then
                                       if (kind==@@ident) then
                                           sp = Sym.new(Node::Nt, name, 0) # forward nt
                                       elsif (@@genScanner) then
                                           sp = Sym.new(Node::T, name, @token.line)
                                           DFA.MatchLiteral(sp)
                                       else # undefined string in production
                                           SemErr(6) 
					   sp = nil
                                       end
                                   end
				   sym = sp # FIX
				   typ = sym.typ
                                   if (typ!=Node::T && typ!=Node::Nt) then
				     SemErr(4)
				   end
                                   if (weak) then
                                       if (sym.typ==Node::T) then
				         typ = Node::Wt
				       else
				         SemErr(23)
				       end
				   end
                                   g.l = Node.new(typ, sp, @token.line)
				   g.r = g.l
                                   n = g.l
				 
			if (@t.kind==25) then
				self.Attribs(n)
				if (kind!=@@ident) then
    	    			     SemErr(3)
				   end
				 
			end
			if (undefined) then
                                     sym.attrPos = n.pos
				     sym.retVar  = n.retVar # dummies
                                   else
                                     if ((!n.pos.nil?    &&  sym.attrPos.nil?) ||
				         (!n.retVar.nil? &&  sym.retVar.nil?) ||
					 ( n.pos.nil?    && !sym.attrPos.nil?) ||
					 ( n.retVar.nil? && !sym.retVar.nil?)) then
				       SemErr(5)
				     end
                                   end
				 
		when 22 then

			Get()
			g = self.Expression()
			Expect(23)
		when 31 then

			Get()
			g = self.Expression()
			Expect(32)
			Graph.Option(g) 
		when 33 then

			Get()
			g = self.Expression()
			Expect(34)
			Graph.Iteration(g) 
		when 37 then

			pos = self.SemText()
			g.l = Node.new(Node::Sem, 0, 0)
                                   g.r = g.l
                                   n = g.l
				   n.pos = pos
				 
		when 24 then

			Get()
			set = Sets.FullSet(Tab::MaxTerminals)
                                   set.clear(Sym::EofSy)
                                   g.l = Node.new(Node::Any, Tab.NewSet(set), 0)
                                   g.r = g.l
				 
		when 35 then

			Get()
			g.l = Node.new(Node::Sync, 0, 0)
                                   g.r = g.l
				 
		else
  Error(43)
		end
		return g
	end

	private; def self.Term()
		g2 = nil 
		g = nil 
		if (StartOf(5)) then
			g = self.Factor()
			while (StartOf(5))
				g2 = self.Factor()
				Graph.Sequence(g, g2) 
			end
		elsif (StartOf(6)) then
			g = Graph.new()
                                   g.l = Node.new(Node::Eps, 0, 0)
                                   g.r = g.l
				 
		else Error(44)
end
		return g
	end

	private; def self.Symbol()
		name = "???"
				   kind = @@ident
				 
		if (@t.kind==2) then
			Get()
			name = @token.val 
		elsif (@t.kind==3) then
			Get()
			name = FixString(@token.val)
    				   kind = @@string
				 
		else Error(45)
end
		return name, kind
	end

	private; def self.SimSet()
		name = ""
				   c = n = 0
				
		s = BitSet.new(128) 
		if (@t.kind==2) then
			Get()
			c = CharClass.Find(@token.val)
                                   if c.nil? then
				     SemErr(15)
				   else
				     s.or(c.set)
				   end
				
		elsif (@t.kind==3) then
			Get()
			name = @token.val
				   i=1
                                   while (name[i] != name[0]) do
                                     s.set(name[i])
				     i += 1
				   end
				
		elsif (@t.kind==21) then
			Get()
			Expect(22)
			Expect(4)
			n = @token.val.to_i
                                   s.set(n)
				
			Expect(23)
		elsif (@t.kind==24) then
			Get()
			s = Sets.FullSet(127) 
		else Error(46)
end
		return s
	end

	private; def self.Set()
		s2 = nil 
		s = self.SimSet()
		while (@t.kind==19 || @t.kind==20)
			if (@t.kind==19) then
				Get()
				s2 = self.SimSet()
				s.or(s2) 
			else
				Get()
				s2 = self.SimSet()
				Sets.Differ(s, s2) 
			end
		end
		return s
	end

	private; def self.TokenExpr()
		g2 = nil
				   first = false
				 
		g = self.TokenTerm()
		first = true 
		while (WeakSeparator(29,2,7) )
			g2 = self.TokenTerm()
			if (first) then
				     Graph.FirstAlt(g)
				     first = false
				   end
                                   Graph.Alternative(g, g2)
				 
		end
		return g
	end

	private; def self.TokenDecl(typ)
		s = pos = g = nil
				   sp = 0
				 
		name, kind = self.Symbol()
		if (Sym.Find(name) != Sym::NoSym) then
				     SemErr(7)
				     sp = 0
                                   else
                                     sp = Sym.new(typ, name, @token.line)
                                     sp.graph = Sym::ClassToken # TODO: tokenKind
                                   end
				 
		while (!(StartOf(8))); Error(47); Get(); end
		if (@t.kind==8) then
			Get()
			g = self.TokenExpr()
			Expect(9)
			if (kind != @@ident) then
				     SemErr(13)
				   end
                                   Graph.Finish(g)
                                   DFA.ConvertToStates(g.l, sp)
				 
		elsif (StartOf(9)) then
			if (kind==@@ident) then
				     @@genScanner = false
                                   else
				     DFA.MatchLiteral(sp)
				   end
				
		else Error(48)
end
		if (@t.kind==37) then
			pos = self.SemText()
			if (typ==Node::T) then
				     SemErr(14)
				   end
                                   sp.semPos = pos
				 
		end
	end

	private; def self.SetDecl()
		c = 0
				   s = nil
				   name = ""
				
		Expect(2)
		name = @token.val
                                   c = CharClass.Find(name)
                                   SemErr(7) unless c.nil?
				
		Expect(8)
		s = self.Set()
		c = CharClass.new(name, s) 
		Expect(9)
	end

	private; def self.Expression()
		g2 = nil
	   	   		   first = false
				 
		g = self.Term()
		first = true 
		while (WeakSeparator(29,10,11) )
			g2 = self.Term()
			if (first) then
				     Graph.FirstAlt(g)
				     first = false
				   end
                                   Graph.Alternative(g, g2)
				 
		end
		return g
	end

	private; def self.SemText()
		Expect(37)
		beg = @t.pos
				   col = @t.col
				 
		while (StartOf(12))
			if (StartOf(13)) then
				Get()
			elsif (@t.kind==5) then
				Get()
				SemErr(18) 
			else
				Get()
				SemErr(19) 
			end
		end
		Expect(38)
		pos = Position.new(beg, @token.pos - beg, col)
  				 
		return pos
	end

	private; def self.AttrDecl(sym)
		beg = col = 0
				   buf = nil
				   buf2 = []
				 
		Expect(25)
		while (@t.kind==26)
			Get()
			Expect(2)
			buf = @token.val.clone 
			Expect(2)
			buf2 << @token.val.dup
    				   sym.retType = buf.to_s
				 
			if (@t.kind==27) then
				Get()
			end
		end
		sym.retVar = buf2.join(', ') unless buf2.empty?
  				   beg = @t.pos
  				   col = @t.col
				 
		while (StartOf(1))
			Get()
		end
		Expect(28)
		if (@token.pos > beg) then
                                     sym.attrPos = Position.new(beg, @token.pos - beg, col)
                                   end
				 
	end

	private; def self.Declaration()
		g1 = g2 = nil
				   nested = false
				
		if (@t.kind==11) then
			Get()
			while (@t.kind==2)
				self.SetDecl()
			end
		elsif (@t.kind==12) then
			Get()
			while (@t.kind==2 || @t.kind==3)
				self.TokenDecl(Node::T)
			end
		elsif (@t.kind==13) then
			Get()
			while (@t.kind==2 || @t.kind==3)
				self.TokenDecl(Node::Pr)
			end
		elsif (@t.kind==14) then
			Get()
			Expect(15)
			g1 = self.TokenExpr()
			Expect(16)
			g2 = self.TokenExpr()
			if (@t.kind==17) then
				Get()
				nested = true 
			elsif (StartOf(14)) then
				nested = false 
			else Error(49)
end
			Comment.new(g1.l, g2.l, nested) 
		elsif (@t.kind==18) then
			Get()
			Tab.ignored = self.Set()
		else Error(50)
end
	end

	private; def self.Coco()
		gramLine = sp = eofSy = 0
                                   undefined = noAttrs = noRet = ok = ok1 = false
                                   gramName = ""
                                   sym = nil
                                   g = nil
				
		Expect(6)
		gramLine = @token.line
                                   eofSy = Sym.new(Node::T, "EOF", 0)
                                   @@genScanner = true
                                   ok = true
                                   Tab.ignored = BitSet.new()
				
		Expect(2)
		gramName = @token.val
                                   beg = @t.pos
				
		while (StartOf(15))
			Get()
		end
		Tab.semDeclPos = Position.new(beg, @t.pos-beg, 0)
				
		while (StartOf(16))
			self.Declaration()
		end
		while (!(@t.kind==0 || @t.kind==7)); Error(51); Get(); end
		Expect(7)
		Tab.ignored.set(32)	#' ' is always ignored
                                   if (@@genScanner) then
					ok = DFA.MakeDeterministic()
				   end
                                   Node.EraseNodes
				
		while (@t.kind==2)
			Get()
			sym = Sym.Find(@token.val)
                                   undefined = sym == Sym::NoSym
                                   if (undefined) then
                                       sym = Sym.new(Node::Nt, @token.val, @token.line)
                                   else 
                                       if (sym.typ==Node::Nt) then
					   unless sym.graph.nil? then
					      SemErr(7)
					   end
                                       else
					 SemErr(8)
				       end
                                       sym.line = @token.line
                                   end
                                   noAttrs = sym.attrPos.nil?
				   sym.attrPos = nil
                                   noRet = sym.retVar.nil? || sym.retVar.empty?
				   sym.retVar = nil
				
			if (@t.kind==25) then
				self.AttrDecl(sym)
			end
			if (!undefined) then
                                     if ((noAttrs  && !sym.attrPos.nil?) || 
				         (noRet    && !sym.retVar.nil?) || 
					 (!noAttrs && sym.attrPos.nil?) || 
					 (!noRet   && sym.retVar .nil?)) then
				       SemErr(5)
				     end
				   end
                                   
			if (@t.kind==37) then
				sym.semPos = self.SemText()
			end
			ExpectWeak(8, 17)
			g = self.Expression()
			sym.graph = g.l
                                   Graph.Finish(g)
				
			ExpectWeak(9, 18)
		end
		if (Tab.ddt[2]) then
				     Node.PrintNodes()
				   end
                                   Tab.gramSy = Sym.Find(gramName)
                                   if (Tab.gramSy==Sym::NoSym) then
				       SemErr(11)
                                   else
                                       sym = Tab.gramSy
                                       unless (sym.attrPos.nil?) then
				         SemErr(12)
				       end
                                   end
				
		Expect(10)
		Expect(2)
		if (gramName != @token.val) then
					 SemErr(17)
				   end
                                   if (Scanner.err.count == 0) then
                                       puts("checking"); STDOUT.flush
                                       Tab.CompSymbolSets()
                                       if (ok) then
					 ok = Tab.NtsComplete()
				       end
                                       if (ok) then
                                           ok1 = Tab.AllNtReached()
                                           ok = Tab.NoCircularProductions()
                                       end
                                       if (ok) then
					 ok = Tab.AllNtToTerm()
				       end
                                       if (ok) then
					 ok1 = Tab.LL1()
				       end
                                       if (Tab.ddt[7]) then
					 Tab.XRef()
				       end
                                       if (ok) then
                                           print("parser"); STDOUT.flush()
                                           ParserGen.WriteParser()
                                           if (@@genScanner) then
                                               print(" + scanner"); STDOUT.flush()
                                               ok = DFA.WriteScanner()
                                               if (Tab.ddt[0]) then
					         DFA.PrintStates()
					       end
                                           end
                                           puts(" generated"); STDOUT.flush
                                           if (Tab.ddt[8]) then
					     ParserGen.WriteStatistics()
					   end
                                       end
                                   else
				     ok = false
				   end
                                   if (Tab.ddt[6]) then
					Tab.PrintSymbolTable()
				   end
                                   puts
				
		Expect(9)
	end



	def Parser.Parse()
		@t = Token.new();
		Get();
		Coco()

	end

	@@set = [
	[T,X,X,X, X,X,X,X, X,X,X,X, X,X,X,X, X,X,X,X, X,X,X,X, X,X,X,X, X,X,X,X, X,X,X,X, X,X,X,X, X],
	[X,T,T,T, T,T,T,T, T,T,T,T, T,T,T,T, T,T,T,T, T,T,T,T, T,T,T,T, X,T,T,T, T,T,T,T, T,T,T,T, X],
	[X,X,T,T, X,X,X,X, X,X,X,X, X,X,X,X, X,X,X,X, X,X,T,X, X,X,X,X, X,X,X,T, X,T,X,X, X,X,X,X, X],
	[X,T,T,T, T,T,T,T, T,T,T,T, T,T,T,T, T,T,T,T, T,T,T,T, T,T,T,X, X,T,T,T, T,T,T,T, T,T,T,T, X],
	[X,T,T,T, T,T,T,T, T,T,T,T, T,T,T,T, T,T,T,T, T,T,T,T, T,T,T,T, T,T,T,T, T,T,T,T, T,T,T,T, X],
	[X,X,T,T, X,X,X,X, X,X,X,X, X,X,X,X, X,X,X,X, X,X,T,X, T,X,X,X, X,X,T,T, X,T,X,T, X,T,X,X, X],
	[X,X,X,X, X,X,X,X, X,T,X,X, X,X,X,X, X,X,X,X, X,X,X,T, X,X,X,X, X,T,X,X, T,X,T,X, X,X,X,X, X],
	[X,X,X,X, X,X,X,T, X,T,X,T, T,T,T,X, T,T,T,X, X,X,X,T, X,X,X,X, X,X,X,X, T,X,T,X, X,X,X,X, X],
	[T,X,T,T, X,X,X,T, T,X,X,T, T,T,T,X, X,X,T,X, X,X,X,X, X,X,X,X, X,X,X,X, X,X,X,X, X,T,X,X, X],
	[X,X,T,T, X,X,X,T, X,X,X,T, T,T,T,X, X,X,T,X, X,X,X,X, X,X,X,X, X,X,X,X, X,X,X,X, X,T,X,X, X],
	[X,X,T,T, X,X,X,X, X,T,X,X, X,X,X,X, X,X,X,X, X,X,T,T, T,X,X,X, X,T,T,T, T,T,T,T, X,T,X,X, X],
	[X,X,X,X, X,X,X,X, X,T,X,X, X,X,X,X, X,X,X,X, X,X,X,T, X,X,X,X, X,X,X,X, T,X,T,X, X,X,X,X, X],
	[X,T,T,T, T,T,T,T, T,T,T,T, T,T,T,T, T,T,T,T, T,T,T,T, T,T,T,T, T,T,T,T, T,T,T,T, T,T,X,T, X],
	[X,T,T,T, T,X,T,T, T,T,T,T, T,T,T,T, T,T,T,T, T,T,T,T, T,T,T,T, T,T,T,T, T,T,T,T, T,X,X,T, X],
	[X,X,X,X, X,X,X,T, X,X,X,T, T,T,T,X, X,X,T,X, X,X,X,X, X,X,X,X, X,X,X,X, X,X,X,X, X,X,X,X, X],
	[X,T,T,T, T,T,T,X, T,T,T,X, X,X,X,T, T,T,X,T, T,T,T,T, T,T,T,T, T,T,T,T, T,T,T,T, T,T,T,T, X],
	[X,X,X,X, X,X,X,X, X,X,X,T, T,T,T,X, X,X,T,X, X,X,X,X, X,X,X,X, X,X,X,X, X,X,X,X, X,X,X,X, X],
	[T,X,T,T, X,X,X,T, T,T,X,T, T,T,T,X, X,X,T,X, X,X,T,X, T,X,X,X, X,T,T,T, X,T,X,T, X,T,X,X, X],
	[T,X,T,T, X,X,X,T, T,X,T,T, T,T,T,X, X,X,T,X, X,X,X,X, X,X,X,X, X,X,X,X, X,X,X,X, X,T,X,X, X],
	]
end

