%{
#include<stdio.h>
int locf=0, locp=0, locc=0, locw=0, complejidad = 1; /* Variables globales contadores */
%}

%x COMEN


%%
<INITIAL>^[ \t]*"//".*\n                      				{locf++; locc++;} 			/* lineas enteras de comentario "//" */
<INITIAL>"//".*                               				;                 			/* codigo + comentario "//" */
<INITIAL>^[ \t]*("/*"[^"*/"\n]*["/*"]*[^"*/"\n]*"*/"[ \t]*)+\n		{locf++; locc++;} 			/* lineas con solo comentarios completos */
<INITIAL>"/*"[^"*/"\n]*"*/"                     			;                 			/* comentario en una línea entre codigo */
<INITIAL>^[ \t]*("/*"[^"*/"\n]*"*/"[ \t]*)*"/*"[^"*/"\n]*\n             {BEGIN COMEN; locc++; locf++;}		/* terminar una linea con solo comentarios con comentario abierto */
<INITIAL>"/*"[^"*/"\n]*\n                       			{BEGIN COMEN; locp++; locf++;}		/* terminar una linea de codigo iniciando en comentario */
<INITIAL>^[ \t]*\n							{locf++; locw++;} 			/* lineas en blanco */
<INITIAL>\n								{locf++; locp++;}			/* codigo normal */
<INITIAL>"||" |
"&&" |
"?" |
"if" |
"for" |
"while" |
"case" |
"catch"									{complejidad++;}			/* complejidad ciclomatica */
<COMEN>"*/"								{BEGIN INITIAL;}			/* fin de comentario */
<COMEN>"*/"[ \t]*("/*"[^"*/"\n]*["/*"]*[^"*/"\n]*"*/"[ \t]*)+\n		{BEGIN INITIAL; locf++; locc++;} /* fin de comentario seguido de mas comentarios completos */
<COMEN>"*/"[ \t]*("/*"[^"*/"\n]*"*/"[ \t]*)*"/*"[^"*/"\n]*\n 		{locf++; locc++;} /* fin de comentario seguido de mas comentarios terminando en comentario abierto */
<COMEN>\n								{locf++; locc++;}			/* se añaden mas lineas de comentario */
<COMEN>"*/"[ \t]*\n							{BEGIN INITIAL; locf++; locc++;}	/* termina comentario y salta de linea */
.									;
%%
int main(int argc, char *argv[])
{
    if(argc < 2 || argc > 3){
        fprintf(stderr, "Error: número incorrecto de argumentos.\n   \u257b\n   \u2517\u2501 Argumentos: $ ./prog f_entrada [f_salida]\n");
        return 1;
    }
    /* Ficheros de entrada (primer argumento en CLI) y salida (segundo argumento en CLI) */

    yyin = fopen(argv[1], "r");
    if(argc == 3){
	yyout = fopen(argv[2], "w");
    } else {
	yyout = fopen("salida.txt", "w");
    }

    /* Iniciamos el analisis */
    yylex();

    /* Escribimos los resultados en el fichero de salida y por pantalla */
    fprintf(yyout, "%d\n", locf);   		/* Lineas totales */
    fprintf(yyout, "%d\n", locp);   		/* Lineas de codigo */
    fprintf(yyout, "%d\n", locc);   		/* Lineas de comentarios */
    fprintf(yyout, "%d\n", locw);   		/* Lineas en blanco */
    fprintf(yyout, "%d\n", complejidad);	/* Complejidad ciclomatica */

    printf("%d\n", locf);   		/* Lineas totales */
    printf("%d\n", locp);   		/* Lineas de codigo */
    printf("%d\n", locc);   		/* Lineas de comentarios */
    printf("%d\n", locw);   		/* Lineas en blanco */
    printf("%d\n", complejidad);	/* Complejidad ciclomatica */

    return 0;
}
