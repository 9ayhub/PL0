program  PL0 ( input, output);
{���д������ɵ�PL0�������}

//label  99;

//-----------------------------------------------
{��������}
const
  norw = 13; {�����ֵĸ���}
  txmax = 100; {��ʶ������}
  nmax = 14; {���ֵ����λ��}
  al = 10; {��ʶ���ĳ���}
  amax = 2047; {����ַ}
  levmax = 3; {������Ƕ�׵�������}
  cxmax = 200; {��������Ĵ�С}

//-----------------------------------------------


//-----------------------------------------------
{���ͱ�������}
type
  symbol = (nul, ident, number, plus, minus, times, slash, oddsym,
            eql, neq, lss, leq, gtr, geq, lparen, rparen, comma, semicolon,
            period, becomes, beginsym, endsym, ifsym, thensym,
            whilesym, dosym, callsym, constsym, varsym, procsym, readsym, writesym);
  alfa = packed array [1..al] of char; 
  objectt = (constant, variable, proceduree);
  symset = set of symbol;
  fct = (lit, opr, lod, sto, cal, int, jmp, jpc, red, wrt); {functions}
  {LIT 0,a : ȡ����a
  OPR 0,a : ִ������a
  LOD l,a : ȡ���Ϊl�Ĳ�p��Ե�ַΪa�ı���
  STO l,a : �浽���Ϊl�Ĳ�p��Ե�ַΪa�ı���
  CAL l,a : ���ò��Ϊl�Ĺ���
  INT 0,a : t�Ĵ�������a
  JMP 0,a : ת�Ƶ�ָ���ַa��
  JPC 0,a : ����ת�Ƶ�ָ���ַa�� 
  RED
  WRT
  }
  instruction = packed record
        f : fct;  {������}
        l : 0..levmax; {��Բ���}
        a : 0..amax; {��Ե�ַ}
  end;

//-----------------------------------------------


//-----------------------------------------------
{ȫ�ֱ�������}
var
  ch : char; {����������ַ�}
  sym : symbol; {��������ķ���}
  id : alfa; {��������ı�ʶ��}
  num : integer; {�����������}
  cc : integer; {��ǰ�е��ַ�����}
  ll : integer; {��ǰ�еĳ���}
  kk, err : integer;
  cx : integer; {��������ĵ�ǰ�±�}
  line : array [1..81] of char; {��ǰ��}
  a : alfa; {��ǰ��ʶ�����ַ���}
  code : array [0..cxmax] of instruction; {�м��������}
  word : array [1..norw] of alfa; {��ű����ֵ��ַ���}
  wsym : array [1..norw] of symbol; {��ű����ֵļǺ�}
  ssym : array [char] of symbol; {�������ͱ����ŵļǺ�}
  mnemonic : array [fct] of packed array [1..5] of char;
  {�м����������ַ���}
  declbegsys, statbegsys, facbegsys : symset;
  table : array [0..txmax] of {���ű�}
         record
           name : alfa;
           case kind : objectt of
            constant : (val : integer);
            variable, proceduree : (level, adr : integer)
         end;
  fin : text;       {Դ�����ļ�}
  fout : text;      {����ļ�}

//-----------------------------------------------


//-----------------------------------------------
{���������}
procedure error (n : integer);
begin 
  writeln(fout, '****', ' ':cc-1, '^', n:2);  {ccΪ��ǰ���Ѷ����ַ���, nΪ�����}
  err := err + 1{������err��1}
end {error};
//-----------------------------------------------


//-----------------------------------------------
{�ʷ���������}
procedure getsym;
var  i, j, k : integer;

{ȡ��һ�ַ�}
procedure  getch ; 
begin
    if cc = ll then {���ccָ����ĩ}
    begin
        if eof(fin) then {����ѵ��ļ�β}
        begin
            writeln(fout, 'PROGRAM INCOMPLETE'); 
            close(fin);
            close(fout);
            exit;
            //goto 99
        end;
        {���µ�һ��}
        ll := 0; 
        cc := 0; 
        write(fout, cx : 5, ' ');{cx : 5λ��}
        while not eoln(fin) do {���������ĩ}
        begin
            ll := ll + 1; {���л������ĳ���+1}
            read(fin, ch); {��Դ�ļ��ж�ȡһ���ַ���ch��}
            write(fout, ch);{���ch������ļ���}
            line[ll] := ch  {������ַ��ŵ���ǰ��ĩβ}
        end;
        writeln(fout); {����}
        readln(fin);{��Դ�ļ���һ�п�ʼ��ȡ}
        ll := ll + 1; {���л������ĳ���+1}
        line[ll] := ' ' { process end-line }	{���������һ��Ԫ��Ϊ�ո�}
    end;
    cc := cc + 1; 
    ch := line[cc]  {chȡline����һ���ַ�}
end {getch};


