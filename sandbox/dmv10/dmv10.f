      SUBROUTINE DMV10 (AM,Q,POTENP,H,NSTEP,RPAR,IPAR)
C-----------------------------------------------------------------------
C            PREPROCESSED DISCRETE MOSER-VESELOV ALGORITHM 
C-----------------------------------------------------------------------
C  PREPROCESSED DISCRETE MOSER-VESELOV ALGORITHM OF ORDER 10 FOR THE 
C  NUMERICAL SOLUTION OF THE EQUATIONS OF MOTION OF THE FREE RIGID BODY. 
C  ORTHOGONAL MATRICES ARE REPRESENTED BY QUATERNIONS. 
C  THE CODE IS READY TO INCLUDE AN EXERNAL POTENTIAL (SYMMETRIC STRANG  
C  SPLITTING OF ORDER 2). 
C-----------------------------------------------------------------------
C     AUTHORS: ERNST HAIRER (1) AND GILLES VILMART (1)(2)
C                (1) UNIVERSITE DE GENEVE, DEPT. DE MATHEMATIQUES
C                    2-4 RUE DU LIEVRE, CASE POSTALE 64
C                    CH-1211 GENEVE 4, SWITZERLAND 
C                (2) IRISA/INRIA RENNES, PROJET IPSO
C                    CAMPUS DE BEAULIEU, F-35042 RENNES CEDEX, FRANCE
C     E-MAILS: Ernst.Hairer@math.unige.ch
C              Gilles.Vilmart@math.unige.ch
C
C  THIS CODE IS DESCRIBED IN:
C    E. HAIRER AND G. VILMART, PREPROCESSED DISCRETE MOSER-VESELOV
C    ALGORITHM FOR THE FULL DYNAMICS OF A RIGID BODY
C    J. Phys. A: Math. Gen. 39 (2006) 13225-13235. 
C    http://stacks.iop.org/0305-4470/39/13225
C
C     VERSION: AUGUST 29, 2006
C     (latest correction of a small bug: December 28, 2007)
C-----------------------------------------------------------------------
C     INPUT PARAMETERS
C     ----------------
C     AM(I)      INITIAL ANGULAR MOMENTUM (I=1,2,3)
C     Q(I)       INITIAL QUATERNION FOR ORTHOGONAL MATRIX (I=1,2,3,4) 
C     H          STEP SIZE
C     NSTEP      NUMBER OF STEPS
C     POTENP     NAME (EXTERNAL) OF SUBROUTINE FOR AN EXTERNAL POTENTIAL
C                   SUBROUTINE POTENP(Q,POTP,RPAR,IPAR)
C                   DIMENSION Q(4),POTP(3)
C                   POTP(1)=...   ETC.
C     RPAR,IPAR  REAL AND INTEGER PARAMETERS (OR PARAMETER ARRAYS) WHICH
C                CAN BE USED FOR COMMUNICATION BETWEEN SUBROUTINES
C     RPAR(11), RPAR(12), RPAR(13) ARE THE THREE MOMENTS OF INERTIA OF
C                THE RIGID BODY
C
C     OUTPUT PARAMETERS
C     -----------------
C     AM(I)       SOLUTION (ANGULAR MOMENTUM) AT ENDPOINT
C     Q(I)        SOLUTION (QUATERNION) AT ENDPOINT
C----------------------------------------------------------------------- 
      PARAMETER (MSPLIT=1)
C----------------------------------------------------------------------- 
      IMPLICIT REAL*8 (A-H,O-Z) 
      DOUBLE PRECISION Q(4),AM(3),POTP(3)
      DIMENSION IPAR(20),RPAR(20)
      EPS=ABS(1.D-15*H)
      HA=H/2.0D0
      HB=H/MSPLIT
C
      HD=HB/2.0D0
      HC=4.0D0/HB
      AI1=RPAR(11)
      AI2=RPAR(12)
      AI3=RPAR(13) 
