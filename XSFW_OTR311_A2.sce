
#<<<<<<<<<<<<<<<<<<<< X314 - Lubbricación 4.0 >>>>>>>>>>>>>>>>>>>>;


#a,b,c,d,e,f,g,h,i,j,k,l,n,m,p,q,r,s,t,v,p,A,B,C,D,M,N,L,R,U variables usadas;



#Inicializo variables;
start
{
	read_io 0,p,4;	#Lee estado actual de válvula inversora y lo guardo en variable temporal "p";
	read_str 111,n,v;	#Leo el primer número telefónico de la agenda y lo cargo en "n";
};


#Leo las entradas digitales;
read_io 0,a,1;	#Auxiliar guardamotor;
read_io 0,b,2;	#Manual/Automático;
read_io 0,c,3;	#Reset;
read_io 0,d,4;	#Conmutación de válvula;
read_io 0,e,5;	#Bajo nivel;
read_io 0,f,6;	#Alto nivel;
read_io 0,h,7;  #Sensor tanque vacio;

#Leo las entradas analogicas;


#Pendiente/ levantar el seteo de los temporizadores (q, s y t) y contadores (r), remanencia?;



#------------------------------PROGRAMA------------------------------;

if C=1	#Sistema en alarma?;
{
	A=0;	#Desenergizo bomba de lubricación;
	B=0;	#Apago testigo de marcha;
	D=0;	#Desenergizo bomba neumática;
	if c=1	#Pulsador de Reset presionado?;
	{
		if e=0
		{
			if a=1
			{
				C=0;	#Apago testigo de alarma;
				g=0;	#Reseteo variables;
				j=0;
				k=0;
				l=0;
				R=0;
				i=0;
				c=0;
				M=0;
				N=0;
				L=0;
			};
		};
	};
}
else 	#sistema sin alarma;
{
	r=2;
	B=1;	#Enciendo testigo de marcha;
	if a=0	#Consulto estado de guardamotor;
	{
		C=1;	#Acuso alarma y enciendo testigo;
		write_str 5,v; #Carga el número telefónico (5=numero de telefono);
		write_str 4,'Proteccion termica actuada'; #Carga el texto del SMS (4=texto de SMS) y lo enviag;
		M=1;
	};
	if b=1	#Sistema en automático?;
	{
		if R<r 	#Sistema en ciclo?;
		{
			if h=0
			{
				if u=0
				{
					A=1;	#Energizo bomba de lubricación;
				};
			};
#Pendiente/ si al invertir la válvula son estados concretos, detecto cambio de estado consultando por "d!p". Si en cambio me llega un pulso, reemplasar por "d>p" para leer el flanco positivo;
			if d!p	#Consulto si cambió el estado de la válvula inversora?;
			{
				R=R+1;	#Actualizo contador de ciclos;
				U=U+1;	#Incremento contador de ciclos totales (se reinicia al desenergizar tablero);
				p=d;	#Actualizo auxiliar para detección de flanco;
				A=0;
				j=1;
				timer m, 15000;
			};
			if A=0
			{
				u=1;
				check_timer m
				{
					A=1;
					u=0;
					if j=1
					{
						timer t, 180000;
						j=2;
					};		
				};
			};
			if j=2
			{
				check_timer t	#Tiempo de guardia de lubricación excedido?;
				{
					C=1;	#Acuso alarma y enciendo testigo;
					j=0;
					if i=0 
					{
						write_str 5,v; #Carga el número telefónico (5=numero de telefono);
						write_str 4,'Falla de lubricación'; #Carga el texto del SMS (4=texto de SMS) y lo envia;
						N=1;
						i=1;
					};
				};
			};
		}
		else	#cumplido la cantidad de ciclos mando a reposo;
		{
			A=0;	#Desenergizo bomba de lubricación;
			if k=0
			{
				timer q, 60000;
				k=1;
			};
			if k=1
			{
				check_timer q	#Corriendo tiempo de espera;
				{
					k=0;
					R=0;	#Reinicio contador de ciclos;
				};	
			};	
		};
	}
	else	#sistema en manual;
	{
		if h=0
		{
			A=1;	#Energizo bomba de lubricación;
		};
	};	
	
};

#Rellenado de deposito, independiente al estado del sistema de lubricación;
if f=0	#Si no esta en alto nivel;
{
	if e=1	#Y se da bajo nivel;
	{
		if h=0
		{
			D=1;	#Energizo bomba neumática;
		};
	};

}
else	#Si llegó a alto nivel;
{
	if e=0
	{
		D=0;
	};
	
};

if h=1	#Si se vacio;
{
	if o=0
	{
		write_str 5, v; #Carga el número telefónico (5=numero de telefono);
		write_str 4,'Sin lubricante en el deposito'; #Carga el texto del SMS (4=texto de SMS) y lo envia;
		L=1;
		D=0;
		o=1;
	};
};
if h=0
{
	o=0;
};
#----------------------------------------------------------------------;


#Escribo las salidas;
write_io 1,1,A;	#Bomba lubricación;
write_io 1,2,B;	#Testigo Marcha;
write_io 1,3,C;	#Testigo Alarma;
write_io 1,4,D;	#Bomba neumática;


end;
