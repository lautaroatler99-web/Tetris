unit figuras;

interface

uses graph,crt,interfaz;


const
max=4;
type
	fig=array [1..max,1..max] of boolean;
	
	coordenada=record
		X:integer;
		Y:integer;
	end;
	
	pieza=record
		posValida:fig;
		posBloque:array[1..max,1..max] of coordenada; //guarda las coordenadas de la grilla de cada bloque (1..22 , 1..12)
		colorBorde:integer;
		colorRelleno:integer;
		rotacion:boolean;
		tipo:string;
	end;

	
procedure crearFigura(var P:pieza; var G:interfaz.grilla);

procedure dibujarPieza(P:pieza;G:interfaz.grilla);

procedure inicializarPieza (var P:pieza);

implementation

procedure figL(var f:fig;var rotacion:boolean;var tipo:string);
//figura L
	begin
		//X,Y
		f[1,3]:=true;	//		[]
		f[2,3]:=true;	//		[]
		f[3,3]:=true;	//		[][]
		f[3,4]:=true;
		rotacion:=true;
		tipo:='figL';
	end;

procedure figInvertedL (var f:fig;var rotacion:boolean;var tipo:string);
//figura L invertida
	begin
		//X,Y
		f[1,3]:=true;	//		  []
		f[2,3]:=true;	//		  []
		f[3,3]:=true;	//	    [][]
		f[3,2]:=true;
		rotacion:=true;
		tipo:='figInvertedL';
	end;

procedure figPlus (var f:fig;var rotacion:boolean;var tipo:string);
//figura cruz
	begin
		//X,Y
		f[1,3]:=true;	//		[]
		f[2,3]:=true;	//	  [][][]
		f[3,3]:=true;	//		[]
		f[2,4]:=true;
		f[2,2]:=true;
		rotacion:=false;
		tipo:='figPlus';
	end;
	
procedure figI (var f:fig;var rotacion:boolean;var tipo:string);
//figura en I
	begin
		//X,Y
		f[1,3]:=true;	//		[]
		f[2,3]:=true;	//		[]
		f[3,3]:=true;	//		[]
		f[4,3]:=true;	//		[]
		rotacion:=true;
		tipo:='figI';
	end;
	
procedure figT (var f:fig;var rotacion:boolean;var tipo:string);
//figura en T
	begin
		//X,Y
		f[1,2]:=true;
		f[1,3]:=true;	//	  [][][]
		f[1,4]:=true;	//		[]
		f[2,3]:=true;
		rotacion:=true;
		tipo:='figT';
	end;
	
procedure figS (var f:fig;var rotacion:boolean;var tipo:string);
//sigura en S
	begin
		//X,Y
		f[1,4]:=true;
		f[1,3]:=true;	//	 	[][]
		f[2,3]:=true;	//	  [][]
		f[2,2]:=true;
		rotacion:=true;
		tipo:='figS';
	end;
	
procedure figInvertedS (var f:fig;var rotacion:boolean;var tipo:string);
//figura en S invertida
	begin
		//X,Y	
		f[1,2]:=true;
		f[1,3]:=true;	//	  [][]
		f[2,3]:=true;	//	    [][]
		f[2,4]:=true;
		rotacion:=true;
		tipo:='figInvertedS';
	end;

procedure figQuad (var f:fig;var rotacion:boolean;var tipo:string);
//figura en cuadrado
	begin
		//X,Y
		f[1,2]:=true;
		f[1,3]:=true;	//	[][]
		f[2,2]:=true;	//	[][]
		f[2,3]:=true;
		rotacion:=false;
		tipo:='figQuad';
	end;
	
procedure figPoint (var f:fig;var rotacion:boolean;var tipo:string);
//figura en punto
	begin
		//X,Y
		f[2,3]:=true;	//	[]
		rotacion:=false;
		tipo:='figPoint';
	end;
	
	
procedure inicializarPieza (var P:pieza);
//inicializa la matriz 4x4 de la pieza en 0
	var i,j:integer;
	begin
		for i:=1 to max do
			for j:=1 to max do begin
				P.posValida[i,j]:=false;
				P.posBloque[i,j].X:=0;
				P.posBloque[i,j].Y:=0;
			end;
		P.rotacion:=false;
		P.tipo:='';
	end;