begin {getsym} 
    {�������ÿհ�}
    while ch = ' ' do getch;

    {��ʶ��������} 
    if ch in ['a'..'z'] then 
    begin 
        k := 0;
        repeat {������ĸ��ͷ����ĸ�p���ִ�}
            if k < al then
                begin 
                    k:= k + 1; 
                    a[k] := ch
                end;
            getch
        until  not (ch in ['a'..'z', '0'..'9']);
        if k >= kk  then kk := k 
        else
            repeat 
                a[kk] := ' '; 
                kk := kk-1 {�����ʶ�����Ȳ�����󳤶�, ���油�հ�}
            until kk = k; 
        {id�д�ŵ�ǰ��ʶ�������ֵ��ַ���}               
        id := a;  
        i := 1;  
        j := norw;
        {�ö��ֲ��ҷ��ڱ����ֱ����ҵ�ǰ�ı�ʶ��id}
        repeat  
            k := (i+j) div 2; 
            if id <= word[k] then j := k-1;  
            if id >= word[k] then i := k + 1
        until i > j;
        {����ҵ�, ��ǰ�Ǻ�symΪ������, ����symΪ��ʶ��}
        if i-1 > j then 
            sym := wsym[k] 
        else 
            sym := ident
    end 

    {����} 
    else if ch in ['0'..'9'] then
    begin
        k := 0;  
        num := 0;  
        sym := number; {��ǰ�Ǻ�symΪ����}
        repeat {�������ִ���ֵ}
            num := 10*num + (ord(ch)-ord('0'));
            {ord(ch)��ord(0)��ch��0��ASCII���е����}
            k := k + 1;  
            getch;
        until not(ch in ['0'..'9']);
        {��ǰ���ִ��ĳ��ȳ����Ͻ�,�򱨸����}
        if k > nmax then error(30)
    end 

    {����ֵ��}
    else if ch = ':' then 
    begin 
        getch;
        if ch = '=' then
            begin  
                sym := becomes; 
                getch 
            end
        else  
            sym := nul;
    end 

    {����'<'}
    else if ch = '<' then 
    begin	
        getch;	
        {'<='}
        if ch = '=' then 
        begin
            sym := leq;	{��ʾС�ڵ���}
            getch	{����һ���ַ�}
        end
        {'<>'}
        else if ch = '>' then 
        begin
            sym := neq;	{��ʾ������}
            getch
        end
        {'<'}
        else sym := lss	{��ʾС��}
    end

    {����'>'}
    else if ch = '>' then 
    begin	
        getch;	
        {'>='}
        if ch = '=' then 
        begin
            sym := geq;	{��ʾ���ڵ���}
            getch	{����һ���ַ�}
        end
        {'>'}
        else sym := gtr	{��ʾ����}
    end

    {������������������}
    else 
    begin  
        sym := ssym[ch];  
        getch
    end

end {getsym};

//-----------------------------------------------


//-----------------------------------------------
{Ŀ��������ɹ���,x��ʾPCODEָ��,y,z��ָ�������������}
procedure  gen(x : fct; y, z : integer); 
begin 
    {�����ǰָ�����>�������󳤶�}
    if cx > cxmax then 
        begin 
            write(fout, 'PROGRAM TOO LONG'); 
            close(fin);
            close(fout);
            exit
            //goto 99
        end;
        with code[cx] do {�ڴ�������cxλ������һ���´���}
        begin  
            f := x; {������} 
            l := y; {���} 
            a := z {��ַ}
        end;
    cx := cx + 1 {ָ����ż�1}
end {gen};
//-----------------------------------------------


//-----------------------------------------------
{���Ե�ǰ�ַ��Ϸ��Թ���,���ڴ����﷨����,�����Ϸ�����������ֵֻ�����Ϸ�����Ϊֹ}
procedure  test(s1, s2 : symset; n : integer);
begin
    if not (sym in s1) then 
    {�����ǰ�ǺŲ����ڼ���S1,�򱨸����n}
    begin  
        error(n);  
        s1 := s1 + s2;
        while not (sym in s1) do 
            getsym 
        {����һЩ�Ǻ�, ֱ����ǰ�Ǻ�����S1��S2}
    end
end {test};
//-----------------------------------------------


//-----------------------------------------------
{block}
procedure  block(lev, tx : integer; fsys : symset);
var
    dx : integer; {���������ݿռ�����±�}
    tx0 : integer; {�����̱�ʶ����ʼ�±�}
    cx0 : integer; {�����̴�����ʼ�±�}

{��������뵽���ű���}
{enter}
procedure  enter(k : objectt);
begin {��objectt������ű���}
    tx := tx + 1; {���ű�ָ���1}
    {�ڷ��ű��������µ�һ����Ŀ}
    with table[tx] do
    begin  
        name := id; {��ǰ��ʶ��������} 
        kind := k; {��ǰ��ʶ��������}
        case k of
            {��ǰ��ʶ���ǳ�����}
            constant : 
                begin 
                    if num > amax then {��ǰ����ֵ�����Ͻ�,�����}
                    begin 
                        error(30); 
                        num := 0 
                    end;
                    val := num
                end;
            {��ǰ��ʶ���Ǳ�����}
            variable : 
                begin 
                    level := lev; {����ñ����Ĺ��̵�Ƕ�ײ���} 
                    adr := dx; {������ַΪ��ǰ�������ݿռ�ջ��} 
                    dx := dx +1; {ջ��ָ���1}
                end;
            proceduree : 
                level := lev; {�����̵�Ƕ�ײ���}
        end
    end
