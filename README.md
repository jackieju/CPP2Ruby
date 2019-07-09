# CPP2Ruby
A Translator for converting c/c++  code to ruby

Intro
=====
1 . This is a full featured translator for c/c++ code to ruby, which has passed the test on a 10 Million lines cpp product.
It covers all c/c++ syntax expect some cpp11 features.
Actually it is a compiler, the ruby version of c/c++ compiler generated by cocoR. (Since cocoR doesn't generate ruby code, so I move my c-script compiler to this as a base compiler). It does preprocessor, so can parse all kinds of c/c++ macros. 
Then it does parsing and generate ruby code.  

But in most case, you can't run the generate ruby code just as same result as c/c++.  
You absolutely need do some manual work. This tool's goal is helping you do the 99% of job.  

2 . The is a very "soft" compiler. You can just translate part of your cpp project(e.g. one or two modules) without any error. This is useful when you work on a million-lines c/c++ project. You can do nice refactoring to ruby gradually,  module by module.

3 . You can extend this compile by define more macros to translate platform dependant api to ruby api.

4 . Directory of this projects:<br>
 1) All source of compiler is under root.<br> 
 2) ./output: The ruby code generated from POJDT.c<br>
 3) ./jdt: The testing rails project for generated ruby code<br>

5 . License is GPL

Supported Features
===
This tools supports all cpp features expect some after cpp11.
Here describe some and explain how we support it.
1. goto statement

Althought ruby doesn't support goto, but will generate which code has same effection.
Please see https://rubygems.org/gems/goto

2. Mulit-inheritence

Although ruby doesn't support, but will generate code which has same functionality.
If the class has more than one parent class, The translator will generate normal class for the first one, 
and from the 2nd parent class, it will generate a class with same name which include a ruby module withe the name "<name>_module", and the current class will include it.
	e.g. in cpp
	<pre>
	class A: B, C{
	}
	</pre>
	generated ruby code:
	<pre>
	class A< B
	end
	class B
	end
	class C
	include C_module
	end
	module C_module
	end
	</pre>
3. Function Polymophism with different parameter number

The generated ruby will implement it in this ways.
The translator will generate one ruby method with variable arguments, which will call relative method with name "<functionname>_v<number of parameter>"
e.g. in cpp
<pre>
void fn(){}
void fn(int a){}
</pre>
generated ruby code:
<pre>
def fn(*_args_)                    # this method has been overriden with different number of parameters
   if _args_.size != 0
      return method("fn_v#{_args_.size}").call(*_args_)
   end
end

def fn_v1(a)
end

</pre>
Unsupported Features
===
Some cpp11 features are not supported

1. lumda
2. operator=, because in ruby class you cannot override = to do copy construction
3. Multi call to multiple parent classs's constructor is not support, generated ruby will only call one "super(xxx)"
e.g.
</pre>
class CTaxMoneyOverflowException : virtual public CTaxException, public CMoneyOverflowFormulaException, public C
{
public:
	CTaxMoneyOverflowException (long id, const SBOString& op1, const SBOString& op2, const SBOString& op, CBizEnv& env)
	: CTaxException (id, env), CMoneyOverflowFormulaException (id, op1, op2, op) {}

</pre>

4. template parameter pack 

<pre>
template <typename T, typename ...Args>
void CBizFormsMgr::SetDisplayObjectUserInterface (long objectType, Args&&... args)
{
	m_objectUserInterfaceRegister.RegisterDisplayObjectUserInterface (SBOString (objectType), std::make_unique<T> (std::forward<Args> (args)...), false);
}
	</pre>
How to translate your cpp to ruby:
===
1 . Download the project from https://github.com/jackieju/CPP2Ruby.git  

***You need install ruby version >= 1.9***

2 . Run translate.rb to do job  

        $ ruby translate.rb -d output POJDT.c POJDT1.c  

You don't need involve all files included by POJDT.c (which will leads to a hell), you just need to copy those file you really want them logic.<br>
So here I only want copy 3 file POJDT.c POJDT1.c and POJDT.h, and just declare those macros and class name that you don't want involve.<br>

3 . Declare macros and class dependency<br>
Before translation, you need <br>
1) Define some macro in c_macros.c<br>
e.g.
<pre>
	#define TRUE true
	#define FALSE false
	#define NULL nil
	#define _LOGMSG(a,b,c)
</pre>
2) You can define all classes name which are referenced but not defined in your c/cpp file, in c_classdefs.rb<br>
<pre>
$ar_classdefs = [
    "std",
    "SJournalKeys",
    "CBusinessObject",
    "PDAG",
...
    ]
</pre>
4. other options

You can define the type you want parser to ignore, and the file you don't want to include in "c_classdefs.rb"
<pre>
$unusableType =[
    "export",
    "typename"
]

#files don't include
$exclude_file=[
    "stdio",
    "stdio.h",
    "malloc.h",
    "windows.h",
    "sql.h",
    "sqlext.h",
    "__DBM.*\\.h",
]
</pre>
5. Troubleshooting
When you encounter error while translating, please check the line and the perpetrator class and macro in above 2 steps.  
e.g. The error message is:
<pre>
41257|]...... SBOErr RecordHist (CBusinessObject& bizObject, PDAG dag);......
41257|]......~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^~~~~......
41257|]stack:(cr_parser.rb:327:in `GenError'
cr_parser.rb:250:in `Expect'
cp.rb:3695:in `FunctionCall'
cp.rb:1693:in `VarList'
</pre>
Then you need add "CBusinessObject" and "PDAG" into the array in file c_classdefs.rb
	
If you'v done translation successfully, you will see all ruby files under directory "output"

The preprocessing result is in file named like "pre.<your c file name>.<timestamp>".
The "pre.part.<c file name>.<time" is temp file in case the result it too big, the the proprocessing failed, you can also check "pre.part.." file.
The "./included_files" stores the including infomation during preprocessing.
The "./allmacros" stores all the macro defined in preprocessing.

4 . You can define more macros in c_macros.c to extend this tranlate. 
This is very useful to translate platform dependant api to ruby api.  
e.g. You want to translate strlen(s) to ruby code s.size()
		#define strlen(s) s.size

Easy ? :)

