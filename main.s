
; Archivo:	main.s
; Dispositivo:	PIC16F887
; Autor:	Javier Monzón 20054
; Compilador:	pic-as (v2.30), MPLABX V5.40
;
; Programa:	Contador de 8 bits en el puerto B
; Hardware:	LEDs en el puerto B y push buttons en el puerto A
;
; Creado:	20 febrero 2022
; Última modificación: 20 febrero 2022

PROCESSOR 16F887
#include <xc.inc>
    
; Configuration word 1
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscilador interno sin salidas
  CONFIG  WDTE = OFF            ; WDT disabled (reinicio repetitivo del PIC)
  CONFIG  PWRTE = OFF           ; PWRT enabled (espera de 72ms al iniciar)
  CONFIG  MCLRE = OFF           ; El pin de MCLR se utiliza como I/O
  CONFIG  CP = OFF              ; Sin protección de código 
  CONFIG  CPD = OFF             ; Sin protección de datos
  
  CONFIG  BOREN = OFF           ; Sin reinicio cuando el voltaje de alimentación baja de 4V
  CONFIG  IESO = OFF            ; Reinicio sin cambio de reloj de interno a externo
  CONFIG  FCMEN = OFF           ; Cambio de reloj externo a interno en caso de fallo
  CONFIG  LVP = OFF             ; Programación en bajo voltaje permitida
  
; Configuration word 2
  CONFIG  BOR4V = BOR40V        ; Reinicio abajo de 4V 
  CONFIG  WRT = OFF             ; Protección de autoescritura por el programa desactivada 
    
PSECT udata_bank0		; Variables almacenadas en el banco 0
  cont_1:	DS  1
  
PSECT resVect, class = CODE, abs, delta = 2
 ;-------------- vector reset ---------------
 ORG 00h			; Posición 00h para el reset
 resVect:
    goto main

PSECT code,  delta = 2, abs
ORG 100h
 
main:
    call    config_IO		; Configuración de I/O
    
loop:
    call    B1
    call    B2
    movf    cont_1, 0
    movwf   PORTB
    goto    loop
    
;--------------- Subrutinas ------------------
config_IO:
    banksel ANSEL
    clrf    ANSEL
    clrf    ANSELH	    ; I/O digitales
    banksel TRISA
    bsf	    TRISA,  0	    ; RA0 como entrada
    bsf	    TRISA,  1	    ; RA1 como entrada
    clrf    TRISB	    ; Puerto B como salida
    banksel PORTA
    clrf    PORTA
    clrf    PORTB	    
    movlw   0x00
    movwf   cont_1	    ; Contador siempre inicia en 0
    return
 
B1:
    btfsc   PORTA,  0
    return
    call    antirebotes1
    return
    
B2:
    btfsc   PORTA,  1
    return
    call    antirebotes2
    return
    
antirebotes1:
    btfss   PORTA,  0	
    goto    $-1
    incf    cont_1
    return
    
antirebotes2:
    btfss   PORTA,  1
    goto    $-1
    decf    cont_1
    return
    
END