C---      CONSTANT COEFFICIENTS FOR THE MODIFIED MOMENTS OF INERTIA
      XI1=1.0D0/AI1+1.0D0/AI2+1.0D0/AI3
      XI2=1.0D0/AI1**2+1.0D0/AI2**2+1.0D0/AI3**2
      XI3=1.0D0/AI1**3+1.0D0/AI2**3+1.0D0/AI3**3
      XI4=1.0D0/AI1**4+1.0D0/AI2**4+1.0D0/AI3**4
      XDET=AI1*AI2*AI3
      XDET2=XDET**2
      XDET3=XDET**3
      XDET4=XDET2**2
      XS1=AI1+AI2+AI3
      XS2=AI1**2+AI2**2+AI3**2
      XS3=AI1**3+AI2**3+AI3**3
      XS4=AI1**4+AI2**4+AI3**4
      XSI=(AI1+AI2)/AI3+(AI2+AI3)/AI1+(AI3+AI1)/AI2
      XSI12=(AI1+AI2)/AI3**2+(AI2+AI3)/AI1**2+(AI3+AI1)/AI2**2
      XSI21=(AI1**2+AI2**2)/AI3+(AI2**2+AI3**2)/AI1+(AI3**2+AI1**2)/AI2
      XSI13=(AI1+AI2)/AI3**3+(AI2+AI3)/AI1**3+(AI3+AI1)/AI2**3
      XSI31=(AI1**3+AI2**3)/AI3+(AI2**3+AI3**3)/AI1+(AI3**3+AI1**3)/AI2
      XSI22=(AI1**2+AI2**2)/AI3**2+(AI2**2+AI3**2)/AI1**2
     &      +(AI3**2+AI1**2)/AI2**2
C
      S3C1=XS1/(6.0D0*XDET)
      S3C2=-XI1/3.0D0
      D3C1=-1.0D0/(3.0D0*XDET)
      D3C2=S3C1
C
      S5C1=(XS2/XDET-XI1)/(30.0D0*XDET)
      S5C2=(1.0D0-XSI)/(30.0D0*XDET)
      S5C3=(3.0D0*XS1/XDET+2.0D0*XI2)/60.0D0
      D5C1=-XS1/XDET2/60.0D0
      D5C2=XI1/XDET/10.0D0-XS2/XDET2/60.0D0
      D5C3=-(9.0D0+XSI)/XDET/60.0D0
C
      S7C1=(4.0D0*XDET+17.0D0*XS3-15.0D0*XDET*XSI)/(2520.0D0*XDET3)
      S7C2=(9.0D0*XS1+10.0D0*XDET*XI2-6.0D0*XSI21)/(420.0D0*XDET2)
      S7C3=((6.0D0*XSI12-1.0D2*XI1)*XDET+53.0D0*XS2)/(2520.0D0*XDET2)
      S7C4=(15.0D0-XDET*XI3-2.0D0*XSI)/(630.0D0*XDET)
      D7C1=(34.0D0*XDET*XI1-19.0D0*XS2)/(2520.0D0*XDET3)
      D7C2=(XS3+2.0D0*XDET*XSI-85.0D0*XDET)/(1260.0D0*XDET3)
      D7C3=(47.0D0*XS1+13.0D0*XSI21-38.0D0*XDET*XI2)/(2520.0D0*XDET2)
      D7C4=(9.0D0*XDET*XI1+XDET*XSI12-11.0D0*XS2)/(1260.0D0*XDET2)
C
      S9C1=(62.0D0*XS4-94.0D0*XDET*XSI21
     &     +66.0D0*XDET2*XI2+81.0D0*XDET*XS1)/(45360.0D0*XDET4)
      S9C2=(-77.0D0*XSI31+75.0D0*XDET*XSI12
     &     +214.0D0*XS2-240.0D0*XDET*XI1)/(22680.0D0*XDET3)
      S9C3=(26.0D0*XDET*XSI22+55.0D0*XS3+204.0D0*XDET
     &     -50.0D0*XDET2*XI3-59.0D0*XDET*XSI)/(7560.0D0*XDET3)
      S9C4=(137.0D0*XDET*XI2-XDET*XSI13
     &     +3.0D0*XS1-69.0D0*XSI21)/(11340.0D0*XDET2)
      S9C5=(2.0D0*XDET2*XI4+5.0D0*XDET*XSI12
     &     -171.0D0*XDET*XI1+159.0D0*XS2)/(45360.0D0*XDET2)
      D9C1=(60.0D0*XSI*XDET-61.0D0*XS3-247.0D0*XDET)/(45360.0D0*XDET4)
      D9C2=(54.0D0*XDET*XS1-XS4+218.0D0*XDET*XSI21
     &     -426.0D0*XDET2*XI2)/(45360.0D0*XDET4)
      D9C3=(125.0D0*XDET*XI1-5.0D0*XSI31-130.0D0*XS2
     &     +4.0D0*XDET*XSI12)/(7560.0D0*XDET3)
      D9C4=(67.0D0*XS3-735.0D0*XDET-15.0D0*XDET*XSI22
     &     +87.0D0*XDET*XSI+34.0D0*XDET2*XI3)/(22680.0D0*XDET3)
      D9C5=(165.0D0*XS1-XDET*XSI13-9.0D0*XSI21
     &     -145.0D0*XDET*XI2)/(45360.0D0*XDET2)
