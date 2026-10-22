typedef   signed char       int8;
typedef unsigned char      uint8;
typedef   signed short      int16;
typedef unsigned short     uint16;
typedef   signed int        int32;
typedef unsigned int       uint32;
typedef   signed long long  int64;
typedef unsigned long long uint64;
typedef struct { char *data; int64 len; int64 size; } FBSTRING;
typedef int8 boolean;
typedef int64 $11FB_DATATYPE;
typedef int64 $11FB_FUNCMODE;
typedef int64 $12FB_SYMBCLASS;
typedef int64 $13FB_SYMBATTRIB;
typedef int64 $13FB_PROCATTRIB;
typedef int64 $12FB_SYMBSTATS;
struct $9FB_SYMBID {
	char* NAME;
	char* ALIAS;
	char* MANGLED;
};
#define __FB_STATIC_ASSERT( expr ) extern int __$fb_structsizecheck[(expr) ? 1 : -1]
__FB_STATIC_ASSERT( sizeof( struct $9FB_SYMBID ) == 24 );
struct $8FBSYMBOL;
typedef int64 $13AST_NODECLASS;
union $7FBVALUE {
	struct $8FBSYMBOL* S;
	int64 I;
	double F;
};
__FB_STATIC_ASSERT( sizeof( union $7FBVALUE ) == 8 );
struct $14AST_NODE_CONST {
	union {
		union $7FBVALUE VALUE;
		struct $8FBSYMBOL* S;
		int64 I;
		double F;
	};
	int64 HASSUFFIX;
};
__FB_STATIC_ASSERT( sizeof( struct $14AST_NODE_CONST ) == 16 );
struct $12AST_NODE_VAR {
	int64 OFS;
};
__FB_STATIC_ASSERT( sizeof( struct $12AST_NODE_VAR ) == 8 );
struct $12AST_NODE_IDX {
	int64 OFS;
	int64 MULT;
};
__FB_STATIC_ASSERT( sizeof( struct $12AST_NODE_IDX ) == 16 );
struct $12AST_NODE_PTR {
	int64 OFS;
};
__FB_STATIC_ASSERT( sizeof( struct $12AST_NODE_PTR ) == 8 );
struct $7ASTNODE;
struct $19AST_TMPSTRLIST_ITEM;
struct $19AST_TMPSTRLIST_ITEM {
	struct $8FBSYMBOL* SYM;
	struct $7ASTNODE* SRCTREE;
	struct $19AST_TMPSTRLIST_ITEM* PREV;
};
__FB_STATIC_ASSERT( sizeof( struct $19AST_TMPSTRLIST_ITEM ) == 24 );
struct $13AST_NODE_CALL {
	int64 ISRTL;
	int64 ARGS;
	struct $8FBSYMBOL* CURRARG;
	struct $7ASTNODE* ARGTAIL;
	struct $19AST_TMPSTRLIST_ITEM* STRTAIL;
	struct $8FBSYMBOL* TMPRES;
	struct $7ASTNODE* PROFBEGIN;
	struct $7ASTNODE* PROFEND;
};
__FB_STATIC_ASSERT( sizeof( struct $13AST_NODE_CALL ) == 64 );
struct $12AST_NODE_ARG {
	int64 MODE;
	int64 LGT;
};
__FB_STATIC_ASSERT( sizeof( struct $12AST_NODE_ARG ) == 16 );
struct $12AST_NODE_IIF {
	struct $8FBSYMBOL* FALSELABEL;
};
__FB_STATIC_ASSERT( sizeof( struct $12AST_NODE_IIF ) == 8 );
typedef int64 $9AST_OPOPT;
struct $11AST_NODE_OP {
	int64 OP;
	$9AST_OPOPT OPTIONS;
	struct $8FBSYMBOL* EX;
};
__FB_STATIC_ASSERT( sizeof( struct $11AST_NODE_OP ) == 24 );
struct $13AST_NODE_LOAD {
	int64 ISRES;
};
__FB_STATIC_ASSERT( sizeof( struct $13AST_NODE_LOAD ) == 8 );
struct $14AST_NODE_LABEL {
	int64 FLUSH;
};
__FB_STATIC_ASSERT( sizeof( struct $14AST_NODE_LABEL ) == 8 );
struct $13AST_NODE_OFFS {
	int64 OFS;
};
__FB_STATIC_ASSERT( sizeof( struct $13AST_NODE_OFFS ) == 8 );
struct $12AST_NODE_LIT {
	char* TEXT;
};
__FB_STATIC_ASSERT( sizeof( struct $12AST_NODE_LIT ) == 8 );
typedef int64 $14AST_ASMTOKTYPE;
struct $9ASTASMTOK;
struct $9ASTASMTOK {
	$14AST_ASMTOKTYPE TYPE;
	union {
		struct $8FBSYMBOL* SYM;
		char* TEXT;
	};
	struct $9ASTASMTOK* NEXT;
};
__FB_STATIC_ASSERT( sizeof( struct $9ASTASMTOK ) == 24 );
struct $12AST_NODE_ASM {
	struct $9ASTASMTOK* TOKHEAD;
};
__FB_STATIC_ASSERT( sizeof( struct $12AST_NODE_ASM ) == 8 );
struct $14AST_NODE_JMPTB {
	uint64* VALUES;
	struct $8FBSYMBOL** LABELS;
	int64 LABELCOUNT;
	struct $8FBSYMBOL* DEFLABEL;
	uint64 BIAS;
	uint64 SPAN;
};
__FB_STATIC_ASSERT( sizeof( struct $14AST_NODE_JMPTB ) == 48 );
struct $12AST_NODE_DBG {
	int64 EX;
	char* FILENAME;
	int64 OP;
};
__FB_STATIC_ASSERT( sizeof( struct $12AST_NODE_DBG ) == 24 );
struct $12AST_NODE_MEM {
	int64 OP;
	int64 BYTES;
	int64 FILLCHAR;
};
__FB_STATIC_ASSERT( sizeof( struct $12AST_NODE_MEM ) == 24 );
struct $14AST_NODE_STACK {
	int64 OP;
};
__FB_STATIC_ASSERT( sizeof( struct $14AST_NODE_STACK ) == 8 );
struct $16AST_NODE_TYPEINI {
	int64 OFS;
	union {
		int64 BYTES;
		int64 ELEMENTS;
	};
	struct $8FBSYMBOL* SCP;
	struct $8FBSYMBOL* LASTSCP;
};
__FB_STATIC_ASSERT( sizeof( struct $16AST_NODE_TYPEINI ) == 32 );
struct $21AST_NODE_TYPEINISCOPE {
	int64 IS_ARRAY;
};
__FB_STATIC_ASSERT( sizeof( struct $21AST_NODE_TYPEINISCOPE ) == 8 );
struct $13AST_BREAKLIST {
	struct $7ASTNODE* HEAD;
	struct $7ASTNODE* TAIL;
};
__FB_STATIC_ASSERT( sizeof( struct $13AST_BREAKLIST ) == 16 );
struct $13AST_NODE_PROC {
	int64 ISMAIN;
	struct $7ASTNODE* DECL_LAST;
};
__FB_STATIC_ASSERT( sizeof( struct $13AST_NODE_PROC ) == 16 );
struct $14AST_NODE_BLOCK {
	struct $7ASTNODE* PARENT;
	int64 INISTMT;
	int64 ENDSTMT;
	struct $8FBSYMBOL* INITLABEL;
	struct $8FBSYMBOL* EXITLABEL;
	struct $13AST_BREAKLIST BREAKLIST;
	struct $13AST_NODE_PROC PROC;
};
__FB_STATIC_ASSERT( sizeof( struct $14AST_NODE_BLOCK ) == 72 );
struct $14AST_NODE_BREAK {
	struct $7ASTNODE* PARENT;
	int64 SCOPE;
	int64 LINENUM;
	int64 STMTNUM;
};
__FB_STATIC_ASSERT( sizeof( struct $14AST_NODE_BREAK ) == 32 );
struct $17AST_NODE_DATASTMT {
	union {
		int64 ID;
		int64 ELMTS;
	};
};
__FB_STATIC_ASSERT( sizeof( struct $17AST_NODE_DATASTMT ) == 8 );
struct $13AST_NODE_LINK {
	int64 RET;
};
__FB_STATIC_ASSERT( sizeof( struct $13AST_NODE_LINK ) == 8 );
struct $13AST_NODE_CAST {
	int64 DOCONV;
	int64 DO_CONVFD2FS;
	int64 CONVCONST;
};
__FB_STATIC_ASSERT( sizeof( struct $13AST_NODE_CAST ) == 24 );
struct $7ASTNODE {
	$13AST_NODECLASS CLASS;
	int64 DTYPE;
	struct $8FBSYMBOL* SUBTYPE;
	struct $8FBSYMBOL* SYM;
	int64 VECTOR;
	union {
		struct $14AST_NODE_CONST VAL;
		struct $12AST_NODE_VAR VAR_;
		struct $12AST_NODE_IDX IDX;
		struct $12AST_NODE_PTR PTR;
		struct $13AST_NODE_CALL CALL;
		struct $12AST_NODE_ARG ARG;
		struct $12AST_NODE_IIF IIF;
		struct $11AST_NODE_OP OP;
		struct $13AST_NODE_LOAD LOD;
		struct $14AST_NODE_LABEL LBL;
		struct $13AST_NODE_OFFS OFS;
		struct $12AST_NODE_LIT LIT;
		struct $12AST_NODE_ASM ASM;
		struct $14AST_NODE_JMPTB JMPTB;
		struct $12AST_NODE_DBG DBG;
		struct $12AST_NODE_MEM MEM;
		struct $14AST_NODE_STACK STACK;
		struct $16AST_NODE_TYPEINI TYPEINI;
		struct $21AST_NODE_TYPEINISCOPE TYPEINISCOPE;
		struct $14AST_NODE_BLOCK BLOCK;
		struct $14AST_NODE_BREAK BREAK;
		struct $17AST_NODE_DATASTMT DATA;
		struct $13AST_NODE_LINK LINK;
		struct $13AST_NODE_CAST CAST;
	};
	struct $7ASTNODE* L;
	struct $7ASTNODE* R;
	struct $7ASTNODE* PREV;
	struct $7ASTNODE* NEXT;
};
__FB_STATIC_ASSERT( sizeof( struct $7ASTNODE ) == 144 );
struct $10FBARRAYDIM {
	int64 LOWER;
	int64 UPPER;
};
__FB_STATIC_ASSERT( sizeof( struct $10FBARRAYDIM ) == 16 );
struct $9FBS_ARRAY {
	int64 DIMENSIONS;
	struct $10FBARRAYDIM* DIMTB;
	int64 DIFF;
	int64 ELEMENTS;
	struct $8FBSYMBOL* DESC;
	struct $8FBSYMBOL* DESCTYPE;
};
__FB_STATIC_ASSERT( sizeof( struct $9FBS_ARRAY ) == 48 );
struct $10FBVAR_DESC {
	struct $8FBSYMBOL* ARRAY;
};
__FB_STATIC_ASSERT( sizeof( struct $10FBVAR_DESC ) == 8 );
struct $10FBVAR_DATA {
	struct $8FBSYMBOL* PREV;
};
__FB_STATIC_ASSERT( sizeof( struct $10FBVAR_DATA ) == 8 );
struct $7FBS_VAR {
	union {
		char* LITTEXT;
		uint32* LITTEXTW;
		struct $7ASTNODE* INITREE;
	};
	struct $9FBS_ARRAY ARRAY;
	struct $10FBVAR_DESC DESC;
	int64 STMTNUM;
	int64 ALIGN;
	struct $10FBVAR_DATA DATA;
	int64 BITPOS;
	int64 BITS;
};
__FB_STATIC_ASSERT( sizeof( struct $7FBS_VAR ) == 104 );
struct $9FBS_CONST {
	union {
		union $7FBVALUE VALUE;
		struct $8FBSYMBOL* S;
		int64 I;
		double F;
	};
	int64 HASSUFFIX;
};
__FB_STATIC_ASSERT( sizeof( struct $9FBS_CONST ) == 16 );
struct $10FBSYMBOLTB {
	struct $8FBSYMBOL* OWNER;
	struct $8FBSYMBOL* HEAD;
	struct $8FBSYMBOL* TAIL;
};
__FB_STATIC_ASSERT( sizeof( struct $10FBSYMBOLTB ) == 24 );
struct $8HASHITEM;
struct $8HASHITEM {
	char* NAME;
	void* DATA;
	struct $8HASHITEM* PREV;
	struct $8HASHITEM* NEXT;
};
__FB_STATIC_ASSERT( sizeof( struct $8HASHITEM ) == 32 );
struct $8HASHLIST {
	struct $8HASHITEM* HEAD;
	struct $8HASHITEM* TAIL;
};
__FB_STATIC_ASSERT( sizeof( struct $8HASHLIST ) == 16 );
struct $5THASH {
	struct $8HASHLIST* LIST;
	int64 NODES;
	int64 DELSTR;
};
__FB_STATIC_ASSERT( sizeof( struct $5THASH ) == 24 );
struct $8FBHASHTB;
struct $8FBHASHTB {
	struct $8FBSYMBOL* OWNER;
	struct $5THASH TB;
	struct $8FBHASHTB* PREV;
	struct $8FBHASHTB* NEXT;
};
__FB_STATIC_ASSERT( sizeof( struct $8FBHASHTB ) == 48 );
struct $9FBSYMLIST {
	struct $8FBSYMBOL* HEAD;
	struct $8FBSYMBOL* TAIL;
};
__FB_STATIC_ASSERT( sizeof( struct $9FBSYMLIST ) == 16 );
struct $10FBSYMCHAIN;
struct $10FBSYMCHAIN {
	struct $8FBSYMBOL* SYM;
	struct $10FBSYMCHAIN* NEXT;
	int64 ISIMPORT;
	struct $10FBSYMCHAIN* PREV;
	struct $8HASHITEM* ITEM;
	struct $10FBSYMCHAIN* IMP_NEXT;
};
__FB_STATIC_ASSERT( sizeof( struct $10FBSYMCHAIN ) == 48 );
struct $13FBNAMESPC_EXT {
	struct $9FBSYMLIST IMPLIST;
	struct $9FBSYMLIST EXPLIST;
	int64 CNT;
	struct $10FBSYMCHAIN* IMPSYM_HEAD;
	struct $10FBSYMCHAIN* IMPSYM_TAIL;
};
__FB_STATIC_ASSERT( sizeof( struct $13FBNAMESPC_EXT ) == 56 );
struct $9FBNAMESPC {
	struct $10FBSYMBOLTB SYMTB;
	struct $8FBHASHTB HASHTB;
	struct $13FBNAMESPC_EXT* EXT;
};
__FB_STATIC_ASSERT( sizeof( struct $9FBNAMESPC ) == 80 );
typedef int64 $15FB_STRUCT_INREG;
struct $13FB_STRUCT_DBG {
	int64 TYPENUM;
};
__FB_STATIC_ASSERT( sizeof( struct $13FB_STRUCT_DBG ) == 8 );
struct $12FB_STRUCTEXT {
	struct $8FBSYMBOL* CTORHEAD;
	struct $8FBSYMBOL* DEFCTOR;
	struct $8FBSYMBOL* COPYCTOR;
	struct $8FBSYMBOL* COPYCTORCONST;
	struct $8FBSYMBOL* DTOR1;
	struct $8FBSYMBOL* DTOR0;
	struct $8FBSYMBOL* COPYLETOP;
	struct $8FBSYMBOL* COPYLETOPCONST;
	struct $8FBSYMBOL* OPOVLTB[28];
	int64 VTABLEELEMENTS;
	struct $8FBSYMBOL* VTABLE;
	struct $8FBSYMBOL* RTTI;
	int64 ABSTRACTCOUNT;
};
__FB_STATIC_ASSERT( sizeof( struct $12FB_STRUCTEXT ) == 320 );
struct $10FBS_STRUCT {
	struct $9FBNAMESPC NS;
	struct $8FBSYMBOL* BASE;
	struct $8FBSYMBOL* ANONPARENT;
	int64 NATALIGN;
	int64 UNPADLGT;
	int32 OPTIONS;
	uint8 BITPOS;
	uint8 ALIGN;
	$11FB_DATATYPE RETDTYPE;
	$15FB_STRUCT_INREG RETIN2REGS;
	struct $13FB_STRUCT_DBG DBG;
	struct $12FB_STRUCTEXT* EXT;
};
__FB_STATIC_ASSERT( sizeof( struct $10FBS_STRUCT ) == 152 );
struct $8FBS_ENUM {
	struct $9FBNAMESPC NS;
	int64 ELEMENTS;
	struct $13FB_STRUCT_DBG DBG;
};
__FB_STATIC_ASSERT( sizeof( struct $8FBS_ENUM ) == 96 );
typedef int64 $21FB_PROC_RETURN_METHOD;
typedef int64 (*tmp$34)( struct $8FBSYMBOL* );
struct $10FB_PROCRTL {
	tmp$34 CALLBACK;
};
__FB_STATIC_ASSERT( sizeof( struct $10FB_PROCRTL ) == 8 );
struct $10FB_PROCOVL {
	int16 MINPARAMS;
	int16 MAXPARAMS;
	struct $8FBSYMBOL* NEXT;
};
__FB_STATIC_ASSERT( sizeof( struct $10FB_PROCOVL ) == 16 );
struct $10FB_PROCSTK {
	int64 ARGOFS;
	int64 LOCALOFS;
	int64 LOCALMAX;
};
__FB_STATIC_ASSERT( sizeof( struct $10FB_PROCSTK ) == 24 );
struct $10FB_PROCDBG {
	int64 INILINE;
	int64 ENDLINE;
	char* INCFILE;
};
__FB_STATIC_ASSERT( sizeof( struct $10FB_PROCDBG ) == 24 );
struct $10FB_PROCERR {
	struct $8FBSYMBOL* LASTHND;
	struct $8FBSYMBOL* LASTMOD;
	struct $8FBSYMBOL* LASTFUN;
};
__FB_STATIC_ASSERT( sizeof( struct $10FB_PROCERR ) == 24 );
typedef int64 $6AST_OP;
struct $12FB_PROCOPOVL {
	$6AST_OP OP;
};
__FB_STATIC_ASSERT( sizeof( struct $12FB_PROCOPOVL ) == 8 );
struct $7TLISTTB;
struct $7TLISTTB {
	struct $7TLISTTB* NEXT;
	void* NODETB;
	int64 NODES;
};
__FB_STATIC_ASSERT( sizeof( struct $7TLISTTB ) == 24 );
struct $9TLISTNODE;
struct $9TLISTNODE {
	struct $9TLISTNODE* PREV;
	struct $9TLISTNODE* NEXT;
};
__FB_STATIC_ASSERT( sizeof( struct $9TLISTNODE ) == 16 );
typedef int64 $10LIST_FLAGS;
struct $5TLIST {
	struct $7TLISTTB* TBHEAD;
	struct $7TLISTTB* TBTAIL;
	int64 NODES;
	int64 NODELEN;
	struct $9TLISTNODE* FHEAD;
	void* HEAD;
	void* TAIL;
	$10LIST_FLAGS FLAGS;
};
__FB_STATIC_ASSERT( sizeof( struct $5TLIST ) == 64 );
typedef int64 $12FB_PROCSTATS;
struct $10FB_PROCGSB {
	struct $8FBSYMBOL* CTX;
};
__FB_STATIC_ASSERT( sizeof( struct $10FB_PROCGSB ) == 8 );
struct $10FB_PROCEXT {
	struct $8FBSYMBOL* RES;
	struct $10FB_PROCSTK STK;
	struct $10FB_PROCDBG DBG;
	struct $10FB_PROCERR ERR;
	struct $12FB_PROCOPOVL OPOVL;
	struct $5TLIST* STATDTOR;
	$12FB_PROCSTATS STATS;
	int64 STMTNUM;
	int64 PRIORITY;
	struct $10FB_PROCGSB GOSUB;
	struct $7ASTNODE* BASE_INITREE;
	int64 VTABLEINDEX;
	struct $8FBSYMBOL* OVERRIDDEN;
};
__FB_STATIC_ASSERT( sizeof( struct $10FB_PROCEXT ) == 152 );
struct $8FBS_PROC {
	struct $10FBSYMBOLTB SYMTB;
	int16 PARAMS;
	int16 OPTPARAMS;
	struct $10FBSYMBOLTB PARAMTB;
	$11FB_FUNCMODE MODE;
	$11FB_DATATYPE REALDTYPE;
	struct $8FBSYMBOL* REALSUBTYPE;
	$21FB_PROC_RETURN_METHOD RETURNMETHOD;
	struct $10FB_PROCRTL RTL;
	struct $10FB_PROCOVL OVL;
	struct $10FB_PROCEXT* EXT;
};
__FB_STATIC_ASSERT( sizeof( struct $8FBS_PROC ) == 120 );
typedef int64 $12FB_PARAMMODE;
struct $9FBS_PARAM {
	$12FB_PARAMMODE MODE;
	struct $8FBSYMBOL* VAR;
	struct $7ASTNODE* OPTEXPR;
	int64 BYDESCDIMENSIONS;
	struct $8FBSYMBOL* BYDESCREALSUBTYPE;
	int64 REGNUM;
};
__FB_STATIC_ASSERT( sizeof( struct $9FBS_PARAM ) == 48 );
struct $9FBS_LABEL {
	struct $8FBSYMBOL* PARENT;
	int64 DECLARED;
	int64 STMTNUM;
	boolean GOSUB;
};
__FB_STATIC_ASSERT( sizeof( struct $9FBS_LABEL ) == 32 );
struct $11FB_DEFPARAM;
struct $11FB_DEFPARAM {
	char* NAME;
	int64 NUM;
	struct $11FB_DEFPARAM* NEXT;
};
__FB_STATIC_ASSERT( sizeof( struct $11FB_DEFPARAM ) == 24 );
typedef int64 $14FB_DEFTOK_TYPE;
struct $9FB_DEFTOK;
struct $9FB_DEFTOK {
	$14FB_DEFTOK_TYPE TYPE;
	union {
		char* TEXT;
		uint32* TEXTW;
		int64 PARAMNUM;
	};
	struct $9FB_DEFTOK* PREV;
	struct $9FB_DEFTOK* NEXT;
};
__FB_STATIC_ASSERT( sizeof( struct $9FB_DEFTOK ) == 32 );
typedef int64 $15FB_DEFINE_FLAGS;
typedef FBSTRING* (*tmp$28)( void );
struct $8DZSTRING {
	char* DATA;
	int64 LEN;
	int64 SIZE;
};
__FB_STATIC_ASSERT( sizeof( struct $8DZSTRING ) == 24 );
struct $8DWSTRING {
	uint32* DATA;
	int64 LEN;
	int64 SIZE;
};
__FB_STATIC_ASSERT( sizeof( struct $8DWSTRING ) == 24 );
struct $9LEXPP_ARG {
	union {
		struct $8DZSTRING TEXT;
		struct $8DWSTRING TEXTW;
	};
};
__FB_STATIC_ASSERT( sizeof( struct $9LEXPP_ARG ) == 24 );
struct $11LEXPP_ARGTB {
	struct $9LEXPP_ARG TB[32];
	int64 COUNT;
};
__FB_STATIC_ASSERT( sizeof( struct $11LEXPP_ARGTB ) == 776 );
typedef FBSTRING* (*tmp$29)( struct $11LEXPP_ARGTB*, int64* );
typedef uint32* (*tmp$30)( struct $11LEXPP_ARGTB*, int64* );
struct $10FBS_DEFINE {
	int64 PARAMS;
	struct $11FB_DEFPARAM* PARAMHEAD;
	union {
		struct $9FB_DEFTOK* TOKHEAD;
		char* TEXT;
		uint32* TEXTW;
	};
	int64 ISARGLESS;
	$15FB_DEFINE_FLAGS FLAGS;
	union {
		tmp$28 DPROCZ;
		tmp$29 MPROCZ;
	};
	union {
		tmp$30 MPROCW;
	};
};
__FB_STATIC_ASSERT( sizeof( struct $10FBS_DEFINE ) == 56 );
typedef int64 $10FB_TKCLASS;
struct $11FBS_KEYWORD {
	int64 ID;
	$10FB_TKCLASS TKCLASS;
};
__FB_STATIC_ASSERT( sizeof( struct $11FBS_KEYWORD ) == 16 );
struct $8FBFWDREF;
struct $8FBFWDREF {
	struct $8FBSYMBOL* REF;
	struct $8FBFWDREF* PREV;
};
__FB_STATIC_ASSERT( sizeof( struct $8FBFWDREF ) == 16 );
struct $10FBS_FWDREF {
	struct $8FBFWDREF* TAIL;
};
__FB_STATIC_ASSERT( sizeof( struct $10FBS_FWDREF ) == 8 );
struct $11FB_SCOPEDBG {
	int64 INILINE;
	int64 ENDLINE;
	struct $8FBSYMBOL* INILABEL;
	struct $8FBSYMBOL* ENDLABEL;
};
__FB_STATIC_ASSERT( sizeof( struct $11FB_SCOPEDBG ) == 32 );
struct $12FB_SCOPEEMIT {
	int64 BASEOFS;
};
__FB_STATIC_ASSERT( sizeof( struct $12FB_SCOPEEMIT ) == 8 );
struct $9FBS_SCOPE {
	struct $7ASTNODE* BACKNODE;
	struct $10FBSYMBOLTB SYMTB;
	struct $11FB_SCOPEDBG DBG;
	struct $12FB_SCOPEEMIT EMIT;
};
__FB_STATIC_ASSERT( sizeof( struct $9FBS_SCOPE ) == 72 );
struct $13FBS_NAMESPACE {
	struct $9FBNAMESPC NS;
	int64 CNT;
	struct $8FBSYMBOL* LAST_TAIL;
};
__FB_STATIC_ASSERT( sizeof( struct $13FBS_NAMESPACE ) == 96 );
struct $12FBS_NSIMPORT {
	struct $8FBSYMBOL* IMP_NS;
	struct $8FBSYMBOL* IMP_PREV;
	struct $8FBSYMBOL* IMP_NEXT;
	struct $8FBSYMBOL* EXP_NS;
	struct $8FBSYMBOL* EXP_PREV;
	struct $8FBSYMBOL* EXP_NEXT;
};
__FB_STATIC_ASSERT( sizeof( struct $12FBS_NSIMPORT ) == 48 );
struct $9FBSYMHASH {
	struct $8FBHASHTB* TB;
	struct $8HASHITEM* ITEM;
	uint64 INDEX;
	struct $8FBSYMBOL* PREV;
	struct $8FBSYMBOL* NEXT;
};
__FB_STATIC_ASSERT( sizeof( struct $9FBSYMHASH ) == 40 );
struct $8FBSYMBOL {
	$12FB_SYMBCLASS CLASS;
	$13FB_SYMBATTRIB ATTRIB;
	$13FB_PROCATTRIB PATTRIB;
	$12FB_SYMBSTATS STATS;
	struct $9FB_SYMBID ID;
	$11FB_DATATYPE TYP;
	struct $8FBSYMBOL* SUBTYPE;
	uint16 SCOPE;
	int16 MANGLING;
	int64 LGT;
	int64 OFS;
	union {
		struct $7FBS_VAR VAR_;
		struct $9FBS_CONST VAL;
		struct $10FBS_STRUCT UDT;
		struct $8FBS_ENUM ENUM_;
		struct $8FBS_PROC PROC;
		struct $9FBS_PARAM PARAM;
		struct $9FBS_LABEL LBL;
		struct $10FBS_DEFINE DEF;
		struct $11FBS_KEYWORD KEY;
		struct $10FBS_FWDREF FWD;
		struct $9FBS_SCOPE SCP;
		struct $13FBS_NAMESPACE NSPC;
		struct $12FBS_NSIMPORT NSIMP;
	};
	struct $9FBSYMHASH HASH;
	struct $10FBSYMBOLTB* SYMTB;
	struct $8FBSYMBOL* PARENT;
	struct $8FBSYMBOL* PREV;
	struct $8FBSYMBOL* NEXT;
};
__FB_STATIC_ASSERT( sizeof( struct $8FBSYMBOL ) == 320 );
typedef int64 $10FB_RTL_OPT;
struct $15FB_RTL_PARAMDEF {
	$11FB_DATATYPE DTYPE;
	$12FB_PARAMMODE MODE;
	int64 ISOPT;
	int64 OPTVAL;
};
__FB_STATIC_ASSERT( sizeof( struct $15FB_RTL_PARAMDEF ) == 32 );
struct $14FB_RTL_PROCDEF {
	char* NAME;
	char* ALIAS;
	$11FB_DATATYPE DTYPE;
	$11FB_FUNCMODE CALLCONV;
	tmp$34 CALLBACK;
	$10FB_RTL_OPT OPTIONS;
	int64 PARAMS;
	struct $15FB_RTL_PARAMDEF PARAMTB[16];
};
__FB_STATIC_ASSERT( sizeof( struct $14FB_RTL_PROCDEF ) == 568 );
typedef int64 $12FB_DATACLASS;
struct $13SYMB_DATATYPE {
	$12FB_DATACLASS CLASS;
	int64 SIZE;
	int64 SIGNED;
	int64 INTRANK;
	$11FB_DATATYPE REMAPTYPE;
	int64 SIZETYPE;
	char* NAME;
};
__FB_STATIC_ASSERT( sizeof( struct $13SYMB_DATATYPE ) == 56 );
struct $11TSTRSETITEM {
	FBSTRING S;
	int64 USERDATA;
	struct $8HASHITEM* HASHITEM;
};
__FB_STATIC_ASSERT( sizeof( struct $11TSTRSETITEM ) == 40 );
typedef int64 $13FB_COMPTARGET;
FBSTRING* fb_StrAssign( void*, int64, void*, int64, int32 );
void fb_StrDelete( FBSTRING* );
static void fb_ctor__rtlzgfx( void ) __attribute__(( constructor ));
static void _ZN11TSTRSETITEMaSERKS_( struct $11TSTRSETITEM*, struct $11TSTRSETITEM* );
int64 FBRESTARTGETCOUNT( void );
struct $7ASTNODE* ASTADD( struct $7ASTNODE* );
struct $7ASTNODE* ASTNEWCONSTI( int64, int64, struct $8FBSYMBOL* );
struct $7ASTNODE* ASTNEWCONSTF( double, int64 );
struct $7ASTNODE* ASTNEWVAR( struct $8FBSYMBOL*, int64, int64, struct $8FBSYMBOL* );
struct $7ASTNODE* ASTNEWCALL( struct $8FBSYMBOL*, struct $7ASTNODE*, int64 );
struct $7ASTNODE* ASTNEWARG( struct $7ASTNODE*, struct $7ASTNODE*, int64, int64 );
struct $7ASTNODE* ASTBUILDPROCADDROF( struct $8FBSYMBOL* );
struct $8FBSYMBOL* SYMBALLOCSTRCONST( char*, int64 );
int64 SYMBISSTRING( int64 );
void FBADDLIB( char* );
void RTLADDINTRINSICPROCS( struct $14FB_RTL_PROCDEF* );
struct $8FBSYMBOL* RTLPROCLOOKUP( char*, int64 );
struct $7ASTNODE* RTLERRORCHECK( struct $7ASTNODE* );
static int64 HGFXLIB_CB( struct $8FBSYMBOL* );
static int64 HPORTS_CB( struct $8FBSYMBOL* );
static struct $7ASTNODE* HGETPUTTER( int64 );
typedef int64 $11AST_OPFLAGS;
struct $10AST_OPINFO {
	$13AST_NODECLASS CLASS;
	$11AST_OPFLAGS FLAGS;
	char* ID;
	$6AST_OP SELFOP;
};
__FB_STATIC_ASSERT( sizeof( struct $10AST_OPINFO ) == 32 );
struct $16__FB_ARRAYDIMTB$ {
	int64 ELEMENTS;
	int64 LBOUND;
	int64 UBOUND;
};
__FB_STATIC_ASSERT( sizeof( struct $16__FB_ARRAYDIMTB$ ) == 24 );
struct $8FBARRAY1I10AST_OPINFOE {
	struct $10AST_OPINFO* DATA;
	struct $10AST_OPINFO* PTR;
	int64 SIZE;
	int64 ELEMENT_LEN;
	int64 DIMENSIONS;
	int64 FLAGS;
	struct $16__FB_ARRAYDIMTB$ DIMTB[1];
};
__FB_STATIC_ASSERT( sizeof( struct $8FBARRAY1I10AST_OPINFOE ) == 72 );
static struct $8FBARRAY1I10AST_OPINFOE tmp$82$;
extern struct $13SYMB_DATATYPE SYMB_DTYPETB$[26];
struct $8FBARRAY1I13SYMB_DATATYPEE {
	struct $13SYMB_DATATYPE* DATA;
	struct $13SYMB_DATATYPE* PTR;
	int64 SIZE;
	int64 ELEMENT_LEN;
	int64 DIMENSIONS;
	int64 FLAGS;
	struct $16__FB_ARRAYDIMTB$ DIMTB[1];
};
__FB_STATIC_ASSERT( sizeof( struct $8FBARRAY1I13SYMB_DATATYPEE ) == 72 );
static struct $8FBARRAY1I13SYMB_DATATYPEE tmp$83$;
struct $8FBARRAY2IlE {
	int64* DATA;
	int64* PTR;
	int64 SIZE;
	int64 ELEMENT_LEN;
	int64 DIMENSIONS;
	int64 FLAGS;
	struct $16__FB_ARRAYDIMTB$ DIMTB[2];
};
__FB_STATIC_ASSERT( sizeof( struct $8FBARRAY2IlE ) == 96 );
static struct $8FBARRAY2IlE tmp$84$;
typedef int64 $10FB_OUTTYPE;
typedef int64 $10FB_BACKEND;
typedef int64 $10FB_CPUTYPE;
typedef int64 $10FB_FPUTYPE;
typedef int64 $9FB_FPMODE;
typedef int64 $17FB_VECTORIZELEVEL;
typedef int64 $12FB_ASMSYNTAX;
typedef int64 $7FB_LANG;
typedef int64 $10FB_PDCHECK;
typedef int64 $11FB_MODEVIEW;
struct $12FBCMMLINEOPT {
	$10FB_OUTTYPE OUTTYPE;
	int64 PPONLY;
	int64 SYNTAXONLY;
	$10FB_BACKEND BACKEND;
	$13FB_COMPTARGET TARGET;
	$10FB_CPUTYPE CPUTYPE;
	$10FB_FPUTYPE FPUTYPE;
	$9FB_FPMODE FPMODE;
	$17FB_VECTORIZELEVEL VECTORIZE;
	int64 OPTLEVEL;
	$12FB_ASMSYNTAX ASMSYNTAX;
	$7FB_LANG LANG;
	int64 FORCELANG;
	int64 DEBUG;
	int64 DEBUGINFO;
	int64 ASSERTIONS;
	int64 ERRORCHECK;
	int64 RESUMEERR;
	int64 EXTRAERRCHK;
	int64 ERRLOCATION;
	int64 ARRAYBOUNDCHK;
	int64 ARRAYDIMSCHK;
	int64 NULLPTRCHK;
	int64 UNWINDINFO;
	int64 PROFILE;
	int64 WARNINGLEVEL;
	int64 SHOWERROR;
	int64 MAXERRORS;
	$10FB_PDCHECK PDCHECKOPT;
	int64 GOSUBSETJMP;
	int64 VALISTASPTR;
	int64 NOTHISCALL;
	int64 NOFASTCALL;
	int64 FBRT;
	int64 EXPORT;
	int64 MSBITFIELDS;
	int64 MULTITHREADED;
	int64 FBGFX;
	int64 PIC;
	int64 STACKSIZE;
	int64 OBJINFO;
	int64 SHOWINCLUDES;
	$11FB_MODEVIEW MODEVIEW;
	int64 NOCMDLINE;
	int64 RETURNINFLTS;
	int64 NOBUILTINS;
	int64 OPTABSTRACT;
};
__FB_STATIC_ASSERT( sizeof( struct $12FBCMMLINEOPT ) == 376 );
typedef int64 $12FB_TARGETOPT;
struct $8FBTARGET {
	char* ID;
	$11FB_DATATYPE WCHAR;
	$11FB_FUNCMODE FBCALL;
	$11FB_FUNCMODE STDCALL;
	$12FB_TARGETOPT OPTIONS;
};
__FB_STATIC_ASSERT( sizeof( struct $8FBTARGET ) == 40 );
typedef int64 $12FB_WCHARCONV;
typedef int64 $13FBFILE_FORMAT;
struct $6FBFILE {
	int64 NUM;
	char NAME[261];
	char* INCFILE;
	int64 ISMAIN;
	$13FBFILE_FORMAT FORMAT;
};
__FB_STATIC_ASSERT( sizeof( struct $6FBFILE ) == 296 );
struct $6FBMAIN {
	struct $8FBSYMBOL* PROC;
	struct $7ASTNODE* INITNODE;
};
__FB_STATIC_ASSERT( sizeof( struct $6FBMAIN ) == 16 );
typedef int64 $11FB_LANG_OPT;
struct $11FB_LANG_CTX {
	$11FB_LANG_OPT OPT;
	$11FB_DATATYPE INTEGERKEYWORDDTYPE;
	$11FB_DATATYPE INT15LITERALDTYPE;
	$11FB_DATATYPE INT16LITERALDTYPE;
	$11FB_DATATYPE INT31LITERALDTYPE;
	$11FB_DATATYPE INT32LITERALDTYPE;
	$11FB_DATATYPE INT63LITERALDTYPE;
	$11FB_DATATYPE INT64LITERALDTYPE;
	$11FB_DATATYPE FLOATLITERALDTYPE;
};
__FB_STATIC_ASSERT( sizeof( struct $11FB_LANG_CTX ) == 72 );
struct $8FBOPTION {
	int64 BASE;
	int64 PARAMMODE;
	int64 EXPLICIT;
	int64 PROCPUBLIC;
	int64 PROCPROFILE;
	int64 ESCAPESTR;
	int64 DYNAMIC;
	int64 GOSUB;
};
__FB_STATIC_ASSERT( sizeof( struct $8FBOPTION ) == 64 );
typedef int64 $16FB_RESTART_FLAGS;
struct $7TSTRSET {
	struct $5TLIST LIST;
	struct $5THASH HASH;
};
__FB_STATIC_ASSERT( sizeof( struct $7TSTRSET ) == 88 );
struct $5FBENV {
	struct $5TLIST PREDEFINES;
	struct $5TLIST PREINCLUDES;
	struct $5TLIST INCLUDEPATHS;
	struct $12FBCMMLINEOPT CLOPT;
	struct $8FBTARGET TARGET;
	$12FB_WCHARCONV WCHARCONV;
	int64 UNDERSCOREPREFIX;
	int64 POINTERSIZE;
	struct $6FBFILE INF;
	struct $6FBFILE OUTF;
	int64 PPFILE_NUM;
	struct $5THASH FILENAMEHASH;
	struct $5THASH INCFILEHASH;
	struct $5THASH INCONCEHASH;
	int64 INCLUDEREC;
	char ENTRY[128];
	struct $6FBMAIN MAIN;
	struct $11FB_LANG_CTX LANG;
	struct $8FBOPTION OPT;
	int64 INITED;
	int64 MODULE_COUNT;
	$16FB_RESTART_FLAGS RESTART_REQUEST;
	$16FB_RESTART_FLAGS RESTART_ACTION;
	$16FB_RESTART_FLAGS RESTART_STATUS;
	int64 RESTART_COUNT;
	$7FB_LANG RESTART_LANG;
	struct $7TSTRSET LIBS;
	struct $7TSTRSET LIBPATHS;
	int64 FBCTINF_STARTED;
};
__FB_STATIC_ASSERT( sizeof( struct $5FBENV ) == 1832 );
extern struct $5FBENV ENV$;
static struct $14FB_RTL_PROCDEF FUNCDATA$[72] = { { (char*)"fb_GfxPset", (char*)0ull, 0ll, -1ll, (tmp$34)&HGFXLIB_CB, 0ll, 6ll, { { 32ll, 1ll, -1ll, 0ll }, { 527ll, 1ll, 0ll }, { 527ll, 1ll, 0ll }, { 524ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll } } }, { (char*)"fb_GfxPoint", (char*)0ull, 12ll, -1ll, (tmp$34)&HGFXLIB_CB, 0ll, 3ll, { { 32ll, 1ll, -1ll, 0ll }, { 527ll, 1ll, 0ll }, { 527ll, 1ll, 0ll } } }, { (char*)"fb_GfxLine", (char*)0ull, 0ll, -1ll, (tmp$34)&HGFXLIB_CB, 0ll, 9ll, { { 32ll, 1ll, -1ll, 0ll }, { 527ll, 1ll, 0ll }, { 527ll, 1ll, 0ll }, { 527ll, 1ll, 0ll }, { 527ll, 1ll, 0ll }, { 524ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 524ll, 1ll, -1ll, 65535ll }, { 523ll, 1ll, 0ll } } }, { (char*)"fb_GfxEllipse", (char*)0ull, 0ll, -1ll, (tmp$34)&HGFXLIB_CB, 0ll, 10ll, { { 32ll, 1ll, -1ll, 0ll }, { 527ll, 1ll, 0ll }, { 527ll, 1ll, 0ll }, { 527ll, 1ll, 0ll }, { 524ll, 1ll, 0ll }, { 527ll, 1ll, 0ll }, { 527ll, 1ll, 0ll }, { 527ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll } } }, { (char*)"fb_GfxPaint", (char*)0ull, 0ll, -1ll, (tmp$34)&HGFXLIB_CB, 0ll, 8ll, { { 32ll, 1ll, -1ll, 0ll }, { 527ll, 1ll, 0ll }, { 527ll, 1ll, 0ll }, { 524ll, 1ll, 0ll }, { 524ll, 1ll, 0ll }, { 529ll, 2ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll } } }, { (char*)"fb_GfxDraw", (char*)0ull, 0ll, -1ll, (tmp$34)&HGFXLIB_CB, 0ll, 2ll, { { 32ll, 1ll, -1ll, 0ll }, { 529ll, 2ll, 0ll } } }, { (char*)"fb_GfxDrawString", (char*)0ull, 8ll, -1ll, (tmp$34)&HGFXLIB_CB, 2ll, 11ll, { { 32ll, 1ll, -1ll, 0ll }, { 527ll, 1ll, 0ll }, { 527ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 529ll, 2ll, 0ll }, { 524ll, 1ll, 0ll }, { 1056ll, 1ll, -1ll, 0ll }, { 523ll, 1ll, 0ll }, { 32ll, 1ll, 0ll }, { 32ll, 1ll, -1ll, 0ll }, { 32ll, 1ll, 0ll } } }, { (char*)"fb_GfxView", (char*)0ull, 0ll, -1ll, (tmp$34)&HGFXLIB_CB, 0ll, 7ll, { { 523ll, 1ll, -1ll, -32768ll }, { 523ll, 1ll, -1ll, -32768ll }, { 523ll, 1ll, -1ll, -32768ll }, { 523ll, 1ll, -1ll, -32768ll }, { 524ll, 1ll, -1ll, 0ll }, { 524ll, 1ll, -1ll, 0ll }, { 523ll, 1ll, 0ll } } }, { (char*)"fb_GfxWindow", (char*)0ull, 0ll, -1ll, (tmp$34)&HGFXLIB_CB, 0ll, 5ll, { { 527ll, 1ll, -1ll, 0ll }, { 527ll, 1ll, -1ll, 0ll }, { 527ll, 1ll, -1ll, 0ll }, { 527ll, 1ll, -1ll, 0ll }, { 523ll, 1ll, -1ll, 0ll } } }, { (char*)"fb_GfxPalette", (char*)0ull, 0ll, -1ll, (tmp$34)&HGFXLIB_CB, 0ll, 4ll, { { 523ll, 1ll, -1ll, -1ll }, { 523ll, 1ll, -1ll, -1ll }, { 523ll, 1ll, -1ll, -1ll }, { 523ll, 1ll, -1ll, -1ll } } }, { (char*)"fb_GfxPaletteUsing", (char*)0ull, 0ll, -1ll, (tmp$34)&HGFXLIB_CB, 0ll, 1ll, { { 1067ll, 1ll, 0ll } } }, { (char*)"fb_GfxPaletteUsing64", (char*)0ull, 0ll, -1ll, (tmp$34)&HGFXLIB_CB, 0ll, 1ll, { { 1069ll, 1ll, 0ll } } }, { (char*)"fb_GfxPaletteGet", (char*)0ull, 0ll, -1ll, (tmp$34)&HGFXLIB_CB, 0ll, 4ll, { { 523ll, 1ll, -1ll, -1ll }, { 11ll, 2ll, 0ll }, { 11ll, 2ll, 0ll }, { 11ll, 2ll, 0ll } } }, { (char*)"fb_GfxPaletteGet64", (char*)0ull, 0ll, -1ll, (tmp$34)&HGFXLIB_CB, 0ll, 4ll, { { 523ll, 1ll, -1ll, -1ll }, { 13ll, 2ll, 0ll }, { 13ll, 2ll, 0ll }, { 13ll, 2ll, 0ll } } }, { (char*)"fb_GfxPaletteGetUsing", (char*)0ull, 0ll, -1ll, (tmp$34)&HGFXLIB_CB, 0ll, 1ll, { { 43ll, 1ll, 0ll } } }, { (char*)"fb_GfxPaletteGetUsing64", (char*)0ull, 0ll, -1ll, (tmp$34)&HGFXLIB_CB, 0ll, 1ll, { { 45ll, 1ll, 0ll } } }, { (char*)"fb_GfxPut", (char*)0ull, 11ll, -1ll, (tmp$34)&HGFXLIB_CB, 2ll, 14ll, { { 32ll, 1ll, -1ll, 0ll }, { 527ll, 1ll, 0ll }, { 527ll, 1ll, 0ll }, { 1056ll, 1ll, 0ll }, { 523ll, 1ll, -1ll, 4294901760ll }, { 523ll, 1ll, -1ll, 4294901760ll }, { 523ll, 1ll, -1ll, 4294901760ll }, { 523ll, 1ll, -1ll, 4294901760ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 32ll, 1ll, 0ll }, { 523ll, 1ll, -1ll, -1ll }, { 32ll, 1ll, -1ll, 0ll }, { 32ll, 1ll, -1ll, 0ll } } }, { (char*)"fb_GfxGet", (char*)0ull, 11ll, -1ll, (tmp$34)&HGFXLIB_CB, 1026ll, 8ll, { { 1056ll, 1ll, -1ll, 0ll }, { 527ll, 1ll, 0ll }, { 527ll, 1ll, 0ll }, { 527ll, 1ll, 0ll }, { 527ll, 1ll, 0ll }, { 32ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 512ll, 3ll, 0ll } } }, { (char*)"fb_GfxGetQB", (char*)0ull, 11ll, -1ll, (tmp$34)&HGFXLIB_CB, 514ll, 8ll, { { 1056ll, 1ll, -1ll, 0ll }, { 527ll, 1ll, 0ll }, { 527ll, 1ll, 0ll }, { 527ll, 1ll, 0ll }, { 527ll, 1ll, 0ll }, { 32ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 0ll, 3ll, 0ll } } }, { (char*)"fb_GfxScreen", (char*)0ull, 11ll, -1ll, (tmp$34)&HGFXLIB_CB, 0ll, 5ll, { { 523ll, 1ll, 0ll }, { 523ll, 1ll, -1ll, 8ll }, { 523ll, 1ll, -1ll, 0ll }, { 523ll, 1ll, -1ll, 0ll }, { 523ll, 1ll, -1ll, 0ll } } }, { (char*)"fb_GfxScreenQB", (char*)0ull, 11ll, -1ll, (tmp$34)&HGFXLIB_CB, 0ll, 3ll, { { 523ll, 1ll, 0ll }, { 523ll, 1ll, -1ll, -1ll }, { 523ll, 1ll, -1ll, -1ll } } }, { (char*)"screenres", (char*)"fb_GfxScreenRes", 11ll, -1ll, (tmp$34)&HGFXLIB_CB, 130ll, 6ll, { { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, -1ll, 8ll }, { 523ll, 1ll, -1ll, 1ll }, { 523ll, 1ll, -1ll, 0ll }, { 523ll, 1ll, -1ll, 0ll } } }, { (char*)"bload", (char*)"fb_GfxBload", 11ll, -1ll, (tmp$34)&HGFXLIB_CB, 1026ll, 3ll, { { 529ll, 2ll, 0ll }, { 32ll, 1ll, -1ll, 0ll }, { 32ll, 1ll, -1ll, 0ll } } }, { (char*)"bload", (char*)"fb_GfxBloadQB", 11ll, -1ll, (tmp$34)&HGFXLIB_CB, 514ll, 3ll, { { 529ll, 2ll, 0ll }, { 32ll, 1ll, -1ll, 0ll }, { 32ll, 1ll, -1ll, 0ll } } }, { (char*)"bsave", (char*)"fb_GfxBsave", 11ll, -1ll, (tmp$34)&HGFXLIB_CB, 3ll, 4ll, { { 529ll, 2ll, 0ll }, { 1056ll, 1ll, 0ll }, { 524ll, 1ll, -1ll, 0ll }, { 1056ll, 1ll, -1ll, 0ll } } }, { (char*)"bsave", (char*)"fb_GfxBsaveEx", 11ll, -1ll, (tmp$34)&HGFXLIB_CB, 3ll, 5ll, { { 529ll, 2ll, 0ll }, { 1056ll, 1ll, 0ll }, { 524ll, 1ll, -1ll, 0ll }, { 1056ll, 1ll, 0ll }, { 523ll, 1ll, 0ll } } }, { (char*)"flip", (char*)"fb_GfxFlip", 11ll, -1ll, (tmp$34)&HGFXLIB_CB, 128ll, 2ll, { { 523ll, 1ll, -1ll, -1ll }, { 523ll, 1ll, -1ll, -1ll } } }, { (char*)"screencopy", (char*)"fb_GfxFlip", 11ll, -1ll, (tmp$34)&HGFXLIB_CB, 128ll, 2ll, { { 523ll, 1ll, -1ll, -1ll }, { 523ll, 1ll, -1ll, -1ll } } }, { (char*)"pointcoord", (char*)"fb_GfxCursor", 15ll, -1ll, (tmp$34)&HGFXLIB_CB, 128ll, 1ll, { { 523ll, 1ll, 0ll } } }, { (char*)"pmap", (char*)"fb_GfxPMap", 15ll, -1ll, (tmp$34)&HGFXLIB_CB, 0ll, 2ll, { { 527ll, 1ll, 0ll }, { 523ll, 1ll, 0ll } } }, { (char*)"out", (char*)"fb_Out", 11ll, -1ll, (tmp$34)&HPORTS_CB, 2ll, 2ll, { { 518ll, 1ll, 0ll }, { 515ll, 1ll, 0ll } } }, { (char*)"inp", (char*)"fb_In", 11ll, -1ll, (tmp$34)&HPORTS_CB, 0ll, 1ll, { { 518ll, 1ll, 0ll } } }, { (char*)"wait", (char*)"fb_Wait", 11ll, -1ll, (tmp$34)&HPORTS_CB, 2ll, 3ll, { { 518ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, -1ll, 0ll } } }, { (char*)"screensync", (char*)"fb_GfxWaitVSync", 11ll, -1ll, (tmp$34)&HGFXLIB_CB, 128ll, 0ll }, { (char*)"screenset", (char*)"fb_GfxPageSet", 11ll, 3ll, (tmp$34)&HGFXLIB_CB, 128ll, 2ll, { { 523ll, 1ll, -1ll, -1ll }, { 523ll, 1ll, -1ll, -1ll } } }, { (char*)"screenlock", (char*)"fb_GfxLock", 0ll, -1ll, (tmp$34)&HGFXLIB_CB, 128ll, 0ll }, { (char*)"screenunlock", (char*)"fb_GfxUnlock", 0ll, -1ll, (tmp$34)&HGFXLIB_CB, 128ll, 2ll, { { 523ll, 1ll, -1ll, -1ll }, { 523ll, 1ll, -1ll, -1ll } } }, { (char*)"screenptr", (char*)"fb_GfxScreenPtr", 32ll, -1ll, (tmp$34)&HGFXLIB_CB, 128ll, 0ll }, { (char*)"windowtitle", (char*)"fb_GfxSetWindowTitle", 0ll, -1ll, (tmp$34)&HGFXLIB_CB, 128ll, 1ll, { { 529ll, 2ll, 0ll } } }, { (char*)"multikey", (char*)"fb_Multikey", 11ll, -1ll, (tmp$34)0ull, 128ll, 1ll, { { 523ll, 1ll, 0ll } } }, { (char*)"getmouse", (char*)"fb_GetMouse", 11ll, -1ll, (tmp$34)0ull, 129ll, 5ll, { { 11ll, 2ll, 0ll, 0ll }, { 11ll, 2ll, 0ll, 0ll }, { 11ll, 2ll, -1ll, 0ll }, { 11ll, 2ll, -1ll, 0ll }, { 11ll, 2ll, -1ll, 0ll } } }, { (char*)"getmouse", (char*)"fb_GetMouse64", 11ll, -1ll, (tmp$34)0ull, 129ll, 5ll, { { 13ll, 2ll, 0ll, 0ll }, { 13ll, 2ll, 0ll, 0ll }, { 13ll, 2ll, -1ll, 0ll }, { 13ll, 2ll, -1ll, 0ll }, { 13ll, 2ll, -1ll, 0ll } } }, { (char*)"setmouse", (char*)"fb_SetMouse", 11ll, -1ll, (tmp$34)0ull, 128ll, 4ll, { { 523ll, 1ll, -1ll, 2147483648ll }, { 523ll, 1ll, -1ll, 2147483648ll }, { 523ll, 1ll, -1ll, -1ll }, { 523ll, 1ll, -1ll, -1ll } } }, { (char*)"getjoystick", (char*)"fb_GfxGetJoystick", 11ll, -1ll, (tmp$34)&HGFXLIB_CB, 128ll, 10ll, { { 523ll, 1ll, 0ll, 0ll }, { 8ll, 2ll, -1ll, 0ll }, { 15ll, 2ll, -1ll, 0ll }, { 15ll, 2ll, -1ll, 0ll }, { 15ll, 2ll, -1ll, 0ll }, { 15ll, 2ll, -1ll, 0ll }, { 15ll, 2ll, -1ll, 0ll }, { 15ll, 2ll, -1ll, 0ll }, { 15ll, 2ll, -1ll, 0ll }, { 15ll, 2ll, -1ll, 0ll } } }, { (char*)"stick", (char*)"fb_GfxStickQB", 11ll, -1ll, (tmp$34)&HGFXLIB_CB, 256ll, 1ll, { { 523ll, 1ll, 0ll } } }, { (char*)"strig", (char*)"fb_GfxStrigQB", 11ll, -1ll, (tmp$34)&HGFXLIB_CB, 256ll, 1ll, { { 523ll, 1ll, 0ll } } }, { (char*)"screeninfo", (char*)"fb_GfxScreenInfo32", 0ll, -1ll, (tmp$34)&HGFXLIB_CB, 129ll, 7ll, { { 11ll, 2ll, -1ll, 0ll }, { 11ll, 2ll, -1ll, 0ll }, { 11ll, 2ll, -1ll, 0ll }, { 11ll, 2ll, -1ll, 0ll }, { 11ll, 2ll, -1ll, 0ll }, { 11ll, 2ll, -1ll, 0ll }, { 17ll, 2ll, -1ll, 0ll } } }, { (char*)"screeninfo", (char*)"fb_GfxScreenInfo64", 0ll, -1ll, (tmp$34)&HGFXLIB_CB, 129ll, 7ll, { { 13ll, 2ll, 0ll }, { 13ll, 2ll, 0ll }, { 13ll, 2ll, -1ll, 0ll }, { 13ll, 2ll, -1ll, 0ll }, { 13ll, 2ll, -1ll, 0ll }, { 13ll, 2ll, -1ll, 0ll }, { 17ll, 2ll, -1ll, 0ll } } }, { (char*)"screenlist", (char*)"fb_GfxScreenList", 11ll, -1ll, (tmp$34)&HGFXLIB_CB, 128ll, 1ll, { { 523ll, 1ll, -1ll, 0ll } } }, { (char*)"fb_GfxImageCreate", (char*)0ull, 32ll, -1ll, (tmp$34)&HGFXLIB_CB, 1024ll, 5ll, { { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 524ll, 1ll, -1ll, 0ll }, { 523ll, 1ll, -1ll, 0ll }, { 523ll, 1ll, -1ll, 0ll } } }, { (char*)"fb_GfxImageCreateQB", (char*)0ull, 32ll, -1ll, (tmp$34)&HGFXLIB_CB, 128ll, 5ll, { { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 524ll, 1ll, -1ll, 0ll }, { 523ll, 1ll, -1ll, 0ll }, { 523ll, 1ll, -1ll, 0ll } } }, { (char*)"imagedestroy", (char*)"fb_GfxImageDestroy", 0ll, -1ll, (tmp$34)&HGFXLIB_CB, 128ll, 1ll, { { 1056ll, 1ll, 0ll } } }, { (char*)"imageinfo", (char*)"fb_GfxImageInfo32", 11ll, -1ll, (tmp$34)&HGFXLIB_CB, 129ll, 7ll, { { 1056ll, 1ll, 0ll }, { 11ll, 2ll, -1ll, 0ll }, { 11ll, 2ll, -1ll, 0ll }, { 11ll, 2ll, -1ll, 0ll }, { 11ll, 2ll, -1ll, 0ll }, { 32ll, 2ll, -1ll, 0ll }, { 11ll, 2ll, -1ll, 0ll } } }, { (char*)"imageinfo", (char*)"fb_GfxImageInfo64", 11ll, -1ll, (tmp$34)&HGFXLIB_CB, 129ll, 7ll, { { 1056ll, 1ll, 0ll }, { 13ll, 2ll, 0ll }, { 13ll, 2ll, 0ll }, { 13ll, 2ll, -1ll, 0ll }, { 13ll, 2ll, -1ll, 0ll }, { 32ll, 2ll, -1ll, 0ll }, { 13ll, 2ll, -1ll, 0ll } } }, { (char*)"imageconvertrow", (char*)"fb_GfxImageConvertRow", 0ll, -1ll, (tmp$34)&HGFXLIB_CB, 128ll, 6ll, { { 1056ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 32ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, -1ll, 1ll } } }, { (char*)"screenevent", (char*)"fb_GfxEvent", 11ll, -1ll, (tmp$34)&HGFXLIB_CB, 128ll, 1ll, { { 32ll, 1ll, -1ll, 0ll } } }, { (char*)"screencontrol", (char*)"fb_GfxControl_s", 0ll, -1ll, (tmp$34)&HGFXLIB_CB, 129ll, 2ll, { { 523ll, 1ll, 0ll }, { 17ll, 2ll } } }, { (char*)"screencontrol", (char*)"fb_GfxControl_i32", 0ll, -1ll, (tmp$34)&HGFXLIB_CB, 129ll, 5ll, { { 523ll, 1ll, 0ll }, { 11ll, 2ll, -1ll, 2147483648ll }, { 11ll, 2ll, -1ll, 2147483648ll }, { 11ll, 2ll, -1ll, 2147483648ll }, { 11ll, 2ll, -1ll, 2147483648ll } } }, { (char*)"screencontrol", (char*)"fb_GfxControl_i64", 0ll, -1ll, (tmp$34)&HGFXLIB_CB, 129ll, 5ll, { { 523ll, 1ll, 0ll }, { 13ll, 2ll, 0ll }, { 13ll, 2ll, -1ll, 2147483648ll }, { 13ll, 2ll, -1ll, 2147483648ll }, { 13ll, 2ll, -1ll, 2147483648ll } } }, { (char*)"screenglproc", (char*)"fb_GfxGetGLProcAddress", 32ll, -1ll, (tmp$34)&HGFXLIB_CB, 129ll, 1ll, { { 1060ll, 1ll, 0ll } } }, { (char*)"fb_hPutTrans", (char*)0ull, 0ll, 3ll, (tmp$34)&HGFXLIB_CB, 0ll, 9ll, { { 1059ll, 1ll, 0ll }, { 35ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 32ll, 1ll, 0ll }, { 32ll, 1ll, 0ll } } }, { (char*)"fb_hPutMask", (char*)0ull, 0ll, 3ll, (tmp$34)&HGFXLIB_CB, 0ll, 9ll, { { 1059ll, 1ll, 0ll }, { 35ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 32ll, 1ll, 0ll }, { 32ll, 1ll, 0ll } } }, { (char*)"fb_hPutPSet", (char*)0ull, 0ll, 3ll, (tmp$34)&HGFXLIB_CB, 0ll, 9ll, { { 1059ll, 1ll, 0ll }, { 35ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 32ll, 1ll, 0ll }, { 32ll, 1ll, 0ll } } }, { (char*)"fb_hPutPReset", (char*)0ull, 0ll, 3ll, (tmp$34)&HGFXLIB_CB, 0ll, 9ll, { { 1059ll, 1ll, 0ll }, { 35ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 32ll, 1ll, 0ll }, { 32ll, 1ll, 0ll } } }, { (char*)"fb_hPutAnd", (char*)0ull, 0ll, 3ll, (tmp$34)&HGFXLIB_CB, 0ll, 9ll, { { 1059ll, 1ll, 0ll }, { 35ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 32ll, 1ll, 0ll }, { 32ll, 1ll, 0ll } } }, { (char*)"fb_hPutOr", (char*)0ull, 0ll, 3ll, (tmp$34)&HGFXLIB_CB, 0ll, 9ll, { { 1059ll, 1ll, 0ll }, { 35ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 32ll, 1ll, 0ll }, { 32ll, 1ll, 0ll } } }, { (char*)"fb_hPutXor", (char*)0ull, 0ll, 3ll, (tmp$34)&HGFXLIB_CB, 0ll, 9ll, { { 1059ll, 1ll, 0ll }, { 35ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 32ll, 1ll, 0ll }, { 32ll, 1ll, 0ll } } }, { (char*)"fb_hPutAlpha", (char*)0ull, 0ll, 3ll, (tmp$34)&HGFXLIB_CB, 0ll, 9ll, { { 1059ll, 1ll, 0ll }, { 35ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 32ll, 1ll, 0ll }, { 32ll, 1ll, 0ll } } }, { (char*)"fb_hPutBlend", (char*)0ull, 0ll, 3ll, (tmp$34)&HGFXLIB_CB, 0ll, 9ll, { { 1059ll, 1ll, 0ll }, { 35ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 32ll, 1ll, 0ll }, { 32ll, 1ll, 0ll } } }, { (char*)"fb_hPutAdd", (char*)0ull, 0ll, 3ll, (tmp$34)&HGFXLIB_CB, 0ll, 9ll, { { 1059ll, 1ll, 0ll }, { 35ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 32ll, 1ll, 0ll }, { 32ll, 1ll, 0ll } } }, { (char*)"fb_hPutCustom", (char*)0ull, 0ll, 3ll, (tmp$34)&HGFXLIB_CB, 0ll, 9ll, { { 1059ll, 1ll, 0ll }, { 35ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 523ll, 1ll, 0ll }, { 32ll, 1ll, 0ll }, { 32ll, 1ll, 0ll } } }, { (char*)0ull } };

