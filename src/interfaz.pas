unit interfaz;

interface


//las dimensiones del cuadro es X=800-1000, Y=200-800, tamaño=30;

uses graph,crt;

type
	arrayGrilla=array [1..22,1..12] of boolean;
	
	coordenada=record //coordenadas en pixeles de cada celda
		X:integer;
		Y:integer;
	end;
	
	colores=record
		colorBorde:integer;
		colorRelleno:integer;
	end;
	
	grilla=record
		panel:arrayGrilla;	//se usa para validar posiciones
		pos:array[1..22,1..12] of coordenada; //(X,Y) en pixeles
		color:array[1..22,1..12] of colores; //colores de cada celda
	end;
	
function GrillaX():integer;
function GrillaY():integer;
function pixelX(X:integer):integer;
function pixelY(Y:integer):integer;

procedure iniciarJuego(var G:grilla);

procedure pausa ();

implementation

const 
tam=30;	//tamaño absoluto de cada bloque
	
function grillaX ():integer;
	//divide el total de los pixeles del eje X en bloques de 30,
	// y lo divide a la mitad retornarno su centro de pantalla.
	begin
		grillaX:=( (getmaxX div tam) div 2); //centro de la pantalla eje X
	end;

	
function grillaY ():integer;
	//lo mismo que grillaX pero pra el eje Y
	begin
		grillaY:=( (getmaxY div tam) div 2); //centro de la pantalla eje Y
	end;


function pixelX(X:integer):integer;
		//transforma las coordenadas X en la ubicacion exacto del pixel a partir del borde
var inicioBordeX:integer;
	begin
		inicioBordeX:=6;		// como el ancho es de 12, al restarle 6 me quedo con el borde del eje X
		pixelX:=grillaX()*tam - (inicioBordeX*tam) + X*tam;	//con grillaX() me ubico en el centro, al restarle el 6*30, me quedo exactamente en el borde del eje X
	end;													//y con (X*tam) me desplazo la cantidad de pixeles a la ubicacion de la coordenada (X=coordenada entre 1..12)


function pixelY(Y:integer):integer;
	//transforma las coordenadas Y en la ubicacion exacto del pixel a partir del borde
var inicioBordeY:integer;
	begin
		inicioBordeY:=11;	//el largo es de 22, entonces la mitad me deja en el centro
		pixelY:=grillaY()*tam - (inicioBordeY*tam) + Y*tam;	//con grillaY() me ubico en el centro, al restarle 11*30, me quedo exactamente en el borde del eje Y
	end;													//y al sumar (Y*tam) me desplazo la cantidad de pixeles a la ubicacion de la coordenada (Y=coordenada entre 1..22)


procedure crearMarco(var G:grilla;x0,y0:integer);
//procedimiento que se encarga de crear el marco decorativo que rodea el juego
// e inicializa la grilla

var fila,columna,x,y:integer;
	begin
		SetFillStyle(SolidFill,8);		//color gris
		for fila:=1 to 22 do
			for columna:=1 to 12 do begin
				G.pos[fila,columna].X:=x0 + (columna-1)*tam; //ubicacion en pixeles
				G.pos[fila,columna].Y:=y0 + (fila-1)* tam;	//
				if ( (fila=1) or (fila=22) or (columna=1) or (columna=12) )then begin //solo es true si estan en el borde
					x:=G.pos[fila,columna].X;	//variables X Y para una mejor lectura
					y:=G.pos[fila,columna].Y;	//
					G.panel[fila,columna]:=true;
					bar(x+1,y+1,x+tam-1,y+tam-1); 	//creo el cuadrado relleno y el borde con un pixel de distancia
					rectangle(x+1,y+1,x+tam-1,y+tam-1); //para que no se borren o superpongan sus marcos
				end
				else G.panel[fila,columna]:=false;
			end;
	end;


procedure generarInterfazNivel();
	begin
	
	end;
	
	
procedure generarInterSigPieza();
//crea la parte visual del nivel
	begin
		settextstyle(0,0,3); //tamaño de letra
			
		setcolor(lightgray);		//color del marco
		
		SetLineStyle(SolidLn, 0, ThickWidth);	//la linea es mas gruesa
		rectangle(interfaz.pixelX(-6)+15,		//dibujo el marco
		interfaz.pixelY(3),
		interfaz.PixelX(0),
		interfaz.pixelY(6));
		
		setcolor(5);		//color de 'Next'
		
		outTextXY( (interfaz.pixelX(-4)-10),(interfaz.pixelY(8)+15),'Next');	//sig pieza
		
		setColor(white);
		
		outTextXY( (interfaz.pixelX(-5)+10),(interfaz.pixelY(10)),'00000');

		SetLineStyle(SolidLn, 0, NormWidth);	//pongo el grosor de la linea a la normalidad
	end;


procedure generarInterfazPuntuacion ();
//crea el marco visual de la puntuacion
	begin
		settextstyle(0,0,3); //tamaño de letra

		setcolor(lightgray);		//color del marco
		
		SetLineStyle(SolidLn, 0, ThickWidth);	//la linea es mas gruesa
		rectangle(interfaz.pixelX(-6)+15,		//dibujo el marco del score
		interfaz.pixelY(8),
		interfaz.PixelX(0),
		interfaz.pixelY(11));
		
		setcolor(lightblue);		//color de 'Score'
		outTextXY( (interfaz.pixelX(-4)-20),(interfaz.pixelY(3)+15),'Score');	//posicion relativa al marco de 'Score'
		
		setColor(white);
		
		outTextXY( (interfaz.pixelX(-5)+10),(interfaz.pixelY(5)),'00000');	//posicion de puntuacion
		SetLineStyle(SolidLn, 0, NormWidth);	//pongo el grosor de la linea a la normalidad
	end;

procedure pausa ();
//pausa el juego momentaneamente hasta que se presione #27 (ESC)
	var ok:boolean; key:char;
	begin;
		ok:=true;
		while (ok) do begin
			key:=readkey;
			if (key=#27) then
				ok:=false;
			end;
	end;

	
procedure iniciarJuego(var G:grilla);	//la grilla total consta de 12*22 (10*20 jugable + el marco)
	//inicializa el modo grafico, configura el color y los demas componentes.
var gd,gm:integer;	//puestos para la inferfaz grafica
	x0,y0:integer;	//posiciones del inicio
	begin
		gd:=detect;
		Initgraph(gd,gm,''); //iniciamos interfaz
		setcolor(white);

		x0:=pixelX(1);	//le mando 1 por ser la base
		y0:=pixelY(1);	//
		
		/////////////	INTERFAZ	/////////////
		
		crearMarco(G,x0,y0);			//crea el borde de cuadros
		generarInterfazPuntuacion();	//puntacion
		generarInterSigPieza();			//sig pieza
		generarInterfazNivel(); 		//nivel
	end;
end.