end {enter};

{���� id �ڷ��ű�����}
{position}
function  position(id : alfa) : integer; {����id�ڷ��ű�����}
var  i : integer; 
begin {�ڱ�ʶ�����в��ʶ��id}
    table[0].name := id; {�ڷ��ű�ջ�����·�Ԥ���ʶ��id} 
    i := tx; {���ű�ջ��ָ��}
    {�ӷ��ű�ջ�����²��ʶ��id}
    while table[i].name <> id do 
        i := i-1;
    position := i {���鵽,iΪid�����,����i=0 } 
end {position};

{�����������Ĺ���}
{constdeclaration}
procedure constdeclaration;
begin
    if sym = ident then {��ǰ�Ǻ��ǳ�����}
    begin  
        getsym;
        if sym in [eql, becomes] then {��ǰ�Ǻ��ǵȺŻ�ֵ��}
        begin
            {�����ǰ�Ǻ��Ǹ�ֵ��,�����}
            if sym = becomes then 
                error(1);
                getsym;
            {�Ⱥź����ǳ���}
            if sym = number then 
            begin  
                enter(constant); {��������������ű�}
                getsym
            end
            {�Ⱥź��治�ǳ�������}
            else error(2) 
        end 
        {��ʶ�����ǵȺŻ�ֵ�ų���}
        else error(3) 
    end 
    {����˵����û�г�������ʶ��}
    else error(4) 
end {constdeclaration};

{��������Ҫ���һ��symΪ��ʶ��}
{vardeclaration}
procedure  vardeclaration;
begin
    if sym = ident then {�����ǰ�Ǻ��Ǳ�ʶ��}
    begin  
        enter(variable); {���ñ�����������ű����һ��Ŀ} 
        getsym
    end 
    else error(4) {�������˵��δ���ֱ�ʶ��,�����}
end {vardeclaration};

{�г�PCODE�Ĺ���}
{listcode}
procedure  listcode;
var  i : integer;
begin  {�г������������ɵĴ���}
    for i := cx0 to cx-1 do {cx0: �����̵�һ����������, cx-1: ���������һ����������}
    with code[i] do {��ӡ��i������}
        {i: �������; mnemonic[f]: ��������ַ���; l: ��Բ��(���); a: ��Ե�ַ���������} 
        {��ʽ�����}
        writeln(fout, i:4, mnemonic[f]:7, l:3, a:5)
end {listcode};

{��䴦��Ĺ���}
{statement}
procedure  statement(fsys : symset);
var i, cx1, cx2 : integer;

{������ʽ�Ĺ���}
{expression}
procedure  expression(fsys : symset);
var  addop : symbol;

{������Ĺ���}
{term}
procedure  term(fsys : symset);
var  mulop : symbol;

{�������ӵĴ������}
{factor}
procedure  factor(fsys : symset);
var i : integer;
begin  
    test(facbegsys, fsys, 24); 
    {���Ե�ǰ�ļǺ��Ƿ����ӵĿ�ʼ����, �������, ����һЩ�Ǻ�}
    while sym in facbegsys do 
    {�����ǰ�ļǺ��Ƿ����ӵĿ�ʼ����}
    begin
        {��ǰ�Ǻ��Ǳ�ʶ��}
        if sym = ident then 
        begin
            i := position(id); {����ű�,����id�����}
            if i = 0 then 
                error(11) 
            else
                {���ڷ��ű��в鲻��id, �����, ����,�����¹���}
                with table[i] do
                case kind of 
                    constant : gen(lit, 0, val); {��id�ǳ���, ����ָ��,������valȡ��ջ��}
                    variable : gen(lod, lev-level, adr);{��id�Ǳ���, ����ָ��,���ñ���ȡ��ջ��;
                                                        lev: ��ǰ������ڹ��̵Ĳ��;
                                                        level: ����ñ����Ĺ��̲��;
                                                        adr: ����������̵����ݿռ����Ե�ַ}
                    proceduree : error(21) {��id�ǹ�����, �����}
                end;
                getsym {ȡ��һ�Ǻ�}
        end 
        {��ǰ�Ǻ�������}
        else if sym = number then 
        begin
            if num > amax then {����ֵԽ��,�����}
            begin 
                error(30); 
                num := 0 
            end;
            gen(lit, 0, num); 
            {����һ��ָ��, ������numȡ��ջ��}
            getsym {ȡ��һ�Ǻ�}
        end 
        {�����ǰ�Ǻ���������}
        else if sym = lparen then 
        begin  
            getsym; {ȡ��һ�Ǻ�}
            expression([rparen]+fsys); {������ʽ}
            if sym = rparen then 
                getsym
                {�����ǰ�Ǻ���������, ��ȡ��һ�Ǻ�,�������}
            else error(22)
        end;
        {���Ե�ǰ�Ǻ��Ƿ�ͬ��, �������, ����һЩ�Ǻ�}
        test(fsys, [lparen], 23) 
    end {while}
