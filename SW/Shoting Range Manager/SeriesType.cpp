#include "StdAfx.h"
#include ".\seriestype.h"

CScoreRing::CScoreRing(void)
{
}

CScoreRing::~CScoreRing(void)
{
}

IMPLEMENT_SERIAL(CScoreRing, CObject, VERSIONABLE_SCHEMA | 1)

void	CScoreRing::Serialize(CArchive &ar)
{
	if (ar.IsStoring) {
		ar << m_diameter;
		ar << m_color;
		ar << m_score;
		ar << m_penalty;
	} else {
		ar >> m_diameter;
		ar >> m_color;
		ar >> m_score;
		ar >> m_penalty;
	}
}



CSeriesType::CSeriesType(void)
{
	m_biathlon = FALSE;
	m_usePenalty = FALSE;
	m_name = "None";
	m_description = "N/A";
}

CSeriesType::~CSeriesType(void)
{
	// The CSeriesType object is the only pointers to the individual CScoreRings and thus should
	// erase them on completeion.
	while (!m_scoreRings.IsEmpty()) {
		delete m_scoreRings.GetHead();
		m_scoreRings.RemoveHead();
	}
}

IMPLEMENT_SERIAL(CSeriesType, CObject, VERSIONABLE_SCHEMA | 1)



