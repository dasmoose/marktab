%{
#include <stdio.h>

#include "mt_string.h"

// NOTE: 
// It seems that I have to include all the structs that are used in the
// union for marktab.y here. I have no idea why...
#include "mt_object.h"
#include "mt_note.h"
#include "mt_chord.h"
#include "mt_sequence.h"

#include "mt_parser.h"

extern int yyerror(const char* msg);
%}

%x confidbuild
%x confvaluebuild

%%

[#].*[\n]              yylineno++;/* Ignore Comments */
[ \t\r]                /* Ignore Whitespace */
^[ \t\r]*\n            yylineno++; /* Ignore empty lines */

[=].*[\n]              return MT_T_PRINT_LINE;

"^"                    return MT_T_MULTIPLY;

":"                    return MT_T_COLON;
","                    return MT_T_COMMA;

"["                    return MT_T_LEFT_BRACKET;
"]"                    return MT_T_RIGHT_BRACKET;

"("                    return MT_T_LEFT_PAREN;
")"                    return MT_T_RIGHT_PAREN;

"x"                    return MT_T_MUTE;

"r"                    return MT_T_REST;

"_"                    return MT_T_PALM_MUTE;
"*"                    return MT_T_HARMONIC;
"~"                    return MT_T_VIBRATO;

"b"                    return MT_T_BEND;
"/"                    return MT_T_SLIDE_UP;
"\\"                   return MT_T_SLIDE_DOWN;
"h"                    return MT_T_HAMMER_ON;
"p"                    return MT_T_PULL_OFF;

^-{3,}[ \t\r]*\n {
  BEGIN confidbuild; // Begin conf section
}

<confidbuild>^-{3,}[ \t\r]*\n {
  BEGIN 0; // End conf section
}

<confidbuild>[ \t\r]*  /* ignore whitespace */

<confidbuild>[^:\n]+ {
  yylval.string = mt_string_new_from_utf8(yytext);
  return MT_T_CONF_ID; 
}

<confidbuild>":" {
  BEGIN confvaluebuild;
}

<confvaluebuild>[^\n]+ {
  yylval.string = mt_string_new_from_utf8(yytext);
  return MT_T_CONF_VALUE;
}

<confvaluebuild>[\n] {
  BEGIN confidbuild;
}

[a-zA-Z][a-zA-Z0-9]* {
  yylval.string = mt_string_new_from_utf8(yytext);
  return MT_T_ID;
}

[0-9]+ {
  sscanf(yytext, "%i", &yylval.integer);
  return MT_T_NUMBER;
}

[\n] {
  yylineno++;
  return MT_T_NEWLINE;
}

<<EOF>> {
  return MT_T_EOF;
}

.                      yyerror(yytext);