c---
      CALL POTENP(Q,POTP,RPAR,IPAR)
      AM1=AM(1)-HA*POTP(1)
      AM2=AM(2)-HA*POTP(2)
      AM3=AM(3)-HA*POTP(3)
c
      DO ISTEP=1,NSTEP
C ---      COMPUTATION OF THE MODIFIED MOMENTS OF INERTIA
        HAM0=0.5D0*HB**2*(AM1**2/AI1+AM2**2/AI2+AM3**2/AI3)
        ANOR0=0.5D0*HB**2*(AM1**2+AM2**2+AM3**2)
        HAM2=HAM0**2
        ANOR2=ANOR0**2
        HAM3=HAM0**3
        ANOR3=ANOR0**3
        HAM4=HAM2**2
        ANOR4=ANOR2**2
        ANORHAM=HAM0*ANOR0
        ANOR2HAM=HAM0*ANOR2
        ANORHAM2=HAM2*ANOR0
        ANOR3HAM=HAM0*ANOR3
        ANOR2HAM2=HAM2*ANOR2
        ANORHAM3=HAM3*ANOR0
        CSS=1.0D0+(S3C1*ANOR0+S3C2*HAM0)
     &     +(S5C1*ANOR2+S5C2*ANORHAM+S5C3*HAM2)
     &     +(S7C1*ANOR3+S7C2*ANOR2HAM+S7C3*ANORHAM2+S7C4*HAM3)
     &     +(S9C1*ANOR4+S9C2*ANOR3HAM+S9C3*ANOR2HAM2
     &     +S9C4*ANORHAM3+S9C5*HAM4)
        CDD=(D3C1*ANOR0+D3C2*HAM0)
     &     +(D5C1*ANOR2+D5C2*ANORHAM+D5C3*HAM2)
     &     +(D7C1*ANOR3+D7C2*ANOR2HAM+D7C3*ANORHAM2+D7C4*HAM3)
     &     +(D9C1*ANOR4+D9C2*ANOR3HAM+D9C3*ANOR2HAM2
     &     +D9C4*ANORHAM3+D9C5*HAM4)
        AI1MODI=CSS/AI1+CDD
        AI2MODI=CSS/AI2+CDD
        AI3MODI=CSS/AI3+CDD
        AI1MOD=1.0D0/AI1MODI
        AI2MOD=1.0D0/AI2MODI
        AI3MOD=1.0D0/AI3MODI
        FAD1=AI2MOD-AI3MOD
        FAD2=AI3MOD-AI1MOD
        FAD3=AI1MOD-AI2MOD
        FAC1=FAD1*AI1MODI
        FAC2=FAD2*AI2MODI
        FAC3=FAD3*AI3MODI
        DO ISPLIT=1,MSPLIT
C ---      SOLVE FOR INTERNAL STAGE
          AM1I=AM1*HD*AI1MODI
          AM2I=AM2*HD*AI2MODI
          AM3I=AM3*HD*AI3MODI
          CM1=AM1I+FAC1*AM2I*AM3I
          CM2=AM2I+FAC2*CM1*AM3I
          CM3=AM3I+FAC3*CM1*CM2
          DO I=1,50
            CM1B=CM1
            CM2B=CM2
            CM3B=CM3
            CALPHA=1+CM1**2+CM2**2+CM3**2
            CM1=CALPHA*AM1I+FAC1*CM2*CM3
            CM2=CALPHA*AM2I+FAC2*CM1*CM3
            CM3=CALPHA*AM3I+FAC3*CM1*CM2
            ERR=ABS(CM1B-CM1)+ABS(CM2B-CM2)+ABS(CM3B-CM3)
            IF (ERR.LT.EPS) GOTO 22
          END DO
 22       CONTINUE
C ---      UPDATE Q
          Q0=Q(1)
          Q1=Q(2)
          Q2=Q(3)
          Q3=Q(4)
          Q(1)=Q0-CM1*Q1-CM2*Q2-CM3*Q3
          Q(2)=Q1+CM1*Q0+CM3*Q2-CM2*Q3
          Q(3)=Q2+CM2*Q0+CM1*Q3-CM3*Q1
          Q(4)=Q3+CM3*Q0+CM2*Q1-CM1*Q2
C ---       UPDATE M
          CALPHA=HC/CALPHA
          AM1=AM1+FAD1*CM2*CM3*CALPHA
          AM2=AM2+FAD2*CM1*CM3*CALPHA
          AM3=AM3+FAD3*CM1*CM2*CALPHA
        END DO
