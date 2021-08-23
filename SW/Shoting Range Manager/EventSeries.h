#pragma once
#include "afx.h"
#include "PlayerSeries.h"

class CEventSeries :
	public CObject
{
public:
	CEventSeries(void);
	~CEventSeries(void);
	void				Serialize(CArchive &ar);
	DECLARE_SERIAL(CPlayerSeries)

protected:
	CTypedPtrList<CObList, CPlayerSeries*>	m_series; // One for each player of this series
	CSeriesType*		m_seriesType;

};
