#pragma once
#include "ColorButton.h"

// CDlgScoreRing dialog

class CDlgScoreRing : public CDialog
{
	DECLARE_DYNAMIC(CDlgScoreRing)

public:
	CDlgScoreRing(CWnd* pParent = NULL);   // standard constructor
	virtual ~CDlgScoreRing();

// Dialog Data
	enum { IDD = IDD_SCORE_RING_DIALOG };

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

	DECLARE_MESSAGE_MAP()
public:
	double			m_diameter;
	int				m_score;
	int				m_penalty;
	CColorButton	m_colorPicker;
	COLORREF		m_color;
};