C ---       PROJECTION
        QUAT=1.0D0/SQRT(Q(1)**2+Q(2)**2+Q(3)**2+Q(4)**2)
        Q(1)=Q(1)*QUAT
        Q(2)=Q(2)*QUAT
        Q(3)=Q(3)*QUAT
        Q(4)=Q(4)*QUAT
C
        CALL POTENP(Q,POTP,RPAR,IPAR)
        AM1=AM1-H*POTP(1)
        AM2=AM2-H*POTP(2)
        AM3=AM3-H*POTP(3)
      END DO
      AM(1)=AM1+HA*POTP(1)
      AM(2)=AM2+HA*POTP(2)
      AM(3)=AM3+HA*POTP(3)
      RETURN
      END
C
C----------------------------------------------------------------------- 
C
      SUBROUTINE DMV2 (AM,Q,POTENP,H,NSTEP,RPAR,IPAR)
C--- DISCRETE MOSER-VESELOV ALGORITHM OF ORDER 2
C--- ORTHOGONAL MATRICES ARE REPRESENTED BY QUATERNIONS
      IMPLICIT REAL*8 (A-H,O-Z) 
      DOUBLE PRECISION Q(4),AM(3),POTP(3)
      DIMENSION IPAR(20),RPAR(20)
      EPS=ABS(1.D-15*H)
      HA=H/2.0D0
      AI1=RPAR(11)
      AI2=RPAR(12)
      AI3=RPAR(13) 
      HC=4.0D0/H
      FAD1=HC*(AI2-AI3)
      FAD2=HC*(AI3-AI1)
      FAD3=HC*(AI1-AI2)
      FAC1=(AI2-AI3)/AI1
      FAC2=(AI3-AI1)/AI2
      FAC3=(AI1-AI2)/AI3
c---
      CALL POTENP(Q,POTP,RPAR,IPAR)
      AM1=AM(1)-HA*POTP(1)
      AM2=AM(2)-HA*POTP(2)
      AM3=AM(3)-HA*POTP(3)
c
      DO ISTEP=1,NSTEP
C ---      SOLVE FOR INTERNAL STAGE
        AM1I=AM1*HA/AI1
        AM2I=AM2*HA/AI2
        AM3I=AM3*HA/AI3
        CM1=AM1I+FAC1*AM2I*AM3I
        CM2=AM2I+FAC2*CM1*AM3I
        CM3=AM3I+FAC3*CM1*CM2
        DO I=1,50
          CM1B=CM1
          CM2B=CM2
          CM3B=CM3
          CALPHA=1+CM1**2+CM2**2+CM3**2
          CM1=CALPHA*AM1I+FAC1*CM2*CM3
          CM2=CALPHA*AM2I+FAC2*CM1*CM3
          CM3=CALPHA*AM3I+FAC3*CM1*CM2
          ERR=ABS(CM1B-CM1)+ABS(CM2B-CM2)+ABS(CM3B-CM3)
          IF (ERR.LT.EPS) GOTO 22
        END DO
 22     CONTINUE
C ---      UPDATE Q
        Q0=Q(1)
        Q1=Q(2)
        Q2=Q(3)
        Q3=Q(4)
        Q(1)=Q0-CM1*Q1-CM2*Q2-CM3*Q3
        Q(2)=Q1+CM1*Q0+CM3*Q2-CM2*Q3
        Q(3)=Q2+CM2*Q0+CM1*Q3-CM3*Q1
        Q(4)=Q3+CM3*Q0+CM2*Q1-CM1*Q2
C ---       PROJECTION
        QUAT=1.0D0/SQRT(Q(1)**2+Q(2)**2+Q(3)**2+Q(4)**2)
        Q(1)=Q(1)*QUAT
        Q(2)=Q(2)*QUAT
        Q(3)=Q(3)*QUAT
        Q(4)=Q(4)*QUAT
C ---       UPDATE M
        CALL POTENP(Q,POTP,RPAR,IPAR)
        AM1=AM1-H*POTP(1)+FAD1*CM2*CM3/CALPHA
        AM2=AM2-H*POTP(2)+FAD2*CM1*CM3/CALPHA
        AM3=AM3-H*POTP(3)+FAD3*CM1*CM2/CALPHA
      END DO
      AM(1)=AM1+HA*POTP(1)
      AM(2)=AM2+HA*POTP(2)
      AM(3)=AM3+HA*POTP(3)
      RETURN
      END
C
      SUBROUTINE DMV4 (AM,Q,POTENP,H,NSTEP,RPAR,IPAR)
