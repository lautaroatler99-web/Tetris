unit interfaz;

interface


//las dimensiones del cuadro es X=800-1000, Y=200-800, tamaño=30;

uses graph,wincrt,SysUtils,figuras,tablero,archivo;
	

procedure iniciarJuego(var G:grilla);

procedure pausa ();
procedure sumarPuntos (lineasCompletadas,nivel:integer;var score:longint);
procedure actualizarNivel (lineasTotales:integer;var nivel:integer);
procedure actualizarLineas(lineasTotales:integer);
procedure panelPiezaSiguiente(SP:vectorPiezas);
procedure actualizarContBloques (var blocks:integer);
procedure borrarPantalla();
procedure actualizarHighScore(highScore:longint);
function ingresarNombre():string;
procedure finalizarPartida(Grilla:tablero.grilla);
procedure dibujarPiezaFantasma (P:pieza; var Grilla:tablero.grilla);

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


procedure mensajeGameOver();
//imprime un mensaje luego de perder
var X1,Y1,X2,Y2:integer;
	begin
		X1:=pixelX(3);
		Y1:=pixelY(9);
		X2:=pixelX(11);
		Y2:=PixelY(13);
		
		setFillStyle(solidFill,blue);
		bar (X1,Y1,X2,Y2 );
		setColor(red);
		
		SetLineStyle(SolidLn, 0, ThickWidth);	//la linea es mas gruesa
		
		rectangle (X1,Y1,X2,Y2 );
		
		setColor(lightRed);
		outTextXY(X1+15,Y1+30,'Game Over');
		setColor(white);
		
		settextstyle(0,0,2); //tamaño de letra
		
		outTextXY(X1+15,Y1+70,'Press any key');
		readkey;
	end;


procedure crearBloque(grilla:tablero.grilla;i,j:integer;reverse:boolean);
//crea un cuadrado de color aleatorio para pintar la grilla en el gameOver
var tam,color,lightColor,X,Y:integer;
	begin
		delay(10);
		tam:=30;
		if (not reverse) then begin	//primera espiral con colores aleatorios
			color:=random(6)+1;
			lightColor:=color+8;
		end
		//cuando la espiral es invertida, se pinta del fondo para hacerla desaparecer
		else begin
			color:=fondo;
			lightcolor:=fondo;
		end;
		setFillStyle(SolidFill,color);	//color del bloque
		setColor(lightColor);			//color de borde
			
		X:=grilla.pos[i,j].X;
		Y:=grilla.pos[i,j].Y;
		bar(x+1,y+1,x+tam-1,y+tam-1);		//imprimo bloque
		rectangle(x+1,y+1,x+tam-1,y+tam-1); //imprimo borde
	end;

	
procedure finalizarPartida(Grilla:tablero.grilla);
	//recorre la grilla en espiral pintando todo a su paso con colores aleatorios
	//y luego una espiral invertida del color del fondo.
	//los 'exit' son para que se pueda saltear en cualquier momento y volver al menu.
var i,j:integer;
	filaMin,filaMax,colMin,colMax:integer;
	reverse:boolean;
	begin
		filaMin:=2;		//
		colMin:=2;		//rangos de la grilla jugable
		filaMax:=21;	//
		colMax:=11;		//
		
		reverse:=false;
		while (filaMin<=filaMax) and (colMin <=colMax) do begin
		
			//IZQUIERDA A DERECHA
			for j:=colMin to colMax do begin
				crearBloque(grilla,filaMin,j,reverse);
				if (keypressed) then
					exit;
			end;
			filaMin:=filaMin+1;
			
			//ARRIBA A ABAJO
			for i:=filaMin to filaMax do begin
				crearBloque(grilla,i,colMax,reverse);
				if (keypressed) then
					exit;
			end;
			colMax:=colMax-1;
			
			//ABAJO A ARRIBA
			for j:=colMax downto colMin do begin
				crearBloque(grilla,filaMax,j,reverse);
				if (keypressed) then
					exit;
			end;
			filaMax:=filaMax-1;
			
			//DERECHA A IZQUIERDA
			for i:=filaMax downto filaMin do begin
				crearBloque(grilla,i,colMin,reverse);
				if (keypressed) then
					exit;
			end;
			colMin:=colMin+1;
		end;
		delay(100);
		
		//////////// espiral invertida //////////// 
		
		reverse:=true;
		colMin:=colMin-1;
		
		while (filaMax<21) and (colMax <11) do begin	

			//ABAJO
			for i:=filaMin to filaMax do begin
				crearBloque(grilla,i,colMin,reverse);
				if (keypressed) then
					exit;
			end;
			filaMax:=filaMax+1;

			//DERECHA
			for j:=colMin to colMax do begin
				crearBloque(grilla,filaMax,j,reverse);
				if (keypressed) then
					exit;
			end;
			colMax:=colMax+1;

			//ARRIBA
			for i:=filaMax downto filaMin do begin
				crearBloque(grilla,i,colMax,reverse);
				if (keypressed) then
					exit;
			end;
			filaMin:=filaMin-1;

			//IZQUIERDA
			for j:=colMax downto colMin do begin
				crearBloque(grilla,filaMin,j,reverse);
				if (keypressed) then
					exit;
			end;
			colMin:=colMin-1;
			
		end;
		
		mensajeGameOver();	//imprimo cartel de gameover
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