end {factor};

{��ķ������̿�ʼ}
begin {term}
    factor(fsys+[times, slash]); {�������е�һ������}
    while sym in [times, slash] do 
    {��ǰ�Ǻ��ǡ��ˡ��򡰳�����}
    begin
        mulop := sym; {���������mulop} 
        getsym; {ȡ��һ�Ǻ�}
        factor(fsys+[times, slash]); {����һ������}
        {��mulop�ǡ��ˡ���,����һ���˷�ָ��}
        if mulop = times then 
            gen(opr, 0, 4)
        {����, mulop�ǳ���, ����һ������ָ��}
        else gen(opr, 0, 5)   
    end
end {term};

{���ʽ�ķ������̿�ʼ}
begin {expression}
    {����һ���Ǻ��ǼӺŻ����}
    if sym in [plus, minus] then 
    begin 
        addop := sym;  {��+����-������addop}
        getsym; 
        term(fsys+[plus, minus]); {����һ����}
        if addop = minus then gen(opr, 0, 1)
        {����һ����ǰ�Ǹ���, ����һ���������㡱ָ��}
    end 
    {��һ���ǺŲ��ǼӺŻ����, ����һ����}
    else term(fsys+[plus, minus]);
    {����ǰ�Ǻ��ǼӺŻ����}
    while sym in [plus, minus] do 
    begin
        addop := sym; {��ǰ�������addop} 
        getsym; {ȡ��һ�Ǻ�}
        term(fsys+[plus, minus]); {����һ����}
        {��addop�ǼӺ�, ����һ���ӷ�ָ��}
        if addop = plus then gen(opr, 0, 2)
        {����, addop�Ǽ���, ����һ������ָ��}
        else gen(opr, 0, 3)
    end
end {expression};

{�����������}
{condition}
procedure  condition(fsys : symset);
var  relop : symbol;
begin
    {�����ǰ�Ǻ��ǡ�odd��}
    if sym = oddsym then 
    begin
        getsym;  {ȡ��һ�Ǻ�}
        expression(fsys); {�����������ʽ}
        gen(opr, 0, 6) {����ָ��,�ж����ʽ��ֵ�Ƿ�Ϊ����,��,��ȡ���桱;����, ��ȡ���١�}
    end 
    {�����ǰ�ǺŲ��ǡ�odd��}
    else 
    begin
        expression([eql, neq, lss, gtr, leq, geq] + fsys); 
        {�����������ʽ}
        if not (sym in [eql, neq, lss, leq, gtr, geq]) then
        {�����ǰ�ǺŲ��ǹ�ϵ��, �����; ����,�����¹���}
            error(20)  
        else 
        begin
            relop := sym; {��ϵ������relop} 
            getsym; {ȡ��һ�Ǻ�} 
            expression(fsys); {�����ϵ���ұߵ��������ʽ}
            case relop of
                eql : gen(opr, 0, 8); {����ָ��, �ж��������ʽ��ֵ�Ƿ����}
                neq : gen(opr, 0, 9); {����ָ��, �ж��������ʽ��ֵ�Ƿ񲻵�}
                lss : gen(opr, 0, 10); {����ָ��,�ж�ǰһ���ʽ�Ƿ�С�ں�һ���ʽ}
                geq : gen(opr, 0, 11); {����ָ��,�ж�ǰһ���ʽ�Ƿ���ڵ��ں�һ���ʽ}
                gtr : gen(opr, 0, 12); {����ָ��,�ж�ǰһ���ʽ�Ƿ���ں�һ���ʽ}
                leq : gen(opr, 0, 13); {����ָ��,�ж�ǰһ���ʽ�Ƿ�С�ڵ��ں�һ���ʽ}
            end
        end
    end
end {condition};