C--- PREPROCESSED DISCRETE MOSER-VESELOV ALGORITHM OF ORDER 4
C--- ORTHOGONAL MATRICES ARE REPRESENTED BY QUATERNIONS
      IMPLICIT REAL*8 (A-H,O-Z) 
      DOUBLE PRECISION Q(4),AM(3),POTP(3)
      DIMENSION IPAR(20),RPAR(20)
      EPS=ABS(1.D-15*H)
      HA=H/2.0D0
      AI1=RPAR(11)
      AI2=RPAR(12)
      AI3=RPAR(13) 
      HC=4.0D0/H
C
      XI1=1.0D0/AI1+1.0D0/AI2+1.0D0/AI3
      XDET=AI1*AI2*AI3
      XS1=AI1+AI2+AI3
      S3C1=XS1/(6.0D0*XDET)
      S3C2=-XI1/3.0D0
      D3C1=-1.0D0/(3.0D0*XDET)
      D3C2=S3C1
c---
      CALL POTENP(Q,POTP,RPAR,IPAR)
      AM1=AM(1)-HA*POTP(1)
      AM2=AM(2)-HA*POTP(2)
      AM3=AM(3)-HA*POTP(3)
c
      DO ISTEP=1,NSTEP
        HAM0=0.5D0*(AM1**2/AI1+AM2**2/AI2+AM3**2/AI3)
        ANOR0=0.5D0*(AM1**2+AM2**2+AM3**2)
        CSS=1.0D0+H**2*(S3C1*ANOR0+S3C2*HAM0)
        CDD=H**2*(D3C1*ANOR0+D3C2*HAM0)
        AI1MODI=CSS/AI1+CDD
        AI2MODI=CSS/AI2+CDD
        AI3MODI=CSS/AI3+CDD
        AI1MOD=1.0D0/AI1MODI
        AI2MOD=1.0D0/AI2MODI
        AI3MOD=1.0D0/AI3MODI
        FAD1=AI2MOD-AI3MOD
        FAD2=AI3MOD-AI1MOD
        FAD3=AI1MOD-AI2MOD
        FAC1=FAD1*AI1MODI
        FAC2=FAD2*AI2MODI
        FAC3=FAD3*AI3MODI
C ---      SOLVE FOR INTERNAL STAGE
        AM1I=AM1*HA*AI1MODI
        AM2I=AM2*HA*AI2MODI
        AM3I=AM3*HA*AI3MODI
        CM1=AM1I+FAC1*AM2I*AM3I
        CM2=AM2I+FAC2*CM1*AM3I
        CM3=AM3I+FAC3*CM1*CM2
        DO I=1,50
          CM1B=CM1
          CM2B=CM2
          CM3B=CM3
          CALPHA=1+CM1**2+CM2**2+CM3**2
          CM1=CALPHA*AM1I+FAC1*CM2*CM3
          CM2=CALPHA*AM2I+FAC2*CM1*CM3
          CM3=CALPHA*AM3I+FAC3*CM1*CM2
          ERR=ABS(CM1B-CM1)+ABS(CM2B-CM2)+ABS(CM3B-CM3)
          IF (ERR.LT.EPS) GOTO 22
        END DO
 22     CONTINUE
C ---      UPDATE Q
        Q0=Q(1)
        Q1=Q(2)
        Q2=Q(3)
        Q3=Q(4)
        Q(1)=Q0-CM1*Q1-CM2*Q2-CM3*Q3
        Q(2)=Q1+CM1*Q0+CM3*Q2-CM2*Q3
        Q(3)=Q2+CM2*Q0+CM1*Q3-CM3*Q1
        Q(4)=Q3+CM3*Q0+CM2*Q1-CM1*Q2
C ---       PROJECTION
        QUAT=1.0D0/SQRT(Q(1)**2+Q(2)**2+Q(3)**2+Q(4)**2)
        Q(1)=Q(1)*QUAT
        Q(2)=Q(2)*QUAT
        Q(3)=Q(3)*QUAT
        Q(4)=Q(4)*QUAT
C ---       UPDATE M
        CALL POTENP(Q,POTP,RPAR,IPAR)
        CALPHA=HC/CALPHA
        AM1=AM1-H*POTP(1)+FAD1*CM2*CM3*CALPHA
        AM2=AM2-H*POTP(2)+FAD2*CM1*CM3*CALPHA
        AM3=AM3-H*POTP(3)+FAD3*CM1*CM2*CALPHA
      END DO
      AM(1)=AM1+HA*POTP(1)
      AM(2)=AM2+HA*POTP(2)
      AM(3)=AM3+HA*POTP(3)
      RETURN
      END
C
      SUBROUTINE DMV6 (AM,Q,POTENP,H,NSTEP,RPAR,IPAR)
