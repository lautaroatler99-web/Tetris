unit archivo;

interface
type
	recordPlayer=record
		name:string[7];
		score:longint;
		level:integer;
		lines:integer;
	end;

arch=file of recordPlayer;
	
procedure abrirArchivo(var filePlayer:arch);
procedure guardarResultados (player:recordPlayer; var filePlayer:arch);

implementation

procedure abrirArchivo(var filePlayer:arch);
//abre el archivo de puntuaciones (no lo cierra. Eso lo maneja el procedimiento que lo invoca)
	begin
		assign(filePlayer,'records.dat');
		
		{$I-}		//se deshabilitan las interrupciones para que no falle el programa al momento de abrirlo
		reset(filePlayer);  //abro el archivo
		{$I+}
		//IOresult guarda el numero del error. si es 0 significa que salio todo bien
		
		if (IOresult<>0) then	//si entra significa que el archivo no existe
			rewrite(filePlayer);
		
	end;

procedure guardarResultados (player:recordPlayer; var filePlayer:arch);
//guarda en el archivo los resultados del jugador ordenado por puntuacion
var P:recordPlayer;encontre:boolean;
	begin
		encontre:=false;
		abrirArchivo (filePlayer);
		while ( (not EOF (filePlayer)) and (not encontre) ) do begin	//si el archivo no llego al final..
			read (filePlayer,P);	//leo los jugadores
			if (player.score>P.score) then
				encontre:=true;
		end;
		if (encontre) then begin
			seek(filePlayer, filePos(filePlayer) -1);
			while (not EOF (filePlayer) ) do begin 				//recorro todo el archivo hasta el final
				read(filePlayer,P);								//leo el jugador de esa posicion
				seek(filePlayer, filePos(filePlayer) -1);		//me posiciono en la pos recien leida
				write(filePlayer,player);						//sobreescribo el valor
				player:=P;										//ahora player tiene el jugador anterior
			end;
		end
		else begin	//no hay jugador con puntuacion mas alta, se guarda en el ultimo puesto
			seek(filePlayer,filesize(filePlayer)); 	//me desplazo a la ultima posicion del archivo
			write(filePlayer,player); 				//escribo al jugador en la ultima posicion
		end;
		close(filePlayer);
	end;
	
	
end.
