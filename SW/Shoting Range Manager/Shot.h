#pragma once
#include "afx.h"

#include "TargetPoint.h"
#include "Constants.h"
#include "Target.h"

#include "resource.h" /// Varför behövs denna här! Snälla hjälp mig!!!!
#include "ViewStpDlg.h"

// Shot info definition
#define	SID_TOP				0x01
#define	SID_RIGHT			0x02
#define	SID_BOTTOM			0x03
#define	SID_LEFT			0x04

// Diagonal slope index
#define DSI_POSITIVE_SLOPE	0x01
#define DSI_NEGATIVE_SLOPE	0x02

class CShot :
	public CObject
{
public:
	CShot(void);
	CShot(CTargetHW* docTarget);
	~CShot(void);

	void Serialize( CArchive& archive );

	DECLARE_SERIAL(CShot)

	void			UpdateShotData(CString name, double llt, double lrt, double ult, double urt, CTime time);
	void			UpdateHitPoint(CTargetPoint hitPoint);
	void			UpdateTargetReference(CTargetHW* docTarget) {m_docTarget = docTarget; }
	double			CalcShot( void );
	void			DrawShot(CDC* dc, CViewStpDlg* viewSetup);	


	CString			GetName( void ) {return m_name;}
	CTargetPoint	GetHitPoint( void ) { return m_hitPoint; }
	CTargetPoint	GetCalcHitPoint( void ) { return m_avgTargetPoint; }
	CString			GetInfoString( void );
	void			SetSelection( bool selected) { m_selected = selected; }
	bool			GetSelection( void ) { return m_selected; }
	double			GetDistanceToShot( CTargetPoint point );
	CString			GetShotInfo( void );

private:
    // The following members are saved (serialized) and is the core info of the shot
	// Schema 2
	CString			m_name;
	bool			m_hitPointValid;
	CTargetPoint	m_hitPoint;
public:									// Public access required for dialog data transfer
	double			m_llt;				// [us]
	double			m_lrt;				// [us]
	double			m_ult;				// [us]
	double			m_urt;				// [us]
private:
	// Added in schema 3
	CTime			m_time;
	// Added in schema 4
public:									// Public access required for dialog data transfer
	BOOL			m_foldedPaper;
	BOOL			m_shotInShot;
	CString			m_comment;

private:
    // The following members are derived at run time and are not saved (serialized)
	CTargetPoint	m_topPath[ACN_NUMOF_PATH_PNTS];
	CTargetPoint	m_leftPath[ACN_NUMOF_PATH_PNTS];
	CTargetPoint	m_bottomPath[ACN_NUMOF_PATH_PNTS];
	CTargetPoint	m_rightPath[ACN_NUMOF_PATH_PNTS];
	CTargetPoint	m_intSectTopRight;
	CTargetPoint	m_intSectTopLeft;
	CTargetPoint	m_intSectBottomRight;
	CTargetPoint	m_intSectBottomLeft;
	CTargetPoint	m_avgTargetPoint;
	CTargetPoint	m_posSlopeDiagLeft;
	CTargetPoint	m_posSlopeDiagRight;
	CTargetPoint	m_negSlopeDiagLeft;
	CTargetPoint	m_negSlopeDiagRight;
	double			m_errorDistance;
	CTargetHW*		m_docTarget;
	bool			m_selected;
	bool			m_shotValid;
public:									// Public access required for dialog data transfer
	BOOL			m_ulMicActive;
	BOOL			m_urMicActive;
	BOOL			m_llMicActive;
	BOOL			m_lrMicActive;
private:
	int				CalcShotPath(int pathIndex, double deltaTime, CTargetPoint leftMicPos, CTargetPoint rightMicPos, CTargetPoint* path);
	bool			FindIntersections(CTargetPoint* path1, CTargetPoint* path2, CTargetPoint* intersectionPoint);
	bool			CalcLineIntersection(CTargetPoint l1p1, CTargetPoint l1p2, CTargetPoint l2p1, CTargetPoint l2p2, CTargetPoint* intPoint);
	bool			CalcAverageHitPoint(bool topRightOk, bool topLeftOk, bool bottomRightOk, bool bottomLeftOk);
	void			CalcDiagonals(double deltaTime, int diagonalSlopeIndex, CTargetPoint* left, CTargetPoint* right);
	void			CalcMicHeight(double deltaTime, CTargetPoint xy, double* h, int micPair);
	bool			IsDeltaTimesWithinTarget( void );
	double			LeastDeltaDistance(double time1, double time2);
	double			MicDistance(int pathIndex);
	void			DrawPath(CDC* dc, CTargetPoint* path, COLORREF c);
	void			DrawShotRing(CDC* dc, CTargetPoint p, COLORREF cNormal, COLORREF cSelected);
	void			DrawShotLine(CDC* dc, CTargetPoint p1, CTargetPoint p2, COLORREF cNormal, COLORREF cSelected);
};
