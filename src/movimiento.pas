unit movimiento;


interface

uses graph,wincrt,tablero,figuras,interfaz;

type

limitesPieza=array[1..4] of integer; //vector que retrata el lateral de la pieza


//pasos para mover una pieza:
//							1: Identificar el tipo de movimiento
//							2: Recorrer sus extremos izquierdos/derechos
//							3: Localizar la posicion actual de la pieza.
//							4: Localizar esa posicion en la grilla
//							5: Consultar si el desplazamiento en la grilla esta permitido (grilla X=+1/-1 en FALSE)
//
//
//pasos para borrar una linea:
//							1: Registrar las coordenadas una vez la pieza quede fija (toca piso)
//							2: Identificar las filas en la grilla
//							3: Recorrer las 4 filas en la grilla buscando todos valores TRUE por fila
//							4: Una vez finalizado el recorrido, se identifican las filas en TRUE y se invoca borrarLinea()
//							5: Se posiciona en la fila completa de manera descendente y baja toda la fila de arriba (si esa es false)
//							   copiando todos los bloques de arriba y desplazandolos hacia abajo, incluido su color y borde.
//
//pasos para rotar una pieza:
//							1: Usamos una copia de la pieza y rotamos su matriz
//							2: Usamos una copia de la grilla y borramos las celdas que ocupa la pieza original
//							3: Comprobamos si la pieza rotada sobrepasa los limites de la copia de la grilla
//							4: Comprobamos si la pieza rotada encaja en la copia de la grilla
//							5: Borramos las celdas de la pieza original en la grilla original
//							6: Ocupamos las celdas de la pieza rotada en la grilla original
//							7: Borramos los pixeles de la pieza original
//							8: Reemplazamos la grilla original por la copia ya actualizada
//							9: Dibujamos los pixeles de la pieza rotada a partir de sus coordenadas y de PixelX() y PixelY();
//							10: EXTRA: La figura I es un caso especial y se tiene que rotar manual


procedure registrarAccion (var key:char;var P:figuras.pieza;var SP:figuras.pieza;var Grilla:tablero.grilla;var nivel:integer;var score:longint;var lineasTotales:integer;var blocks:integer;var gameOver:boolean);
procedure moverPieza(var key:char;var P:figuras.pieza;var grilla:tablero.grilla);


implementation

procedure borrarPiezaColor (var P:figuras.pieza;var Grilla:tablero.grilla);
	//pinta la pieza actual de negro simulando que desaparece
var color:integer;colorRelleno:FillSettingsType;
	
	begin
		color:=getColor; //guardo el color actual
		getFillSettings(colorRelleno); //la configuracion de getfill actual
		
		setFillStyle(solidFill, fondo);	//cambio relleno de bloques
		SetColor(fondo);	//cambio color
		
		figuras.dibujarPieza(P,Grilla);	//piso el bloque actual
		
		SetColor(color);	//devuelvo el color anterior
		SetFillStyle(colorRelleno.Pattern, colorRelleno.Color); //devuelvo la configuracion de fillStyle anterior
	end;

	
procedure marcarCeldas (var P:figuras.pieza;var Grilla:tablero.grilla);
		//procedimiento que se encarga de marcas las celdas de la pieza en la copia de la grilla
		//y mantiene los colores
	var i,j,fila,columna:integer;
	begin
		for i:=1 to 4 do
			for j:=1 to 4 do
				if (P.posValida[i,j]) then begin
					fila:=P.posBloque[i,j].Y;
					columna:=P.posBloque[i,j].X;
					
					Grilla.panel[fila,columna]:=true;	//ocupa todas las celdas de la pieza
					Grilla.color[fila,columna].colorBorde := P.colorBorde;
					Grilla.color[fila,columna].colorRelleno := P.colorRelleno;
				end;
	end;


procedure borrarCeldas (var P:pieza;var Grilla:tablero.grilla);
		//procedimiento que se encarga de desmarcar las celdas de la pieza en la grilla
	var i,j:integer;
	begin
		for i:=1 to 4 do
			for j:=1 to 4 do
				if (P.posValida[i,j]) then begin
					Grilla.panel[P.posBloque[i,j].Y,P.posBloque[i,j].x]:=false;	//libero todas las celdas que ocupa la pieza
					Grilla.color[P.posBloque[i,j].Y,P.posBloque[i,j].X].colorBorde:=0;		//pongo sus colores en 0 (negro);
					Grilla.color[P.posBloque[i,j].Y,P.posBloque[i,j].X].colorRelleno:=0;	//
				end;
	end;


