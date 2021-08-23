// SRMDoc.h : interface of the CSRMDoc class
//
#pragma once

#include "DlgScoreRing.h"
#include "Tournament.h"
#include "Player.h"
#include "SeriesType.h"
#include "TargetHW.h"

class CSRMDoc : public CDocument
{
protected: // create from serialization only
	CSRMDoc();
	DECLARE_DYNCREATE(CSRMDoc)

// Attributes saved by serialization:
protected:
	CTypedPtrList<CObList, CTournament*>	m_tournaments;
	CTournament*	m_activeTournament;
	CTypedPtrList<CObList, CPlayer*>		m_players;
	CTypedPtrList<CObList, CSeriesType*>	m_seriesTypes;
	CTypedPtrList<CObList, CTargetHW*>		m_targetHWs;

	CDlgScoreRing	m_scoreRingDlg;

// Operations
public:

// Overrides
	public:
	virtual BOOL OnNewDocument();
	virtual void Serialize(CArchive& ar);

// Implementation
public:
	virtual ~CSRMDoc();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

protected:

// Generated message map functions
protected:
	DECLARE_MESSAGE_MAP()
public:
	afx_msg void OnDebugScoreringdialog();
};