procedure calibrarPiezas (tipo:string;var PosX:integer; var PosY:integer);
//ajusta unos pixeles correspondientes para mostrar la pieza centrada
	begin
		if (tipo='figT') or (tipo='figS') or (tipo='figInvertedS') then
			posY:=PosY+15;	//medio bloque abajo
			
		if (tipo='figQuad') then begin	//medio bloque abajo y a la derecha
			PosX:=PosX+15;
			posY:=PosY+15;	
		end;
		if (tipo='figL') then	//medio bloque a la izquierda
			PosX:=PosX-15;
		if (tipo='figInvertedL') then	//medio bloque a la derecha
			PosX:=PosX+15;
	end;
	
	
procedure dibujarSigPieza (SP:figuras.pieza;posX,posY:integer);
//dibuja la siguiente pieza en la pantalla
var i,j,tam:integer;
	X,Y:integer;
	begin
		tam:=30;//tamaño de cada cuadro
		SetFillStyle(SolidFill,SP.colorRelleno);
		setcolor(SP.colorBorde);
		
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
		
		else begin	//para cualquier otra pieza
		
			calibrarPiezas(SP.tipo,PosX,PosY);
			
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
//crea un bloque negro borrando los pixeles de las 3 siguientes piezas
var X,Y,I:integer;
	begin
		posicionSigPieza(X,Y);
		for i:=1 to 2 do begin
			setFillStyle(solidFill, fondo);
			bar(X+15,Y,X+(30*4)+20,Y+30*3);
			Y:=Y+140;
		end;
	end;

	
procedure panelPiezaSiguiente(SP:vectorPiezas);
	//procedimiento base para limpiar pantalla y redibujar la pieza siguiente
	var	color:integer;
		colorRelleno:FillSettingsType;
		i:integer;X,Y:integer;
	begin
		color:=getColor;				//guardo el color actual (PUSH)
		getFillSettings(colorRelleno); 	//guardo la configuracion de fillstyle actual (PUSH)
		
		borrarSigPieza();
		
		posicionSigPieza(X,Y);	//consigo el pixel para dibujar las piezas
		
		for i:=1 to 2 do begin
			dibujarSigPieza(SP[i],X,Y);
			Y:=Y+140;
		end;
		setColor(color); 	//restauro el color	(POP)
		SetFillStyle(colorRelleno.Pattern, colorRelleno.Color);// restauro la configuracion de fillStyle (POP)
	end;


procedure generarInterfazSigPieza();
//inicia la parte visual de la siguiente pieza por primerae vez
var X1,X2,Y1,Y2,i,altura:integer;
	begin
		settextstyle(0,0,3); //tamaño de letra
			
		setcolor(lightgray);		//color del marco
		
		SetLineStyle(SolidLn, 0, ThickWidth);	//la linea es mas gruesa
		
		X1:=tablero.pixelX(-6)+15;		//
		Y1:=tablero.pixelY(8);			//	posiciones del marco
		X2:=tablero.PixelX(0);			//
		Y2:=tablero.pixelY(13)+15;		//
		
		altura:=Y2-Y1-30;
		for i:=1 to 2 do begin
			rectangle(X1,Y1,X2,Y2);		//dibujo los 3 marcos
			Y2:=Y2+altura;
			Y1:=Y2-altura;
		end;
		
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
		X:=pixelX(15);
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
		
		dig:=digitosScore(highScore);
		ceros:='';
		for i:=1 to 5-dig do		//la puntuacion tiene 5 digitos. Se agregan
			ceros:=ceros+'0';			//tantos 0 como la diferencia entre digitos y SCORE
		
		setColor(green);
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
		
		SetLineStyle(SolidLn, 0, ThickWidth);	//la linea es mas gruesa
		
		setColor(lightgray);
		rectangle(X-20,Y-20,X+textwidth(text)+15,Y+80);
		
		SetLineStyle(SolidLn, 0, NormWidth);	//pongo el grosor de la linea a la normalidad
		
		
		
		close (datos);
	end;


