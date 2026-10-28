unit menu;

interface

uses graph,wincrt,crt,tablero;

function inicio():boolean;
procedure terminar();
implementation

procedure terminar();
	begin
		writeln('se termino el game');
	end;
	
function opcion (var op:integer):boolean;
	begin
		readln(op);
		while ((op<1) or (op>3)) do begin
			writeln('Elija una opcion valida');
			readln(op);
		end;
		case op of
			1:opcion:=true;
			2:opcion:=false;{puntuacion}
			3:opcion:=false {salir}
		end;
		
	end;

procedure marco (X1,X2,Y1,Y2:integer);
//crea el cuadro donde estaran las opciones
	begin
		setFillStyle(solidFill, 10);
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
	
procedure interfazMenu();
var X1,X2,Y1,Y2:integer;
	distancia:integer;
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

		distancia:=70;	//distancia entre cada boton
		
		crearBoton(X1,X2,Y1,Y2,'Jugar');
		
		Y1:=Y1+distancia;
		Y2:=Y2+distancia;


		crearBoton(X1,X2,Y1,Y2,'Score');
		
		Y1:=Y1+distancia;
		Y2:=Y2+distancia;		

		crearBoton(X1,X2,Y1,Y2,'Exit');
		
	end;

procedure iniciarGraficos();
	var gd,gm:integer;	//puestos para la inferfaz grafica
	begin
		gd:=detect;
		Initgraph(gd,gm,''); //iniciamos interfaz
	end;
	

function inicio():boolean;
var op:integer;

	begin
		iniciarGraficos();
		interfazMenu();
		
		writeln('1.jugar');
		writeln('2.puntuacion');
		writeln('3.salir');
		inicio:=opcion(op);
	end;
end.
