program tetris;

uses graph,crt,SysUtils,interfaz,figuras,menu,movimiento;
const
max=4;

var
	ok:boolean;
	key:char;
	P:figuras.pieza;
	Grilla:interfaz.grilla;
	tiempo, tiempoActual: longint;
	nivel:integer;
	score:longint;
begin					//tablero principal 10*20;
	randomize;
	ok:=true; //ok:=menu.inicio();
	score:=0;
	nivel:=1;
	
	if (ok) then begin
		interfaz.iniciarJuego(Grilla);
		figuras.crearFigura(P,Grilla);
		tiempo:=getTickCount64;
		repeat
			tiempoActual:=GetTickCount64;
			if keypressed then begin
				key:=readkey;
				if ( (key='a') or (key='d') or (key='s') or (key='w') or (key=#27) ) then
					movimiento.registrarAccion(key,P,grilla,nivel,score);
			end;
			if ((tiempoActual - tiempo) >= 1000) then begin
				key:='t';				//se Elvia t para que caiga por segundo
				movimiento.registrarAccion(key, P, grilla,nivel,score);
				tiempo:=tiempoActual;
			end;
		until (ok=false);
	end;
	closegraph;
end.