begin {statement}
    {����ֵ���}
    if sym = ident then 
    begin  
        {�ڷ��ű��в�id, ����id�ڷ��ű��е����}
        i := position(id); 
        {���ڷ��ű��в鲻��id, �����, ���������¹���}
        if i = 0 then error(11) 
        {����ʶ��id���Ǳ���, �����}
        else if table[i].kind <> variable then
        begin  
            error(12); 
            i := 0; {�ԷǱ�����ֵ}
        end;
        getsym; {ȡ��һ�Ǻ�}
        {����ǰ�Ǹ�ֵ��, ȡ��һ�Ǻ�, �������}
        if sym = becomes then getsym else error(13);
        expression(fsys); {������ʽ}
        if i <> 0 then {����ֵ����ߵı���id�ж���}
            with table[i] do 
                gen(sto, lev-level, adr)
                {����һ������ָ��, ��ջ��(���ʽ)��ֵ�������id��;
                lev: ��ǰ������ڹ��̵Ĳ��;
                level: �������id�Ĺ��̵Ĳ��;
                adr: ����id������̵����ݿռ����Ե�ַ}
    end 

    {������̵������}
    else if sym = callsym then 
    begin  
        getsym; {ȡ��һ�Ǻ�}
        if sym <> ident then error(14) else
        {�����һ�ǺŲ��Ǳ�ʶ��(������),�����,
        ���������¹���}
        begin 
            i := position(id); {����ű�,����id�ڱ��е�λ��}
            if i = 0 then error(11) else
            {����ڷ��ű��в鲻��, �����; ����,�����¹���}
                with table[i] do
                    if kind = proceduree then 
                        {����ڷ��ű���id�ǹ�����}
                        gen(cal, lev-level, adr)
                        {����һ�����̵���ָ��;
                        lev: ��ǰ������ڹ��̵Ĳ��
                        level: ���������id�Ĳ��;
                        adr: ����id�Ĵ����е�һ��ָ��ĵ�ַ}
                    else error(15); {��id���ǹ�����,�����}
                    getsym {ȡ��һ�Ǻ�}
        end
    end 

    {�����������}
    else if sym = ifsym then 
    begin
        getsym; {ȡ��һ�Ǻ�} 
        condition([thensym, dosym]+fsys); {�����������ʽ}
        if sym = thensym then getsym else error(16); {�����ǰ�Ǻ��ǡ�then��,��ȡ��һ�Ǻ�; �������}
        cx1 := cx; {cx1��¼��һ����ĵ�ַ} 
        gen(jpc, 0, 0); {����ָ��,���ʽΪ���١�ת��ĳ��ַ(����),����˳��ִ��}
        statement(fsys); {����һ�����}
        code[cx1].a := cx {����һ��ָ��ĵ�ַ��������jpcָ���ַ��}
    end 

    {�����������}
    else if sym = beginsym then 
    begin
        getsym;  
        statement([semicolon, endsym]+fsys);{ȡ��һ�Ǻ�, �����һ�����}
        {�����ǰ�Ǻ��ǷֺŻ����Ŀ�ʼ����,�������¹���}
        while sym in [semicolon]+statbegsys do 
        begin
            if sym = semicolon then getsym else error(10); {�����ǰ�Ǻ��Ƿֺ�,��ȡ��һ�Ǻ�, �������}
            statement([semicolon, endsym]+fsys) {������һ�����}
        end;
        if sym = endsym then getsym else error(17) {�����ǰ�Ǻ��ǡ�end��,��ȡ��һ�Ǻ�,�������}
    end 

    {����ѭ�����}
    else if sym = whilesym then 
    begin
        cx1 := cx; {cx1��¼��һָ���ַ,���������ʽ�ĵ�һ������ĵ�ַ} 
        getsym; {ȡ��һ�Ǻ�}
        condition([dosym]+fsys); {�����������ʽ}
        cx2 := cx; {��¼��һָ��ĵ�ַ} 
        gen(jpc, 0, 0); {����һ��ָ��,���ʽΪ���١�ת��ĳ��ַ(������), ����˳��ִ��}
        if sym = dosym then getsym else error(18);{�����ǰ�Ǻ��ǡ�do��,��ȡ��һ�Ǻ�, �������}
        statement(fsys); {����do����������}
        gen(jmp, 0, cx1); {����������ת��ָ��, ת�Ƶ���while������������ʽ�Ĵ���ĵ�һ��ָ�} 
        code[cx2].a := cx {����һָ���ַ���ǰ�����ɵ�jpcָ��ĵ�ַ��}
    end

    {����read�ؼ���}
    else if sym = readsym then
    begin
        getsym; {��ȡ��һ��sym����}

        {read�ĺ���Ӧ�ý�������}
        if sym = lparen then
        begin
            {ѭ����ʼ��ֱ�����Ų��Ƕ���}
            repeat
                getsym;
                {�����һ��sym�Ǳ�ʶ��}
                if sym = ident then
                begin
                    i := position(id); {��¼��ǰ�����ڷ��ű��е�λ��}
                    if i = 0 then error(11) {���iΪ0,˵�����ű���û���ҵ�id��Ӧ�ķ��ţ���11����}
                    
                    {����ҵ���,���÷��ŵ����Ͳ��Ǳ���}
                    else if table[i].kind <> variable then
                    begin
                        error(12);
                        i := 0
                    end

                    {����Ǳ�������, ����һ��redָ���ȡ����}
                    else with table[i] do
                        gen(red, lev-level, adr)
                end

                {��������ź�����Ĳ��Ǳ�ʶ��,��4�Ŵ���}
                else error(4);
                getsym;
            until sym <> comma
        end

        else error(40);

        if sym <> rparen then error(22);

        getsym
    end

    {����write�ؼ���}
    else if sym = writesym then
    begin
        getsym;
        if sym = lparen then
        begin
            {ѭ����ʼ��ֱ����ȡ����sym���Ƕ���}
            repeat
                getsym;
                expression([rparen, comma]+fsys);{���������еı��ʽ}
                gen(wrt, 0, 0);{����Ӧwrt, �����������}
            until sym <> comma;

            if sym <> rparen then error(22);
            getsym
        end

        else error(40)
    end;
    
    test(fsys, [ ], 19) {������һ�Ǻ��Ƿ�����, �������, ����һЩ�Ǻ�}
end {statement};