void RTLGFXMODINIT( void )
{
	label$10:;
	RTLADDINTRINSICPROCS( (struct $14FB_RTL_PROCDEF*)FUNCDATA$ );
	label$11:;
}

void RTLGFXMODEND( void )
{
	label$12:;
	label$13:;
}

int64 RTLGFXPSET( struct $7ASTNODE* TARGET$1, struct $7ASTNODE* XEXPR$1, struct $7ASTNODE* YEXPR$1, struct $7ASTNODE* CEXPR$1, int64 COORDTYPE$1, int64 ISPRESET$1 )
{
	int64 fb$result$1;
	__builtin_memset( &fb$result$1, 0, 8ll );
	label$41:;
	struct $7ASTNODE* PROC$1;
	fb$result$1 = 0ll;
	struct $8FBSYMBOL* vr$1 = RTLPROCLOOKUP( (char*)"fb_GfxPset", 308ll );
	struct $7ASTNODE* vr$2 = ASTNEWCALL( vr$1, (struct $7ASTNODE*)0ull, -1ll );
	PROC$1 = vr$2;
	struct $7ASTNODE* vr$3 = ASTNEWARG( PROC$1, TARGET$1, 2147483648ll, -1ll );
	if( vr$3 != (struct $7ASTNODE*)0ull) goto label$44;
	{
		goto label$42;
	}
	label$44:;
	label$43:;
	struct $7ASTNODE* vr$4 = ASTNEWARG( PROC$1, XEXPR$1, 2147483648ll, -1ll );
	if( vr$4 != (struct $7ASTNODE*)0ull) goto label$46;
	{
		goto label$42;
	}
	label$46:;
	label$45:;
	struct $7ASTNODE* vr$5 = ASTNEWARG( PROC$1, YEXPR$1, 2147483648ll, -1ll );
	if( vr$5 != (struct $7ASTNODE*)0ull) goto label$48;
	{
		goto label$42;
	}
	label$48:;
	label$47:;
	struct $7ASTNODE* vr$6 = ASTNEWARG( PROC$1, CEXPR$1, 2147483648ll, -1ll );
	if( vr$6 != (struct $7ASTNODE*)0ull) goto label$50;
	{
		goto label$42;
	}
	label$50:;
	label$49:;
	struct $7ASTNODE* vr$7 = ASTNEWCONSTI( COORDTYPE$1, 8ll, (struct $8FBSYMBOL*)0ull );
	struct $7ASTNODE* vr$8 = ASTNEWARG( PROC$1, vr$7, 2147483648ll, -1ll );
	if( vr$8 != (struct $7ASTNODE*)0ull) goto label$52;
	{
		goto label$42;
	}
	label$52:;
	label$51:;
	struct $7ASTNODE* vr$9 = ASTNEWCONSTI( ISPRESET$1, 8ll, (struct $8FBSYMBOL*)0ull );
	struct $7ASTNODE* vr$10 = ASTNEWARG( PROC$1, vr$9, 2147483648ll, -1ll );
	if( vr$10 != (struct $7ASTNODE*)0ull) goto label$54;
	{
		goto label$42;
	}
	label$54:;
	label$53:;
	ASTADD( PROC$1 );
	fb$result$1 = -1ll;
	label$42:;
	return fb$result$1;
}

