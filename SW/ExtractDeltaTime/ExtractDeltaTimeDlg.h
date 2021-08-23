// ExtractDeltaTimeDlg.h : header file
//

#pragma once


// CExtractDeltaTimeDlg dialog
class CExtractDeltaTimeDlg : public CDialog
{
// Construction
public:
	CExtractDeltaTimeDlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	enum { IDD = IDD_EXTRACTDELTATIME_DIALOG };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support


// Implementation
protected:
	HICON m_hIcon;

	// Generated message map functions
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	DECLARE_MESSAGE_MAP()
public:
	afx_msg void OnBnClickedButton1();
	CString m_path;
	afx_msg void OnBnClickedButton2();
	int m_sampleRate;
	CString m_ll;
	CString m_lr;
	CString m_ul;
	CString m_ur;
};