C--- PREPROCESSED DISCRETE MOSER-VESELOV ALGORITHM OF ORDER 6
C--- ORTHOGONAL MATRICES ARE REPRESENTED BY QUATERNIONS
      IMPLICIT REAL*8 (A-H,O-Z) 
      DOUBLE PRECISION Q(4),AM(3),POTP(3)
      DIMENSION IPAR(20),RPAR(20)
      EPS=ABS(1.D-15*H)
      HA=H/2.0D0
      AI1=RPAR(11)
      AI2=RPAR(12)
      AI3=RPAR(13) 
      HC=4.0D0/H
C
      XI1=1.0D0/AI1+1.0D0/AI2+1.0D0/AI3
      XI2=1.0D0/AI1**2+1.0D0/AI2**2+1.0D0/AI3**2
      XDET=AI1*AI2*AI3
      XS1=AI1+AI2+AI3
      XS2=AI1**2+AI2**2+AI3**2
      XSI=(AI1+AI2)/AI3+(AI2+AI3)/AI1+(AI3+AI1)/AI2
      XSJ=AI1/AI2/AI3+AI2/AI3/AI1+AI3/AI1/AI2
C
      S3C1=XS1/(6.0D0*XDET)
      S3C2=-XI1/3.0D0
      D3C1=-1.0D0/(3.0D0*XDET)
      D3C2=S3C1
C
      S5C1=(XS2/XDET-XI1)/(30.0D0*XDET)
      S5C2=(1.0D0-XSI)/(30.0D0*XDET)
      S5C3=(3.0D0*XS1/XDET+2.0D0*XI2)/60.0D0
      D5C1=-XS1/XDET**2/60.0D0
      D5C2=XI1/XDET/10.0D0-XS2/XDET**2/60.0D0
      D5C3=-(9.0D0+XSI)/XDET/60.0D0
c---
      CALL POTENP(Q,POTP,RPAR,IPAR)
      AM1=AM(1)-HA*POTP(1)
      AM2=AM(2)-HA*POTP(2)
      AM3=AM(3)-HA*POTP(3)
c
      DO ISTEP=1,NSTEP
        HAM0=0.5D0*H**2*(AM1**2/AI1+AM2**2/AI2+AM3**2/AI3)
        ANOR0=0.5D0*H**2*(AM1**2+AM2**2+AM3**2)
        HAM2=HAM0**2
        ANOR2=ANOR0**2
        ANORHAM=HAM0*ANOR0
        CSS=1.0D0+(S3C1*ANOR0+S3C2*HAM0)
     &     +(S5C1*ANOR2+S5C2*ANORHAM+S5C3*HAM2)
        CDD=(D3C1*ANOR0+D3C2*HAM0)
     &     +(D5C1*ANOR2+D5C2*ANORHAM+D5C3*HAM2)
        AI1MODI=CSS/AI1+CDD
        AI2MODI=CSS/AI2+CDD
        AI3MODI=CSS/AI3+CDD
        AI1MOD=1.0D0/AI1MODI
        AI2MOD=1.0D0/AI2MODI
        AI3MOD=1.0D0/AI3MODI
        FAD1=AI2MOD-AI3MOD
        FAD2=AI3MOD-AI1MOD
        FAD3=AI1MOD-AI2MOD
        FAC1=FAD1*AI1MODI
        FAC2=FAD2*AI2MODI
        FAC3=FAD3*AI3MODI
C ---      SOLVE FOR INTERNAL STAGE
        AM1I=AM1*HA*AI1MODI
        AM2I=AM2*HA*AI2MODI
        AM3I=AM3*HA*AI3MODI
        CM1=AM1I+FAC1*AM2I*AM3I
        CM2=AM2I+FAC2*CM1*AM3I
        CM3=AM3I+FAC3*CM1*CM2
        DO I=1,50
          CM1B=CM1
          CM2B=CM2
          CM3B=CM3
          CALPHA=1+CM1**2+CM2**2+CM3**2
          CM1=CALPHA*AM1I+FAC1*CM2*CM3
          CM2=CALPHA*AM2I+FAC2*CM1*CM3
          CM3=CALPHA*AM3I+FAC3*CM1*CM2
          ERR=ABS(CM1B-CM1)+ABS(CM2B-CM2)+ABS(CM3B-CM3)
          IF (ERR.LT.EPS) GOTO 22
        END DO
 22     CONTINUE
