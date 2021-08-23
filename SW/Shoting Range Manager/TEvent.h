#pragma once
#include "afx.h"
#include "EventSeries.h"

class CTEvent :
	public CObject
{
public:
	CTEvent(void);
	~CTEvent(void);
	void			Serialize(CArchive &ar);
	DECLARE_SERIAL(CTEvent)

protected:
	CString			m_name;
	CString			m_description;
	CTypedPtrList<CObList, CEventSeries*>	m_eventSeries;
	CEventSeries*	m_activeEventSeries;
};