procedure elegirFigura(var P:pieza);
//elije aleatoriamente la pieza
var figura:integer;
	begin
		figura:=(random(9)+1); //hay un total de 9 figuras
		case figura of
			1:figL (P.posValida,P.rotacion,P.tipo);
			2:figInvertedL (P.posValida,P.rotacion,P.tipo);
			3:figPlus (P.posValida,P.rotacion,P.tipo);
			4:figI (P.posValida,P.rotacion,P.tipo);
			5:figT (P.posValida,P.rotacion,P.tipo);
			6:figS (P.posValida,P.rotacion,P.tipo);
			7:figInvertedS (P.posValida,P.rotacion,P.tipo);
			8:figQuad (P.posValida,P.rotacion,P.tipo);
			9:figPoint (P.posValida,P.rotacion,P.tipo);
		end;
	end;
	
	
procedure elegirColor(var p:pieza);
//elije el color entre los 6 colores predominantes de pascal
//1=azul/ 2=verde / 3=celeste /4=rojo /5=violeta /6=marron.
//pascal cuenta con 16 colores y estan ordenados de manera que la distancia
//entre un color y su version clara es de 8 unidades.
//Ej: el color rojo es 4 y el color rojo claro es el 12 (4+8)

	var color,lightColor:integer;
	begin
		color:=random(6)+1;		//sumo 1 para que el rango se mantenga entre 1 y 6 ya que el 0 es el color negro
		lightColor:=color+8;	//al sumar 8, se consigue la version clara del color
		
		P.colorRelleno:=color;
		P.colorBorde:=lightColor;
	end;

procedure dibujarPieza(P:pieza;G:interfaz.grilla);
//dibuja la pieza
var i,j,tam,x,y:integer;
	begin
		tam:=30;//tamaño de cada cuadro

		for i:=1 to max do 
			for j:=1 to max do 
				if (P.posValida[i,j]) then begin
					x:=G.pos[P.posBloque[i,j].Y , P.posBloque[i,j].X].X;
					y:=G.pos[P.posBloque[i,j].Y , P.posBloque[i,j].X].Y;
					
					bar(x+1,y+1,x+tam-1,y+tam-1);
					rectangle(x+1,y+1,x+tam-1,y+tam-1);
				end;
	end;


procedure crearPiezaInicial(var P:pieza; var G:interfaz.grilla);
//crea la pieza en su primera aparicion, posicionandola en el centro superior de la grilla (2,5)
var i,j,tam,fila,columna:integer;
x,y:integer;
	begin
		tam:=30;//tamaño de cada cuadro
		
		SetFillStyle(SolidFill,P.colorRelleno);
		setcolor(P.colorBorde);
		for i:=1 to max do 
			for j:=1 to max do 
				if (P.posValida[i,j]) then begin
					
					fila:=1+i;	//Le sumo 1 (i) para que quede empiece en 2
					columna:=4 + j; //Le sumo 1 (j) para que empiece en la columna 5
					
					x:=interfaz.pixelX(columna); 	//fila en pixeles
					y:=interfaz.pixelY(fila);		//columna en pixeles
					
					P.posBloque[i,j].X:=columna; //guardo la coordenada (2..11) en la grilla
					P.posBloque[i,j].Y:=fila; //

					G.panel[fila,columna]:=true; //se valida la celda para marcarla como "ocupada"
					
					G.pos[fila,columna].X := x;		//guardo los pixeles
					G.pos[fila,columna].Y := y;		//
					
					G.color[fila,columna].colorRelleno:=P.colorRelleno;
					G.color[fila,columna].colorBorde:=P.colorBorde;

					bar(x+1,y+1,x+tam-1,y+tam-1);		//imprimo el bloque
					rectangle(x+1,y+1,x+tam-1,y+tam-1); //imprimo su borde
				end;
	end;


procedure crearFigura(var P:pieza;var G:grilla);
	begin
		inicializarPieza(P); //pone todos los campos en false
		elegirFigura(P); //se elije una figura aleatoria
		elegirColor(P); //se elije un color aleatorio
		crearPiezaInicial(P,G); //crea figura inicial
	end;
end.
