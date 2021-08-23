// TargetGraphDoc.h : interface of the CTargetGraphDoc class
//


#pragma once

class CTargetGraphDoc : public CDocument
{
protected: // create from serialization only
	CTargetGraphDoc();
	DECLARE_DYNCREATE(CTargetGraphDoc)

// Attributes
public:

// Operations
public:

// Overrides
	public:
	virtual BOOL OnNewDocument();
	virtual void Serialize(CArchive& ar);

// Implementation
public:
	virtual ~CTargetGraphDoc();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

protected:

// Generated message map functions
protected:
	DECLARE_MESSAGE_MAP()
};


