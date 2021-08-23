// ExtractDeltaTimeDlg.cpp : implementation file
//

#include "stdafx.h"
#include "ExtractDeltaTime.h"
#include "ExtractDeltaTimeDlg.h"
#include ".\extractdeltatimedlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CAboutDlg dialog used for App About

class CAboutDlg : public CDialog
{
public:
	CAboutDlg();

// Dialog Data
	enum { IDD = IDD_ABOUTBOX };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

// Implementation
protected:
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialog(CAboutDlg::IDD)
{
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialog)
END_MESSAGE_MAP()


// CExtractDeltaTimeDlg dialog



CExtractDeltaTimeDlg::CExtractDeltaTimeDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CExtractDeltaTimeDlg::IDD, pParent)
	, m_path(_T(""))
	, m_sampleRate(600000)
	, m_ll(_T(""))
	, m_lr(_T(""))
	, m_ul(_T(""))
	, m_ur(_T(""))
{
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CExtractDeltaTimeDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Text(pDX, IDC_EDIT1, m_path);
	DDX_Text(pDX, IDC_SAMPLE_RATE, m_sampleRate);
	DDV_MinMaxInt(pDX, m_sampleRate, 0, 30000000);
	DDX_Text(pDX, IDC_LL, m_ll);
	DDX_Text(pDX, IDC_LR, m_lr);
	DDX_Text(pDX, IDC_UL, m_ul);
	DDX_Text(pDX, IDC_UR, m_ur);
}

BEGIN_MESSAGE_MAP(CExtractDeltaTimeDlg, CDialog)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	//}}AFX_MSG_MAP
	ON_BN_CLICKED(IDC_BUTTON1, OnBnClickedButton1)
	ON_BN_CLICKED(IDC_BUTTON2, OnBnClickedButton2)
END_MESSAGE_MAP()


// CExtractDeltaTimeDlg message handlers

BOOL CExtractDeltaTimeDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// Add "About..." menu item to system menu.

	// IDM_ABOUTBOX must be in the system command range.
	ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	ASSERT(IDM_ABOUTBOX < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != NULL)
	{
		CString strAboutMenu;
		strAboutMenu.LoadString(IDS_ABOUTBOX);
		if (!strAboutMenu.IsEmpty())
		{
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
		}
	}

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon

	// TODO: Add extra initialization here
	
	return TRUE;  // return TRUE  unless you set the focus to a control
}

void CExtractDeltaTimeDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == IDM_ABOUTBOX)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialog::OnSysCommand(nID, lParam);
	}
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CExtractDeltaTimeDlg::OnPaint() 
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, reinterpret_cast<WPARAM>(dc.GetSafeHdc()), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	}
}

// The system calls this function to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CExtractDeltaTimeDlg::OnQueryDragIcon()
{
	return static_cast<HCURSOR>(m_hIcon);
}

void CExtractDeltaTimeDlg::OnBnClickedButton1()
{
	UpdateData(TRUE);
	// TODO: Add your control notification handler code here
	CFileDialog	fd(TRUE, "*.CSV", NULL, OFN_FILEMUSTEXIST, "Comma Seperated Values (*.csv)|*.csv|All Files (*.*)|*.*||");

	if (fd.DoModal() == IDOK) {
		m_path = fd.GetPathName();
		UpdateData(FALSE);
	}
}

void CExtractDeltaTimeDlg::OnBnClickedButton2()
{
	// TODO: Add your control notification handler code here

	UpdateData(TRUE);

	FILE*	fp;
	int		a, b, c, d, i;
	int		ll, lr, ul, ur;
	int		oll = 0, olr = 0, oul = 0, our = 0;
	int		tll = 0;
	int		tlr = 0;
	int		tul = 0;
	int		tur = 0;

	if (m_path == "") {
		MessageBox("Please select file to analyse", "Error");
		return;
	}

	fp = fopen(m_path, "rt");
	if (fp) {
		i = 0;
		while (!feof(fp)) {
			fscanf(fp, "%d\t%d\t%d\t%d\n", &a, &b, &c, &d);
			ll = (d >> 4) & 0x01;
			lr = (d >> 6) & 0x01;
			ul = (d >> 2) & 0x01;
			ur = d & 0x01;

			if ((tll == 0) && (ll == 1) && (oll == 0)) tll = i;
			if ((tlr == 0) && (lr == 1) && (olr == 0)) tlr = i;
			if ((tur == 0) && (ur == 1) && (our == 0)) tur = i;
			if ((tul == 0) && (ul == 1) && (oul == 0)) tul = i;

			oll = ll; olr = lr; oul = ul; our = ur;
			i++;
		}
		fclose(fp);

		int minT = min( min(tll, tlr), min(tul, tur));

		m_ll.Format("%2.2f", (double) (tll - minT) / (double) m_sampleRate * 1000000.0);
		m_lr.Format("%2.2f", (double) (tlr - minT) / (double) m_sampleRate * 1000000.0);
		m_ur.Format("%2.2f", (double) (tur - minT) / (double) m_sampleRate * 1000000.0);
		m_ul.Format("%2.2f", (double) (tul - minT) / (double) m_sampleRate * 1000000.0);
		UpdateData(FALSE);
	}
}