struct $7ASTNODE* RTLGFXPOINT( struct $7ASTNODE* TARGET$1, struct $7ASTNODE* XEXPR$1, struct $7ASTNODE* YEXPR$1 )
{
	struct $7ASTNODE* fb$result$1;
	__builtin_memset( &fb$result$1, 0, 8ll );
	label$55:;
	struct $7ASTNODE* PROC$1;
	fb$result$1 = (struct $7ASTNODE*)0ull;
	struct $8FBSYMBOL* vr$1 = RTLPROCLOOKUP( (char*)"fb_GfxPoint", 309ll );
	struct $7ASTNODE* vr$2 = ASTNEWCALL( vr$1, (struct $7ASTNODE*)0ull, -1ll );
	PROC$1 = vr$2;
	struct $7ASTNODE* vr$3 = ASTNEWARG( PROC$1, TARGET$1, 2147483648ll, -1ll );
	if( vr$3 != (struct $7ASTNODE*)0ull) goto label$58;
	{
		goto label$56;
	}
	label$58:;
	label$57:;
	struct $7ASTNODE* vr$4 = ASTNEWARG( PROC$1, XEXPR$1, 2147483648ll, -1ll );
	if( vr$4 != (struct $7ASTNODE*)0ull) goto label$60;
	{
		goto label$56;
	}
	label$60:;
	label$59:;
	if( YEXPR$1 != (struct $7ASTNODE*)0ull) goto label$62;
	{
		struct $7ASTNODE* vr$5 = ASTNEWCONSTF( -0x1.FFFFFCp+22, 15ll );
		YEXPR$1 = vr$5;
	}
	label$62:;
	label$61:;
	struct $7ASTNODE* vr$6 = ASTNEWARG( PROC$1, YEXPR$1, 2147483648ll, -1ll );
	if( vr$6 != (struct $7ASTNODE*)0ull) goto label$64;
	{
		goto label$56;
	}
	label$64:;
	label$63:;
	fb$result$1 = PROC$1;
	label$56:;
	return fb$result$1;
}

