#pragma once

#include	"math.h"

#define pi				3.1415926535897932384626433832795

#define ACN_SL			1000.0							/* Side lenght = Distance between sensors, [0.1mm] */
#define ACN_OA_OFFSET	CTargetPoint(400.0, -1600.0)

#define	ACN_ORIGO_A		CTargetPoint(0.0, 0.0)
#define ACN_ORIGO_B		CTargetPoint(ACN_SL*cos(3.0*pi/5.0), ACN_SL*sin(3.0*pi/5.0))
#define ACN_ORIGO_C		CTargetPoint(ACN_SL/2.0, ACN_SL*sin(pi/5.0) + ACN_SL*sin(3.0*pi/5.0))
#define ACN_ORIGO_D		CTargetPoint(ACN_SL - ACN_SL*cos(3.0*pi/5.0), ACN_SL*sin(3.0*pi/5.0))
#define	ACN_ORIGO_E		CTargetPoint(ACN_SL, 0.0)

#define	ACN_RTF_AE_BA	-2.0*pi/5.0
#define	ACN_RTF_AE_CB	-4.0*pi/5.0
#define	ACN_RTF_AE_DC	-6.0*pi/5.0
#define	ACN_RTF_AE_ED	-8.0*pi/5.0

#define ACN_CENTER_PNT	CTargetPoint(ACN_SL / 2.0, ACN_SL / 2.0 * tan(3.0 * pi / 10.0))

#define	ACN_SONIC_SPEED	331.4							/* [m/s] */ 

#define ACN_NUMOF_PATH_PNTS	100
#define	ACN_PATH_PNTS_DELTA	10
//#define ACN_NUMOF_PATH_PNTS	2
//#define	ACN_PATH_PNTS_DELTA	500
