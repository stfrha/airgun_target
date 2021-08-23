#pragma once
#include "afx.h"

class CPlayer :
	public CObject
{
public:
	CPlayer(void);
	~CPlayer(void);
	void		Serialize(CArchive &ar);
	DECLARE_SERIAL(CPlayer)

protected:
	CString		m_name;
	BOOL		m_female;
	CString		m_nation;
	int			m_age;
	CString		m_club;
};
