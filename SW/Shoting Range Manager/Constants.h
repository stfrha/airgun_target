#pragma once

#include	"math.h"

#define pi				3.1415926535897932384626433832795

#define	ACN_SONIC_SPEED	343.59999999999996  /* [m/s] */

#define ACN_NUMOF_PATH_PNTS	50
#define	ACN_PATH_PNTS_DELTA	1000.0			/* 10 mm [0.01 mm] */

//#define	CENTER_MIC_DIST		7159.46
#define	CENTER_MIC_DIST		7000

#define UNCAL_UL_MICPOS		CTargetPoint(-CENTER_MIC_DIST, CENTER_MIC_DIST)
#define UNCAL_UR_MICPOS		CTargetPoint(CENTER_MIC_DIST, CENTER_MIC_DIST)
#define UNCAL_LL_MICPOS		CTargetPoint(-CENTER_MIC_DIST, -CENTER_MIC_DIST)
#define UNCAL_LR_MICPOS		CTargetPoint(CENTER_MIC_DIST, -CENTER_MIC_DIST)

#define DEF_SAMPLERATE		40000000

#define	ORIGO_POS			CTargetPoint(8000.0, -8000.0)

#define TOP_PATH_INDEX		0x01
#define RIGHT_PATH_INDEX	0x02
#define BOTTOM_PATH_INDEX	0x04
#define LEFT_PATH_INDEX		0x08

// Diagonal line start position (x)
#define DIAGONAL_START_X	-10000.0
#define DIAGONAL_LEN		50000.0

// INTERSECTION_CIRCLE_RADIUS:
#define ICR					225			

// View displacement of target origo
#define DO					CTargetPoint(20000.0, -20000.0)
//#define DO					CTargetPoint(0.0, 0.0)

// Target file defines:
#define	TARGET_FILE_EXT		"*.tdf"
#define TARGET_FILE_DEF		"Target definition file (*.tdf)|*.tdf|All Files (*.*)|*.*||"

//#define ACN_NUMOF_PATH_PNTS	2
//#define	ACN_PATH_PNTS_DELTA	500

// TargetGraphView Mouse Activiy
#define TGV_MA_IDLE			0x01
#define TGV_MA_SET_POINT	0x02

