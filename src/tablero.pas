unit tablero;
//unidad creada exclusivamente para evitar la dependencia circular


interface

uses graph;

const 
	tam=30;	//tamaño de los bloques de la grilla
	fondo=0; //color del fondo del juego
	
	
type
  arrayGrilla = array[1..22, 1..12] of Boolean;

  coordenada = record
    X: Integer;
    Y: Integer;
  end;

  colores = record
    colorBorde: Integer;
    colorRelleno: Integer;
  end;

  grilla = record
    panel: arrayGrilla;
    pos: array[1..22, 1..12] of coordenada;
    color: array[1..22, 1..12] of colores;
  end;


function GrillaX():integer;
function GrillaY():integer;
function pixelX(X:integer):integer;
function pixelY(Y:integer):integer;


implementation

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

end.
