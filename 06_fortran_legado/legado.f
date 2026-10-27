C=======================================================================
C     PROGRAMA VDPF77
C     INTEGRA EL OSCILADOR DE VAN DER POL CON RUNGE-KUTTA 4 DE PASO FIJO.
C     ESTILO FORTRAN 77 TIPICO: FORMATO FIJO, TIPADO IMPLICITO, COMMON,
C     GOTO, DIMENSION Y ETIQUETAS.  (ASI SE ESCRIBIA HACIA 1985.)
C
C     COLUMNAS:  1     'C' O '*' = COMENTARIO
C                1-5   ETIQUETAS (NUMEROS)
C                6     CUALQUIER CARACTER = CONTINUACION DE LA LINEA
C                7-72  INSTRUCCIONES (LO QUE PASA DE LA 72 SE IGNORA)
C=======================================================================
      PROGRAM VDPF77
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION Y(2)
      COMMON /PARAM/ AMU
      EXTERNAL FCN
C
      AMU = 1.0D0
      H = 0.01D0
      NPASOS = 3000
      NSALID = 300
      T = 0.0D0
      Y(1) = 0.5D0
      Y(2) = 0.0D0
C
      WRITE(6,100)
      WRITE(6,110) T, Y(1), Y(2)
C     BLOQUES DE NSALID PASOS; SE ESCRIBE AL FINAL DE CADA BLOQUE
      NBLOQ = NPASOS/NSALID
      DO 10 IB = 1, NBLOQ
         CALL RK4(FCN, 2, T, Y, H, NSALID)
         WRITE(6,110) T, Y(1), Y(2)
   10 CONTINUE
C
  100 FORMAT(1X,'       T',14X,'X',23X,'Y')
  110 FORMAT(1X,F8.3,2E24.16)
      END
C
C-----------------------------------------------------------------------
C     RK4: AVANZA NPASOS PASOS DE RUNGE-KUTTA CLASICO DESDE (T,Y).
C     A LA SALIDA T E Y CONTIENEN EL NUEVO ESTADO.  N <= 10.
C-----------------------------------------------------------------------
      SUBROUTINE RK4(F, N, T, Y, H, NPASOS)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION Y(N), YK(10), DK1(10), DK2(10), DK3(10), DK4(10)
      EXTERNAL F
C
      K = 0
   20 IF (K .GE. NPASOS) GOTO 99
      CALL F(N, T, Y, DK1)
      DO 30 I = 1, N
   30 YK(I) = Y(I) + 0.5D0*H*DK1(I)
      CALL F(N, T + 0.5D0*H, YK, DK2)
      DO 40 I = 1, N
   40 YK(I) = Y(I) + 0.5D0*H*DK2(I)
      CALL F(N, T + 0.5D0*H, YK, DK3)
      DO 50 I = 1, N
   50 YK(I) = Y(I) + H*DK3(I)
      CALL F(N, T + H, YK, DK4)
      DO 60 I = 1, N
         Y(I) = Y(I) + H/6.0D0*(DK1(I) + 2.0D0*DK2(I) + 2.0D0*DK3(I)
     &          + DK4(I))
   60 CONTINUE
      T = T + H
      K = K + 1
      GOTO 20
C
   99 RETURN
      END
C
C-----------------------------------------------------------------------
C     FCN: CAMPO DE VAN DER POL.  EL PARAMETRO LLEGA POR COMMON.
C-----------------------------------------------------------------------
      SUBROUTINE FCN(N, T, Y, DY)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION Y(N), DY(N)
      COMMON /PARAM/ AMU
      DY(1) = Y(2)
      DY(2) = -AMU*(Y(1)**2 - 1.0D0)*Y(2) - Y(1)
      RETURN
      END