function comprobarRotacion (rotada:figuras.pieza; copiaGrilla:tablero.grilla):boolean;
	//comprueba que todas las celdas de la pieza rotada tengan espacio en la grilla
	var ok:boolean;
		i,j:integer;
	begin
		ok:=true;
			for i:=1 to 4 do		//comprobamos que la nueva matriz corresponde a un espacio vacio de la grilla
				for j:=1 to 4 do begin
					if (rotada.posValida[i,j]) then
						if (copiaGrilla.panel[rotada.posBloque[i,j].Y, rotada.posBloque[i, j].X])	then begin			//preguntamos si esa posicion de la grilla esta 
																														//ocupada (true=ocupada)
							ok:=false;
							break;			//corto el segundo for
						end;
					if (not (ok) ) then		//corto el primer for
						break;
				end;
		comprobarRotacion:=ok;
	end;


procedure rotarPieza (P: figuras.pieza; var R:figuras.pieza);
// procedimiento que se encarga de rotar la pieza desde el punto fijo [2,3]
var 
	i, j, minX, minY: integer;
	X, Y: integer;
	centroX, centroY: integer;
	nuevoI, nuevoJ: integer;
	nuevaX, nuevaY: integer;
	esVertical:boolean;
begin
	figuras.inicializarPieza(R);    //inicializo la nueva pieza
	
	minX := 99;
	minY := 99;
    
    //se posiciona en la esquina relativa de la pieza en la grilla
	for i := 1 to 4 do
		for j := 1 to 4 do
			if (P.posValida[i, j]) then begin
				if ((P.posBloque[i, j].X - (j - 1)) < minX) then
					minX := P.posBloque[i, j].X - (j - 1);				//calcula el limite izquierdo de la matriz		
				if ((P.posBloque[i, j].Y - (i - 1)) < minY) then
					minY := P.posBloque[i, j].Y - (i - 1);				//calcula el limite superior de la matriz
			end;


	if (P.tipo <>'figI') then begin //verifico si la pieza es figI ya que al rotarla desborda la matriz
		centroX := minX + 2;            
		centroY := minY + 1;            
    
		for i := 1 to 4 do      
			for j := 1 to 4 do
				if (P.posValida[i, j]) then begin
					X := P.posBloque[i, j].X;
					Y := P.posBloque[i, j].Y;
				
					//nuevos indices en la matriz 4x4 rotando 90° alrededor de (2,3)
					nuevoI := 2 + (j - 3);
					nuevoJ := 3 - (i - 2);

					nuevaX := centroX - (Y - centroY);
					nuevaY := centroY + (X - centroX);
                
					R.posValida[nuevoI, nuevoJ] := true;          
					R.posBloque[nuevoI, nuevoJ].X := nuevaX;     
					R.posBloque[nuevoI, nuevoJ].Y := nuevaY;     
				end;
	end
	else begin		//es la figura en I
		
		esVertical:=false;
		
		for j:=1 to 4 do		//recorro de izquierda a derecha la fila 1
			if (P.posValida[1,j]) then
				esVertical:=true;
	
		if (esVertical) then begin	//si es vertical entonces la paso a horizontal
			
			////////////Vertical >>>>>>>Horizontal////////////

			// la construyo manualmente de forma horizontal
			for j:=1 to 4 do begin
				R.posValida[2,j]:=true;
				R.posBloque[2,j].X:= minX + j-1;
				R.posBloque[2,j].Y:= minY+1;		//fila 2
			end;
		end
		
		else begin
			//////////// Horizontal >>>>>>>Vertical////////////

			// la construyo manualmente de forma vertical
			for i:=1 to 4 do begin
				R.posValida[i,2]:=true;
				R.posBloque[i,2].X:= minX+ 1;	//columna 2
				R.posBloque[i,2].Y:= minY + i-1;
			end;
		end;
	end;
	R.colorBorde := P.colorBorde;				//
	R.colorRelleno := P.colorRelleno;			//fuera del bucle copiamos sus colores
	R.rotacion := P.rotacion;					//y rotacion
	R.tipo:=P.tipo;
