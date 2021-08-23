#pragma once
#include "afx.h"

#include "TargetPoint.h"

class CTargetHW :
	public CObject
{
public:
	CTargetHW(void);
	CTargetHW(CTargetHW& copy);
	~CTargetHW(void);

	void Serialize( CArchive& archive );
	DECLARE_SERIAL(CTargetHW)

	void ReinitializeTarget( void );

	CTargetHW& operator=(const CTargetHW& other);

	CString			m_pathName;

	CTargetPoint	m_llMicPos;
	CTargetPoint	m_lrMicPos;
	CTargetPoint	m_ulMicPos;
	CTargetPoint	m_urMicPos;

	int				m_sampleRate;
	int				m_sonicSpeed;
};
