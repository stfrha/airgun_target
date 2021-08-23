#pragma once
#include "afx.h"

#include "TEvent.h"

class CTournament :
	public CObject
{
public:
	CTournament(void);
	~CTournament(void);
	void			Serialize(CArchive &ar);
	DECLARE_SERIAL(CTournament)

protected:
	CString			m_name;
	CString			m_description;
	CTypedPtrList<CObList, CTEvent*>	m_events;
	CTEvent*		m_activeEvent;
};