end;


function limites (rotada:figuras.pieza):boolean;
	//verifica que no ocurra un desbordamiento al girar la matriz de la pieza
	var ok:boolean; i,j:integer;
	begin
		ok:=true;		
		for i:=1 to 4 do
			for j:=1 to 4 do	
				if (rotada.posValida[i,j]) then
					if ( (rotada.posBloque[i,j].Y < 2) or			//
						(rotada.posBloque[i,j].Y >21) or			//comprobamos que no haya desbordamiento
						(rotada.posBloque[i,j].X < 2) or			//una vez rotada
						(rotada.posBloque[i,j].X > 11)				//
						) then										//
						ok:=false;
		limites:=ok;
	end;
	
	
function rotacion (var P:figuras.pieza;var grilla:tablero.grilla):boolean;	
		//se encarga de toda la rotacion y finalmente, si se puede, rota la pieza		
	var ok,limite,puedeRotar:boolean;
		R:figuras.pieza;
		copiaGrilla:tablero.grilla;		//copia de la grilla
	begin
		ok:=false;
		
		copiaGrilla:=grilla;				//todas las modificaciones se hacen primero en una copia de la grilla
		
		borrarCeldas(P,copiaGrilla);		//desocupamos la pieza original en la copia de la grilla
		
		figuras.inicializarPieza(R);			//inicializo la matriz
		
		rotarPieza(P,R);			//rotamos la pieza
		
		limite:=limites(R);		//comprobamos que la pieza no se haya desbordado de la grilla
		
		puedeRotar:=false;

		if (limite) then			//si es true, significa que no hay desbordamiento y se puede comprobar la matriz de la grilla,
										//caso contrario podria acceder a una posicion no valida
			puedeRotar:=comprobarRotacion(R,copiaGrilla);			//comprobamos si en la grilla estan ocupadas las nuevas posiciones de la pieza rotada

		if ( (limite) and (puedeRotar)) then					//significa que hay espacio para rotar
			ok:=true;
		rotacion:=ok;
	end;


procedure bordeLateral(key:char;P:figuras.pieza; var bordeMovimiento:limitesPieza);
//recorre el borde izquierdo o derecho dependiendo del resultado de KEY y carga un vector con la posicion lateral del eje Y
var i,j:integer;
	begin
		for i:=1 to 4 do
			bordeMovimiento[i]:=0;
			
		if (key='a') then begin	//busco el primer bloque valido
			for i:=1 to 4 do
				for j:=1 to 4 do
					if (P.posvalida[i,j]) then begin
						bordeMovimiento[i]:=j;  //consigo la PRIMERA posicion de la figura (mas a la izquierda)
						break;			//sigo con la siguiente posicion
					end;
		end
		
		else if (key='d') then begin
			for i:=1 to 4 do
				for j:=4 downto 1 do
					if (P.posvalida[i,j]) then begin
						bordeMovimiento[i]:=j;  //consigo la posicion del bloque mas a la derecha de la figura
						break;
					end;
		end;
	end;


function lados(
						key:char;
						P:figuras.pieza;
						grilla:tablero.grilla;
						bordeMovimiento:limitesPieza
						):boolean;
// Comprueba en la grilla si hay espacio disponible para realizar el desplazamiento izquierda/derecha
var
fila,columna,i:integer; ok:boolean;
	begin
		ok:=true;
		
		bordeLateral(key,P, bordeMovimiento);
		
		///////////////////////////////////////////////////////////////////////////
		//esto es para la D (derecha)
			
		if (key='a') then begin
			for i:=1 to 4 do
				if (bordeMovimiento[i]<>0) then begin
					columna:=P.posBloque[i,bordeMovimiento[i]].X;	//consigo las coordenadas exactas del bloque mas a la izquierda.
					if (columna<=2) then begin //si el bloque esta en la posicion 2, significa que alcanzo el limite del marco
						ok:=false;
						break;
					end;
					fila:=P.posBloque[i,bordeMovimiento[i]].Y;
					if (grilla.panel[fila,columna-1]) then begin	//consulto la grilla si el lugar esta disponible para poder desplazarse
						ok:=false;
						break;
					end;
				end;
		end
		///////////////////////////////////////////////////////////////////////////
		//esto es para la D (derecha)

		else if (key='d') then begin
			for i:=1 to 4 do
				if (bordeMovimiento[i]<>0) then begin
					columna:=P.posBloque[i,bordeMovimiento[i]].X;	//consigo las coordenadas exactas del bloque mas a la derecha.
					if (columna>=11) then begin //si el bloque esta en la posicion 11, significa que alcanzo el limite del marco
						ok:=false;
						break;
					end;
					fila:=P.posBloque[i,bordeMovimiento[i]].Y;
					if (grilla.panel[fila,columna+1]) then begin	//consulto la grilla si el lugar esta disponible para poder desplazarse
						ok:=false;
						break;
					end;
				end;
		end
		else ok:=false;
		lados:=ok;
	end;

	
