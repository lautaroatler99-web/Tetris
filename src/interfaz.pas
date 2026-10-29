unit interfaz;

interface


//las dimensiones del cuadro es X=800-1000, Y=200-800, tamaño=30;

uses graph,wincrt,SysUtils,figuras,tablero,archivo;
	

procedure iniciarJuego(var G:grilla);

procedure pausa ();
procedure sumarPuntos (lineasCompletadas,nivel:integer;var score:longint);
procedure actualizarNivel (lineasTotales:integer;var nivel:integer);
procedure actualizarLineas(lineasTotales:integer);
procedure panelPiezaSiguiente(SP:figuras.pieza);
procedure actualizarContBloques (var blocks:integer);
procedure iniciarFondo();
procedure actualizarHighScore(highScore:longint);

implementation

const 
tam=30;	//tamaño absoluto de cada bloque


procedure posicionNivel(var ancho,alto:integer);
//devuelve las coordenadas XY del nivel
	begin
		ancho := tablero.pixelX(-5)-15;	//posicion del texto
		alto := tablero.pixelY(6)+20;		//
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
// Pasos para actualizar el nivel:
//										1. Se guardan los colores actuales.
//										2. Se dividen las lineas totales por 10 y se suma 1.
//										3. Se compara el resultado con el nivel actual.
//										4. Se borra la puntuacion actual.
//										5. Se imprime la puntuacion actual.
//										6. Se restauran los colores anteriores.
//
// Cada nivel consta de 10 lineas:
//										nivel 1: 0-9 lineas
//										nivel 2: 10-19 lineas
//										nivel 3: 20-29 lineas
//											...
//										nivel X: (lineasTotales div 10) +1
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
		texto:='Level:';
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
		setColor(white);
		texto:='Level:';
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

procedure posicionSigPieza(var X:integer; var Y:integer);
//calcula la posicion de la siguiente pieza
	begin
		X:=tablero.pixelX(-5)-10;
		Y:=tablero.pixelY(10)-10;
	end;
	
	
procedure dibujarSigPieza (SP:figuras.pieza);
//dibuja la siguiente pieza en la pantalla
var i,j,tam:integer;
	X,Y:integer;
	posX,posY:integer;
	begin
		tam:=30;//tamaño de cada cuadro
		SetFillStyle(SolidFill,SP.colorRelleno);
		setcolor(SP.colorBorde);
		
		posicionSigPieza(posX,posY);	//consigo el pixel para dibujar las piezas
		
		//si es figura en I, lo dibujo acostado para centrarlo
		if (SP.tipo='figI') then begin
			for i:=1 to max do 
				for j:=1 to max do 
					if (SP.posValida[i,j]) then begin
						X:=(posX+tam)-12+ (i-1) *tam;	//el -12 es para centrar unos pixeles a la izquierda
						Y:=posY-tam+ (j-1) *tam;
	
						bar(x+1,y+1,x+tam-1,y+tam-1);		//imprimo el bloque
						rectangle(x+1,y+1,x+tam-1,y+tam-1); //imprimo su borde
					end;
		end
		//si es cuadrado, lo dibujo un poco mas a la derecha para centrarlo
		else if (SP.tipo='figQuad') then begin
			for i:=1 to max do 
				for j:=1 to max do 
					if (SP.posValida[i,j]) then begin
						X:=posX + 15 + (j-1) *tam;		//lo centro un poco a la derecha
						Y:=posY+ (i-1) * tam+15;			//y un poco abajo
	
						bar(x+1,y+1,x+tam-1,y+tam-1);		//imprimo el bloque
						rectangle(x+1,y+1,x+tam-1,y+tam-1); //imprimo su borde
					end;
		end
		
		//si es cualquier otra pieza:
		else begin
			for i:=1 to max do 
				for j:=1 to max do 
					if (SP.posValida[i,j]) then begin
						X:=posX+ (j-1) *tam;
						Y:=posY+ (i-1) *tam;
	
						bar(x+1,y+1,x+tam-1,y+tam-1);		//imprimo el bloque
						rectangle(x+1,y+1,x+tam-1,y+tam-1); //imprimo su borde
					end;
		end
	end;