int64 RTLGFXLINE( struct $7ASTNODE* TARGET$1, struct $7ASTNODE* X1EXPR$1, struct $7ASTNODE* Y1EXPR$1, struct $7ASTNODE* X2EXPR$1, struct $7ASTNODE* Y2EXPR$1, struct $7ASTNODE* CEXPR$1, int64 LINETYPE$1, struct $7ASTNODE* STYLEEXPR$1, int64 COORDTYPE$1 )
{
	int64 fb$result$1;
	__builtin_memset( &fb$result$1, 0, 8ll );
	label$65:;
	struct $7ASTNODE* PROC$1;
	fb$result$1 = 0ll;
	struct $8FBSYMBOL* vr$1 = RTLPROCLOOKUP( (char*)"fb_GfxLine", 310ll );
	struct $7ASTNODE* vr$2 = ASTNEWCALL( vr$1, (struct $7ASTNODE*)0ull, -1ll );
	PROC$1 = vr$2;
	struct $7ASTNODE* vr$3 = ASTNEWARG( PROC$1, TARGET$1, 2147483648ll, -1ll );
	if( vr$3 != (struct $7ASTNODE*)0ull) goto label$68;
	{
		goto label$66;
	}
	label$68:;
	label$67:;
	struct $7ASTNODE* vr$4 = ASTNEWARG( PROC$1, X1EXPR$1, 2147483648ll, -1ll );
	if( vr$4 != (struct $7ASTNODE*)0ull) goto label$70;
	{
		goto label$66;
	}
	label$70:;
	label$69:;
	struct $7ASTNODE* vr$5 = ASTNEWARG( PROC$1, Y1EXPR$1, 2147483648ll, -1ll );
	if( vr$5 != (struct $7ASTNODE*)0ull) goto label$72;
	{
		goto label$66;
	}
	label$72:;
	label$71:;
	struct $7ASTNODE* vr$6 = ASTNEWARG( PROC$1, X2EXPR$1, 2147483648ll, -1ll );
	if( vr$6 != (struct $7ASTNODE*)0ull) goto label$74;
	{
		goto label$66;
	}
	label$74:;
	label$73:;
	struct $7ASTNODE* vr$7 = ASTNEWARG( PROC$1, Y2EXPR$1, 2147483648ll, -1ll );
	if( vr$7 != (struct $7ASTNODE*)0ull) goto label$76;
	{
		goto label$66;
	}
	label$76:;
	label$75:;
	struct $7ASTNODE* vr$8 = ASTNEWARG( PROC$1, CEXPR$1, 2147483648ll, -1ll );
	if( vr$8 != (struct $7ASTNODE*)0ull) goto label$78;
	{
		goto label$66;
	}
	label$78:;
	label$77:;
	struct $7ASTNODE* vr$9 = ASTNEWCONSTI( LINETYPE$1, 8ll, (struct $8FBSYMBOL*)0ull );
	struct $7ASTNODE* vr$10 = ASTNEWARG( PROC$1, vr$9, 2147483648ll, -1ll );
	if( vr$10 != (struct $7ASTNODE*)0ull) goto label$80;
	{
		goto label$66;
	}
	label$80:;
	label$79:;
	struct $7ASTNODE* vr$11 = ASTNEWARG( PROC$1, STYLEEXPR$1, 2147483648ll, -1ll );
	if( vr$11 != (struct $7ASTNODE*)0ull) goto label$82;
	{
		goto label$66;
	}
	label$82:;
	label$81:;
	struct $7ASTNODE* vr$12 = ASTNEWCONSTI( COORDTYPE$1, 8ll, (struct $8FBSYMBOL*)0ull );
	struct $7ASTNODE* vr$13 = ASTNEWARG( PROC$1, vr$12, 2147483648ll, -1ll );
	if( vr$13 != (struct $7ASTNODE*)0ull) goto label$84;
	{
		goto label$66;
	}
	label$84:;
	label$83:;
	ASTADD( PROC$1 );
	fb$result$1 = -1ll;
	label$66:;
	return fb$result$1;
}