C ---      UPDATE Q
        Q0=Q(1)
        Q1=Q(2)
        Q2=Q(3)
        Q3=Q(4)
        Q(1)=Q0-CM1*Q1-CM2*Q2-CM3*Q3
        Q(2)=Q1+CM1*Q0+CM3*Q2-CM2*Q3
        Q(3)=Q2+CM2*Q0+CM1*Q3-CM3*Q1
        Q(4)=Q3+CM3*Q0+CM2*Q1-CM1*Q2
C ---       PROJECTION
        QUAT=1.0D0/SQRT(Q(1)**2+Q(2)**2+Q(3)**2+Q(4)**2)
        Q(1)=Q(1)*QUAT
        Q(2)=Q(2)*QUAT
        Q(3)=Q(3)*QUAT
        Q(4)=Q(4)*QUAT
C ---       UPDATE M
        CALL POTENP(Q,POTP,RPAR,IPAR)
        CALPHA=HC/CALPHA
        AM1=AM1-H*POTP(1)+FAD1*CM2*CM3*CALPHA
        AM2=AM2-H*POTP(2)+FAD2*CM1*CM3*CALPHA
        AM3=AM3-H*POTP(3)+FAD3*CM1*CM2*CALPHA
      END DO
      AM(1)=AM1+HA*POTP(1)
      AM(2)=AM2+HA*POTP(2)
      AM(3)=AM3+HA*POTP(3)
      RETURN
      END
C
      SUBROUTINE DMV8 (AM,Q,POTENP,H,NSTEP,RPAR,IPAR)
C--- PREPROCESSED DISCRETE MOSER-VESELOV ALGORITHM OF ORDER 8
C--- ORTHOGONAL MATRICES ARE REPRESENTED BY QUATERNIONS
      IMPLICIT REAL*8 (A-H,O-Z) 
      DOUBLE PRECISION Q(4),AM(3),POTP(3)
      DIMENSION IPAR(20),RPAR(20)
      EPS=ABS(1.D-15*H)
      HA=H/2.0D0
      AI1=RPAR(11)
      AI2=RPAR(12)
      AI3=RPAR(13) 
      HC=4.0D0/H
C---      CONSTANT COEFFICIENTS FOR THE MODIFIED MOMENTS OF INERTIA
      XI1=1.0D0/AI1+1.0D0/AI2+1.0D0/AI3
      XI2=1.0D0/AI1**2+1.0D0/AI2**2+1.0D0/AI3**2
      XI3=1.0D0/AI1**3+1.0D0/AI2**3+1.0D0/AI3**3
      XDET=AI1*AI2*AI3
      XS1=AI1+AI2+AI3
      XS2=AI1**2+AI2**2+AI3**2
      XS3=AI1**3+AI2**3+AI3**3
      XSI=(AI1+AI2)/AI3+(AI2+AI3)/AI1+(AI3+AI1)/AI2
      XSI12=(AI1+AI2)/AI3**2+(AI2+AI3)/AI1**2+(AI3+AI1)/AI2**2
      XSI21=(AI1**2+AI2**2)/AI3+(AI2**2+AI3**2)/AI1+(AI3**2+AI1**2)/AI2
C
      S3C1=XS1/(6.0D0*XDET)
      S3C2=-XI1/3.0D0
      D3C1=-1.0D0/(3.0D0*XDET)
      D3C2=S3C1
C
      S5C1=(XS2/XDET-XI1)/(30.0D0*XDET)
      S5C2=(1.0D0-XSI)/(30.0D0*XDET)
      S5C3=(3.0D0*XS1/XDET+2.0D0*XI2)/60.0D0
      D5C1=-XS1/XDET**2/60.0D0
      D5C2=XI1/XDET/10.0D0-XS2/XDET**2/60.0D0
      D5C3=-(9.0D0+XSI)/XDET/60.0D0
C
      S7C1=(4.0D0*XDET+17.0D0*XS3-15.0D0*XDET*XSI)/(2520.0D0*XDET**3)
      S7C2=(9.0D0*XS1+10.0D0*XDET*XI2-6.0D0*XSI21)/(420.0D0*XDET**2)
      S7C3=((6.0D0*XSI12-1.0D2*XI1)*XDET+53.0D0*XS2)/(2520.0D0*XDET**2)
      S7C4=(15.0D0-XDET*XI3-2.0D0*XSI)/(630.0D0*XDET)
      D7C1=(34.0D0*XDET*XI1-19.0D0*XS2)/(2520.0D0*XDET**3)
      D7C2=(XS3+2.0D0*XDET*XSI-85.0D0*XDET)/(1260.0D0*XDET**3)
      D7C3=(47.0D0*XS1+13.0D0*XSI21-38.0D0*XDET*XI2)/(2520.0D0*XDET**2)
      D7C4=(9.0D0*XDET*XI1+XDET*XSI12-11.0D0*XS2)/(1260.0D0*XDET**2)
