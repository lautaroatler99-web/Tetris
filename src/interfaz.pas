unit interfaz;

interface


//las dimensiones del cuadro es X=800-1000, Y=200-800, tamaño=30;

uses graph,crt,SysUtils;

const fondo=0; //color del fondo del juego

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
procedure sumarPuntos (lineasCompletadas,nivel:integer;var score:longint);
procedure actualizarNivel (lineasTotales:integer;var nivel:integer);
procedure actualizarLineas(lineasTotales:integer);

implementation

const 
tam=30;	//tamaño absoluto de cada bloque


////////////////////////////////////////////// FUNCIONES DE UBICACION //////////////////////////////////////////////

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
	//transforma las coordenadas Y en la ubicacion exacto del pixel en relacion a la grilal jugable.
var inicioBordeY:integer;
	begin
		inicioBordeY:=11;	//el largo es de 22, entonces la mitad me deja en el centro
		pixelY:=grillaY()*tam - (inicioBordeY*tam) + Y*tam;	//con grillaY() me ubico en el centro, al restarle 11*30, me quedo exactamente en el borde del eje Y
	end;													//y al sumar (Y*tam) me desplazo la cantidad de pixeles a la ubicacion de la coordenada (Y=coordenada entre 1..22)


procedure posicionNivel(var ancho,alto:integer);
//devuelve las coordenadas XY del nivel
	begin
		ancho := interfaz.pixelX(-5)-15;	//posicion del texto
		alto := interfaz.pixelY(6)+20;		//
	end;
		
////////////////////////////////////////////////////////////////////////////////////////////	


// Pasos para actualizar la puntuacion:
//										1. Se guardan los colores actuales.
//										2. Se calculan las dimensiones del bloque de la puntuacion  (unidad absoluta).
//										3. Se borran los pixeles de la puntuacion actual.
//										4. Se calculan los digitos que tiene la puntuacion.
//										5. Se le agregan tantos 0 como necesite para completar los 5 digitos totales.
//										6. Se imprime la nueva puntuacion actualizada.
//										7. Se restauran los colores anteriores.
//
////////////////////////////////////////////////////////////////////////////////////////////
// Pasos para actualizar el nivel:
//									1. Se dividen las lineas totales por 10 y se suma 1.
//									2. Se compara el resultado con el nivel actual
//									3. 
//

// Cada nivel consta de 10 lineas:
//									nivel 1: 0-9 lineas
//									nivel 2: 10-19 lineas
//									nivel 3: 20-29 lineas
//											...
//									nivel X: (lineasTotales div 10) +1
////////////////////////////////////////////////////////////////////////////////////////////
//
//
//
//
//
//
//
//
//
//
////////////////////////////////////////////////////////////////////////////////////////////		
		
		
		
////////////////////////////////////////////// MARCO //////////////////////////////////////////////

procedure crearMarco(var G:grilla;x0,y0:integer);
//procedimiento que se encarga de crear el marco decorativo que rodea el juego
// e inicializa la grilla

var fila,columna,x,y:integer;
	begin
		SetFillStyle(SolidFill,8);		//color gris
		setColor(white);
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
				else begin
					G.panel[fila,columna]:=false;
					G.color[fila,columna].colorRelleno:=fondo;
					G.color[fila,columna].colorBorde:=fondo;
				end;
			end;
	end;


////////////////////////////////////////////// NIVEL //////////////////////////////////////////////

procedure modificarNivel (nivel:integer);
//borra los pixeles del numero de nivel y los reemplaza por el nivel actualizado
	var ancho,alto:integer; numeros,texto:string;
	begin
		texto:='Nivel:';
		setFillStyle(solidFill, fondo);		//cambio relleno de bloques
		numeros:='55';			//variable con el ancho de 2 digitos
		posicionNivel(ancho,alto);
		
		bar(		//borro los numeros del nivel
					ancho+ textWidth(texto), 	//X posicionada en el inicio de los numeros de nivel
					alto,						//Y posicionada en el inicio de los numeros de nivel
					(ancho+ textWidth (texto)+ textWidth(numeros)), 		//X+ desplazamiento X del tamaño que ocupan 2 digitos
					alto+ textheight(numeros) ); 							//Y+      ''
	
		setColor(white);		//color de los digitos del nivel (blanco)
		
		outTextXY( ancho + textWidth(texto), alto, intToStr(nivel));		//piso los digitos del nivel
		
	end;
	