int64 RTLGFXCIRCLE( struct $7ASTNODE* TARGET$1, struct $7ASTNODE* XEXPR$1, struct $7ASTNODE* YEXPR$1, struct $7ASTNODE* RADEXPR$1, struct $7ASTNODE* CEXPR$1, struct $7ASTNODE* ASPEXPR$1, struct $7ASTNODE* INIEXPR$1, struct $7ASTNODE* ENDEXPR$1, int64 FILLFLAG$1, int64 COORDTYPE$1 )
{
	int64 fb$result$1;
	__builtin_memset( &fb$result$1, 0, 8ll );
	label$85:;
	struct $7ASTNODE* PROC$1;
	fb$result$1 = 0ll;
	struct $8FBSYMBOL* vr$1 = RTLPROCLOOKUP( (char*)"fb_GfxEllipse", 311ll );
	struct $7ASTNODE* vr$2 = ASTNEWCALL( vr$1, (struct $7ASTNODE*)0ull, -1ll );
	PROC$1 = vr$2;
	struct $7ASTNODE* vr$3 = ASTNEWARG( PROC$1, TARGET$1, 2147483648ll, -1ll );
	if( vr$3 != (struct $7ASTNODE*)0ull) goto label$88;
	{
		goto label$86;
	}
	label$88:;
	label$87:;
	struct $7ASTNODE* vr$4 = ASTNEWARG( PROC$1, XEXPR$1, 2147483648ll, -1ll );
	if( vr$4 != (struct $7ASTNODE*)0ull) goto label$90;
	{
		goto label$86;
	}
	label$90:;
	label$89:;
	struct $7ASTNODE* vr$5 = ASTNEWARG( PROC$1, YEXPR$1, 2147483648ll, -1ll );
	if( vr$5 != (struct $7ASTNODE*)0ull) goto label$92;
	{
		goto label$86;
	}
	label$92:;
	label$91:;
	struct $7ASTNODE* vr$6 = ASTNEWARG( PROC$1, RADEXPR$1, 2147483648ll, -1ll );
	if( vr$6 != (struct $7ASTNODE*)0ull) goto label$94;
	{
		goto label$86;
	}
	label$94:;
	label$93:;
	struct $7ASTNODE* vr$7 = ASTNEWARG( PROC$1, CEXPR$1, 2147483648ll, -1ll );
	if( vr$7 != (struct $7ASTNODE*)0ull) goto label$96;
	{
		goto label$86;
	}
	label$96:;
	label$95:;
	if( ASPEXPR$1 != (struct $7ASTNODE*)0ull) goto label$98;
	{
		struct $7ASTNODE* vr$8 = ASTNEWCONSTF( 0x0p+0, 15ll );
		ASPEXPR$1 = vr$8;
	}
	label$98:;
	label$97:;
	struct $7ASTNODE* vr$9 = ASTNEWARG( PROC$1, ASPEXPR$1, 2147483648ll, -1ll );
	if( vr$9 != (struct $7ASTNODE*)0ull) goto label$100;
	{
		goto label$86;
	}
	label$100:;
	label$99:;
	if( INIEXPR$1 != (struct $7ASTNODE*)0ull) goto label$102;
	{
		struct $7ASTNODE* vr$10 = ASTNEWCONSTF( 0x0p+0, 15ll );
		INIEXPR$1 = vr$10;
	}
	label$102:;
	label$101:;
	struct $7ASTNODE* vr$11 = ASTNEWARG( PROC$1, INIEXPR$1, 2147483648ll, -1ll );
	if( vr$11 != (struct $7ASTNODE*)0ull) goto label$104;
	{
		goto label$86;
	}
	label$104:;
	label$103:;
	if( ENDEXPR$1 != (struct $7ASTNODE*)0ull) goto label$106;
	{
		struct $7ASTNODE* vr$12 = ASTNEWCONSTF( 0x1.921FB82C2BD7Fp+2, 15ll );
		ENDEXPR$1 = vr$12;
	}
	label$106:;
	label$105:;
	struct $7ASTNODE* vr$13 = ASTNEWARG( PROC$1, ENDEXPR$1, 2147483648ll, -1ll );
	if( vr$13 != (struct $7ASTNODE*)0ull) goto label$108;
	{
		goto label$86;
	}
	label$108:;
	label$107:;
	struct $7ASTNODE* vr$14 = ASTNEWCONSTI( FILLFLAG$1, 8ll, (struct $8FBSYMBOL*)0ull );
	struct $7ASTNODE* vr$15 = ASTNEWARG( PROC$1, vr$14, 2147483648ll, -1ll );
	if( vr$15 != (struct $7ASTNODE*)0ull) goto label$110;
	{
		goto label$86;
	}
	label$110:;
	label$109:;
	struct $7ASTNODE* vr$16 = ASTNEWCONSTI( COORDTYPE$1, 8ll, (struct $8FBSYMBOL*)0ull );
	struct $7ASTNODE* vr$17 = ASTNEWARG( PROC$1, vr$16, 2147483648ll, -1ll );
	if( vr$17 != (struct $7ASTNODE*)0ull) goto label$112;
	{
		goto label$86;
	}
	label$112:;
	label$111:;
	ASTADD( PROC$1 );
	fb$result$1 = -1ll;
	label$86:;
	return fb$result$1;
}