function puedeBajar(
					P:figuras.pieza;
					Grilla:tablero.grilla;
					bordeMovimiento:limitesPieza
					):boolean;	
//comprueba si las celdas debajo de la pieza estan disponibles para bajar
var fila,columna,i,j:integer; ok:boolean;		
	begin
		ok:=true;
		
		for i:=1 to 4 do //bordeMovimiento queda con todo el eje de la posicion mas baja de la pieza (calcula el piso)
			for j:=1 to 4 do
				if (P.posvalida[i,j]) then
					bordeMovimiento[j]:=i;
	
		for i:=1 to 4 do
			if (bordeMovimiento[i]<>0) then begin
				fila:=P.posBloque[bordeMovimiento[i],i].Y; 		//coordenadas del eje X Y
				columna:=P.posBloque[bordeMovimiento[i],i].X;	//
				if  (fila>=21) then begin //si toca el piso se cancela el desplazamiento
					ok:=false;
					break
				end
				else if (Grilla.panel[fila+1,columna]) then begin //compruebo si la celda debajo esta ocupada
						ok:=false;
						break;
				end;
			end;
		puedeBajar:=ok;
	end;


procedure moverPieza(var key:char;var P:figuras.pieza;var grilla:tablero.grilla);
	//mueve la pieza dependiendo de la accion que se realiza
	var i,j,desplX, desplY:integer;
	puedeRotar:boolean;
	R:figuras.pieza;
	begin
		desplY:=0;
		desplX:=0;
		if (key='a') or (key='d') or (key='s') or (key='t')then begin	//compruebo para separar los desplazamientos a un lado y la rotacion ('w') a otro
			if (key= 'a') then
				desplX := -1
			else if (key= 'd') then
				desplX:= 1
			else if (key= 's') or (key = 't') then
				desplY:=1;
		
			borrarPiezaColor(P, grilla);
			//primero borro las posiciones viejas, luego actualizo los bloques en base al desplazamiento y despues activo las celdas en la grilla
			
			
			borrarCeldas(P,Grilla);	

			for i := 1 to 4 do// Actualiza las columnas de los bloques
				for j := 1 to 4 do
					if P.posValida[i,j] then begin
						P.posBloque[i,j].X:= P.posBloque[i,j].X + desplX;
						P.posBloque[i,j].Y:= P.posBloque[i,j].Y + desplY;
					end;
			
			marcarCeldas(P,grilla);
			figuras.dibujarPieza(P, grilla);// se vuelve a dibujar la pieza en su nueva posicion
		
		end
	
		else if (key='w') then begin
			inicializarPieza(R);	//setea todas las posiciones en 0
			puedeRotar:=rotacion(P,grilla);
			if (puedeRotar) then begin	//si bien no necesito hacer todo de vuelta, lo hago para encapsular todos los movimientos en 'moverPieza'
				rotarPieza(P,R);		//primero roto la pieza
				borrarCeldas(P,grilla);		//borro la posicion logica de la pieza original
				borrarPiezaColor(P, grilla);		//borro los colores de la pieza

				P:=R;		//ahora la pieza original es la que fue rotada
				
				marcarCeldas(P,grilla);	//activo las celdas de la pieza rotada en la grilla

				figuras.dibujarPieza(P,grilla);	//imprimo la pieza rotada
			end;
		end;
	end;