procedure borrarSigPieza();
//crea un bloque negro borrando los pixeles de la sig pieza
var X,Y:integer;
	begin
		posicionSigPieza(X,Y);
		setFillStyle(solidFill, fondo);
		bar(X+15,Y,X+(30*4)+20,Y+30*3);
	end;

	
procedure panelPiezaSiguiente(SP:figuras.pieza);
	//procedimiento base para limpiar pantalla y redibujar la pieza siguiente
	var	color:integer;
		colorRelleno:FillSettingsType;

	begin
		color:=getColor;				//guardo el color actual (PUSH)
		getFillSettings(colorRelleno); 	//guardo la configuracion de fillstyle actual (PUSH)
		
		borrarSigPieza();
		dibujarSigPieza(SP);
		
		setColor(color); 	//restauro el color	(POP)
		SetFillStyle(colorRelleno.Pattern, colorRelleno.Color);// restauro la configuracion de fillStyle (POP)
	end;


procedure generarInterfazSigPieza();
//inicia la parte visual de la siguiente pieza por primerae vez
	begin
		settextstyle(0,0,3); //tamaño de letra
			
		setcolor(lightgray);		//color del marco
		
		SetLineStyle(SolidLn, 0, ThickWidth);	//la linea es mas gruesa
		
		rectangle(
		tablero.pixelX(-6)+15,		//dibujo el marco
		tablero.pixelY(8),
		tablero.PixelX(0),
		tablero.pixelY(13)+15);

		setcolor(5);		//color de 'Next'
		
		outTextXY( (tablero.pixelX(-4)-10),(tablero.pixelY(8)+15),'Next');	//sig pieza
		SetLineStyle(SolidLn, 0, NormWidth);	//pongo el grosor de la linea a la normalidad
		
	end;

////////////////////////////////////////////// PUNTUACION //////////////////////////////////////////////


procedure borrarScore (Xscore,Yscore,score:integer);
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
		Xscore:=(tablero.pixelX(-5)+10);				//posicion de puntuacion
		Yscore:=(tablero.pixelY(5));					//
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
		
		borrarScore(Xscore,Yscore,score);			//borro los pixeles de puntuacion anterior
		
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

		Xrectangle:=(tablero.pixelX(-6)+15);			//posicion rectangulo
		Yrectangle:=(tablero.pixelY(3));				//
		
		Xtext:=(tablero.pixelX(-4)-20);				//posicion de 'score'
		Ytext:=(tablero.pixelY(3)+15);					//
		
		rectangle(Xrectangle,		//dibujo el marco del score
				Yrectangle,
				tablero.PixelX(0),
				tablero.pixelY(6));
		
		setcolor(lightblue);		//color de 'Score'
		
		outTextXY( Xtext,Ytext,'Score');	//posicion relativa al marco de 'Score'
		
		setColor(white);
		
		outTextXY( Xscore,Yscore,'00000');	//posicion de puntuacion
		
		SetLineStyle(SolidLn, 0, NormWidth);	//pongo el grosor de la linea a la normalidad
	end;


////////////////////////////////////////////// HIGH SCORE //////////////////////////////////////////////

procedure posicionHighScore(var X:integer; var Y:integer);
//posicion de la parte de high score
	begin
		X:=pixelX(14);
		Y:=pixelY(8)+10;
	end;


procedure borrarPixelHighScore(X,Y:integer);
//borra los pixeles de la puntuacion de high score
	begin
		setFillStyle(solidFill,fondo);
		bar (X+50,Y+40,X+50+textwidth('00000'),Y+40+textheight('00000')); //coordenadas exactas del tamaño de la puntuacion
	end;


procedure actualizarHighScore(highScore:longint);
//actualiza la puntuacion de high score
	var X,Y,color:integer;colorRelleno:FillSettingsType;
	ceros:string;
	dig,i:integer;
	begin
		color:=getColor;				//guardo el color actual (PUSH)
		getFillSettings(colorRelleno); 	//guardo la configuracion de fillstyle actual (PUSH)
		
		posicionHighScore(X,Y);
		
		borrarPixelHighScore(X,Y);
		
		setColor(white);
		dig:=digitosScore(highScore);
		ceros:='';
		for i:=1 to 5-dig do		//la puntuacion tiene 5 digitos. Se agregan
			ceros:=ceros+'0';			//tantos 0 como la diferencia entre digitos y SCORE
		
		outTextXY( X+50,Y+40, ceros+IntToStr(highScore));		//piso el valor de la puntuacion
		
		setColor(color); 	//restauro el color	(POP)
		SetFillStyle(colorRelleno.Pattern, colorRelleno.Color);// restauro la configuracion de fillStyle (POP)

	end;
	
	