////////////////////////////////////////////// INTERFAZ CONTADOR DE LINEAS //////////////////////////////////////////////

procedure posicionLineas(var X:integer; var Y:integer);
//devuelve las posiciones XY del contador de lineas
	begin
		X:=pixelX(15);
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
		outTextXY (X,Y,'S / '+#25+': Down');
		setColor(lightMagenta);
		Y:=Y+40;
		outTextXY (X,Y,'W / '+#24+': Rotate');
		setColor(red);
		Y:=Y+40;
		outTextXY (X,Y,'Space: Drop');
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
		X:=pixelX(15);
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

procedure generarTituloTETRIS ();
//crea el titulo 'Tetris' arriba del juego
var medio:integer;text:string;
	begin
		setColor(cyan);
		settextstyle(0,0,3); //tamaño de letra
		text:='Pascal Tetris';
		medio:=( pixelX(12)-pixelX(0) ) div 2 - {esto me da el centro del marco}
				(textWidth(text) div 2)+		{le resto la mitad del texto}
				pixelX(1);						{por ultimo le sumo el origen}
		//getMaxX div 2 - textWidth(text) div 2;
		outTextXY(medio,pixelY(-1)+15,text);
	end;
	

procedure borrarPantalla();
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

procedure borrarLetra(X,Y:integer);
	var colorRelleno:FillSettingsType;
	var text:string;
	begin
		getFillSettings(colorRelleno); 	//guardo la configuracion de fillstyle actual (PUSH)
		
		setFillStyle(solidFill, fondo); //cambio color
		text:='qqqqqqq';			//variable para simular el ancho y largo en pixeles;
		
		bar(X,Y,X+textWidth(text),Y+textHeight(text));
		
		SetFillStyle(colorRelleno.Pattern, colorRelleno.Color);// restauro la configuracion de fillStyle (POP)
	end;
	
	
////////////////////////////////////////////// FUNCIONES PUBLICAS //////////////////////////////////////////////
	

procedure dibujarPiezaFantasma (P:pieza; var Grilla:tablero.grilla);
//crea la silueta de la pieza actual en el final del tablero
var i,j,tam,x,y:integer;
	begin
		tam:=30;//tamaño de cada cuadro
		for i:=1 to max do 
			for j:=1 to max do 
				if (P.posValida[i,j]) then begin
					x:=Grilla.pos[P.posBloque[i,j].Y , P.posBloque[i,j].X].X;
					y:=Grilla.pos[P.posBloque[i,j].Y , P.posBloque[i,j].X].Y;
					
					rectangle(x+1,y+1,x+tam-1,y+tam-1);
				end;
	end;


function ingresarNombre():string;
var X,Y,cant:integer;ok:boolean;c:char;
	name:string;
	begin
		borrarPantalla();			//tapamos todo
		X:=(getMaxX div 2);
		Y:=(getMaxY div 2);
		outTextXY(X - (textWidth('Enter name') div 2),Y-200,'Enter name');
		setColor(white);
		
		X:=X - ((textWidth('Enter name') div 2) div 2)-30;
		Y:=Y-100;
		name:='';
		cant:=0;
		ok:=false;
		outTextXY(X ,Y,'_');
		while (not ok) do begin
			c:=readkey;
			if (c=#13) then //enter
				ok:=true
			else
			if (c=#8) then begin	//backspace
				if (cant>0) then begin
					delete(name , length(name), 1); //borro la ultima letra
					cant:=cant-1;
				end;
			end
			else
			if ( (cant<7) and (c>=' ') ) then begin 	//solo hasta 7 caracteres
														//(c>= ' ') permite solo caracteres imprimibles
				cant:=cant+1;
				name:=name+c;
			end;
			
			borrarLetra(X,Y);
			outTextXY(X ,Y,name);		//imprimo el nombre actualizado
		end;
		ingresarNombre:=name;
	end;


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
		borrarPantalla();
		crearMarco(G,x0,y0);			//crea el borde de cuadros
		generarTituloTETRIS();
		generarInterfazPuntuacion();	//puntacion
		generarInterfazSigPieza();			//sig pieza
		generarInterfazNivel(); 		//nivel
		generarInterfazLinea();			//lineas totales
		generarInterfazControles();		//muestra los controles
		interfazContBloques(0);		//muestra cant bloques
		generarInterfazHighScore();
	end;
end.