int64 RTLGFXPAINT( struct $7ASTNODE* TARGET$1, struct $7ASTNODE* XEXPR$1, struct $7ASTNODE* YEXPR$1, struct $7ASTNODE* PEXPR$1, struct $7ASTNODE* BEXPR$1, int64 COORD_TYPE$1 )
{
	int64 TMP$199$1;
	int64 fb$result$1;
	__builtin_memset( &fb$result$1, 0, 8ll );
	label$113:;
	struct $7ASTNODE* PROC$1;
	int64 PATTERN$1;
	fb$result$1 = 0ll;
	struct $8FBSYMBOL* vr$1 = RTLPROCLOOKUP( (char*)"fb_GfxPaint", 312ll );
	struct $7ASTNODE* vr$2 = ASTNEWCALL( vr$1, (struct $7ASTNODE*)0ull, -1ll );
	PROC$1 = vr$2;
	struct $7ASTNODE* vr$3 = ASTNEWARG( PROC$1, TARGET$1, 2147483648ll, -1ll );
	if( vr$3 != (struct $7ASTNODE*)0ull) goto label$116;
	{
		goto label$114;
	}
	label$116:;
	label$115:;
	struct $7ASTNODE* vr$4 = ASTNEWARG( PROC$1, XEXPR$1, 2147483648ll, -1ll );
	if( vr$4 != (struct $7ASTNODE*)0ull) goto label$118;
	{
		goto label$114;
	}
	label$118:;
	label$117:;
	struct $7ASTNODE* vr$5 = ASTNEWARG( PROC$1, YEXPR$1, 2147483648ll, -1ll );
	if( vr$5 != (struct $7ASTNODE*)0ull) goto label$120;
	{
		goto label$114;
	}
	label$120:;
	label$119:;
	int64 vr$8 = SYMBISSTRING( *(int64*)((uint8*)PEXPR$1 + 8ll) & 511ll );
	if( vr$8 == 0ll) goto label$122;
	{
		PATTERN$1 = -1ll;
		struct $7ASTNODE* vr$9 = ASTNEWCONSTI( 4294901760ll, 8ll, (struct $8FBSYMBOL*)0ull );
		struct $7ASTNODE* vr$10 = ASTNEWARG( PROC$1, vr$9, 2147483648ll, -1ll );
		if( vr$10 != (struct $7ASTNODE*)0ull) goto label$124;
		{
			goto label$114;
		}
		label$124:;
		label$123:;
	}
	goto label$121;
	label$122:;
	{
		PATTERN$1 = 0ll;
		struct $7ASTNODE* vr$11 = ASTNEWARG( PROC$1, PEXPR$1, 2147483648ll, -1ll );
		if( vr$11 != (struct $7ASTNODE*)0ull) goto label$126;
		{
			goto label$114;
		}
		label$126:;
		label$125:;
	}
	label$121:;
	struct $7ASTNODE* vr$12 = ASTNEWARG( PROC$1, BEXPR$1, 2147483648ll, -1ll );
	if( vr$12 != (struct $7ASTNODE*)0ull) goto label$128;
	{
		goto label$114;
	}
	label$128:;
	label$127:;
	if( PATTERN$1 == 0ll) goto label$130;
	{
		struct $7ASTNODE* vr$13 = ASTNEWARG( PROC$1, PEXPR$1, 2147483648ll, -1ll );
		if( vr$13 != (struct $7ASTNODE*)0ull) goto label$132;
		{
			goto label$114;
		}
		label$132:;
		label$131:;
	}
	goto label$129;
	label$130:;
	{
		struct $8FBSYMBOL* vr$14 = SYMBALLOCSTRCONST( (char*)"", 0ll );
		struct $7ASTNODE* vr$15 = ASTNEWVAR( vr$14, 0ll, 2147483648ll, (struct $8FBSYMBOL*)0ull );
		struct $7ASTNODE* vr$16 = ASTNEWARG( PROC$1, vr$15, 2147483648ll, -1ll );
		if( vr$16 != (struct $7ASTNODE*)0ull) goto label$134;
		{
			goto label$114;
		}
		label$134:;
		label$133:;
	}
	label$129:;
	if( PATTERN$1 == 0ll) goto label$135;
	TMP$199$1 = 1ll;
	goto label$140;
	label$135:;
	TMP$199$1 = 0ll;
	label$140:;
	struct $7ASTNODE* vr$17 = ASTNEWCONSTI( TMP$199$1, 8ll, (struct $8FBSYMBOL*)0ull );
	struct $7ASTNODE* vr$18 = ASTNEWARG( PROC$1, vr$17, 2147483648ll, -1ll );
	if( vr$18 != (struct $7ASTNODE*)0ull) goto label$137;
	{
		goto label$114;
	}
	label$137:;
	label$136:;
	struct $7ASTNODE* vr$19 = ASTNEWCONSTI( COORD_TYPE$1, 8ll, (struct $8FBSYMBOL*)0ull );
	struct $7ASTNODE* vr$20 = ASTNEWARG( PROC$1, vr$19, 2147483648ll, -1ll );
	if( vr$20 != (struct $7ASTNODE*)0ull) goto label$139;
	{
		goto label$114;
	}
	label$139:;
	label$138:;
	ASTADD( PROC$1 );
	fb$result$1 = -1ll;
	label$114:;
	return fb$result$1;
}

int64 RTLGFXDRAW( struct $7ASTNODE* TARGET$1, struct $7ASTNODE* CEXPR$1 )
{
	int64 fb$result$1;
	__builtin_memset( &fb$result$1, 0, 8ll );
	label$141:;
	struct $7ASTNODE* PROC$1;
	fb$result$1 = 0ll;
	struct $8FBSYMBOL* vr$1 = RTLPROCLOOKUP( (char*)"fb_GfxDraw", 313ll );
	struct $7ASTNODE* vr$2 = ASTNEWCALL( vr$1, (struct $7ASTNODE*)0ull, -1ll );
	PROC$1 = vr$2;
	struct $7ASTNODE* vr$3 = ASTNEWARG( PROC$1, TARGET$1, 2147483648ll, -1ll );
	if( vr$3 != (struct $7ASTNODE*)0ull) goto label$144;
	{
		goto label$142;
	}
	label$144:;
	label$143:;
	struct $7ASTNODE* vr$4 = ASTNEWARG( PROC$1, CEXPR$1, 2147483648ll, -1ll );
	if( vr$4 != (struct $7ASTNODE*)0ull) goto label$146;
	{
		goto label$142;
	}
	label$146:;
	label$145:;
	ASTADD( PROC$1 );
	fb$result$1 = -1ll;
	label$142:;
	return fb$result$1;
}

int64 RTLGFXDRAWSTRING( struct $7ASTNODE* TARGET$1, struct $7ASTNODE* XEXPR$1, struct $7ASTNODE* YEXPR$1, struct $7ASTNODE* SEXPR$1, struct $7ASTNODE* CEXPR$1, struct $7ASTNODE* FEXPR$1, int64 COORD_TYPE$1, int64 MODE$1, struct $7ASTNODE* ALPHAEXPR$1, struct $7ASTNODE* FUNCEXPR$1, struct $7ASTNODE* PARAMEXPR$1 )
{
	struct $7ASTNODE* TMP$200$1;
	int64 fb$result$1;
	__builtin_memset( &fb$result$1, 0, 8ll );
	label$147:;
	struct $7ASTNODE* PROC$1;
	struct $7ASTNODE* PUTTER$1;
	fb$result$1 = 0ll;
	struct $8FBSYMBOL* vr$1 = RTLPROCLOOKUP( (char*)"fb_GfxDrawString", 314ll );
	struct $7ASTNODE* vr$2 = ASTNEWCALL( vr$1, (struct $7ASTNODE*)0ull, -1ll );
	PROC$1 = vr$2;
	struct $7ASTNODE* vr$3 = ASTNEWARG( PROC$1, TARGET$1, 2147483648ll, -1ll );
	if( vr$3 != (struct $7ASTNODE*)0ull) goto label$150;
	{
		goto label$148;
	}
	label$150:;
	label$149:;
	struct $7ASTNODE* vr$4 = ASTNEWARG( PROC$1, XEXPR$1, 2147483648ll, -1ll );
	if( vr$4 != (struct $7ASTNODE*)0ull) goto label$152;
	{
		goto label$148;
	}
	label$152:;
	label$151:;
	struct $7ASTNODE* vr$5 = ASTNEWARG( PROC$1, YEXPR$1, 2147483648ll, -1ll );
	if( vr$5 != (struct $7ASTNODE*)0ull) goto label$154;
	{
		goto label$148;
	}
	label$154:;
	label$153:;
	struct $7ASTNODE* vr$6 = ASTNEWCONSTI( COORD_TYPE$1, 8ll, (struct $8FBSYMBOL*)0ull );
	struct $7ASTNODE* vr$7 = ASTNEWARG( PROC$1, vr$6, 2147483648ll, -1ll );
	if( vr$7 != (struct $7ASTNODE*)0ull) goto label$156;
	{
		goto label$148;
	}
	label$156:;
	label$155:;
	struct $7ASTNODE* vr$8 = ASTNEWARG( PROC$1, SEXPR$1, 2147483648ll, -1ll );
	if( vr$8 != (struct $7ASTNODE*)0ull) goto label$158;
	{
		goto label$148;
	}
	label$158:;
	label$157:;
	if( ALPHAEXPR$1 == (struct $7ASTNODE*)0ull) goto label$160;
	{
		CEXPR$1 = ALPHAEXPR$1;
	}
	label$160:;
	label$159:;
	struct $7ASTNODE* vr$9 = ASTNEWARG( PROC$1, CEXPR$1, 2147483648ll, -1ll );
	if( vr$9 != (struct $7ASTNODE*)0ull) goto label$162;
	{
		goto label$148;
	}
	label$162:;
	label$161:;
	struct $7ASTNODE* vr$10 = ASTNEWARG( PROC$1, FEXPR$1, 2147483648ll, -1ll );
	if( vr$10 != (struct $7ASTNODE*)0ull) goto label$164;
	{
		goto label$148;
	}
	label$164:;
	label$163:;
	struct $7ASTNODE* vr$11 = ASTNEWCONSTI( MODE$1, 8ll, (struct $8FBSYMBOL*)0ull );
	struct $7ASTNODE* vr$12 = ASTNEWARG( PROC$1, vr$11, 2147483648ll, -1ll );
	if( vr$12 != (struct $7ASTNODE*)0ull) goto label$166;
	{
		goto label$148;
	}
	label$166:;
	label$165:;
	if( FEXPR$1 == (struct $7ASTNODE*)0ull) goto label$167;
	struct $7ASTNODE* vr$13 = HGETPUTTER( MODE$1 );
	TMP$200$1 = vr$13;
	goto label$176;
	label$167:;
	struct $7ASTNODE* vr$14 = ASTNEWCONSTI( 0ll, 8ll, (struct $8FBSYMBOL*)0ull );
	TMP$200$1 = vr$14;
	label$176:;
	struct $7ASTNODE* vr$15 = ASTNEWARG( PROC$1, TMP$200$1, 2147483648ll, -1ll );
	if( vr$15 != (struct $7ASTNODE*)0ull) goto label$169;
	{
		goto label$148;
	}
	label$169:;
	label$168:;
	struct $7ASTNODE* vr$16 = ASTNEWARG( PROC$1, FUNCEXPR$1, 2147483648ll, -1ll );
	if( vr$16 != (struct $7ASTNODE*)0ull) goto label$171;
	{
		goto label$148;
	}
	label$171:;
	label$170:;
	if( PARAMEXPR$1 != (struct $7ASTNODE*)0ull) goto label$173;
	{
		struct $7ASTNODE* vr$17 = ASTNEWCONSTI( 0ll, 8ll, (struct $8FBSYMBOL*)0ull );
		PARAMEXPR$1 = vr$17;
	}
	label$173:;
	label$172:;
	struct $7ASTNODE* vr$18 = ASTNEWARG( PROC$1, PARAMEXPR$1, 2147483648ll, -1ll );
	if( vr$18 != (struct $7ASTNODE*)0ull) goto label$175;
	{
		goto label$148;
	}
	label$175:;
	label$174:;
	struct $7ASTNODE* vr$19 = RTLERRORCHECK( PROC$1 );
	ASTADD( vr$19 );
	fb$result$1 = -1ll;
	label$148:;
	return fb$result$1;
}

int64 RTLGFXVIEW( struct $7ASTNODE* X1EXPR$1, struct $7ASTNODE* Y1EXPR$1, struct $7ASTNODE* X2EXPR$1, struct $7ASTNODE* Y2EXPR$1, struct $7ASTNODE* FILLEXPR$1, struct $7ASTNODE* BORDEXPR$1, int64 SCREENFLAG$1 )
{
	int64 fb$result$1;
	__builtin_memset( &fb$result$1, 0, 8ll );
	label$177:;
	struct $7ASTNODE* PROC$1;
	fb$result$1 = 0ll;
	struct $8FBSYMBOL* vr$1 = RTLPROCLOOKUP( (char*)"fb_GfxView", 315ll );
	struct $7ASTNODE* vr$2 = ASTNEWCALL( vr$1, (struct $7ASTNODE*)0ull, -1ll );
	PROC$1 = vr$2;
	struct $7ASTNODE* vr$3 = ASTNEWARG( PROC$1, X1EXPR$1, 2147483648ll, -1ll );
	if( vr$3 != (struct $7ASTNODE*)0ull) goto label$180;
	{
		goto label$178;
	}
	label$180:;
	label$179:;
	struct $7ASTNODE* vr$4 = ASTNEWARG( PROC$1, Y1EXPR$1, 2147483648ll, -1ll );
	if( vr$4 != (struct $7ASTNODE*)0ull) goto label$182;
	{
		goto label$178;
	}
	label$182:;
	label$181:;
	struct $7ASTNODE* vr$5 = ASTNEWARG( PROC$1, X2EXPR$1, 2147483648ll, -1ll );
	if( vr$5 != (struct $7ASTNODE*)0ull) goto label$184;
	{
		goto label$178;
	}
	label$184:;
	label$183:;
	struct $7ASTNODE* vr$6 = ASTNEWARG( PROC$1, Y2EXPR$1, 2147483648ll, -1ll );
	if( vr$6 != (struct $7ASTNODE*)0ull) goto label$186;
	{
		goto label$178;
	}
	label$186:;
	label$185:;
	struct $7ASTNODE* vr$7 = ASTNEWARG( PROC$1, FILLEXPR$1, 2147483648ll, -1ll );
	if( vr$7 != (struct $7ASTNODE*)0ull) goto label$188;
	{
		goto label$178;
	}
	label$188:;
	label$187:;
	struct $7ASTNODE* vr$8 = ASTNEWARG( PROC$1, BORDEXPR$1, 2147483648ll, -1ll );
	if( vr$8 != (struct $7ASTNODE*)0ull) goto label$190;
	{
		goto label$178;
	}
	label$190:;
	label$189:;
	struct $7ASTNODE* vr$9 = ASTNEWCONSTI( SCREENFLAG$1, 8ll, (struct $8FBSYMBOL*)0ull );
	struct $7ASTNODE* vr$10 = ASTNEWARG( PROC$1, vr$9, 2147483648ll, -1ll );
	if( vr$10 != (struct $7ASTNODE*)0ull) goto label$192;
	{
		goto label$178;
	}
	label$192:;
	label$191:;
	ASTADD( PROC$1 );
	fb$result$1 = -1ll;
	label$178:;
	return fb$result$1;
}

