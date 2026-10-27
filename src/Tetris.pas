program tetris;

uses graph,crt,SysUtils,interfaz,figuras,menu,movimiento,tablero;
const
max=4;

var
	ok:boolean;
	key:char;
	P,SP:figuras.pieza; //pieza y sig pieza
	Grilla:tablero.grilla;
	tiempo, tiempoActual: longint;
	nivel,lineasTotales:integer;
	score:longint;
	intervalo:integer;
	gameOver:boolean;
begin					//tablero principal 10*20;
	randomize;
	ok:=true; //ok:=menu.inicio();
	score:=0;
	nivel:=1;
	lineasTotales:=0;
	gameOver:=false;
	if (ok) then begin
		interfaz.iniciarJuego(Grilla);
		figuras.elegirPieza(P);			//se elije la primera pieza
		figuras.elegirPieza(SP);		//se elije la segunda pieza
		figuras.crearPiezaInicial(P,Grilla,gameOver);	//se crea la primera pieza en la pos central superior
		panelPiezaSiguiente(SP);		//creo la pieza siguiente en la interfaz
		tiempo:=getTickCount64;
		
		while (not (gameOver)) do begin
			tiempoActual:=GetTickCount64;
			if keypressed then begin
				key:=readkey;
				if ( (key='a') or (key='d') or (key='s') or (key='w') or (key=#27{esc}) ) then
					movimiento.registrarAccion(key,P,SP,grilla,nivel,score,lineasTotales,gameOver);
			end;
			
			intervalo:=1100- nivel*100;    //al principio queda en 1000ms
				
			if (intervalo<100) then		//ajusto el intervalo para que no quede en 0 o negativo
				intervalo:=100;
						
			if ((tiempoActual - tiempo) >= intervalo) then begin
				key:='t';				//se envia t para que caiga por segundo
				movimiento.registrarAccion(key, P, SP, Grilla,nivel,score,lineasTotales,gameOver);
				tiempo:=tiempoActual;
			end;
		end;
		menu.terminar();
	end;
	closegraph;
end.