begin {block}
    dx := 3; {���������ݿռ�ջ��ָ��} 
    tx0 := tx; {��ʶ����ĳ���(��ǰָ��)} 
    table[tx].adr := cx; {���������ĵ�ַ, ����һ��ָ������}
    gen(jmp, 0, 0); {����һ��ת��ָ��}
    if lev > levmax then error(32);
    {�����ǰ���̲��>������, �����}
    repeat
        if sym = constsym then {������˵�����}
        begin  
            getsym;
            repeat 
                constdeclaration; {����һ������˵��}
                while sym = comma do {�����ǰ�Ǻ��Ƕ���}
                    begin 
                        getsym; 
                        constdeclaration 
                    end; {������һ������˵��}
                if sym = semicolon then getsym else error(5)
                {�����ǰ�Ǻ��Ƿֺ�,����˵���Ѵ�����, �������}
            until sym <> ident 
        {����һЩ�Ǻ�, ֱ����ǰ�ǺŲ��Ǳ�ʶ��(����ʱ���õ�)}
        end;
        {��ǰ�Ǻ��Ǳ���˵����俪ʼ����}
        if sym = varsym then 
        begin  getsym;
            repeat 
                vardeclaration; {����һ������˵��}
                while sym = comma do {�����ǰ�Ǻ��Ƕ���}
                    begin  
                        getsym;  
                        vardeclaration  
                    end; 
                    {������һ������˵��}
                if sym = semicolon then getsym else error(5)
                {�����ǰ�Ǻ��Ƿֺ�,�����˵���Ѵ�����, �������}
            until sym <> ident; 
            {����һЩ�Ǻ�, ֱ����ǰ�ǺŲ��Ǳ�ʶ��(����ʱ���õ�)}
        end;
        {�������˵��}
        while sym = procsym do 
            begin  getsym;
            if sym = ident then {�����ǰ�Ǻ��ǹ�����}
            begin  
                enter(proceduree);  
                getsym  
            end 
            {�ѹ�����������ű�}
            else error(4); {����, ȱ�ٹ���������}
            if sym = semicolon then getsym else error(5);
            {��ǰ�Ǻ��Ƿֺ�, ��ȡ��һ�Ǻ�,����,��������©���ֺų���}
            block(lev+1, tx, [semicolon]+fsys); {���������}
            {lev+1: ����Ƕ�ײ�����1; tx: ���ű�ǰջ��ָ��,Ҳ���¹��̷��ű���ʼλ��; [semicolon]+fsys: �����忪ʼ��ĩβ���ż�}
            if sym = semicolon then {�����ǰ�Ǻ��Ƿֺ�}
            begin  
                getsym; {ȡ��һ�Ǻ�}
                test(statbegsys+[ident, procsym], fsys, 6)
                {���Ե�ǰ�Ǻ��Ƿ���俪ʼ���Ż����˵����ʼ����,
                ���򱨸����6, ������һЩ�Ǻ�}
            end
            else error(5) {�����ǰ�ǺŲ��Ƿֺ�,�����}
        end; {while}
        test(statbegsys+[ident], declbegsys, 7)
        {��⵱ǰ�Ǻ��Ƿ���俪ʼ����, �������, ������һЩ
        �Ǻ�}
    until not (sym in declbegsys); 
    {�ص�˵�����Ĵ���(����ʱ����),ֱ����ǰ�ǺŲ���˵�����
    �Ŀ�ʼ����}
    code[table[tx0].adr].a := cx;  {table[tx0].adr�Ǳ��������ĵ�1��
    ����(jmp, 0, 0)�ĵ�ַ,����伴�ǽ���һ����(���������ĵ�
    1������)�ĵ�ַ�����jmpָ����,��(jmp, 0, cx)}
    with table[tx0] do {���������ĵ�1������ĵ�ַ��Ϊ��һָ��
        ��ַcx}
    begin  
        adr := cx; {���뿪ʼ��ַ}
    end;
    cx0 := cx; {cx0��¼��ʼ�����ַ}
    gen(int, 0, dx); {����һ��ָ��, ��ջ��Ϊ�������������ݿռ�}
    statement([semicolon, endsym]+fsys); {����һ�����}
    gen(opr, 0, 0); {���ɷ���ָ��}
    test(fsys, [ ], 8); {���Թ���������ķ����Ƿ�����,�������}
    listcode; {��ӡ�����̵��м��������}
end  {block};
//-----------------------------------------------


//-----------------------------------------------
{����ִ�г���}
{interpret}
procedure  interpret;
const  stacksize = 500; {����ʱ���ݿռ�(ջ)���Ͻ�}
var  p, b, t : integer; {�����ַ�Ĵ���, ����ַ�Ĵ���,ջ����ַ�Ĵ���}
     i : instruction; {ָ��Ĵ���}
     s : array [1..stacksize] of integer; {���ݴ洢ջ}

{�������ַ�ĺ���}
{base}
function  base(l : integer) : integer;
var  b1 : integer;
begin
  b1 := b; {˳��̬������Ϊl�����Ļ���ַ}
  while l > 0 do
  begin  
    b1 := s[b1];  
    l := l-1 
  end;
  base := b1