int64 RTLGFXWINDOW( struct $7ASTNODE* X1EXPR$1, struct $7ASTNODE* Y1EXPR$1, struct $7ASTNODE* X2EXPR$1, struct $7ASTNODE* Y2EXPR$1, int64 SCREENFLAG$1 )
{
	int64 fb$result$1;
	__builtin_memset( &fb$result$1, 0, 8ll );
	label$193:;
	struct $7ASTNODE* PROC$1;
	fb$result$1 = 0ll;
	struct $8FBSYMBOL* vr$1 = RTLPROCLOOKUP( (char*)"fb_GfxWindow", 316ll );
	struct $7ASTNODE* vr$2 = ASTNEWCALL( vr$1, (struct $7ASTNODE*)0ull, -1ll );
	PROC$1 = vr$2;
	if( X1EXPR$1 != (struct $7ASTNODE*)0ull) goto label$196;
	{
		struct $7ASTNODE* vr$3 = ASTNEWCONSTF( 0x0p+0, 15ll );
		X1EXPR$1 = vr$3;
	}
	label$196:;
	label$195:;
	struct $7ASTNODE* vr$4 = ASTNEWARG( PROC$1, X1EXPR$1, 2147483648ll, -1ll );
	if( vr$4 != (struct $7ASTNODE*)0ull) goto label$198;
	{
		goto label$194;
	}
	label$198:;
	label$197:;
	if( Y1EXPR$1 != (struct $7ASTNODE*)0ull) goto label$200;
	{
		struct $7ASTNODE* vr$5 = ASTNEWCONSTF( 0x0p+0, 15ll );
		Y1EXPR$1 = vr$5;
	}
	label$200:;
	label$199:;
	struct $7ASTNODE* vr$6 = ASTNEWARG( PROC$1, Y1EXPR$1, 2147483648ll, -1ll );
	if( vr$6 != (struct $7ASTNODE*)0ull) goto label$202;
	{
		goto label$194;
	}
	label$202:;
	label$201:;
	if( X2EXPR$1 != (struct $7ASTNODE*)0ull) goto label$204;
	{
		struct $7ASTNODE* vr$7 = ASTNEWCONSTF( 0x0p+0, 15ll );
		X2EXPR$1 = vr$7;
	}
	label$204:;
	label$203:;
	struct $7ASTNODE* vr$8 = ASTNEWARG( PROC$1, X2EXPR$1, 2147483648ll, -1ll );
	if( vr$8 != (struct $7ASTNODE*)0ull) goto label$206;
	{
		goto label$194;
	}
	label$206:;
	label$205:;
	if( Y2EXPR$1 != (struct $7ASTNODE*)0ull) goto label$208;
	{
		struct $7ASTNODE* vr$9 = ASTNEWCONSTF( 0x0p+0, 15ll );
		Y2EXPR$1 = vr$9;
	}
	label$208:;
	label$207:;
	struct $7ASTNODE* vr$10 = ASTNEWARG( PROC$1, Y2EXPR$1, 2147483648ll, -1ll );
	if( vr$10 != (struct $7ASTNODE*)0ull) goto label$210;
	{
		goto label$194;
	}
	label$210:;
	label$209:;
	struct $7ASTNODE* vr$11 = ASTNEWCONSTI( SCREENFLAG$1, 8ll, (struct $8FBSYMBOL*)0ull );
	struct $7ASTNODE* vr$12 = ASTNEWARG( PROC$1, vr$11, 2147483648ll, -1ll );
	if( vr$12 != (struct $7ASTNODE*)0ull) goto label$212;
	{
		goto label$194;
	}
	label$212:;
	label$211:;
	ASTADD( PROC$1 );
	fb$result$1 = -1ll;
	label$194:;
	return fb$result$1;
}

int64 RTLGFXPALETTE( struct $7ASTNODE* ATTEXPR$1, struct $7ASTNODE* REXPR$1, struct $7ASTNODE* GEXPR$1, struct $7ASTNODE* BEXPR$1, int64 ISGET$1 )
{
	int64 fb$result$1;
	__builtin_memset( &fb$result$1, 0, 8ll );
	label$213:;
	struct $7ASTNODE* PROC$1;
	struct $8FBSYMBOL* F$1;
	int64 GBDEFVAL$1;
	int64 GBMODE$1;
	fb$result$1 = 0ll;
	if( ISGET$1 == 0ll) goto label$216;
	{
		int64 TMP$201$2;
		if( ((*(int64*)((uint8*)REXPR$1 + 8ll) & 511ll) & 480ll) == 0ll) goto label$217;
		TMP$201$2 = 24ll;
		goto label$234;
		label$217:;
		TMP$201$2 = (*(int64*)((uint8*)REXPR$1 + 8ll) & 511ll) & 31ll;
		label$234:;
		if( *(int64*)(((int64)(struct $13SYMB_DATATYPE*)SYMB_DTYPETB$ + (TMP$201$2 * 56ll)) + 8ll) != 8ll) goto label$219;
		{
			struct $8FBSYMBOL* vr$8 = RTLPROCLOOKUP( (char*)"fb_GfxPaletteGet64", 321ll );
			F$1 = vr$8;
		}
		goto label$218;
		label$219:;
		{
			struct $8FBSYMBOL* vr$9 = RTLPROCLOOKUP( (char*)"fb_GfxPaletteGet", 320ll );
			F$1 = vr$9;
		}
		label$218:;
	}
	goto label$215;
	label$216:;
	{
		struct $8FBSYMBOL* vr$10 = RTLPROCLOOKUP( (char*)"fb_GfxPalette", 317ll );
		F$1 = vr$10;
	}
	label$215:;
	struct $7ASTNODE* vr$11 = ASTNEWCALL( F$1, (struct $7ASTNODE*)0ull, -1ll );
	PROC$1 = vr$11;
	struct $7ASTNODE* vr$12 = ASTNEWARG( PROC$1, ATTEXPR$1, 2147483648ll, -1ll );
	if( vr$12 != (struct $7ASTNODE*)0ull) goto label$221;
	{
		goto label$214;
	}
	label$221:;
	label$220:;
	if( REXPR$1 != (struct $7ASTNODE*)0ull) goto label$223;
	{
		struct $7ASTNODE* vr$13 = ASTNEWCONSTI( -1ll, 8ll, (struct $8FBSYMBOL*)0ull );
		REXPR$1 = vr$13;
	}
	label$223:;
	label$222:;
	struct $7ASTNODE* vr$14 = ASTNEWARG( PROC$1, REXPR$1, 2147483648ll, -1ll );
	if( vr$14 != (struct $7ASTNODE*)0ull) goto label$225;
	{
		goto label$214;
	}
	label$225:;
	label$224:;
	if( GEXPR$1 == (struct $7ASTNODE*)0ull) goto label$227;
	{
		GBMODE$1 = -1ll;
	}
	goto label$226;
	label$227:;
	{
		if( ISGET$1 == 0ll) goto label$229;
		{
			GBDEFVAL$1 = 0ll;
		}
		goto label$228;
		label$229:;
		{
			GBDEFVAL$1 = -1ll;
		}
		label$228:;
		struct $7ASTNODE* vr$15 = ASTNEWCONSTI( GBDEFVAL$1, 8ll, (struct $8FBSYMBOL*)0ull );
		GEXPR$1 = vr$15;
		struct $7ASTNODE* vr$16 = ASTNEWCONSTI( GBDEFVAL$1, 8ll, (struct $8FBSYMBOL*)0ull );
		BEXPR$1 = vr$16;
		GBMODE$1 = 1ll;
	}
	label$226:;
	struct $7ASTNODE* vr$17 = ASTNEWARG( PROC$1, GEXPR$1, 2147483648ll, GBMODE$1 );
	if( vr$17 != (struct $7ASTNODE*)0ull) goto label$231;
	{
		goto label$214;
	}
	label$231:;
	label$230:;
	struct $7ASTNODE* vr$18 = ASTNEWARG( PROC$1, BEXPR$1, 2147483648ll, GBMODE$1 );
	if( vr$18 != (struct $7ASTNODE*)0ull) goto label$233;
	{
		goto label$214;
	}
	label$233:;
	label$232:;
	ASTADD( PROC$1 );
	fb$result$1 = -1ll;
	label$214:;
	return fb$result$1;
}

int64 RTLGFXPALETTEUSING( struct $7ASTNODE* ARRAYEXPR$1, int64 ISGET$1, int64 IS64BIT$1 )
{
	int64 fb$result$1;
	__builtin_memset( &fb$result$1, 0, 8ll );
	label$235:;
	struct $7ASTNODE* PROC$1;
	struct $8FBSYMBOL* F$1;
	fb$result$1 = 0ll;
	if( IS64BIT$1 == 0ll) goto label$238;
	{
		if( ISGET$1 == 0ll) goto label$240;
		{
			struct $8FBSYMBOL* vr$1 = RTLPROCLOOKUP( (char*)"fb_GfxPaletteGetUsing64", 323ll );
			F$1 = vr$1;
		}
		goto label$239;
		label$240:;
		{
			struct $8FBSYMBOL* vr$2 = RTLPROCLOOKUP( (char*)"fb_GfxPaletteUsing64", 319ll );
			F$1 = vr$2;
		}
		label$239:;
	}
	goto label$237;
	label$238:;
	{
		if( ISGET$1 == 0ll) goto label$242;
		{
			struct $8FBSYMBOL* vr$3 = RTLPROCLOOKUP( (char*)"fb_GfxPaletteGetUsing", 322ll );
			F$1 = vr$3;
		}
		goto label$241;
		label$242:;
		{
			struct $8FBSYMBOL* vr$4 = RTLPROCLOOKUP( (char*)"fb_GfxPaletteUsing", 318ll );
			F$1 = vr$4;
		}
		label$241:;
	}
	label$237:;
	struct $7ASTNODE* vr$5 = ASTNEWCALL( F$1, (struct $7ASTNODE*)0ull, -1ll );
	PROC$1 = vr$5;
	struct $7ASTNODE* vr$6 = ASTNEWARG( PROC$1, ARRAYEXPR$1, 2147483648ll, -1ll );
	if( vr$6 != (struct $7ASTNODE*)0ull) goto label$244;
	{
		goto label$236;
	}
	label$244:;
	label$243:;
	ASTADD( PROC$1 );
	fb$result$1 = -1ll;
	label$236:;
	return fb$result$1;
}

int64 RTLGFXPUT( struct $7ASTNODE* TARGET$1, struct $7ASTNODE* XEXPR$1, struct $7ASTNODE* YEXPR$1, struct $7ASTNODE* ARRAYEXPR$1, struct $7ASTNODE* X1EXPR$1, struct $7ASTNODE* X2EXPR$1, struct $7ASTNODE* Y1EXPR$1, struct $7ASTNODE* Y2EXPR$1, int64 MODE$1, struct $7ASTNODE* ALPHAEXPR$1, struct $7ASTNODE* FUNCEXPR$1, struct $7ASTNODE* PARAMEXPR$1, int64 COORDTYPE$1 )
{
	int64 fb$result$1;
	__builtin_memset( &fb$result$1, 0, 8ll );
	label$245:;
	struct $7ASTNODE* PROC$1;
	fb$result$1 = 0ll;
	struct $8FBSYMBOL* vr$1 = RTLPROCLOOKUP( (char*)"fb_GfxPut", 324ll );
	struct $7ASTNODE* vr$2 = ASTNEWCALL( vr$1, (struct $7ASTNODE*)0ull, -1ll );
	PROC$1 = vr$2;
	struct $7ASTNODE* vr$3 = ASTNEWARG( PROC$1, TARGET$1, 2147483648ll, -1ll );
	if( vr$3 != (struct $7ASTNODE*)0ull) goto label$248;
	{
		goto label$246;
	}
	label$248:;
	label$247:;
	struct $7ASTNODE* vr$4 = ASTNEWARG( PROC$1, XEXPR$1, 2147483648ll, -1ll );
	if( vr$4 != (struct $7ASTNODE*)0ull) goto label$250;
	{
		goto label$246;
	}
	label$250:;
	label$249:;
	struct $7ASTNODE* vr$5 = ASTNEWARG( PROC$1, YEXPR$1, 2147483648ll, -1ll );
	if( vr$5 != (struct $7ASTNODE*)0ull) goto label$252;
	{
		goto label$246;
	}
	label$252:;
	label$251:;
	struct $7ASTNODE* vr$6 = ASTNEWARG( PROC$1, ARRAYEXPR$1, 2147483648ll, -1ll );
	if( vr$6 != (struct $7ASTNODE*)0ull) goto label$254;
	{
		goto label$246;
	}
	label$254:;
	label$253:;
	struct $7ASTNODE* vr$7 = ASTNEWARG( PROC$1, X1EXPR$1, 2147483648ll, -1ll );
	if( vr$7 != (struct $7ASTNODE*)0ull) goto label$256;
	{
		goto label$246;
	}
	label$256:;
	label$255:;
	struct $7ASTNODE* vr$8 = ASTNEWARG( PROC$1, X2EXPR$1, 2147483648ll, -1ll );
	if( vr$8 != (struct $7ASTNODE*)0ull) goto label$258;
	{
		goto label$246;
	}
	label$258:;
	label$257:;
	struct $7ASTNODE* vr$9 = ASTNEWARG( PROC$1, Y1EXPR$1, 2147483648ll, -1ll );
	if( vr$9 != (struct $7ASTNODE*)0ull) goto label$260;
	{
		goto label$246;
	}
	label$260:;
	label$259:;
	struct $7ASTNODE* vr$10 = ASTNEWARG( PROC$1, Y2EXPR$1, 2147483648ll, -1ll );
	if( vr$10 != (struct $7ASTNODE*)0ull) goto label$262;
	{
		goto label$246;
	}
	label$262:;
	label$261:;
	struct $7ASTNODE* vr$11 = ASTNEWCONSTI( COORDTYPE$1, 8ll, (struct $8FBSYMBOL*)0ull );
	struct $7ASTNODE* vr$12 = ASTNEWARG( PROC$1, vr$11, 2147483648ll, -1ll );
	if( vr$12 != (struct $7ASTNODE*)0ull) goto label$264;
	{
		goto label$246;
	}
	label$264:;
	label$263:;
	struct $7ASTNODE* vr$13 = ASTNEWCONSTI( MODE$1, 8ll, (struct $8FBSYMBOL*)0ull );
	struct $7ASTNODE* vr$14 = ASTNEWARG( PROC$1, vr$13, 2147483648ll, -1ll );
	if( vr$14 != (struct $7ASTNODE*)0ull) goto label$266;
	{
		goto label$246;
	}
	label$266:;
	label$265:;
	struct $7ASTNODE* vr$15 = HGETPUTTER( MODE$1 );
	struct $7ASTNODE* vr$16 = ASTNEWARG( PROC$1, vr$15, 2147483648ll, -1ll );
	if( vr$16 != (struct $7ASTNODE*)0ull) goto label$268;
	{
		goto label$246;
	}
	label$268:;
	label$267:;
	struct $7ASTNODE* vr$17 = ASTNEWARG( PROC$1, ALPHAEXPR$1, 2147483648ll, -1ll );
	if( vr$17 != (struct $7ASTNODE*)0ull) goto label$270;
	{
		goto label$246;
	}
	label$270:;
	label$269:;
	struct $7ASTNODE* vr$18 = ASTNEWARG( PROC$1, FUNCEXPR$1, 2147483648ll, -1ll );
	if( vr$18 != (struct $7ASTNODE*)0ull) goto label$272;
	{
		goto label$246;
	}
	label$272:;
	label$271:;
	struct $7ASTNODE* vr$19 = ASTNEWARG( PROC$1, PARAMEXPR$1, 2147483648ll, -1ll );
	if( vr$19 != (struct $7ASTNODE*)0ull) goto label$274;
	{
		goto label$246;
	}
	label$274:;
	label$273:;
	struct $7ASTNODE* vr$20 = RTLERRORCHECK( PROC$1 );
	ASTADD( vr$20 );
	fb$result$1 = -1ll;
	label$246:;
	return fb$result$1;
}