procedure generarInterfazNivel();
//crea la interfaz relacionada al nivel
var ancho,alto:integer;texto:string;
	begin
		texto:='Nivel:';
		posicionNivel(ancho,alto);
		outTextXY (ancho,alto,texto);
		outTextXY(ancho + textWidth(texto),alto,'1');
	end;


procedure actualizarNivel (lineasTotales:integer;var nivel:integer);
//actualiza el valor de nivel  si se cumplen las condiciones
var color:integer; colorRelleno:FillSettingsType;
	begin
		if ( ((lineasTotales div 10) +1 ) >nivel) then begin
			nivel:=nivel+1; //actualizo el nivel
			
			color:=getColor;				//guardo el color actual (PUSH)
			getFillSettings(colorRelleno); 	//guardo la configuracion de fillstyle actual (PUSH)
		
			modificarNivel(nivel);	//borro y actualiza los pixeles del nivel actual

			setColor(color); 	//restauro el color	(POP)
			SetFillStyle(colorRelleno.Pattern, colorRelleno.Color);// restauro la configuracion de fillStyle (POP)
		end;
	end;


////////////////////////////////////////////// SIG PIEZA ////////////////////////////////////////////// 
	
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

////////////////////////////////////////////// PUNTUACION //////////////////////////////////////////////


procedure borrarPuntuacion (Xscore,Yscore,score:integer);
//crea un bloque negro que tapa los pixeles de la puntuacion
	var alto,ancho:integer; numeros:string;
	begin
		setFillStyle(solidFill, fondo);		//cambio relleno de bloques
		numeros:='12345';			//variable con el ancho de 5 digitos
		ancho := Xscore + TextWidth(numeros);	//se toman las dimensiones que ocuparian esos 5 digitos
		alto := Yscore + TextHeight(numeros);	//
		
		bar(Xscore,Yscore,ancho,alto); //borro todos los pixeles de la puntuacion
	end;


function digitosScore (score:integer):integer;
//cuenta la cantidad de digitos que tiene SCORE
var digitos:integer;
	begin
		digitos:=0;
		repeat
			digitos:=digitos+1;
			score:=score div 10;
		until (score=0);
		digitosScore:=digitos;
	end;


procedure posicionScore (var Xscore:integer;var Yscore:integer);
//devuelve las coordenadas XY del score
	begin
		Xscore:=(interfaz.pixelX(-5)+10);				//posicion de puntuacion
		Yscore:=(interfaz.pixelY(5));					//
	end;
	
	
procedure actualizarPuntuacion (score:longint);
//acutaliza la puntuacion del tablero
var Xscore,Yscore,color,digitos,i:integer;
	colorRelleno:FillSettingsType;
	ceros:string;
	begin
		if (score>=100000) then	//medida de seguridad para evitar overflow
			score:=score-100000;
		
		color:=getColor;				//guardo el color actual (PUSH)
		getFillSettings(colorRelleno); 	//guardo la configuracion de fillstyle actual (PUSH)
		
		posicionScore(Xscore,Yscore);
		
		borrarPuntuacion(Xscore,Yscore,score);			//borro los pixeles de puntuacion anterior
		
		digitos:=digitosScore(score);
		ceros:='';
		for i:=1 to 5-digitos do		//la puntuacion tiene 5 digitos. Se agregan
			ceros:=ceros+'0';			//tantos 0 como la diferencia entre digitos y SCORE
				
		setColor(white);		//color de puntuacion (blanco)
		outTextXY( Xscore, Yscore, ceros+IntToStr(score));		//piso el valor de la puntuacion
		
		setColor(color); 	//restauro el color	(POP)
		SetFillStyle(colorRelleno.Pattern, colorRelleno.Color);// restauro la configuracion de fillStyle (POP)
	end;

	