end {base};

begin  
    writeln(fout, 'START PL/0');
    t := 0; {ջ����ַ�Ĵ���}
    b := 1; {����ַ�Ĵ���}
    p := 0; {�����ַ�Ĵ���}
    {��������������ݿռ�ջ������Ԥ��������Ԫ}
    s[1] := 0;  
    s[2] := 0;  
    s[3] := 0; 
    {ÿ����������ʱ�����ݿռ��ǰ������Ԫ��:SL, DL, RA;
    SL: ָ�򱾹��̾�ֱ̬�������̵�SL��Ԫ;
    DL: ָ����ñ����̵Ĺ��̵��������ݿռ�ĵ�һ����Ԫ;
    RA: ���ص�ַ }
    repeat
        i := code[p]; {iȡ�����ַ�Ĵ���pָʾ�ĵ�ǰָ��}
        p := p+1; {�����ַ�Ĵ���p��1,ָ����һ��ָ��}
        with i do
            case f of
                lit : 
                    begin {��ǰָ����ȡ����ָ��(lit, 0, a)}
                        t := t+1;  
                        s[t] := a
                    end;
                {ջ��ָ���1, �ѳ���aȡ��ջ��}
                opr : 
                    case a of {��ǰָ��������ָ��(opr, 0, a)}
                        0 : 
                            begin {a=0ʱ,�Ƿ��ص��ù���ָ��}
                                t := b-1; {�ָ����ù���ջ��} 
                                p := s[t+3]; {�����ַ�Ĵ���pȡ���ص�ַ} 
                                b := s[t+2]; 
                                {����ַ�Ĵ���bָ����ù��̵Ļ���ַ}
                            end;
                        1 : s[t] := -s[t]; {һԪ������, ջ��Ԫ�ص�ֵ����}
                        2 : 
                            begin {�ӷ�}
                            t := t-1;  
                            s[t] := s[t] + s[t+1] 
                            end;
                        3 : 
                            begin {����}
                                t := t-1;  
                                s[t] := s[t]-s[t+1]
                            end;
                        4 : 
                            begin {�˷�}
                                t := t-1;  
                                s[t] := s[t] * s[t+1]
                            end;
                        5 : 
                            begin {��������}
                                t := t-1;  
                                s[t] := s[t] div s[t+1]
                            end;
                        6 : 
                            s[t] := ord(odd(s[t])); 
                            {��s[t]�Ƿ�����, ����s[t]=1, ����s[t]=0}
                        8 : 
                            begin  
                            t := t-1;
                            s[t] := ord(s[t] = s[t+1])
                            end; 
                            {���������ʽ��ֵ�Ƿ����,����s[t]=1, ����s[t]=0}
                        9: 
                            begin  
                                t := t-1;
                                s[t] := ord(s[t] <> s[t+1])
                            end; {���������ʽ��ֵ�Ƿ񲻵�,����s[t]=1, ����s[t]=0}
                        10 : 
                            begin  
                                t := t-1;
                                s[t] := ord(s[t] < s[t+1])
                            end; {��ǰһ���ʽ�Ƿ�С�ں�һ���ʽ,����s[t]=1, ����s[t]=0}
                        11: 
                            begin  
                                t := t-1;
                                s[t] := ord(s[t] >= s[t+1])
                            end; {��ǰһ���ʽ�Ƿ���ڻ���ں�һ���ʽ, ����s[t]=1, ����s[t]=0}
                        12 : 
                            begin  
                                t := t-1;
                                s[t] := ord(s[t] > s[t+1])
                            end; {��ǰһ���ʽ�Ƿ���ں�һ���ʽ, ����s[t]=1, ����s[t]=0}
                        13 : 
                            begin  
                                t := t-1;
                                s[t] := ord(s[t] <= s[t+1])
                            end; {��ǰһ���ʽ�Ƿ�С�ڻ���ں�һ���ʽ, ����s[t]=1, ����s[t]=0}
                    end;
                lod : 
                    begin {��ǰָ����ȡ����ָ��(lod, l, a)}
                        t := t + 1;  
                        s[t] := s[base(l) + a]
                        {ջ��ָ���1, ���ݾ�̬��SL,�����Ϊl,��Ե�ַ
                        Ϊa�ı���ֵȡ��ջ��}
                    end;
                sto : 
                    begin {��ǰָ���Ǳ������ֵ(sto, l, a)ָ��}
                        s[base(l) + a] := s[t]; 
                        //writeln(fout, s[t] : 4); 
                        {���ݾ�̬��SL,��ջ����ֵ������Ϊl,��Ե�ַΪa�ı�����}
                        t := t-1 {ջ��ָ���1}
                    end;
                cal : 
                    begin {��ǰָ����(cal, l, a)}
                    {Ϊ�����ù������ݿռ佨����������}
                        s[t+1] := base( l ); 
                        {���ݲ��l�ҵ������̵ľ�ֱ̬�������̵����ݿռ��SL��Ԫ,�����ַ���뱾�����µ����ݿռ��SL��Ԫ}
                        s[t+2] := b; 
                        {���ù��̵����ݿռ����ʼ��ַ���뱾����DL��Ԫ}
                        s[t+3] := p;
                        {���ù���calָ�����һ���ĵ�ַ���뱾����RA��Ԫ}
                        b := t+1; {bָ�򱻵��ù����µ����ݿռ���ʼ��ַ} 
                        p := a {ָ���ַ�Ĵ洢��ָ�򱻵��ù��̵ĵ�ַa}
                    end;
                int : t := t + a; 
                {����ǰָ����(int, 0, a), �����ݿռ�ջ������a��С�Ŀռ�}
                jmp : p := a; 
                {����ǰָ����(jmp, 0, a), �����ת����ַaִ��}
                jpc : 
                    begin {��ǰָ����(jpc, 0, a)}
                        if s[t] = 0 then p := a;
                        {�����ǰ������Ϊ���١�(0), ����ת����ַaִ��, ����˳��ִ��}
                        t := t-1 {����ջ��ָ���1}
                    end;
                red :
                    begin
                        writeln('please input:');
                        readln(s[base(l)+a]);{��һ������,���뵽���l��,����ƫ��Ϊa������ջ�е����ݵ���Ϣ}
                    end;
                wrt : 
                    begin
                        writeln(fout, s[t]); {���ջ������Ϣ}
                        t := t + 1 {ջ������}
                    end
            end {with, case}
    until p = 0; 
    {����һֱִ�е�pȡ�����������ķ��ص�ַ0ʱΪֹ}
    write(fout, 'END PL/0');