int64 RTLGFXGET( struct $7ASTNODE* TARGET$1, struct $7ASTNODE* X1EXPR$1, struct $7ASTNODE* Y1EXPR$1, struct $7ASTNODE* X2EXPR$1, struct $7ASTNODE* Y2EXPR$1, struct $7ASTNODE* ARRAYEXPR$1, int64 COORDTYPE$1, struct $7ASTNODE* DESCEXPR$1 )
{
	struct $8FBSYMBOL* TMP$202$1;
	int64 fb$result$1;
	__builtin_memset( &fb$result$1, 0, 8ll );
	label$275:;
	struct $7ASTNODE* PROC$1;
	fb$result$1 = 0ll;
	if( *(int64*)((uint8*)&ENV$ + 280ll) != 0ll) goto label$277;
	struct $8FBSYMBOL* vr$1 = RTLPROCLOOKUP( (char*)"fb_GfxGet", 336ll );
	TMP$202$1 = vr$1;
	goto label$298;
	label$277:;
	struct $8FBSYMBOL* vr$2 = RTLPROCLOOKUP( (char*)"fb_GfxGetQB", 337ll );
	TMP$202$1 = vr$2;
	label$298:;
	struct $7ASTNODE* vr$3 = ASTNEWCALL( TMP$202$1, (struct $7ASTNODE*)0ull, -1ll );
	PROC$1 = vr$3;
	struct $7ASTNODE* vr$4 = ASTNEWARG( PROC$1, TARGET$1, 2147483648ll, -1ll );
	if( vr$4 != (struct $7ASTNODE*)0ull) goto label$279;
	{
		goto label$276;
	}
	label$279:;
	label$278:;
	struct $7ASTNODE* vr$5 = ASTNEWARG( PROC$1, X1EXPR$1, 2147483648ll, -1ll );
	if( vr$5 != (struct $7ASTNODE*)0ull) goto label$281;
	{
		goto label$276;
	}
	label$281:;
	label$280:;
	struct $7ASTNODE* vr$6 = ASTNEWARG( PROC$1, Y1EXPR$1, 2147483648ll, -1ll );
	if( vr$6 != (struct $7ASTNODE*)0ull) goto label$283;
	{
		goto label$276;
	}
	label$283:;
	label$282:;
	struct $7ASTNODE* vr$7 = ASTNEWARG( PROC$1, X2EXPR$1, 2147483648ll, -1ll );
	if( vr$7 != (struct $7ASTNODE*)0ull) goto label$285;
	{
		goto label$276;
	}
	label$285:;
	label$284:;
	struct $7ASTNODE* vr$8 = ASTNEWARG( PROC$1, Y2EXPR$1, 2147483648ll, -1ll );
	if( vr$8 != (struct $7ASTNODE*)0ull) goto label$287;
	{
		goto label$276;
	}
	label$287:;
	label$286:;
	struct $7ASTNODE* vr$9 = ASTNEWARG( PROC$1, ARRAYEXPR$1, 2147483648ll, -1ll );
	if( vr$9 != (struct $7ASTNODE*)0ull) goto label$289;
	{
		goto label$276;
	}
	label$289:;
	label$288:;
	struct $7ASTNODE* vr$10 = ASTNEWCONSTI( COORDTYPE$1, 8ll, (struct $8FBSYMBOL*)0ull );
	struct $7ASTNODE* vr$11 = ASTNEWARG( PROC$1, vr$10, 2147483648ll, -1ll );
	if( vr$11 != (struct $7ASTNODE*)0ull) goto label$291;
	{
		goto label$276;
	}
	label$291:;
	label$290:;
	if( DESCEXPR$1 == (struct $7ASTNODE*)0ull) goto label$293;
	{
		struct $7ASTNODE* vr$12 = ASTNEWARG( PROC$1, DESCEXPR$1, 2147483648ll, -1ll );
		if( vr$12 != (struct $7ASTNODE*)0ull) goto label$295;
		{
			goto label$276;
		}
		label$295:;
		label$294:;
	}
	goto label$292;
	label$293:;
	{
		struct $7ASTNODE* vr$13 = ASTNEWCONSTI( 0ll, 8ll, (struct $8FBSYMBOL*)0ull );
		struct $7ASTNODE* vr$14 = ASTNEWARG( PROC$1, vr$13, 2147483648ll, 1ll );
		if( vr$14 != (struct $7ASTNODE*)0ull) goto label$297;
		{
			goto label$276;
		}
		label$297:;
		label$296:;
	}
	label$292:;
	struct $7ASTNODE* vr$15 = RTLERRORCHECK( PROC$1 );
	ASTADD( vr$15 );
	fb$result$1 = -1ll;
	label$276:;
	return fb$result$1;
}

int64 RTLGFXSCREENSET( struct $7ASTNODE* MEXPR$1, struct $7ASTNODE* DEXPR$1, struct $7ASTNODE* PEXPR$1, struct $7ASTNODE* FEXPR$1, struct $7ASTNODE* REXPR$1 )
{
	int64 fb$result$1;
	__builtin_memset( &fb$result$1, 0, 8ll );
	label$299:;
	struct $7ASTNODE* PROC$1;
	fb$result$1 = 0ll;
	struct $8FBSYMBOL* vr$1 = RTLPROCLOOKUP( (char*)"fb_GfxScreen", 338ll );
	struct $7ASTNODE* vr$2 = ASTNEWCALL( vr$1, (struct $7ASTNODE*)0ull, -1ll );
	PROC$1 = vr$2;
	struct $7ASTNODE* vr$3 = ASTNEWARG( PROC$1, MEXPR$1, 2147483648ll, -1ll );
	if( vr$3 != (struct $7ASTNODE*)0ull) goto label$302;
	{
		goto label$300;
	}
	label$302:;
	label$301:;
	struct $7ASTNODE* vr$4 = ASTNEWARG( PROC$1, DEXPR$1, 2147483648ll, -1ll );
	if( vr$4 != (struct $7ASTNODE*)0ull) goto label$304;
	{
		goto label$300;
	}
	label$304:;
	label$303:;
	struct $7ASTNODE* vr$5 = ASTNEWARG( PROC$1, PEXPR$1, 2147483648ll, -1ll );
	if( vr$5 != (struct $7ASTNODE*)0ull) goto label$306;
	{
		goto label$300;
	}
	label$306:;
	label$305:;
	struct $7ASTNODE* vr$6 = ASTNEWARG( PROC$1, FEXPR$1, 2147483648ll, -1ll );
	if( vr$6 != (struct $7ASTNODE*)0ull) goto label$308;
	{
		goto label$300;
	}
	label$308:;
	label$307:;
	struct $7ASTNODE* vr$7 = ASTNEWARG( PROC$1, REXPR$1, 2147483648ll, -1ll );
	if( vr$7 != (struct $7ASTNODE*)0ull) goto label$310;
	{
		goto label$300;
	}
	label$310:;
	label$309:;
	struct $7ASTNODE* vr$8 = RTLERRORCHECK( PROC$1 );
	ASTADD( vr$8 );
	fb$result$1 = -1ll;
	label$300:;
	return fb$result$1;
}

int64 RTLGFXSCREENSETQB( struct $7ASTNODE* MODE$1, struct $7ASTNODE* ACTIVE$1, struct $7ASTNODE* VISIBLE$1 )
{
	int64 fb$result$1;
	__builtin_memset( &fb$result$1, 0, 8ll );
	label$311:;
	struct $7ASTNODE* PROC$1;
	fb$result$1 = 0ll;
	struct $8FBSYMBOL* vr$1 = RTLPROCLOOKUP( (char*)"fb_GfxScreenQB", 339ll );
	struct $7ASTNODE* vr$2 = ASTNEWCALL( vr$1, (struct $7ASTNODE*)0ull, -1ll );
	PROC$1 = vr$2;
	struct $7ASTNODE* vr$3 = ASTNEWARG( PROC$1, MODE$1, 2147483648ll, -1ll );
	if( vr$3 != (struct $7ASTNODE*)0ull) goto label$314;
	{
		goto label$312;
	}
	label$314:;
	label$313:;
	struct $7ASTNODE* vr$4 = ASTNEWARG( PROC$1, ACTIVE$1, 2147483648ll, -1ll );
	if( vr$4 != (struct $7ASTNODE*)0ull) goto label$316;
	{
		goto label$312;
	}
	label$316:;
	label$315:;
	struct $7ASTNODE* vr$5 = ASTNEWARG( PROC$1, VISIBLE$1, 2147483648ll, -1ll );
	if( vr$5 != (struct $7ASTNODE*)0ull) goto label$318;
	{
		goto label$312;
	}
	label$318:;
	label$317:;
	struct $7ASTNODE* vr$6 = RTLERRORCHECK( PROC$1 );
	ASTADD( vr$6 );
	fb$result$1 = -1ll;
	label$312:;
	return fb$result$1;
}

struct $7ASTNODE* RTLGFXIMAGECREATE( struct $7ASTNODE* WEXPR$1, struct $7ASTNODE* HEXPR$1, struct $7ASTNODE* CEXPR$1, struct $7ASTNODE* DEXPR$1, int64 FLAGS$1 )
{
	struct $8FBSYMBOL* TMP$203$1;
	struct $7ASTNODE* fb$result$1;
	__builtin_memset( &fb$result$1, 0, 8ll );
	label$319:;
	struct $7ASTNODE* PROC$1;
	fb$result$1 = (struct $7ASTNODE*)0ull;
	if( *(int64*)((uint8*)&ENV$ + 280ll) != 0ll) goto label$321;
	struct $8FBSYMBOL* vr$1 = RTLPROCLOOKUP( (char*)"fb_GfxImageCreate", 340ll );
	TMP$203$1 = vr$1;
	goto label$332;
	label$321:;
	struct $8FBSYMBOL* vr$2 = RTLPROCLOOKUP( (char*)"fb_GfxImageCreateQB", 341ll );
	TMP$203$1 = vr$2;
	label$332:;
	struct $7ASTNODE* vr$3 = ASTNEWCALL( TMP$203$1, (struct $7ASTNODE*)0ull, -1ll );
	PROC$1 = vr$3;
	struct $7ASTNODE* vr$4 = ASTNEWARG( PROC$1, WEXPR$1, 2147483648ll, -1ll );
	if( vr$4 != (struct $7ASTNODE*)0ull) goto label$323;
	{
		goto label$320;
	}
	label$323:;
	label$322:;
	struct $7ASTNODE* vr$5 = ASTNEWARG( PROC$1, HEXPR$1, 2147483648ll, -1ll );
	if( vr$5 != (struct $7ASTNODE*)0ull) goto label$325;
	{
		goto label$320;
	}
	label$325:;
	label$324:;
	struct $7ASTNODE* vr$6 = ASTNEWARG( PROC$1, CEXPR$1, 2147483648ll, -1ll );
	if( vr$6 != (struct $7ASTNODE*)0ull) goto label$327;
	{
		goto label$320;
	}
	label$327:;
	label$326:;
	struct $7ASTNODE* vr$7 = ASTNEWARG( PROC$1, DEXPR$1, 2147483648ll, -1ll );
	if( vr$7 != (struct $7ASTNODE*)0ull) goto label$329;
	{
		goto label$320;
	}
	label$329:;
	label$328:;
	struct $7ASTNODE* vr$8 = ASTNEWCONSTI( FLAGS$1, 8ll, (struct $8FBSYMBOL*)0ull );
	struct $7ASTNODE* vr$9 = ASTNEWARG( PROC$1, vr$8, 2147483648ll, -1ll );
	if( vr$9 != (struct $7ASTNODE*)0ull) goto label$331;
	{
		goto label$320;
	}
	label$331:;
	label$330:;
	fb$result$1 = PROC$1;
	label$320:;
	return fb$result$1;
}

__attribute__(( constructor )) static void fb_ctor__rtlzgfx( void )
{
	label$0:;
	label$1:;
}

static void _ZN11TSTRSETITEMaSERKS_( struct $11TSTRSETITEM* THIS$1, struct $11TSTRSETITEM* __FB_RHS__$1 )
{
	label$4:;
	fb_StrAssign( (void*)THIS$1, -1ll, (void*)__FB_RHS__$1, -1ll, 0 );
	*(int64*)((uint8*)THIS$1 + 24ll) = *(int64*)((uint8*)__FB_RHS__$1 + 24ll);
	*(struct $8HASHITEM**)((uint8*)THIS$1 + 32ll) = *(struct $8HASHITEM**)((uint8*)__FB_RHS__$1 + 32ll);
	label$5:;
}

static int64 HPORTS_CB( struct $8FBSYMBOL* SYM$1 )
{
	int64 fb$result$1;
	__builtin_memset( &fb$result$1, 0, 8ll );
	label$14:;
	static int64 RESTART_COUNT$1;
	static int64 LIBSADDED$1 = 0ll;
	int64 vr$1 = FBRESTARTGETCOUNT(  );
	if( RESTART_COUNT$1 == vr$1) goto label$17;
	{
		int64 vr$2 = FBRESTARTGETCOUNT(  );
		RESTART_COUNT$1 = vr$2;
		LIBSADDED$1 = 0ll;
	}
	label$17:;
	label$16:;
	if( LIBSADDED$1 != 0ll) goto label$19;
	{
		LIBSADDED$1 = -1ll;
		{
			$13FB_COMPTARGET TMP$196$3;
			TMP$196$3 = *($13FB_COMPTARGET*)((uint8*)&ENV$ + 224ll);
			if( TMP$196$3 == 0ll) goto label$22;
			label$23:;
			if( TMP$196$3 != 1ll) goto label$21;
			label$22:;
			{
				FBADDLIB( (char*)"advapi32" );
			}
			label$21:;
			label$20:;
		}
	}
	label$19:;
	label$18:;
	fb$result$1 = -1ll;
	label$15:;
	return fb$result$1;
}

static int64 HGFXLIB_CB( struct $8FBSYMBOL* SYM$1 )
{
	int64 fb$result$1;
	__builtin_memset( &fb$result$1, 0, 8ll );
	label$24:;
	*(int64*)((uint8*)&ENV$ + 488ll) = -1ll;
	fb$result$1 = -1ll;
	label$25:;
	return fb$result$1;
}

static struct $7ASTNODE* HGETPUTTER( int64 MODE$1 )
{
	struct $7ASTNODE* fb$result$1;
	__builtin_memset( &fb$result$1, 0, 8ll );
	label$26:;
	struct $8FBSYMBOL* PROC$1;
	{
		uint64 TMP$198$2;
		TMP$198$2 = (uint64)MODE$1;
		goto label$29;
		label$30:;
		{
			struct $8FBSYMBOL* vr$1 = RTLPROCLOOKUP( (char*)"fb_hPutTrans", 325ll );
			PROC$1 = vr$1;
		}
		goto label$28;
		label$31:;
		{
			struct $8FBSYMBOL* vr$2 = RTLPROCLOOKUP( (char*)"fb_hPutPSet", 326ll );
			PROC$1 = vr$2;
		}
		goto label$28;
		label$32:;
		{
			struct $8FBSYMBOL* vr$3 = RTLPROCLOOKUP( (char*)"fb_hPutPReset", 327ll );
			PROC$1 = vr$3;
		}
		goto label$28;
		label$33:;
		{
			struct $8FBSYMBOL* vr$4 = RTLPROCLOOKUP( (char*)"fb_hPutAnd", 328ll );
			PROC$1 = vr$4;
		}
		goto label$28;
		label$34:;
		{
			struct $8FBSYMBOL* vr$5 = RTLPROCLOOKUP( (char*)"fb_hPutOr", 329ll );
			PROC$1 = vr$5;
		}
		goto label$28;
		label$35:;
		{
			struct $8FBSYMBOL* vr$6 = RTLPROCLOOKUP( (char*)"fb_hPutXor", 330ll );
			PROC$1 = vr$6;
		}
		goto label$28;
		label$36:;
		{
			struct $8FBSYMBOL* vr$7 = RTLPROCLOOKUP( (char*)"fb_hPutAlpha", 331ll );
			PROC$1 = vr$7;
		}
		goto label$28;
		label$37:;
		{
			struct $8FBSYMBOL* vr$8 = RTLPROCLOOKUP( (char*)"fb_hPutBlend", 332ll );
			PROC$1 = vr$8;
		}
		goto label$28;
		label$38:;
		{
			struct $8FBSYMBOL* vr$9 = RTLPROCLOOKUP( (char*)"fb_hPutMask", 333ll );
			PROC$1 = vr$9;
		}
		goto label$28;
		label$39:;
		{
			struct $8FBSYMBOL* vr$10 = RTLPROCLOOKUP( (char*)"fb_hPutAdd", 334ll );
			PROC$1 = vr$10;
		}
		goto label$28;
		label$40:;
		{
			struct $8FBSYMBOL* vr$11 = RTLPROCLOOKUP( (char*)"fb_hPutCustom", 335ll );
			PROC$1 = vr$11;
		}
		goto label$28;
		label$29:;
		static const void* tmp$204[11ll] = {
			&&label$30,
			&&label$31,
			&&label$32,
			&&label$33,
			&&label$34,
			&&label$35,
			&&label$36,
			&&label$39,
			&&label$40,
			&&label$37,
			&&label$38,
		};
		if( TMP$198$2 > 10ull ) goto label$40;
		goto *tmp$204[TMP$198$2 - 0ull];
		label$28:;
	}
	struct $7ASTNODE* vr$12 = ASTBUILDPROCADDROF( PROC$1 );
	fb$result$1 = vr$12;
	label$27:;
	return fb$result$1;
}