procedure generarInterfazHighScore ();
//dibuja en pantalla la mejor puntuacion buscada en el archivo. Si no hay nignuna se ponen '00000'
	var X,Y:integer;datos:archivo.arch;
	dig,i:integer;
	text,ceros:string;
	player:archivo.recordPlayer;
	begin
		text:='High Score';
		archivo.abrirArchivo(datos);	//abro el archivo
		
		posicionHighScore(X,Y);
		
		outTextXY(X,Y,text);			//imprimo 'high score'
		
		if (not EOF(datos)) then begin	//compruebo si no esta vacio
			read(datos,player);			//la primera posicion es la mas alta
			
			dig:=digitosScore(player.score);	//calculo los digitos del score
			ceros:='';
			for i:=1 to 5-dig do		//la puntuacion tiene 5 digitos. Se agregan
				ceros:=ceros+'0';		//tantos 0 como la diferencia entre digitos y high score
		
			outTextXY( X+50,Y+40, ceros+IntToStr(player.score));		//piso el valor de high score
		end
		else
			outTextXY( X + 50,Y+40,'00000' );
		close (datos);
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
		
		text:='Lines:';
		posicionLineas(X,Y);
		borrarPixelLineas(X,Y,text);
		
		setColor(white);
		
		outTextXY( X+textWidth(text),Y ,intToStr(lineasTotales) );	//imprimo el valor actualizado
		
		setColor(color); 	//restauro el color	(POP)
		SetFillStyle(colorRelleno.Pattern, colorRelleno.Color);// restauro la configuracion de fillStyle (POP)
	end;
	
procedure generarInterfazLinea();
//crea la parte del contador de lineas en pantalla
	var X,Y:integer;
	begin
		setColor(white);
		posicionLineas(X,Y);
		outTextXY(X,Y, 'Lines:0');
	end;


////////////////////////////////////////////// CONTROLES //////////////////////////////////////////////

procedure posicionControles (var X:integer; var Y:integer);
	//devuelve las coordenadas en pixeles donde se van a dibujar los controles
	begin
		X:=pixelX(14);
		Y:=pixelY(12);
	end;
	
	