end {interpret};
//------------------------------------------------



begin  {������}
    assign(fin,paramstr(1));
    assign(fout,paramstr(2));	{�������в���str������ֵ���ļ�����}
    reset(fin);
    rewrite(fout);	{����������ļ�}


    For ch := 'A' To ';' Do ssym[ch] := nul;

    //��ASCII��˳��
    word[1] := 'begin        ';
    word[2] := 'call         ';
    word[3] := 'const        ';
    word[4] := 'do           ';
    word[5] := 'end          ';
    word[6] := 'if           ';
    word[7] := 'odd          ';
    word[8] := 'procedure    ';
    word[9] := 'read         ';
    word[10] := 'then         ';
    word[11] := 'var          ';
    word[12] := 'while        ';
    word[13] := 'write        ';

    //�����ֱ���ÿһ�������ֶ�Ӧ�� symbol ����
    wsym[1] := beginsym;
    wsym[2] := callsym;
    wsym[3] := constsym;
    wsym[4] := dosym;
    wsym[5] := endsym;
    wsym[6] := ifsym;
    wsym[7] := oddsym;
    wsym[8] := procsym;
    wsym[9] :=  readsym;
    wsym[10] := thensym;
    wsym[11] := varsym;
    wsym[12] := whilesym;
    wsym[13] := writesym;

    //���ַ��Ŷ�Ӧ�� symbol ���ͱ�
    ssym['+'] := plus;
    ssym['-'] := minus;
    ssym['*'] := times;
    ssym['/'] := slash;
    ssym['('] := lparen;
    ssym[')'] := rparen;
    ssym['='] := eql;
    ssym[','] := comma;
    ssym['.'] := period;
    ssym['<'] := lss;
    ssym['>'] := gtr;
    ssym[';'] := semicolon;

    //�� PCODE ָ�����Ƿ���
    mnemonic[lit] := 'LIT  ';
    mnemonic[opr] := 'OPR  ';
    mnemonic[lod] := 'LOD  ';
    mnemonic[sto] := 'STO  ';
    mnemonic[cal] := 'CAL  ';
    mnemonic[int] := 'INT  ';
    mnemonic[jmp] := 'JMP  ';
    mnemonic[jpc] := 'JPC  ';
    mnemonic[red] := 'RED  ';
    mnemonic[wrt] := 'WRT  ';
    
    declbegsys := [constsym, varsym, procsym];{������ʼ����}
    statbegsys := [beginsym, callsym, ifsym, whilesym];{���ʽ��ʼ����}
    facbegsys := [ident, number, lparen];{�ʼ���ż���}

    //page(output); 

    {ȫ�ֱ����ĳ�ʼ��}
    err := 0; {���ִ���ĸ���}
    cc := 0; {��ǰ���������ַ���ָ��} 
    cx := 0; {��������ĵ�ǰָ��} 
    ll := 0; {���뵱ǰ�еĳ���} 
    ch := ' '; {��ǰ������ַ�}
    kk := al; {��ʶ���ĳ���}

    getsym; {�״ε���getsym()���дʷ�����,ȡ��һ���Ǻ�}
    block(0, 0, [period]+declbegsys+statbegsys); {���������,����block()���̣������ʷ��������﷨����}

    if sym <> period then error(9);{�����ǰ�ǺŲ��Ǿ��, �����}
    if err = 0 then interpret{��������޴���, �����ִ���м����(����interpret()����ִ��Ŀ�����)}
    else write('ERRORS IN PL/0 PROGRAM');

    //99 : writeln
    writeln;
    close(fin);
    close(fout);
end.