procedure generarInterfazPuntuacion ();
//crea el marco visual de la puntuacion
var Xscore,Xrectangle,
	Yscore,Yrectangle,
	Xtext,
	Ytext:integer;
	begin
		settextstyle(0,0,3); //tamaño de letra
		setcolor(lightgray);		//color del marco
		SetLineStyle(SolidLn, 0, ThickWidth);	//la linea es mas gruesa
		
		posicionSCore(Xscore,Yscore);
		
		Xrectangle:=(interfaz.pixelX(-6)+15);			//posicion rectangulo
		Yrectangle:=(interfaz.pixelY(8));				//
		
		Xtext:=(interfaz.pixelX(-4)-20);				//posicion de 'score'
		Ytext:=(interfaz.pixelY(3)+15);					//
		
		rectangle(Xrectangle,		//dibujo el marco del score
				Yrectangle,
				interfaz.PixelX(0),
				interfaz.pixelY(11));
		
		setcolor(lightblue);		//color de 'Score'
		
		outTextXY( Xtext,Ytext,'Score');	//posicion relativa al marco de 'Score'
		
		setColor(white);
		
		outTextXY( Xscore,Yscore,'00000');	//posicion de puntuacion
		
		SetLineStyle(SolidLn, 0, NormWidth);	//pongo el grosor de la linea a la normalidad
	end;

////////////////////////////////////////////// INTERFAZ LINEA //////////////////////////////////////////////

procedure posicionLineas(var X:integer; var Y:integer);
//devuelve las posiciones XY del contador de lineas
	begin
		X:=pixelX(14);
		Y:=pixelY(4);
	end;
	
procedure borrarPixelLineas(X,Y:integer;text:string);
//borra el contador actual de las lineas
var numeros:string;
	begin
		numeros:='9999'; //representacion del espacio fisico de 4 digitos
		setFillStyle(solidFill, fondo);		//cambio relleno de bloques
		bar ( X+ textWidth(text), 			//ubicacion del inicio de los numeros
		 Y,				//
		 X+ textWidth(text) + textWidth(numeros),
		 Y+ textHeight(numeros)
		 );
	end;


procedure actualizarLineas(lineasTotales:integer);
//actualiza el contador de las lineas totales
	var X,Y,color:integer;text:string;
	colorRelleno:FillSettingsType;
	begin
		
		color:=getColor;				//guardo el color actual (PUSH)
		getFillSettings(colorRelleno); 	//guardo la configuracion de fillstyle actual (PUSH)
		
		text:='Lineas:';
		posicionLineas(X,Y);
		borrarPixelLineas(X,Y,text);
		
		setColor(white);
		
		outTextXY( X+textWidth(text),Y ,intToStr(lineasTotales) );	//imprimo el valor actualizado
		
		setColor(color); 	//restauro el color	(POP)
		SetFillStyle(colorRelleno.Pattern, colorRelleno.Color);// restauro la configuracion de fillStyle (POP)
	end;
	
procedure generarInterfazLinea();
	var X,Y:integer;
	begin
		posicionLineas(X,Y);
		outTextXY(X,Y, 'Lineas:0');
	end;


////////////////////////////////////////////// ////////////////////////////////////////////// 


procedure IniciarFondo();
	begin
		SetFillStyle(SolidFill, fondo);
		bar (0,0,getMaxX(),getMaxY);
	end;

////////////////////////////////////////////// FUNCIONES PUBLICAS //////////////////////////////////////////////

procedure sumarPuntos (lineasCompletadas,nivel:integer;var score:longint);
//suma puntos dependiendo de cuantas lineas consecutivas se hayan completados
	begin
		case lineasCompletadas of
			1: score:=score+100*nivel;
			2: score:=score+200*nivel;
			3: score:=score+500*nivel;
			4: score:=score+800*nivel;
		end;
		actualizarPuntuacion (score);
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
		iniciarFondo();
		crearMarco(G,x0,y0);			//crea el borde de cuadros
		generarInterfazPuntuacion();	//puntacion
		generarInterSigPieza();			//sig pieza
		generarInterfazNivel(); 		//nivel
		generarInterfazLinea();			//lineas totales
	end;
end.