procedure borrarLinea (var G:tablero.grilla;PosInicio:integer);
	//borra la linea desplazando toda la grilla desde donde se identifico la linea completa
	//hasta arriba, desplazando todas las filas una mas abajo
	var i,j,X,Y,tam:integer;
	begin
		tam:=30;
		for i:=PosInicio downto 2 do
			for j:=2 to 11 do begin
				if (i=2) then begin						//si i=2 quiere decir que esta en la primera fila.
					G.panel[i,j]:=false;				//como no puede copiar valores de arriba, desaparece,
					G.color[i,j].colorRelleno:=fondo;	//sus celdas se liberan y se pintan cuadros
					G.color[i,j].colorBorde:=fondo;		//del color del fondo
				end
				else begin
					G.panel[i,j]:=G.panel[i-1,j]; 							//
					G.color[i,j].colorRelleno:=G.color[i-1,j].colorRelleno;	//le copio el valor de la celda de arriba
					G.color[i,j].colorBorde:=G.color[i-1,j].colorBorde;		//
				end;
				
				SetFillStyle(SolidFill,G.color[i,j].colorRelleno);		//asigno los colores del cuadro
				setcolor(G.color[i,j].colorBorde);						//y borde
				
				X:=G.pos[i,j].X;			//apunto las coordenadas para
				Y:=G.pos[i,j].Y;			//empezar a dibujar el cuadro
				bar(x+1,y+1,x+tam-1,y+tam-1); //creo el cuadrado relleno con un pixel de distancia
				rectangle(x+1,y+1,x+tam-1,y+tam-1); //borde del cuadrado con un pixel de distancia
			end;
	end;


procedure confirmarLinea (P:figuras.pieza;var G:tablero.grilla;var nivel:integer; var score:longint;var lineasTotales:integer);
	//recorre las 4 lineas donde la pieza quedo estatica y verifica si estan completas para proceder a borrar
var i,j,min,max:integer;
	ok:boolean;
	lineasCompletadas:integer; //variable que acumula las lineas para sumar puntos
	begin
		min:=99;
		max:=0;
		lineasCompletadas:=0;
		for i:=1 to 4 do
			for j:=1 to 4 do
				if (P.posValida[i,j]) then begin
					if ((P.posBloque[i,j].Y)<min) then
						min:=P.posBloque[i,j].Y;					//recorro la matriz y me quedo con la posicion mas alta y mas baja de la pieza y consigo su coordenada de la fila
					if ((P.posBloque[i,j].Y)>max) then				//A partir de eso, recorro de coordenadas MIN a MAX cada fila en la grilla.
						max:=P.posBloque[i,j].Y;
				end;
				
		i:=max;
		while(i>=min) do begin								//Recorrer de min a max evita desbordamientos que superen la grilla jugable
			ok:=true;
			for j:=2 to 11 do									//las celdas jugables del ancho de la grilla son desde 2 a 11	
				if not (G.panel[i,j]) then begin 				//si una celda es falsa significa que la fila no esta completa
					ok:=false;
					break;
				end;
			if (ok) then begin
				lineasCompletadas:=lineasCompletadas+1;
				borrarLinea(G,i);					//si la linea esta completa, procede a borrarla
			end
			else
				i:=i-1;
		end;
		if (lineasCompletadas>0) then begin
			lineasTotales:=lineasTotales+lineasCompletadas;
			interfaz.sumarPuntos(lineasCompletadas,nivel,score);
			interfaz.actualizarNivel(lineasTotales,nivel);
			interfaz.actualizarLineas(lineasTotales);
		end;
	end;


function permitirMovimiento(key:char;P:figuras.pieza; Grilla:tablero.grilla; bordeMovimiento:limitesPieza):boolean;
	//funcion que verifica si el movimiento esta permitido dependiendo de la tecla presionada
	var ok:boolean;i:integer;
	begin
		ok:=false;
		for i:=1 to 4 do
			bordeMovimiento[i]:=0;
		if ( (key='a') or (key='d') ) then
			ok:=lados(key,P,Grilla,bordeMovimiento)
		else if (key='w') then begin
			if (P.rotacion) then	//es la unica validacion para el caso 'w'
				ok:=true;
		end
		else if (key='s') or (key='t') then
			ok:=puedeBajar(P,Grilla,bordeMovimiento);
		permitirMovimiento:=ok;
	end;
	
	