procedure generarInterfazControles();
//muestra en pantalla los controles
var X,Y:integer;
	begin
		posicionControles(X,Y);
		
		setColor(lightBlue);
		outTextXY (X,Y,'A / '+#27+' : Left');
		setColor(lightRed);
		Y:=Y+40;
		outTextXY (X,Y,'D / '+#26+' : Right');
		setColor(lightGreen);
		Y:=Y+40;
		outTextXY (X,Y,'S / '+#25+': Drop');
		setColor(lightMagenta);
		Y:=Y+40;
		outTextXY (X,Y,'W / '+#24+': Rotate');
		setColor(yellow);
		Y:=Y+40;
		outTextXY(X,Y,'Q: quit');
		setColor(lightCyan);
		Y:=Y+40;
		outTextXY (X,Y,'ESC: pause');
	end;


////////////////////////////////////////////// BLOQUES ////////////////////////////////////////////// 


procedure posicionBloques (var X:integer; var Y:integer);
//posicion fija para la interfaz del contador de bloques
	begin
		X:=pixelX(14);
		Y:=pixelY(5)+10;
	end;


procedure borrarContBloques (X,Y:integer;text:string);
//borra el contador actual de los bloques
var numeros:string;
	begin
		numeros:='9999';
		setFillStyle(solidFill, fondo);
		bar (X+textWidth(text),Y,X+textWidth(text)+textWidth(numeros),Y+textHeight(numeros));
	end;


procedure actualizarContBloques (var blocks:integer);
//acutaliza la cantidad del contador de bloques
var X,Y,color:integer;colorRelleno:FillSettingsType;
	text:string;
	begin
		blocks:=blocks+1;
		color:=getColor;				//guardo el color actual (PUSH)
		getFillSettings(colorRelleno); 	//guardo la configuracion de fillstyle actual (PUSH)
		
		text:='Blocks:';
		posicionBloques(X,Y);
		
		borrarContBloques(X,Y,text);
		setColor(white);
		outTextXY(X+textWidth(text),Y,intToStr(blocks) );
		
		setColor(color); 	//restauro el color	(POP)
		SetFillStyle(colorRelleno.Pattern, colorRelleno.Color);// restauro la configuracion de fillStyle (POP)
		
	end;

	
procedure interfazContBloques (blocks:integer);
//crea la interfaz del contador de bloques
var X,Y:integer;
	begin
		posicionBloques(X,Y);
		setColor(white);
		outTextXY(X,Y, 'Blocks:0');
	end;


//////////////////////////////////////////////////////////////////////////////////////////// 


procedure iniciarFondo();
//pinta toda la pantalla del color de fondo
	begin
		SetFillStyle(SolidFill, fondo);
		bar (0,0,getMaxX(),getMaxY);
	end;

procedure cuadroPausa(X1,X2,Y1,Y2,tamanio:integer;var imagen:pointer);
//creo un bloque en pantalla que avisa de la pausa
	begin
		GetMem(imagen, tamanio);	//reservo en memoria el espacio del cuadro
		GetImage(X1, Y1, X2, Y2, imagen^);	//capturo la iamgen dentro de ese cuadrado
		
		setColor(11); 		//color del texto
		setFillStyle(solidFill, 3);	//fondo del cuadro
		
		bar (X1,Y1,X2,Y2);	//creo un bloque
		outTextXY (X1+15,Y1+15,'- pause -');	//centro el texto
	end;


procedure borrarCuadroPausa (X1,Y1:integer;var imagen:pointer;tamanio:integer);
//deshace el cuadro previamente puesto
	begin
		PutImage(X1, Y1, imagen^, NormalPut);	//pongo la imagen guardada
		FreeMem(imagen, tamanio);			//libero la memoria
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
	imagen:pointer;
	X1,X2,Y1,Y2:integer;
	tamanio:integer;
	color:integer;
	colorRelleno:FillSettingsType;
	
	begin;
		color:=getColor;				//guardo el color actual (PUSH)
		getFillSettings(colorRelleno); 	//guardo la configuracion de fillstyle actual (PUSH)
		
		X1:=tablero.PixelX(3);		//
		Y1:=tablero.pixelY(9)+15;	//coordenadas del cuadro
		X2:=tablero.pixelX(11);		//
		Y2:=tablero.pixelY(11)+15;	//

		tamanio:=imageSize(X1,Y1,X2,Y2);	//guardo el tamaño que ocupa el cuadro
		
		ok:=true;
		
		cuadroPausa(X1,X2,Y1,Y2,tamanio,imagen);
		
		while (ok) do begin
			key:=readkey;			//al usar readkey, detiene el bucle y gasta menos procesamiento
			if (key=#27) then		//que dejarlo en bucle verificando si se presiono alguna tecla
				ok:=false;
			end;
		borrarCuadroPausa(X1,Y1,imagen,tamanio);
		setColor(color); 	//restauro el color	(POP)
		SetFillStyle(colorRelleno.Pattern, colorRelleno.Color);// restauro la configuracion de fillStyle (POP)
	end;
	
	
procedure iniciarJuego(var G:grilla);	//la grilla total consta de 12*22 (10*20 jugable + el marco)
	//inicializa el modo grafico, configura el color y los demas componentes.
var x0,y0:integer;	//posiciones del inicio
	begin
		x0:=pixelX(1);	//le mando 1 por ser la base
		y0:=pixelY(1);	//
		
		/////////////	INTERFAZ	/////////////
		iniciarFondo();
		crearMarco(G,x0,y0);			//crea el borde de cuadros
		generarInterfazPuntuacion();	//puntacion
		generarInterfazSigPieza();			//sig pieza
		generarInterfazNivel(); 		//nivel
		generarInterfazLinea();			//lineas totales
		generarInterfazControles();		//muestra los controles
		interfazContBloques(0);		//muestra cant bloques
		generarInterfazHighScore();
	end;
end.
