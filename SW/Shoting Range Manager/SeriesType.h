#pragma once
#include "afx.h"


class CScoreRing :
	public CObject
{
public:
	CScoreRing(void);
	~CScoreRing(void);
	void		Serialize(CArchive &ar);
	DECLARE_SERIAL(CScoreRing)

	double		GetDiameter( void ) { return m_diameter; }
	int			GetScore( void ) { return m_score; }
	int			GetPenalty( void ) { return m_penalty; }
	void		SetDiameter( double diameter ) { m_diameter = diameter; }
	void		SetColor( COLORREF color ) { m_color = color; }
	void		SetScore( int score) { m_score = score; }
	void		SetPenalty( int penalty ) { m_penalty = penalty; }
protected:
// Version Schema 1
	double		m_diameter;				// [0.01mm]
	COLORREF	m_color;
	int			m_score;
	int			m_penalty;
};

// Penalty unit indicies
#define ST_PU_NONE	0x00
#define ST_PU_TIME	0x01
#define ST_PU_DIST	0x02



class CSeriesType :
	public CObject
{
public:
	CSeriesType(void);
	~CSeriesType(void);
	void		Serialize(CArchive &ar);
	DECLARE_SERIAL(CSeriesType)

protected:

// Version Schema 1
	CString		m_name;
	CString		m_description;
	CTypedPtrList<CObList, CScoreRing*>	m_scoreRings;
	BOOL		m_biathlon;
	CTime		m_penaltyTime;
	double		m_penaltyDistance;
	int			m_penaltyUnit;			// ST_PU_NONE, ST_PU_TIME or ST_PU_DIST
	BOOL		m_usePenalty;
};