procedure caidaRepentina(key:char;var P:figuras.pieza;var Grilla:tablero.Grilla; bordeMovimiento:limitesPieza);
//registra la caida progresiva y permite la interaccion de otros movimientos en el transcurso. Una vez que toca piso,
//permite un ultimo movimiento
var ok:boolean;
	begin
		ok:=puedeBajar(P,Grilla,bordeMovimiento);
		
		while (ok) do begin
			delay(75);
			if keypressed then begin		//se puede mover mientras cae
				key:=readkey;
				key:=lowerCase(key);
				if (key=#27) then			//pausa en caida
					interfaz.pausa()
				else
				if (permitirMovimiento(key,p,grilla,bordeMovimiento)) then//comprueba si la accion puede realizarse dependiendo de la tecla presionada
					moverPieza(key,P,Grilla);
			end
			else begin					//si no se presiona nada, sigue cayendo
				key:='s';
				moverPieza(key,P,Grilla);
			end;
			ok:=puedeBajar(P,Grilla,bordeMovimiento);
		end;
		
		delay(300);	//ultima chance para mover la pieza antes de confirmar posicion
		if (keypressed) then begin
			key:=readkey;
			key:=lowerCase(key);
			if (permitirMovimiento(key,p,grilla,bordeMovimiento)) then
				moverPieza(key,P,Grilla);
		end;
	end;

procedure finalizarCaida(var P:figuras.pieza;
						 var SP:figuras.pieza;
						 var Grilla:tablero.grilla;
						 var nivel:integer;
						 var score:longint;
						 var lineasTotales:integer;
						 var blocks:integer;
						 var gameOver:boolean);
	//se encarga de todo el proceso una vez la pieza se haya asentado
	begin
		confirmarLinea(P,Grilla,nivel,score,lineasTotales);			//reviso si la caida de la pieza logro completar una linea
		P:=SP;										//la pieza siguiente pasa a ser la actual
		figuras.elegirPieza(SP);					//se elije la siguiente pieza
		interfaz.panelPiezaSiguiente(SP);
		figuras.crearPiezaInicial(P, Grilla,gameOver);			//la pieza llego al final y se crea una nueva
		interfaz.actualizarContBloques(blocks);
	end;

procedure registrarAccion 	(var key:char;
							var P:figuras.pieza;
							var SP:figuras.pieza;
							var Grilla:tablero.grilla;
							var nivel:integer;
							var score:longint;
							var lineasTotales:integer;
							var blocks:integer;
							var gameOver:boolean);
							
//procedimiento que interpreta la accion realizada
	var
	ok:boolean;
	i:integer;
	bordeMovimiento:limitesPieza;
	begin
		for i:=1 to 4 do 	//inicializo el vector de colision
			bordeMovimiento[i]:=0; //variable para identificar los extremos laterales de la pieza
		
		//////// izquierda/derecha //////////////
		
		if ( (key='a') or (key='d') ) then begin
			if (permitirMovimiento(key,p,grilla,bordeMovimiento)) then
				moverPieza(key,P, Grilla);
		end
		
		//////// caida repentina //////////////
		
		else if (key='s') then begin 
			ok:=puedeBajar(P,Grilla,bordeMovimiento);
			while (ok) do begin
				caidaRepentina(key, P, Grilla, bordeMovimiento);	//la pieza cae hasta tocar piso
				
				if (puedeBajar(P,Grilla,bordeMovimiento)) then			//si despues de moverse sigue en el aire, continua cayendo
					caidaRepentina(key, P, Grilla, bordeMovimiento);	//
				ok:=puedeBajar(P,Grilla,bordeMovimiento);				//el bucle permite multiples caidas
			end;
			finalizarCaida(P,SP,Grilla,nivel,score,lineasTotales,blocks,gameOver);
		end
		
		//////// rotar //////////////
		
		else if (key='w') then begin
			if (p.rotacion) then
				moverPieza(key,P, Grilla);
		end
		
		//////// tiempo //////////////
		
		else if (key='t') then begin			//baja una posicion por cada segundo relativo al nivel
			if puedeBajar(P,Grilla,bordeMovimiento) then begin
				delay(75);
				moverPieza(key,P,Grilla);
			end
			else
				finalizarCaida(P,SP,Grilla,nivel,score,lineasTotales,blocks,gameOver);
		end
		
		//////// pausa //////////////
		
		else if (key=#27) then
			interfaz.pausa();
	end;
end.
