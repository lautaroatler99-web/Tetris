unit menu;

interface

function inicio():boolean;

implementation

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
function inicio():boolean;
var op:integer;
	begin
		writeln('1.jugar');
		writeln('2.puntuacion');
		writeln('3.salir');
		
		inicio:=opcion(op);
	end;
end.
