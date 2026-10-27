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
begin					//tablero principal 10*20;
	randomize;
	ok:=true; //ok:=menu.inicio();
	score:=0;
	nivel:=10;
	lineasTotales:=0;
	if (ok) then begin
		interfaz.iniciarJuego(Grilla);
		figuras.elegirPieza(P);			//se elije la primera pieza
		figuras.elegirPieza(SP);		//se elije la segunda pieza
		figuras.crearPiezaInicial(P,Grilla);	//se crea la primera pieza
		tiempo:=getTickCount64;
		repeat
			tiempoActual:=GetTickCount64;
			if keypressed then begin
				key:=readkey;
				if ( (key='a') or (key='d') or (key='s') or (key='w') or (key=#27) ) then
					movimiento.registrarAccion(key,P,SP,grilla,nivel,score,lineasTotales);
			end;
			
			intervalo:=1100- nivel*100;    //al principio queda en 1000ms
				
			if (intervalo<100) then		//ajusto el intervalo para que no quede en 0 o negativo
				intervalo:=100;
						
			if ((tiempoActual - tiempo) >= intervalo) then begin
				key:='t';				//se envia t para que caiga por segundo
				movimiento.registrarAccion(key, P, SP, Grilla,nivel,score,lineasTotales);
				tiempo:=tiempoActual;
			end;
		until (ok=false);
	end;
	closegraph;
end.
