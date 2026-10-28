unit menu;

interface

uses graph,wincrt,tablero,figuras,interfaz,movimiento,SysUtils;

const fondoMenu=10;
type
puntos=array [1..6] of integer; //array de coordenadas para rellenar el triangulo

procedure inicio();

implementation


procedure jugar ();
//inicia el juego tetris.
var key:char;
	P,SP:figuras.pieza; //pieza y sig pieza
	Grilla:tablero.grilla;	//mapa del juego
	tiempo, tiempoActual: Qword;	//numeros sin signo
	nivel,lineasTotales:integer;
	score:longint;
	intervalo:integer;
	gameOver:boolean;
	blocks:integer;

	begin					//tablero principal 10*20;
		gameOver:=false;

		score:=0;
		nivel:=1;
		lineasTotales:=0;
		blocks:=0;
			
		//iniciamos la inerfaz de juego	
		interfaz.iniciarJuego(Grilla);
		figuras.elegirPieza(P);			//se elije la primera pieza
		figuras.elegirPieza(SP);		//se elije la segunda pieza
		figuras.crearPiezaInicial(P,Grilla,gameOver);	//se crea la primera pieza en la pos central superior
		panelPiezaSiguiente(SP);		//creo la pieza siguiente en la interfaz
		tiempo:=getTickCount64;
		
		while (not gameOver) do begin
			tiempoActual:=GetTickCount64;
			
			if keypressed then begin
				key:=readkey;
				key:=lowerCase(key);
				if ( (key='a') or (key='d') or (key='s') or (key='w') or (key=#27{esc}) ) then
					movimiento.registrarAccion(key,P,SP,grilla,nivel,score,lineasTotales,blocks,gameOver);
			end;
			
			intervalo:=1100 - nivel*100;    //al principio queda en 1000ms
				
			if (intervalo<100) then		//ajusto el intervalo para que no quede en 0 o negativo
				intervalo:=100;
						
			if ((tiempoActual - tiempo) >= intervalo) then begin
				key:='t';				//se envia t para que caiga por segundo
				movimiento.registrarAccion(key, P, SP, Grilla,nivel,score,lineasTotales,blocks,gameOver);
				tiempo:=tiempoActual;
			end;
		end;
	end;


procedure iniciarGraficos();
//configura y da inicio a los graficos
	var gd,gm:integer;	//puestos para la inferfaz grafica
	begin
		gd:=detect;
		Initgraph(gd,gm,''); //iniciamos interfaz
	end;


procedure marco (X1,X2,Y1,Y2:integer);
//crea el cuadro donde estaran las opciones
	begin
		setFillStyle(solidFill, fondoMenu);
		bar(X1,Y1,X2,Y2+50);
		setColor(cyan);
		outTextXY (X1 + (X2-X1) div 2 - textwidth('Tetris') div 2, Y1-50 ,'Tetris');
	end;
	
	
procedure crearBoton(X1,X2,Y1,Y2:integer;text:string);
//crea los botones del menu
	begin
		setFillStyle(solidFill, 8);	//gris oscuro
		bar (X1,Y1,X2,Y2);		//boton
		setcolor(lightgray);
		rectangle (X1,Y1,X2,Y2);	//borde
		
		outTextXY(  X1+ (X2-X1) div 2 - textwidth(text) div 2, //posiciona el eje X a la mitad del cuadro
					Y1+ (Y2-Y1) div 2 - textheight(text) div 2,	//posiciona el eje Y a la mitad del cuadro
					text);
	end;


procedure posicionTriangulo (var P:puntos;X1,Y1:integer);
//se saca la posicion del triangulo con respecto al primer boton
	begin
		P[1]:=X1-40; P[2]:=Y1+17;		//punto superior (1,2)
		P[3]:=X1-40; P[4]:=Y1+37;		//punto inferior (3.4)
		P[5]:=X1-10; P[6]:=Y1+27;		//punto esquina  (5,6)	//perfecta
	end;


procedure crearTriangulo (P:puntos);
//dibuja el triangulo en las opciones del menu
	begin
		setColor(fondomenu); //el marco desaparece al tener el mismo color que el fondo
		setFillStyle(solidFill, blue);
		FillPoly(3, P);	//se rellenas los puntos del vector P, creando el triangulo
	end;


procedure borrarTriangulo (P:puntos);
//borra el triangulo en la posicion actual
	begin
		setFillStyle(solidFill, fondoMenu);
		FillPoly(3, P);	//relleno de poligonos (opcion 3), en las variables de P
	end;


procedure bajarMenu (var P:puntos; distancia:integer);
//baja el triangulo una posicion del menu
var i:integer;
	begin
		borrarTriangulo(P);
		
		for i:=1 to 6 do	//desplazo los pixeles de las posiciones pares (eje Y) hacia abajo (suma)
			if (i mod 2 = 0) then
				P[i]:=P[i]+distancia;
		crearTriangulo (P)
	end;


procedure subirMenu (var P:puntos; distancia:integer);
//sube el triangulo una posicion del menu
var i:integer;
	begin
		borrarTriangulo(P);
		
		for i:=1 to 6 do	//desplazo los pixeles de las posiciones pares (eje Y) hacia arriba (resta)
			if (i mod 2 = 0) then
				P[i]:=P[i]-distancia;
		crearTriangulo (P)
	end;


procedure interfazMenu(var P:puntos;distancia:integer);
//crea los botones del menu y declara el vector de posicione del triangulo de asignacion
var X1,X2,Y1,Y2:integer;
	begin
		setColor(white);
		settextstyle(0,0,3); //tamaño de letra
		
		X1:=pixelX(3);			//
		Y1:=pixelY(6);			//
		X2:=pixelX(12);			//coordenadas base
		Y2:=pixelY(12);			//

		marco(X1,X2,Y1,Y2);
		
		X1:=X1+50;	//un valor positivo la reduce
		X2:=X2-50;	//un valor posivio la agranda
		Y1:=Y1+20;	//un valor posivio la reduce
		Y2:=Y2-110;	//un valor positivo la agranda
		
		posicionTriangulo(P,X1,Y1);		//asignamos los pixeles al vector del triangulo
		
		crearBoton(X1,X2,Y1,Y2,'Jugar');
		
		Y1:=Y1+distancia;
		Y2:=Y2+distancia;


		crearBoton(X1,X2,Y1,Y2,'Score');
		
		Y1:=Y1+distancia;
		Y2:=Y2+distancia;		

		crearBoton(X1,X2,Y1,Y2,'Exit');
		
		crearTriangulo(P);
		////triangulo actualmente apunta a 'Jugar'.
	end;

	
procedure accion (var ok:boolean; P:puntos;distancia:integer);
//desplaza el triangulo entre las 3 opciones (Play, score, exit) y determina la accion
var opcion:integer;key:char;
	begin
		opcion:=1;
		while (ok) do begin
			key:=readkey;
			key:=lowercase(key);
			if (key='s') then begin		//bajar menu
				if (opcion<3) then begin
					bajarMenu (P,distancia);
					opcion:=opcion+1;
				end;
			end
			else
			if (key='w') then begin	//subir menu
				if (opcion>1) then begin //controlamos que no se desborde o tome un valor inaccesible
					subirMenu(P,distancia);
					opcion:=opcion-1;
				end;
			end
			else
			if (key=#13) then //ENTER
				case opcion of
					1:begin
						//jugar
						Jugar();
						//al salir de jugar se vuelve al menu
						closegraph;
						iniciarGraficos();
						interfazMenu(P,distancia);
					end;
					//2:begin
						//score
					//end;
					3:begin
					//salir
						ok:=false;
					end;
				end;
		end;
	end;

procedure inicio();
var P:puntos; distancia:integer;
	ok:boolean;
	begin
		ok:=true;
		distancia:=70; 				//pixeles de distancia para crear los cuadros de la interfaz
		iniciarGraficos();			//inicio los graficos
		interfazMenu(P,distancia);	//creo la interfaz del menu
		accion(ok,P,distancia);		//elijo una opcion
		closegraph;
	end;
end.