c---
      CALL POTENP(Q,POTP,RPAR,IPAR)
      AM1=AM(1)-HA*POTP(1)
      AM2=AM(2)-HA*POTP(2)
      AM3=AM(3)-HA*POTP(3)
c
      DO ISTEP=1,NSTEP
C ---      COMPUTATION OF THE MODIFIED MOMENTS OF INERTIA
        HAM0=0.5D0*H**2*(AM1**2/AI1+AM2**2/AI2+AM3**2/AI3)
        ANOR0=0.5D0*H**2*(AM1**2+AM2**2+AM3**2)
        HAM2=HAM0**2
        ANOR2=ANOR0**2
        HAM3=HAM0**3
        ANOR3=ANOR0**3
        ANORHAM=HAM0*ANOR0
        ANOR2HAM=HAM0*ANOR2
        ANORHAM2=HAM2*ANOR0
        CSS=1.0D0+(S3C1*ANOR0+S3C2*HAM0)
     &     +(S5C1*ANOR2+S5C2*ANORHAM+S5C3*HAM2)
     &     +(S7C1*ANOR3+S7C2*ANOR2HAM+S7C3*ANORHAM2+S7C4*HAM3)
        CDD=(D3C1*ANOR0+D3C2*HAM0)
     &     +(D5C1*ANOR2+D5C2*ANORHAM+D5C3*HAM2)
     &     +(D7C1*ANOR3+D7C2*ANOR2HAM+D7C3*ANORHAM2+D7C4*HAM3)
        AI1MODI=CSS/AI1+CDD
        AI2MODI=CSS/AI2+CDD
        AI3MODI=CSS/AI3+CDD
        AI1MOD=1.0D0/AI1MODI
        AI2MOD=1.0D0/AI2MODI
        AI3MOD=1.0D0/AI3MODI
        FAD1=AI2MOD-AI3MOD
        FAD2=AI3MOD-AI1MOD
        FAD3=AI1MOD-AI2MOD
        FAC1=FAD1*AI1MODI
        FAC2=FAD2*AI2MODI
        FAC3=FAD3*AI3MODI
C ---      SOLVE FOR INTERNAL STAGE
        AM1I=AM1*HA*AI1MODI
        AM2I=AM2*HA*AI2MODI
        AM3I=AM3*HA*AI3MODI
        CM1=AM1I+FAC1*AM2I*AM3I
        CM2=AM2I+FAC2*CM1*AM3I
        CM3=AM3I+FAC3*CM1*CM2
        DO I=1,50
          CM1B=CM1
          CM2B=CM2
          CM3B=CM3
          CALPHA=1+CM1**2+CM2**2+CM3**2
          CM1=CALPHA*AM1I+FAC1*CM2*CM3
          CM2=CALPHA*AM2I+FAC2*CM1*CM3
          CM3=CALPHA*AM3I+FAC3*CM1*CM2
          ERR=ABS(CM1B-CM1)+ABS(CM2B-CM2)+ABS(CM3B-CM3)
          IF (ERR.LT.EPS) GOTO 22
        END DO
 22     CONTINUE
C ---      UPDATE Q
        Q0=Q(1)
        Q1=Q(2)
        Q2=Q(3)
        Q3=Q(4)
        Q(1)=Q0-CM1*Q1-CM2*Q2-CM3*Q3
        Q(2)=Q1+CM1*Q0+CM3*Q2-CM2*Q3
        Q(3)=Q2+CM2*Q0+CM1*Q3-CM3*Q1
        Q(4)=Q3+CM3*Q0+CM2*Q1-CM1*Q2
C ---       PROJECTION
        QUAT=1.0D0/SQRT(Q(1)**2+Q(2)**2+Q(3)**2+Q(4)**2)
        Q(1)=Q(1)*QUAT
        Q(2)=Q(2)*QUAT
        Q(3)=Q(3)*QUAT
        Q(4)=Q(4)*QUAT
C ---       UPDATE M
        CALL POTENP(Q,POTP,RPAR,IPAR)
        CALPHA=HC/CALPHA
        AM1=AM1-H*POTP(1)+FAD1*CM2*CM3*CALPHA
        AM2=AM2-H*POTP(2)+FAD2*CM1*CM3*CALPHA
        AM3=AM3-H*POTP(3)+FAD3*CM1*CM2*CALPHA
      END DO
      AM(1)=AM1+HA*POTP(1)
      AM(2)=AM2+HA*POTP(2)
      AM(3)=AM3+HA*POTP(3)
      RETURN
      END

