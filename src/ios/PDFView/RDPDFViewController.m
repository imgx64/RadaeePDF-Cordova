//
//  RDPDFViewController.m
//  PDFViewer
//
//  Created by Radaee on 12-10-29.
//  Copyright (c) 2012年 Radaee. All rights reserved.
//

#import "RDPDFViewController.h"
#import "ViewModeTableViewController.h"
#import "RDExtendedSearch.h"
#import "SearchResultTableViewController.h"
#import <AVKit/AVKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ViewModeTableViewController.h"
#import "DrawModeTableViewController.h"
#import "SignatureViewController.h"

typedef enum {
    SELECT_DO_NOTHING = 0,
    SELECT_DO_HIGHLIGHT = 1,
    SELECT_DO_UNDERLINE = 2,
    SELECT_DO_STRIKE = 3,
} OnSelectAction;

@interface RDPDFViewController () <UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate,ViewModeDelegate,SearchResultViewControllerDelegate,RDAnnotListViewControllerDelegate, RDMoreTableViewControllerDelegate, SignatureDelegate, DrawModeDelegate>
{
    UIPickerView *pickerView;
    NSArray *pickViewArr;
    UIButton *confirmPickerBtn;
    int selectItem;
    UITextField *textFd;
    UIPopoverController *bookmarkPopover;
    NSString *password;
    UIBarButtonItem *addBookMarkListButton;
    UIBarButtonItem *moreBarButton;
    
    RDMoreTableViewController *moreTVContainer;
    BookmarkTableViewController *b;
    CGPoint annotTapped;
    RDAnnotListViewController *annotListTV;
    
    BOOL autoSave;
    OnSelectAction onSelectAction;
}

@end

@implementation RDPDFViewController

extern int g_PDF_ViewMode;
extern float g_Ink_Width;
extern float g_swipe_speed;
extern float g_swipe_distance;
extern int g_render_quality;
extern bool g_DarkMode;
extern bool g_sel_right;
extern bool g_ScreenAwake;
extern int g_render_quality;
extern NSUserDefaults *userDefaults;
extern int bookMarkNum;
extern NSMutableString *pdfName;
extern NSMutableString *pdfPath;
extern uint g_ink_color;
extern uint g_rect_color;
extern uint g_ellipse_color;
bool b_outline;
bool b_search_outline;
extern uint g_oval_color;

- (void)_toolBarStyle
{
    defaultTranslucent = self.navigationController.navigationBar.isTranslucent;
    [self.navigationController.navigationBar setTranslucent:YES];
    
    //set style
    //_toolBar.barStyle = _searchToolBar.barStyle = _m_searchBar.barStyle = annotToolBar.barStyle = _drawLineToolBar.barStyle = _drawRectToolBar.barStyle = self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    //set tint
    _toolBar.tintColor = _searchToolBar.tintColor = _m_searchBar.tintColor = annotToolBar.tintColor = _drawLineToolBar.tintColor = _drawRectToolBar.tintColor = m_slider.tintColor = self.navigationController.navigationBar.tintColor;
    
    _toolBar.barTintColor = _searchToolBar.barTintColor = _m_searchBar.barTintColor = annotToolBar.barTintColor = _drawLineToolBar.barTintColor = _drawRectToolBar.barTintColor = self.navigationController.navigationBar.barTintColor;
}

//---------------------------------------------------------
/*
 Author: Emanuele
 Date last update: 01/12/16
 Note: Aggiunta la possibilità di nascondere le icone della
 _toolBar
 */
//---------------------------------------------------------

- (void)createToolbarItems
{
    BOOL isActive = [[NSUserDefaults standardUserDefaults] boolForKey:@"actIsActive"];
    int licenseType = [[[NSUserDefaults standardUserDefaults] objectForKey:@"actActivationType"] intValue];
    
    _viewModeButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_view.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showViewModeTableView)];
    _viewModeButton.width =30;
    
    UIBarButtonItem *searchButton;
    
    if (_searchImage) {
        searchButton = [[UIBarButtonItem alloc] initWithImage:_searchImage style:UIBarButtonItemStylePlain target:self action:@selector(searchView:)];
    }
    else
    {
        searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchView:)];
    }
    
    searchButton.width =30;
    
    _drawButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_ink.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showDrawModeTableView)];
    _drawButton.width =30;
    
    _selButton =[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_select"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleSelection)];
    _selButton.width = 30;
    
    UIBarButtonItem *gridButton;
    
    if (_gridImage) {
        gridButton = [[UIBarButtonItem alloc] initWithImage:_gridImage style:UIBarButtonItemStylePlain target:self action:@selector(toggleGridView)];
    }
    else
    {
        gridButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(toggleGridView)];
    }
    
    gridButton.width =30;
    
    UIBarButtonItem *viewMenuButton;
    
    if (_outlineImage) {
        viewMenuButton = [[UIBarButtonItem alloc] initWithImage:_outlineImage style:UIBarButtonItemStylePlain target:self action:@selector(viewMenu:)];
    }
    else
    {
        viewMenuButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(viewMenu:)];
    }
    
    UIBarButtonItem *undoButton=[[UIBarButtonItem alloc]initWithImage:_undoImage style:UIBarButtonItemStylePlain target:self action:@selector(undoAnnot)];
    undoButton.width =30;
    
    UIBarButtonItem *redoButton=[[UIBarButtonItem alloc]initWithImage:_redoImage style:UIBarButtonItemStylePlain target:self action:@selector(redoAnnot)];
    redoButton.width =30;
    
    _moreButton = [[UIBarButtonItem alloc] initWithImage:_moreImage style:UIBarButtonItemStylePlain target:self action:@selector(showMoreButtons)];
    
    NSMutableArray *hiddenItems = [NSMutableArray arrayWithObjects: [NSNumber numberWithBool:_hideViewModeImage], [NSNumber numberWithBool:_hideSearchImage], [NSNumber numberWithBool:_hideDrawImage], [NSNumber numberWithBool:_hideSelImage], [NSNumber numberWithBool:_hideOutlineImage], [NSNumber numberWithBool:_hideGridImage], [NSNumber numberWithBool:_hideUndoImage], [NSNumber numberWithBool:_hideRedoImage], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:_hideMoreImage], nil];
    
    NSMutableArray *_toolBarItem = [[NSMutableArray alloc] initWithObjects:_viewModeButton, searchButton, _drawButton, _selButton, viewMenuButton, gridButton, undoButton, redoButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], _moreButton, nil];
    
    if (!isActive || licenseType < 1) {
        [hiddenItems setObject:[NSNumber numberWithBool:YES] atIndexedSubscript:3];
        
        if (!isActive) {
            [hiddenItems setObject:[NSNumber numberWithBool:YES] atIndexedSubscript:1];
        }
    }
    
    NSMutableArray *objectsToRemove = [NSMutableArray array];
    for (int i = 0; i < hiddenItems.count; i++) {
        if ([[hiddenItems objectAtIndex:i] boolValue]) {
            [objectsToRemove addObject:[_toolBarItem objectAtIndex:i]];
        }
    }
    
    [_toolBarItem removeObjectsInArray:objectsToRemove];
    
    [_toolBar setItems:_toolBarItem animated:NO];
}

-(void)showMoreButtons{
    if (m_bSel == true)
    {
        [m_view vSelEnd];
        m_bSel = false;
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        
        _moreItemsContainer = [UIAlertController
                               alertControllerWithTitle:@"Select Action"
                               message:@""
                               preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *addBookMark = [UIAlertAction actionWithTitle:@"Add book mark" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                      {
                                          [self composeFile:nil];
                                      }];
        
        UIAlertAction *bookMarkList = [UIAlertAction actionWithTitle:@"Book mark list" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                       {
                                           [self bookmarkList];
                                       }];
        
        UIAlertAction *viewMenu =  [UIAlertAction actionWithTitle:@"View menu" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                    {
                                        [self viewMenu:nil];
                                    }];
        
        UIAlertAction *savePDF = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                  {
                                      [self savePdf];
                                  }];
        
        UIAlertAction *printPDF =  [UIAlertAction actionWithTitle:@"Print" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                    {
                                        [self printPdf];
                                    }];
        
        UIAlertAction *cancel =  [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action)
                                  {
                                      [_moreItemsContainer dismissViewControllerAnimated:YES completion:nil];
                                  }];
        
        [addBookMark setValue:[[UIImage imageNamed:@"btn_add"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        [bookMarkList setValue:[[UIImage imageNamed:@"btn_show"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        [viewMenu setValue:[[UIImage imageNamed:@"btn_outline"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        [savePDF setValue:[[UIImage imageNamed:@"btn_save"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        [printPDF setValue:[[UIImage imageNamed:@"btn_print"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        
        [_moreItemsContainer addAction:addBookMark];
        [_moreItemsContainer addAction:bookMarkList];
        [_moreItemsContainer addAction:viewMenu];
        [_moreItemsContainer addAction:savePDF];
        [_moreItemsContainer addAction:printPDF];
        [_moreItemsContainer addAction:cancel];
        
        [self presentViewController:_moreItemsContainer animated:YES completion:nil];
    }
    else
    {
        moreTVContainer = [[RDMoreTableViewController alloc] initWithNibName:@"RDMoreTableViewController" bundle:nil];
        moreTVContainer.modalPresentationStyle = UIModalPresentationPopover;
        [moreTVContainer setPreferredContentSize:CGSizeMake(300, 44 * 5)];
        moreTVContainer.delegate = self;
        UIPopoverPresentationController *popPresenter = [moreTVContainer
                                                         popoverPresentationController];
        popPresenter.barButtonItem = _moreButton;
        popPresenter.permittedArrowDirections = UIPopoverArrowDirectionAny;
        [self presentViewController:moreTVContainer animated:YES completion:nil];
    }
    
}

-(void) selectAction: (int) type
{
    [moreTVContainer dismissViewControllerAnimated:YES completion:nil];
    
    switch (type) {
        case 0:
            [self composeFile:nil];
            break;
        case 1:
            [self bookmarkList];
            break;
        case 2:
            [self viewMenu:nil];
            break;
        case 3:
            [self savePdf];
            break;
        case 4:
            [self printPdf];
            break;
            
        default:
            break;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self = [super initWithNibName:nil bundle:nil]) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PDFannot = [[PDFAnnot alloc] init];
    b_outline = false;
    b_findStart = NO;
    findString = nil;
    b_lock = NO;
    b_sigleTap =false;
    b_keyboard = false;
    statusBarHidden = NO;
    alreadySelected = NO;
    onSelectAction = SELECT_DO_NOTHING;
    tempfiles = [[NSMutableArray alloc]init];

    self.automaticallyAdjustsScrollViewInsets = NO;

    m_bSel = false;
    pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60)];
    pickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.backgroundColor = [UIColor lightGrayColor];
    
    [self.view addSubview:pickerView];
    [self.view bringSubviewToFront:pickerView];
    //pickerView.hidden = YES;
    
    confirmPickerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmPickerBtn.frame = CGRectMake(self.view.frame.size.width - 60, pickerView.frame.origin.y - 40, 60, 40);
    confirmPickerBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [confirmPickerBtn setTitle:@"OK" forState:UIControlStateNormal];
    confirmPickerBtn.hidden = YES;
    [confirmPickerBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    confirmPickerBtn.backgroundColor = [UIColor clearColor];
    [confirmPickerBtn addTarget:self action:@selector(setComboselect) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmPickerBtn];
    
    textFd = [[UITextField alloc] init];
    textFd.delegate = self;
    [self.view addSubview:textFd];
    textFd.hidden = YES;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closeView)];
}
-(void)viewWillAppear:(BOOL)animated
{
    if (SEARCH_LIST == 1 && b_search_outline == YES) {
        b_search_outline = NO;
        return;
    }
    
    if (_delegate) {
        [_delegate willShowReader];
    }
    
    _toolBar = [UIToolbar new];
    [_toolBar sizeToFit];
    b_findStart = NO;
    [self createToolbarItems];
    self.navigationItem.titleView = _toolBar;
    
    [_pageNumLabel setFrame:CGRectMake(0, 20+self.navigationController.navigationBar.frame.size.height+1, 65, 30)];
    
    [self _toolBarStyle];

    // Hide all bars
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCurrentPage) name:@"Radaee-Refresh-Page" object:nil];
    
    if (_delegate) {
        [_delegate didShowReader];
    }
    
    if (isImmersive) {
        [self hideBars];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    if(!b_outline)
    {
        [self.navigationController.navigationBar setTranslucent:defaultTranslucent];
        
        if (_delegate) {
            [_delegate willCloseReader];
        }
        
        //[m_ThumbView vClose] should before [m_view vClose]
        [m_Thumbview vClose];
        [m_Gridview vClose];
        [m_view vClose];
        m_slider = nil;
    }
    
    //delete temp files
    for(int i=0; i<[tempfiles count];i++)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:[tempfiles objectAtIndex:i] error:nil];
        [tempfiles removeObjectAtIndex:i];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if(!b_outline)
    {
        if (_delegate) {
            [_delegate didCloseReader];
        }
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Radaee-Refresh-Page" object:nil];
    }
}

- (void)allModesDone
{
    if ([_drawRectToolBar superview] != nil) {
        [self drawRowDone];
        [self drawImageDone];
    }
    
    if (b_noteAnnot) {
        [self drawNoteDone];
    }
    
    if ([_drawLineToolBar superview] != nil) {
        [self drawLineDone:nil];
    }
    
    if (onSelectAction != SELECT_DO_NOTHING) {
        [self modifyTextDone];
    }

    if (_m_searchBar != nil) {
        [self searchCancel:nil];
    }
}

- (void)closeView
{
    if ([m_view isModified] && !autoSave) {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Exiting"
                                                                       message:@"Document modified.\r\nDo you want to save it?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"Yes"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [self PDFClose];
                                 [self.navigationController popViewControllerAnimated:YES];
                                 [self dismissViewControllerAnimated:YES completion:nil];
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                                 if (_delegate) {
                                     [_delegate popViewController];
                                 }
                             }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"No"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [m_view setModified:NO force:YES];
                                     [self PDFClose];
                                     [self.navigationController popViewControllerAnimated:YES];
                                     [self dismissViewControllerAnimated:YES completion:nil];
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                     if (_delegate) {
                                         [_delegate popViewController];
                                     }
                                 }];
        
        [alert addAction:ok];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    else {
        [self PDFClose];
        [self.navigationController popViewControllerAnimated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
        
        if (_delegate) {
            [_delegate popViewController];
        }
    }
}

- (void)bookmarkList
{
    b = [[BookmarkTableViewController alloc] init];
    b.items = [RadaeePDFPlugin loadBookmarkForPdf:pdfPath withPath:YES];
    b.delegate = self;
    
    b_outline = true;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:b];
    
    nav.popoverPresentationController.sourceView = self.view;
    CGRect rect = self.view.frame;
    nav.popoverPresentationController.sourceRect = CGRectMake(rect.origin.x, rect.origin.y, 0, 0);
    nav.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    
    [self presentViewController:nav animated:YES completion:nil];
    
}

-(void)didSelectItem:(int)pageno {
    [self dismissViewControllerAnimated:YES completion:^{
        [m_view vGoto:pageno];
    }];
}

-(void)composeFile:(id)sender
{
    int pageno = 0;
    struct PDFV_POS pos;
    [m_view vGetPos:&pos];
    pageno = pos.pageno;
    
    NSString *result = [RadaeePDFPlugin addToBookmarks:pdfPath page:pageno label:@""];
    
    NSString *str1=NSLocalizedString(@"Alert", @"Localizable");
    NSString *str2=result;
    NSString *str3=NSLocalizedString(@"OK", @"Localizable");
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:str1 message:str2 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:str3 style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action1];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)searchView:(id) sender
{
    [self allModesDone];
    _searchToolBar = [UIToolbar new];
    [_searchToolBar sizeToFit];
    
    UIBarButtonItem *searchButton=[[UIBarButtonItem alloc]initWithImage:_searchImage style:UIBarButtonItemStylePlain target:self action:@selector(showSearchList)];
    searchButton.width =30;
    UIBarButtonItem *nextbutton= [[UIBarButtonItem alloc] initWithImage:_nextImage style:UIBarButtonItemStylePlain target:self action:@selector(nextword:)];
    nextbutton.width =30;
    UIBarButtonItem *prevbutton=[[UIBarButtonItem alloc] initWithImage:_prevImage style:UIBarButtonItemStylePlain target:self action:@selector(prevword:)];
    prevbutton.width =30;
    UIBarButtonItem *cancelbtn=[[UIBarButtonItem alloc] initWithImage:_removeImage style:UIBarButtonItemStylePlain target:self action:@selector(searchCancel:)];
    cancelbtn.width =30;
    
    NSArray *_toolBarItem = [[NSArray alloc]initWithObjects:searchButton,prevbutton,nextbutton,cancelbtn,nil];
    [_searchToolBar setItems:_toolBarItem animated:NO];
    [_toolBar addSubview:_searchToolBar];
    
    CGRect boundsc = [self.view bounds];
    CGFloat cwidth = boundsc.size.width;
    
    CGFloat hi = self.navigationController.navigationBar.bounds.size.height;
    _m_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, hi, cwidth, 41)];
    
    _m_searchBar.delegate = self;
    //_m_searchBar.barStyle =UIBarStyleBlackTranslucent;
    _m_searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    _m_searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _m_searchBar.placeholder = @"Search";
    _m_searchBar.keyboardType = UIKeyboardTypeDefault;
    // [self.view addSubview:_m_searchBar];
    
    [self _toolBarStyle];
    
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - Undo

- (void)undoAnnot
{
    [m_view vUndo];
}

#pragma mark - Redo

- (void)redoAnnot
{
    [m_view vRedo];
}

#pragma mark - Draw

- (void)showDrawModeTableView
{
    if (m_bSel == true)
    {
        [m_view vSelEnd];
        m_bSel = false;
    }
    
    DrawModeTableViewController *vm = [[DrawModeTableViewController alloc] init];
    vm.delegate = self;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        vm.modalPresentationStyle = UIModalPresentationPopover;
        vm.delegate = self;
        vm.preferredContentSize = CGSizeMake(150, (44 * 6) + 10);
        vm.tableView.scrollEnabled = NO;
        
        UIPopoverPresentationController *pop = vm.popoverPresentationController;
        pop.permittedArrowDirections = UIPopoverArrowDirectionUp;
        pop.sourceView = self.view;
        CGRect rect = self.view.frame;
        pop.sourceRect = CGRectMake(rect.origin.x, rect.origin.y, 0, 0);        
        [self presentViewController:vm animated:YES completion:nil];
    }
    else
    {
        UIAlertController *action = [UIAlertController alertControllerWithTitle:@"Select Draw Mode" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *ink = [UIAlertAction actionWithTitle:@"Ink" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self didSelectDrawMode:0];
        }];
        [ink setValue:[[UIImage imageNamed:@"btn_annot_ink.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        
        UIAlertAction *line = [UIAlertAction actionWithTitle:@"Line" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self didSelectDrawMode:1];
        }];
        [line setValue:[[UIImage imageNamed:@"btn_annot_line.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        
        UIAlertAction *rect = [UIAlertAction actionWithTitle:@"Rect" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self didSelectDrawMode:2];
        }];
        [rect setValue:[[UIImage imageNamed:@"btn_annot_rect.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        
        UIAlertAction *ellipse = [UIAlertAction actionWithTitle:@"Ellipse" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self didSelectDrawMode:3];
        }];
        [ellipse setValue:[[UIImage imageNamed:@"btn_annot_ellipse.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        
        UIAlertAction *stamp = [UIAlertAction actionWithTitle:@"Stamp" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self didSelectDrawMode:4];
        }];
        [stamp setValue:[[UIImage imageNamed:@"pdf_custom_stamp.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        
        UIAlertAction *note = [UIAlertAction actionWithTitle:@"Note" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self didSelectDrawMode:5];
        }];
        [note setValue:[[UIImage imageNamed:@"btn_annot_note.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        
        [action addAction:ink];
        [action addAction:line];
        [action addAction:rect];
        [action addAction:ellipse];
        [action addAction:stamp];
        [action addAction:note];
        [action addAction:cancel];
        
        [self presentViewController:action animated:YES completion:nil];
    }
}

- (void)didSelectDrawMode:(int)mode
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    switch (mode) {
        case 0:
            [self drawLine:nil];
            break;
        case 1:
            [self drawRow];
            break;
        case 2:
            [self drawRect:nil];
            break;
        case 3:
            [self drawEllipse:nil];
            break;
        case 4:
            [self drawImage];
            break;
        case 5:
            [self drawNote];
            break;
            
        default:
            break;
    }
}

- (IBAction)drawLine:(id) sender
{
    [self allModesDone];
    if(![m_view vInkStart])
    {
        NSString *str1=NSLocalizedString(@"Alert", @"Localizable");
        NSString *str2=NSLocalizedString(@"This Document is readonly", @"Localizable");
        NSString *str3=NSLocalizedString(@"OK", @"Localizable");
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:str1 message:str2 delegate:self cancelButtonTitle:str3 otherButtonTitles:nil,nil];
        [alter show];
        return;
    }
    
    _drawLineToolBar = [UIToolbar new];
    [_drawLineToolBar sizeToFit];
    //_drawLineToolBar.barStyle = UIBarStyleBlackOpaque;
    UIBarButtonItem *drawLineDoneBtn= [[UIBarButtonItem alloc] initWithImage:_doneImage style:UIBarButtonItemStylePlain target:self action:@selector(drawLineDone:)];
    drawLineDoneBtn.width =30;
    UIBarButtonItem *drawLineCancelBtn= [[UIBarButtonItem alloc] initWithImage:_removeImage style:UIBarButtonItemStylePlain target:self action:@selector(drawLineCancel:)];
    drawLineCancelBtn.width =30;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                               target:nil
                               action:nil];
    
    NSArray *_toolBarItem = [[NSArray alloc]initWithObjects:drawLineDoneBtn,spacer,drawLineCancelBtn,nil];
    [_drawLineToolBar setItems:_toolBarItem animated:NO];
    [_toolBar addSubview:_drawLineToolBar];
    
    [self _toolBarStyle];
}
-(IBAction)drawLineDone:(id)sender
{
    [m_view vInkEnd];
    [_drawLineToolBar removeFromSuperview];
}
-(IBAction)drawLineCancel:(id)sender
{
    [_drawLineToolBar removeFromSuperview];
    [m_view vInkCancel];
}

- (void)drawRow
{
    [self allModesDone];
    if(![m_view vLineStart])
    {
        NSString *str1=NSLocalizedString(@"Alert", @"Localizable");
        NSString *str2=NSLocalizedString(@"This Document is readonly", @"Localizable");
        NSString *str3=NSLocalizedString(@"OK", @"Localizable");
        UIAlertView *alter = [[UIAlertView alloc]initWithTitle:str1 message:str2 delegate:self cancelButtonTitle:str3 otherButtonTitles:nil,nil];
        [alter show];
        return;
    }
    
    _drawRectToolBar = [UIToolbar new];
    [_drawRectToolBar sizeToFit];
    UIBarButtonItem *drawLineDoneBtn=[[UIBarButtonItem alloc]initWithImage:_doneImage style:UIBarButtonItemStylePlain target:self action:@selector(drawRowDone)];
    drawLineDoneBtn.width =30;
    UIBarButtonItem *drawLineCancelBtn=[[UIBarButtonItem alloc]initWithImage:_removeImage style:UIBarButtonItemStylePlain target:self action:@selector(drawRowCancel)];
    drawLineCancelBtn.width =30;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                               target:nil
                               action:nil];
    
    NSArray *_toolBarItem = [[NSArray alloc]initWithObjects:drawLineDoneBtn,spacer,drawLineCancelBtn,nil];
    [_drawRectToolBar setItems:_toolBarItem animated:NO];
    [_toolBar addSubview:_drawRectToolBar];
    
    [self _toolBarStyle];
}

- (void)drawRowDone
{
    [m_view vLineEnd];
    [_drawRectToolBar removeFromSuperview];
}

- (void)drawRowCancel
{
    [_drawRectToolBar removeFromSuperview];
    [m_view vLineCancel];
}

- (IBAction)drawRect:(id) sender
{
    
    if(![m_view vRectStart])
    {
        NSString *str1=NSLocalizedString(@"Alert", @"Localizable");
        NSString *str2=NSLocalizedString(@"This Document is readonly", @"Localizable");
        NSString *str3=NSLocalizedString(@"OK", @"Localizable");
        UIAlertView *alter = [[UIAlertView alloc]initWithTitle:str1 message:str2 delegate:self cancelButtonTitle:str3 otherButtonTitles:nil,nil];
        [alter show];
        return;
    }
    
    _drawRectToolBar = [UIToolbar new];
    [_drawRectToolBar sizeToFit];
    //_drawRectToolBar.barStyle = UIBarStyleBlackOpaque;
    UIBarButtonItem *drawLineDoneBtn= [[UIBarButtonItem alloc] initWithImage:_doneImage style:UIBarButtonItemStylePlain target:self action:@selector(drawRectDone:)];
    drawLineDoneBtn.width =30;
    UIBarButtonItem *drawLineCancelBtn= [[UIBarButtonItem alloc] initWithImage:_removeImage style:UIBarButtonItemStylePlain target:self action:@selector(drawRectCancel:)];
    drawLineCancelBtn.width =30;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                               target:nil
                               action:nil];
    
    NSArray *_toolBarItem = [[NSArray alloc]initWithObjects:drawLineDoneBtn,spacer,drawLineCancelBtn,nil];
    [_drawRectToolBar setItems:_toolBarItem animated:NO];
    [_toolBar addSubview:_drawRectToolBar];
    
    [self _toolBarStyle];
}
-(IBAction)drawRectDone:(id)sender
{
    
    [m_view vRectEnd];
    [_drawRectToolBar removeFromSuperview];
}
-(IBAction)drawRectCancel:(id)sender
{
    [_drawRectToolBar removeFromSuperview];
    [m_view vRectCancel];
}
- (IBAction)drawEllipse:(id) sender
{
    
    if(![m_view vEllipseStart])
    {
        NSString *str1=NSLocalizedString(@"Alert", @"Localizable");
        NSString *str2=NSLocalizedString(@"This Document is readonly", @"Localizable");
        NSString *str3=NSLocalizedString(@"OK", @"Localizable");
        UIAlertView *alter = [[UIAlertView alloc]initWithTitle:str1 message:str2 delegate:self cancelButtonTitle:str3 otherButtonTitles:nil,nil];
        [alter show];
        return;
    }
    
    _drawRectToolBar = [UIToolbar new];
    [_drawRectToolBar sizeToFit];
    //_drawRectToolBar.barStyle = UIBarStyleBlackOpaque;
    UIBarButtonItem *drawLineDoneBtn= [[UIBarButtonItem alloc] initWithImage:_doneImage style:UIBarButtonItemStylePlain target:self action:@selector(drawEllipseDone:)];
    drawLineDoneBtn.width =30;
    UIBarButtonItem *drawLineCancelBtn= [[UIBarButtonItem alloc] initWithImage:_removeImage style:UIBarButtonItemStylePlain target:self action:@selector(drawEllipseCancel:)];
    drawLineCancelBtn.width =30;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                               target:nil
                               action:nil];
    
    NSArray *_toolBarItem = [[NSArray alloc]initWithObjects:drawLineDoneBtn,spacer,drawLineCancelBtn,nil];
    [_drawRectToolBar setItems:_toolBarItem animated:NO];
    [_toolBar addSubview:_drawRectToolBar];
    
    [self _toolBarStyle];
}
-(IBAction)drawEllipseDone:(id)sender
{
    
    [m_view vEllipseEnd];
    [_drawRectToolBar removeFromSuperview];
}
-(IBAction)drawEllipseCancel:(id)sender
{
    [_drawRectToolBar removeFromSuperview];
    [m_view vEllipseCancel];
}

- (void)drawImage
{
    [self drawImageWithImage:nil];
}

- (void)drawImageWithImage:(UIImage *)image
{
    [self allModesDone];
    BOOL result;
    if (image == nil) {
        result = [m_view vImageStart];
    } else {
        result = [m_view vImageStartWithImage:image];
    }
    if(!result)
    {
        NSString *str1=NSLocalizedString(@"Alert", @"Localizable");
        NSString *str2=NSLocalizedString(@"This Document is readonly", @"Localizable");
        NSString *str3=NSLocalizedString(@"OK", @"Localizable");
        UIAlertView *alter = [[UIAlertView alloc]initWithTitle:str1 message:str2 delegate:self cancelButtonTitle:str3 otherButtonTitles:nil,nil];
        [alter show];
        return;
    }
    
    _drawRectToolBar = [UIToolbar new];
    [_drawRectToolBar sizeToFit];
    UIBarButtonItem *drawLineDoneBtn=[[UIBarButtonItem alloc]initWithImage:_doneImage style:UIBarButtonItemStylePlain target:self action:@selector(drawImageDone)];
    drawLineDoneBtn.width =30;
    UIBarButtonItem *drawLineCancelBtn=[[UIBarButtonItem alloc]initWithImage:_removeImage style:UIBarButtonItemStylePlain target:self action:@selector(drawImageCancel)];
    drawLineCancelBtn.width =30;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                               target:nil
                               action:nil];
    
    NSArray *_toolBarItem = [[NSArray alloc]initWithObjects:drawLineDoneBtn,spacer,drawLineCancelBtn,nil];
    [_drawRectToolBar setItems:_toolBarItem animated:NO];
    [_toolBar addSubview:_drawRectToolBar];
    
    [self _toolBarStyle];
}

- (void)drawImageDone
{
    [_drawRectToolBar removeFromSuperview];
    [m_view vImageEnd];
}

- (void)drawImageCancel
{
    [_drawRectToolBar removeFromSuperview];
    [m_view vImageCancel];
}

- (void)drawNote {
    [self allModesDone];
    b_noteAnnot = YES;
}

- (void)drawNoteDone {
    b_noteAnnot = NO;
}

- (void)highlightText {
    [self allModesDone];
    [self enableSelection];
    onSelectAction = SELECT_DO_HIGHLIGHT;
}

- (void)underlineText {
    [self allModesDone];
    [self enableSelection];
    onSelectAction = SELECT_DO_UNDERLINE;
}

- (void)strikeText {
    [self allModesDone];
    [self enableSelection];
    onSelectAction = SELECT_DO_STRIKE;
}

- (void)modifyTextDone {
    [self disableSelection];
    onSelectAction = SELECT_DO_NOTHING;
}

- (IBAction)viewMenu:(id) sender
{
    
    b_outline =true;
    PDFOutline *root = [m_doc rootOutline];
    if( root )
    {
        outlineView = [[OutLineViewController alloc] init];
        //First parameter is root node
        [outlineView setList:m_doc :NULL :root];
        UINavigationController *nav = self.navigationController;
        outlineView.hidesBottomBarWhenPushed = YES;
        [outlineView setJump:self];
        [nav pushViewController:outlineView animated:YES];
    }
    
    
}
-(IBAction)lockView:(id)sender
{
    
}

- (void)viewDidUnload
{
    NSLog(@"PDFView Unload");
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeOrientation" object:nil];
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGRect rect = [self.view bounds];
    if ([self isPortrait])
    {
        if (rect.size.height < rect.size.width) {
            
            CGFloat height = rect.size.height;
            rect.size.height = rect.size.width;
            rect.size.width = height;
        }
    }
    else
    {
        if (rect.size.height > rect.size.width) {
            
            CGFloat height = rect.size.height;
            rect.size.height = rect.size.width;
            rect.size.width = height;
        }
    }
    
    [m_view setFrame:rect];
    [m_view sizeThatFits:rect.size];
    [_toolBar sizeToFit];
    
    CGRect boundsc = [self.view bounds];
    int cwidth = boundsc.size.width;
    int cheight = boundsc.size.height;
    
    if ([self isPortrait]) {
        if (cwidth > cheight) {
            cwidth = cheight;
            cheight = boundsc.size.width;
        }
    }
    else
    {
        if (cwidth < cheight) {
            cwidth = cheight;
            cheight = boundsc.size.width;
        }
    }
    
    float hi = self.navigationController.navigationBar.bounds.size.height;
    
    
    [m_Thumbview setFrame:CGRectMake(0, cheight-thumbHeight, cwidth, thumbHeight)];
    [m_Thumbview sizeThatFits:CGRectMake(0, cheight-thumbHeight, cwidth, thumbHeight).size];
    [m_Gridview setFrame:CGRectMake(0, [[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - [[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.frame.size.height)];
    [m_Gridview sizeThatFits:CGRectMake(0, [[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - [[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.frame.size.height).size];
    [m_slider setFrame:CGRectMake(0, cheight-50, cwidth, 50)];
    [m_slider sizeThatFits:CGRectMake(0, cheight-50, cwidth, 50).size];
    
    [_m_searchBar setFrame:CGRectMake(0,hi+20,cwidth,41)];
    
    [m_Thumbview didRotate];
    [m_Gridview didRotate];
    
    [m_view resetZoomLevel];
}
- (IBAction)sliderAction:(id)sender
{
}

- (id)getDoc
{
    return m_doc;
}

- (int)getCurrentPage
{
    return [m_view vGetCurrentPage];
}

- (CGImageRef)imageForPage:(int)pg
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        if (bounds.size.height > bounds.size.width) {
            bounds.size.width = bounds.size.height;
            bounds.size.height = [[[[UIApplication sharedApplication] delegate] window] bounds].size.width;
        }
    }
    
    PDFPage *page = [m_doc page:pg];;
    float w = [m_doc pageWidth:pg];
    float h = [m_doc pageHeight:pg];
    int iw = w;
    int ih = h;
    PDF_DIB m_dib = NULL;
    PDF_DIB bmp = Global_dibGet(m_dib, iw, ih);
    float ratiox = 1;
    float ratioy = 1;
    
    if (ratiox>ratioy) {
        ratiox = ratioy;
    }
    
    ratiox = ratiox * 1.0;
    PDF_MATRIX mat = Matrix_createScale(ratiox, -ratiox, 0, h * ratioy);
    Page_renderPrepare(page.handle, bmp);
    Page_render(page.handle, bmp, mat, false, 1);
    Matrix_destroy(mat);
    page = nil;
    
    void *data = Global_dibGetData(bmp);
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, data, iw * ih * 4, NULL);
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    CGImageRef imgRef = CGImageCreate(iw, ih, 8, 32, iw<<2, cs, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst, provider, NULL, FALSE, kCGRenderingIntentDefault);
    
    
    CGContextRef context = CGBitmapContextCreate(NULL, (bounds.size.width - ((bounds.size.width - iw) / 2)) * 1, ih * 1, 8, 0, cs, kCGImageAlphaPremultipliedLast);
    
    
    // Draw ...
    //
    CGContextSetAlpha(context, 1);
    CGContextSetRGBFillColor(context, (CGFloat)0.0, (CGFloat)0.0, (CGFloat)0.0, (CGFloat)1.0 );
    CGContextDrawImage(context, CGRectMake(((bounds.size.width- iw) / 2), 1, iw, ih), imgRef);
    
    
    // Get your image
    //
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    
    
    CGColorSpaceRelease(cs);
    CGDataProviderRelease(provider);
    
    return cgImage;
}

- (void)setThumbnailBGColor:(int)color
{
    [m_Thumbview setThumbBackgroundColor:color];
}

- (void)setThumbGridBGColor:(int)color
{
    gridBackgroundColor = color;
}

- (void)setThumbGridElementHeight:(float)height
{
    gridElementHeight = height;
}

- (void)setThumbGridGap:(float)gap
{
    gridGap = gap;
}

- (void)setThumbGridViewMode:(int)mode
{
    gridMode = mode;
}

- (void)setReaderBGColor:(int)color
{
    [m_view setReaderBackgroundColor:color];
}

- (void)setThumbHeight:(float)height
{
    thumbHeight = height;
}

- (void)setFirstPageCover:(BOOL)cover
{
    firstPageCover = cover;
}

- (void)setDoubleTapZoomMode:(int)mode
{
    doubleTapZoomMode = mode;
}

- (void)setImmersive:(BOOL)immersive
{
    isImmersive = immersive;
    
    if (isImmersive) {
        [self hideBars];
    } else {
        [self showBars];
    }
}

-(int)PDFOpen:(NSString *)path : (NSString *)pwd atPage:(int)page readOnly:(BOOL)readOnlyEnabled autoSave:(BOOL)autoSaveEnabled
{
    autoSave = autoSaveEnabled;
    
    pdfPath = [path mutableCopy];
    pdfName = [[path lastPathComponent] mutableCopy];
    password = pwd;
    
    [self PDFClose];
    PDF_ERR err = 0;
    m_doc = [[PDFDoc alloc] init];
    err = [m_doc open:path :pwd];
    
    if ([m_doc canSave]){
        NSString *cacheFile = [[NSTemporaryDirectory() stringByAppendingString:@""] stringByAppendingString:@"cache.dat"];
        [m_doc setCache:cacheFile];
    }
    
    switch( err )
    {
        case err_ok:
            break;
        case err_password:
            return 2;
            break;
        case err_bad_file:
            return 4;
        default: return 0;
    }

    // This is called before the view is added to superview
    CGRect rect = [[UIScreen mainScreen] bounds];

    //GEAR
    if (![self isPortrait] && rect.size.width < rect.size.height) {
        float height = rect.size.height;
        rect.size.height = rect.size.width;
        rect.size.width = height;
    }
    //END
    
    m_view = [[PDFView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    
    
    [m_view setFirstPageCover:firstPageCover];
    [m_view setDoubleTapZoomMode:doubleTapZoomMode];
    [m_view setReadOnly:readOnlyEnabled];
    [m_view vOpen :m_doc :(id<PDFViewDelegate>)self];
    
    if (page > 0) {
        [m_view vGoto:page];
    }
    
    _pagecount =[m_doc pageCount];
    [self.view addSubview:m_view];
    m_bSel = false;
    
    
    return 1;
}
-(int)PDFOpenStream:(id<PDFStream>)stream :(NSString *)pwd
{
    password = pwd;
    [self PDFClose];
    PDF_ERR err = 0;
    m_doc = [[PDFDoc alloc] init];
    err = [m_doc openStream:stream :password];
    switch( err )
    {
        case err_ok:
            break;
        case err_password:
            return 2;
            break;
        case err_bad_file:
            return 4;
            break;
        default: return 0;
    }
    CGRect rect = [self.view bounds];
    
    //GEAR
    if (![self isPortrait] && rect.size.width < rect.size.height) {
        float height = rect.size.height;
        rect.size.height = rect.size.width;
        rect.size.width = height;
    }
    //END
    
    m_view = [[PDFView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    
    [m_view setFirstPageCover:firstPageCover];
    [m_view setDoubleTapZoomMode:doubleTapZoomMode];
    [m_view vOpen:m_doc:(id<PDFViewDelegate>)self];
    _pagecount =[m_doc pageCount];
    [self.view addSubview:m_view];
    m_bSel = false;
    return 1;
}

-(int)PDFopenMem:(void *)data :(int)data_size :(NSString *)pwd
{
    [self PDFClose];
    PDF_ERR err = 0;
    m_doc = [[PDFDoc alloc] init];
    err = [m_doc openMem:data :data_size :pwd];
    switch( err )
    {
        case err_ok:
            break;
        case err_password:
            return 2;
            break;
        default: return 0;
    }
    
    CGRect rect = [self.view bounds];
    
    //GEAR
    if (![self isPortrait] && rect.size.width < rect.size.height) {
        float height = rect.size.height;
        rect.size.height = rect.size.width;
        rect.size.width = height;
    }
    //END
    
    m_view = [[PDFView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    
    [m_view setFirstPageCover:firstPageCover];
    [m_view setDoubleTapZoomMode:doubleTapZoomMode];
    [m_view vOpen :m_doc :(id<PDFViewDelegate>)self];
    _pagecount =[m_doc pageCount];
    [self.view addSubview:m_view];
    m_bSel = false;
    return 1;
}

- (void)PDFSeekBarInit:(int)pageno
{
    CGRect boundsc = [self.view bounds];
    if (![self isPortrait] && boundsc.size.width < boundsc.size.height) {
        float height = boundsc.size.height;
        boundsc.size.height = boundsc.size.width;
        boundsc.size.width = height;
    }
    
    int cwidth = boundsc.size.width;
    int cheight = boundsc.size.height;
    
    
    float hi = self.navigationController.navigationBar.bounds.size.height;
    hi = 0.0;
    CGRect rect;
    rect = [[UIApplication sharedApplication] statusBarFrame];
    
    m_slider = [[UISlider alloc] initWithFrame:CGRectMake(0, cheight-50, cwidth, 50)];
    _pageNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20+hi+1, 65, 30)];
    
    
    m_slider.minimumValue = 1;
    m_slider.maximumValue = _pagecount;
    m_slider.continuous = NO;
    m_slider.value = pageno;
    
    [m_slider addTarget:self action:@selector(OnSliderValueChange:) forControlEvents:UIControlEventValueChanged];
    
    [m_slider setBackgroundColor:[UIColor blackColor]];
    
    [self _toolBarStyle];
    
    [self.view addSubview:m_slider];
    
    _pagenow = pageno;
    _pageNumLabel.backgroundColor = [UIColor colorWithRed:1.5 green:1.5 blue:1.5 alpha:0.2];
    _pageNumLabel.textColor = [UIColor whiteColor];
    _pageNumLabel.adjustsFontSizeToFitWidth = YES;
    _pageNumLabel.textAlignment= NSTextAlignmentCenter;
    _pageNumLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    _pageNumLabel.layer.cornerRadius = 10;
    NSString *pagestr = [[NSString alloc]initWithFormat:@"%d/",_pagecount];
    pagestr = [pagestr stringByAppendingFormat:@"%d",_pagecount];
    _pageNumLabel.text = pagestr;
    _pageNumLabel.font = [UIFont boldSystemFontOfSize:16];
    _pageNumLabel.shadowColor = [UIColor grayColor];
    _pageNumLabel.shadowOffset = CGSizeMake(1.0,1.0);
    [self.view addSubview:_pageNumLabel];
    
    [_pageNumLabel setHidden:NO];
}


-(void)PDFThumbNailinit:(int)pageno
{
    CGRect boundsc = [self.view bounds];
    if (![self isPortrait] && boundsc.size.width < boundsc.size.height) {
        float height = boundsc.size.height;
        boundsc.size.height = boundsc.size.width;
        boundsc.size.width = height;
    }
    
    int cwidth = boundsc.size.width;
    int cheight = boundsc.size.height;
    
    
    float hi = self.navigationController.navigationBar.bounds.size.height;
    hi = 0.0;
    CGRect rect;
    rect = [[UIApplication sharedApplication] statusBarFrame];
    
    m_Thumbview = [[PDFThumbView alloc] initWithFrame:CGRectMake(0, cheight-thumbHeight, cwidth, thumbHeight)];
    _pageNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20+hi+1, 65, 30)];
    
    [m_Thumbview vOpen :m_doc :(id<PDFThumbViewDelegate>)self];
    [self.view addSubview:m_Thumbview];
    _pagenow = pageno;
    _pageNumLabel.backgroundColor = [UIColor colorWithRed:1.5 green:1.5 blue:1.5 alpha:0.2];
    _pageNumLabel.textColor = [UIColor whiteColor];
    _pageNumLabel.adjustsFontSizeToFitWidth = YES;
    _pageNumLabel.textAlignment = NSTextAlignmentCenter;
    _pageNumLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    _pageNumLabel.layer.cornerRadius = 10;
    NSString *pagestr = [[NSString alloc]initWithFormat:@"%d/",_pagecount];
    pagestr = [pagestr stringByAppendingFormat:@"%d",_pagecount];
    _pageNumLabel.text = pagestr;
    _pageNumLabel.font = [UIFont boldSystemFontOfSize:16];
    _pageNumLabel.shadowColor = [UIColor grayColor];
    _pageNumLabel.shadowOffset = CGSizeMake(1.0,1.0);
    [self.view addSubview:_pageNumLabel];
    
    [_pageNumLabel setHidden:NO];
    
}

-(void)initbar :(int) pageno
{
    CGRect boundsc = [self.view bounds];
    if (![self isPortrait] && boundsc.size.width < boundsc.size.height) {
        float height = boundsc.size.height;
        boundsc.size.height = boundsc.size.width;
        boundsc.size.width = height;
    }
    
    int cwidth = boundsc.size.width;
    int cheight = boundsc.size.height;
    
    _sliderBar = [[UISlider alloc]initWithFrame:CGRectMake(20, cheight-100, cwidth-30, 10)];
    _pagecount = [m_doc pageCount];
    _sliderBar.maximumValue = _pagecount; //The Biggest Page Number
    _sliderBar.minimumValue = 1;//The Littlest Page Number
    [self.view addSubview:_sliderBar];
    [_sliderBar setHidden:NO];
    [_sliderBar addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_sliderBar addTarget:self action:@selector(sliderDragUp:) forControlEvents:UIControlEventTouchUpInside];
}
-(void)PDFGoto :(int)pageno
{
    [m_view vGoto:pageno];
}
-(void)OnSliderValueChange:(UISlider *)slider
{
    int page = (int)round(slider.value);
    [self OnPageClicked:page - 1];
}
-(void)OnPageClicked :(int)pageno
{
    [m_view resetZoomLevel];
    [m_view vGoto:pageno];
    _pagenow = pageno + 1;
    NSString *pagestr = [[NSString alloc]initWithFormat:@"%d/",_pagenow];
    pagestr = [pagestr stringByAppendingFormat:@"%d",_pagecount];
    _pageNumLabel.text = pagestr;
    [self hideGridView];
}

-(int)PDFOpenPage:(NSString *)path :(int)pageno :(float)x :(float)y :(NSString *)pwd
{
    
    PDF_ERR err = 0;
    err = [m_doc open:path :pwd];
    switch( err )
    {
        case err_ok:
            break;
        case err_password:
            return 2;
            break;
        default: return 0;
    }
    
    CGRect rect = [self.view bounds];
    //GEAR
    if (![self isPortrait] && rect.size.width < rect.size.height) {
        float height = rect.size.height;
        rect.size.height = rect.size.width;
        rect.size.width = height;
    }
    //END
    m_view = [[PDFView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height-20-self.navigationController.navigationBar.bounds.size.height)];
    // [m_view vOpenPage:m_doc :pageno :x :y :self];
    [m_view vGoto:pageno];
    _pagecount = [m_doc pageCount];
    [self.view addSubview:m_view];
    return 1;
}
-(IBAction)sliderValueChanged:(id)sender
{
    _pagenow = (int)round(_sliderBar.value);
    NSString *pagestr = [[NSString alloc]initWithFormat:@"%d/",_pagenow];
    pagestr = [pagestr stringByAppendingFormat:@"%d",_pagecount];
    _pageNumLabel.text = pagestr;
    
}
-(IBAction)sliderDragUp:(id)sender
{
    _pagenow = (int)round(_sliderBar.value);
    [m_view vGoto:_pagenow - 1];
    NSString *pagestr = [[NSString alloc]initWithFormat:@"%d/",_pagenow];
    pagestr = [pagestr stringByAppendingFormat:@"%d",_pagecount];
}

-(void)PDFClose
{
    if (SEARCH_LIST == 1) {
        [[RDExtendedSearch sharedInstance] clearSearch];
    }
    
    if( m_view != nil )
    {
        b_outline = false;
        [m_view vClose];
        [m_view removeFromSuperview];
        m_view = NULL;
    }
    m_doc = NULL;
}
//Add Call Search API
- (void)searchBarSearchButtonClicked:(UISearchBar *)_m_searchBar
{
    float hi = self.navigationController.navigationBar.bounds.size.height;
    CGRect boundsc = [self.view bounds];
    int cwidth = boundsc.size.width;
    
    [_m_searchBar setFrame:CGRectMake(0,hi,cwidth,41)];
    
    NSString *text = _m_searchBar.text;
    [_m_searchBar resignFirstResponder];
    if (_m_searchBar.text.length >40)
    {
        return ;
    }
    
    if (SEARCH_LIST == 1) {
        [self showSearchList];
    } else {
        [self startSearch:text dir:1 reset:NO];
    }
}

-(IBAction)prevword:(id)sender
{
    NSString *text = _m_searchBar.text;
    [_m_searchBar resignFirstResponder];
    if (_m_searchBar.text.length >40)
    {
        return ;
    }
    
    if (SEARCH_LIST == 1) {
        int i = [[RDExtendedSearch sharedInstance] getPrevPageFromCurrentPage:_pagenow];
        
        if (i >= 0) {
            [self PDFGoto:i];
            [self startSearch:text dir:-1 reset:YES];
        }
    } else {
        [self startSearch:text dir:-1 reset:NO];
    }
}

-(IBAction)nextword:(id)sender
{
    NSString *text = _m_searchBar.text;
    [_m_searchBar resignFirstResponder];
    if (_m_searchBar.text.length >40)
    {
        return ;
    }
    
    if (SEARCH_LIST == 1) {
        int i = [[RDExtendedSearch sharedInstance] getNextPageFromCurrentPage:_pagenow];
        
        if (i >= 0) {
            [self PDFGoto:i];
            [self startSearch:text dir:1 reset:YES];
        }
    } else {
        NSString *text = _m_searchBar.text;
        [_m_searchBar resignFirstResponder];
        if (_m_searchBar.text.length >40)
        {
            return;
        }
        
        [self startSearch:text dir:1 reset:NO];
    }
}

-(IBAction)searchCancel:(id)sender
{
    if (SEARCH_LIST == 1) {
        [[RDExtendedSearch sharedInstance] clearSearch];
    }
    
    [_m_searchBar resignFirstResponder];
    [_m_searchBar removeFromSuperview];
    [_searchToolBar removeFromSuperview];
    findString = nil;
    [m_view vFindEnd];
    b_findStart = NO;
    _m_searchBar = NULL;
}

- (void)startSearch:(NSString *)text dir:(int)dir reset:(BOOL)reset
{
    if (reset) {
        findString = nil;
        [m_view vFindEnd];
        b_findStart = NO;
    }
    
    if(!b_findStart)
    {
        findString =text;
        [m_view vFindStart:text :g_CaseSensitive :g_MatchWholeWord];
        b_findStart = YES;
        [m_view vFind:dir];
    }
    else if(text != nil && text.length > 0)
    {
        bool stringCmp =false;
        if( findString != NULL )
        {
            if(g_CaseSensitive == true)
                stringCmp=[text compare:findString] == NSOrderedSame;
            else
                stringCmp=[text caseInsensitiveCompare:findString] == NSOrderedSame;
        }
        if( !stringCmp )
        {
            [m_view vFindStart:text :g_CaseSensitive :g_MatchWholeWord];
            findString =text;
        }
        [m_view vFind:dir];
    }
}

#pragma mark - Search List
- (void)showSearchList
{
    if (SEARCH_LIST == 1) {
        [[RDExtendedSearch sharedInstance] searchText:_m_searchBar.text inDoc:m_doc success:^(NSMutableArray *occurrences) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([[[RDExtendedSearch sharedInstance] searchResults] count] > 0) {
                    SearchResultTableViewController *viewController = [[SearchResultTableViewController alloc] initWithNibName:@"SearchResultTableViewController" bundle:nil];
                    viewController.delegate = self;
                    
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                        
                        viewController.modalPresentationStyle = UIModalPresentationPopover;
                        UIPopoverPresentationController *popover = viewController.popoverPresentationController;
                        popover.barButtonItem = (UIBarButtonItem *)[_searchToolBar.items objectAtIndex:0]; // search bar button item
                        
                        [self presentViewController:viewController animated:YES completion:nil];
                    }
                    else
                    {
                        b_outline = YES;
                        [self.navigationController pushViewController:viewController animated:YES];
                    }
                }
            });
        }];
    }
}

- (void)didSelectSelectSearchResult:(int)index
{
    if (b_outline) {
        b_outline = NO;
        b_search_outline = YES;
        [self.navigationController popViewControllerAnimated:YES];
        [self goToSearchResult:index];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            [self goToSearchResult:index];
        }];
    }
}

- (void)goToSearchResult:(int)index
{
    [m_view resetZoomLevel];
    [self PDFGoto:index];
    [self startSearch:[[RDExtendedSearch sharedInstance] searchTxt] dir:1 reset:YES];
}

- (void)OnPageChanged :(int)pageno
{
    static int prevPage = -1;
    if (_delegate) {
        if (pageno != prevPage) {
            prevPage = pageno;
            [_delegate didChangePage:pageno];
        }
    }
    
    pageno++;
    NSString *pagestr = [[NSString alloc]initWithFormat:@"%d/",pageno];
    pagestr = [pagestr stringByAppendingFormat:@"%d",_pagecount];
    _pageNumLabel.text = pagestr;
    
    [m_Thumbview vGoto:pageno-1];
    m_slider.value = pageno;
}

- (void)OnSingleTapped:(float)x :(float)y
{
    if (_delegate) {
        struct PDFV_POS pos;
        [m_view vGetPos:&pos x:x y:y];
        [_delegate didTapOnPage:pos.pageno atPoint:CGPointMake(x, y)];
    }
    
    if (b_noteAnnot) {
        posx = x;
        posy = y;
        [self TextAnnot:nil];
        return;
    }
    
    if (!pickerView.hidden) {
        pickerView.hidden = YES;
        confirmPickerBtn.hidden = YES;
    }
    [_m_searchBar resignFirstResponder];
    
    if(isImmersive)
    {
        [self showBars];
    }
    else
    {
        [self hideBars];
    }
    
    b_outline = true;
    m_bSel = false;
    [m_view vSelEnd];
    [self refreshStatusBar];
    
    
}

- (void)OnDoubleTapped:(float)x :(float)y
{
    if (_delegate) {
        struct PDFV_POS pos;
        [m_view vGetPos:&pos x:x y:y];
        [_delegate didDoubleTapOnPage:pos.pageno atPoint:CGPointMake(x, y)];
    }
}

- (void)OnFound:(bool)found
{
    if (_delegate) {
        [_delegate didSearchTerm:findString found:found];
    }
    
    if( !found )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Waring" message:@"Find Over" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}
-(void)refreshStatusBar{
    [self setNeedsStatusBarAppearanceUpdate];
}


- (void)refreshCurrentPage
{
    [m_view refreshCurrentPage];
}

-(BOOL)prefersStatusBarHidden
{
    return statusBarHidden;
}

#pragma mark annotToolBar

- (NSArray *)getAllAnnotations;
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    int pageCount = [m_doc pageCount];
    for (int pi = 0; pi < pageCount; pi++) {
        PDFPage *page = [m_doc page:pi];
        PDFDIB *dib = [[PDFDIB alloc] init:1 :1];
        [page renderPrepare:dib];
        PDFMatrix *mat = [[PDFMatrix alloc] init:1: -1: 0: 1];
        [page render:dib :mat :mode_normal];
        int annotCount = [page annotCount];
        for (int ai = 0; ai < annotCount; ai++) {
            PDFAnnot *annot = [page annotAtIndex:ai];
            NSDictionary *dict =
            [[NSDictionary alloc] initWithObjectsAndKeys:
             @(pi), @"page",
             @(ai), @"index",
             @([annot type]), @"type",
             [annot getPopupSubject], @"subject",
             [annot getPopupText], @"text",
             nil];
            [arr addObject:dict];
        }
    }
    
    return [arr copy];
}

- (NSArray *)getOutline
{
    PDFOutline *outline = [m_doc rootOutline];

    return [self getOutlineTree: outline];
}

- (NSArray *)getOutlineTree:(PDFOutline *)outline
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    while( outline )
    {
        NSDictionary *dict;
        if (outline.child) {
            NSArray *children = [self getOutlineTree:outline.child];
            
            dict = [[NSDictionary alloc] initWithObjectsAndKeys:
             outline.label, @"label",
             @(outline.dest), @"page",
             children, @"children",
             nil];
        } else {
            dict =
            [[NSDictionary alloc] initWithObjectsAndKeys:
             outline.label, @"label",
             @(outline.dest), @"page",
             nil];
        }

        [arr addObject:dict];
        
        outline = [outline next];
    }
    
    return [arr copy];
}

- (UIImage *)getThumbnail:(int)pageno
{
    float scale = 1;
    float w = [m_doc pageWidth:pageno];
    float h = [m_doc pageHeight:pageno];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(w, h), YES, 1.0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    PDFVCache1 *thumb = [[PDFVCache1 alloc] init: m_doc :pageno :scale : w: h];
    [thumb Render];
    PDFVCanvas *canvas = [[PDFVCanvas alloc] init: context: scale];
    [canvas DrawBmp:[thumb Bmp] :0 :0];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(void)addannotToolBar
{
    annotToolBar = [UIToolbar new];
    [annotToolBar sizeToFit];
    //annotToolBar.barStyle = UIBarStyleBlackOpaque;
    
    UIBarButtonItem *playbutton= [[UIBarButtonItem alloc] initWithImage:_performImage style:UIBarButtonItemStylePlain target:self action:@selector(performAnnot)];
    playbutton.width =30;
    UIBarButtonItem *deletebutton= [[UIBarButtonItem alloc] initWithImage:_deleteImage style:UIBarButtonItemStylePlain target:self action:@selector(deleteAnnot)];
    deletebutton.width =30;
    UIBarButtonItem *cancelbtn= [[UIBarButtonItem alloc] initWithImage:_removeImage style:UIBarButtonItemStylePlain target:self action:@selector(annotCancel)];
    cancelbtn.width =30;
    
    NSArray *_toolBarItem = [[NSArray alloc]initWithObjects:playbutton,deletebutton,cancelbtn,nil];
    [annotToolBar setItems:_toolBarItem animated:NO];
    [_toolBar addSubview:annotToolBar];
    
    [self _toolBarStyle];
}
-(void)performAnnot
{
    [m_view vAnnotPerform];
}
-(void)deleteAnnot
{
    [m_view vAnnotRemove];
}
-(void)annotCancel
{
    [m_view vAnnotEnd];
    [self removeannotToolBar];
}
-(void)removeannotToolBar
{
    [annotToolBar removeFromSuperview];
}

-(void)removeAnnotationAt:(int)page :(int)index
{
    [m_view removeAnnotationAt:page :index];
}

- (void)didTapAnnot:(PDFAnnot *)annot atPage:(int)page atPoint:(CGPoint)point
{
    if (_delegate) {
        [_delegate didTapOnAnnotationOfType:annot.type atPage:page atPoint:point];
    }
}

//enter annotation status.
-(void)OnAnnotClicked:(PDFPage *)page :(PDFAnnot *)annot :(float)x :(float)y
{
    annotTapped = CGPointMake(x, y);
    
    // Check if an empty signature field
    if (annot.fieldType == 4 && annot.getSignStatus == 0) {
        
        NSString *sigPath = [m_view getImageFromAnnot:annot];
        UIImage *sigImage = [UIImage imageWithContentsOfFile:sigPath];
        NSData *sigData = [NSData dataWithContentsOfFile:sigPath];
        
        NSString *emptyPath = [m_view emptyAnnotWithSize:sigImage.size];
        NSData *emptyData = [NSData dataWithContentsOfFile:emptyPath];
        
        // Check if signature is empty
        if ([sigData isEqualToData:emptyData]){
            
            [self presentSignatureViewController];
        }
        else
        {
            // Overwrite signature
            UIAlertController *signAlert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Signature already exist. Do you want delete it?" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self presentSignatureViewController];
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [m_view vAnnotEnd];
            }];
            [signAlert addAction:delete];
            [signAlert addAction:cancel];
            [self presentViewController:signAlert animated:YES completion:nil];
        }
        
        [[NSFileManager defaultManager] removeItemAtPath:sigPath error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:emptyPath error:nil];
    }
    
    m_Thumbview.hidden = NO;
    [_pageNumLabel setHidden:false];
    // [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [_m_searchBar setHidden:NO];
    statusBarHidden = NO;
    
    b_outline = true;
    m_bSel = false;
    [self refreshStatusBar];
    
    PDFannot = annot;
    annot_x  = x;
    annot_y  = y;
    [self addannotToolBar];
}
//notified when annotation status end.
- (void)OnAnnotEnd
{
    if (!pickerView.hidden) {
        pickerView.hidden = YES;
        confirmPickerBtn.hidden = YES;
    }
    if (!textFd.hidden){
        [textFd resignFirstResponder];
        textFd.hidden = YES;
    }
    [self removeannotToolBar];
    if (_delegate != nil) {
        [_delegate didUnselectAnnotation];
    }
}
//this mehod fired only when vAnnotPerform method invoked.
- (void)OnAnnotGoto:(int)pageno
{
    [m_view vGoto:pageno];
}
//this mehod fired only when vAnnotPerform method invoked.
- (void)OnAnnotPopup:(PDFAnnot *)annot :(NSString *)subj :(NSString *)text
{
    
    if(text!=nil)
    {
        textAnnotVC = [[TextAnnotViewController alloc]init];
        [textAnnotVC setPos_x:posx];
        [textAnnotVC setDelegate:self];
        [textAnnotVC setPos_y:posy];
        [textAnnotVC setText:text];
        [textAnnotVC setSubject:subj];
        
        UINavigationController *navController = [[UINavigationController alloc]
                                                 initWithRootViewController:textAnnotVC];
        [navController setModalPresentationStyle:UIModalPresentationFormSheet];
        [self presentViewController:navController animated:YES completion:nil];
    }
    
}

- (void)OnAnnotList:(PDFAnnot *)annot items:(NSArray *)dataArray selectedIndexes:(NSArray *)indexes
{
    NSLog(@"list sels");
    
    annotListTV = [[RDAnnotListViewController alloc] initWithNibName:@"RDAnnotListViewController" bundle:nil];
    BOOL isMultiSel;
    isMultiSel = [annot isMultiSel];
    annotListTV.delegate = self;
    annotListTV.annotList = dataArray;
    annotListTV.multiSel = isMultiSel;
    annotListTV.annotSelected = [NSMutableArray arrayWithArray:indexes];
    annotListTV.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    annotListTV.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    b_outline = TRUE;
    [self presentViewController:annotListTV animated:YES completion:nil];
}

//this mehod fired only when vAnnotPerform method invoked.
- (void)OnAnnotOpenURL:(NSString *)url
{
    if( url )//open URI
    {
        nuri = url;
        NSString *str1=NSLocalizedString(@"Alert", @"Localizable");
        NSString *str2=NSLocalizedString(@"Do you want to open:", @"Localizable");
        NSString *message = [str2 stringByAppendingFormat:@"%@",url];
        NSString *str3=NSLocalizedString(@"OK", @"Localizable");
        NSString *str4=NSLocalizedString(@"Cancel", @"Localizable");
        UIAlertView *alter = [[UIAlertView alloc]initWithTitle:str1 message:message delegate:self cancelButtonTitle:str3 otherButtonTitles:str4, nil];
        [alter show];
        return;
    }
}

//this mehod fired only when vAnnotPerform method invoked.
- (void)OnAnnotMovie:(NSString *)fileName
{
    [tempfiles addObject:fileName];
    //GEAR
    NSURL *urlPath = [NSURL fileURLWithPath:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        mpvc = [[MPMoviePlayerViewController alloc] initWithContentURL:urlPath];
        mpvc.view.frame = self.view.bounds;
        mpvc.modalPresentationStyle = UIModalPresentationFormSheet;
        
        [self presentMoviePlayerViewControllerAnimated:mpvc];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Couldn't find media file" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}
//this mehod fired only when vAnnotPerform method invoked.
- (void)OnAnnotSound:(NSString *)fileName
{
    [tempfiles addObject:fileName];
}

-(void)OnLongPressed:(float)x :(float)y
{
    if (_delegate) {
        [_delegate didLongPressOnPage:(_pagenow - 1) atPoint:CGPointMake(x, y)];
    }
    
    [m_view vSelStart];//start to select
    m_bSel = true;
}

-(void)OnSingleTapped:(float)x :(float)y :(NSString *)text
{
    [_m_searchBar resignFirstResponder];
    //[self OnTouchDown];

    if(YES)
    {
        //  m_Thumbview.hidden = NO;
        [_pageNumLabel setHidden:false];
        // [self.navigationController setNavigationBarHidden:NO animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [_m_searchBar setHidden:NO];
    }
    else
    {
        // m_Thumbview.hidden =YES;
        [_pageNumLabel setHidden:true];
        //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        // BOOL navBarState = [self.navigationController isNavigationBarHidden];
        //Set the navigationBarHidden to the opposite of the current state.
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [_m_searchBar resignFirstResponder];
        [_m_searchBar setHidden:YES];
        //[self.navigationController set_toolBarHidden:!navBarState animated:YES];
        
    }
    b_outline = true;
    m_bSel = false;
    [m_view vSelEnd];
    
    if([text length]>0)
    {
        textAnnotVC = [[TextAnnotViewController alloc]init];
        [textAnnotVC setPos_x:posx];
        [textAnnotVC setDelegate:self];
        [textAnnotVC setPos_y:posy];
        [textAnnotVC setText:text];
        textAnnotVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        textAnnotVC.modalPresentationStyle = UIModalPresentationFormSheet;
        UINavigationController *navController = [[UINavigationController alloc]
                                                 initWithRootViewController:textAnnotVC];
        [navController setModalPresentationStyle:UIModalPresentationFormSheet];
        [self presentViewController:navController animated:YES completion:nil];
    }
    
}

-(void)OnSelStart :(float)x :(float)y;
{
    if(m_bSel)
    {
        m_bSel = false;
        [m_view vSelEnd];
    }
    
}

- (void)OnSelEnd:(float)x1 :(float)y1 :(float)x2 :(float)y2
{
    if (onSelectAction == SELECT_DO_HIGHLIGHT) {
        [self HighLight:nil];
        [self highlightText];
        return;
    } else if (onSelectAction == SELECT_DO_UNDERLINE) {
        [self UnderLine:nil];
        [self underlineText];
        return;
    } else if (onSelectAction == SELECT_DO_STRIKE) {
        [self StrikeOut:nil];
        [self strikeText];
        return;
    }
    
    NSString* selectedText = [m_view vSelGetText];
    if ([selectedText length] == 0 || [selectedText isEqualToString:@" "]){
        m_bSel = false;
    }
    else {
        BOOL isActive = [[NSUserDefaults standardUserDefaults] boolForKey:@"actIsActive"];
        int licenseType = [[[NSUserDefaults standardUserDefaults] objectForKey:@"actActivationType"] intValue];
        
        [self becomeFirstResponder];
        m_bSel = true;
        _underline = [[UIMenuItem alloc] initWithTitle:@"UDL" action:@selector(UnderLine:)];
        _highline = [[UIMenuItem alloc] initWithTitle:@"HGL" action:@selector(HighLight:)];
        _strike = [[UIMenuItem alloc] initWithTitle:@"STR" action:@selector(StrikeOut:)];
        _textCopy = [[UIMenuItem alloc] initWithTitle:@"COPY" action:@selector(Copy:)];
        
        NSArray *itemsMC = [NSArray array];
        
        if (!isActive || licenseType < 1) {
            itemsMC = [[NSArray alloc] initWithObjects:_textCopy, nil];
        } else {
            itemsMC = [[NSArray alloc] initWithObjects:_underline,_highline,_strike,_textCopy, nil];
        }
        
        _selectMC = [UIMenuController sharedMenuController];
        [_selectMC setMenuItems:itemsMC];
        [_selectMC setTargetRect:CGRectMake(x2,y2, 0, 0) inView:self.view];
        [_selectMC setMenuVisible:YES animated:YES];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)_m_searchBar
{
    b_keyboard = true;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)isPortrait
{
    return ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait ||
            [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark -need delete
//PopupView action
- (void)OnOpenURL:(NSString*)url
{
    if( url )//open URI
    {
        nuri = url;
        NSString *str1=NSLocalizedString(@"Alert", @"Localizable");
        NSString *str2=NSLocalizedString(@"Do you want to open:", @"Localizable");
        NSString *message = [str2 stringByAppendingFormat:@"%@",url];
        NSString *str3=NSLocalizedString(@"OK", @"Localizable");
        NSString *str4=NSLocalizedString(@"Cancel", @"Localizable");
        UIAlertView *alter = [[UIAlertView alloc]initWithTitle:str1 message:message delegate:self cancelButtonTitle:str3 otherButtonTitles:str4, nil];
        [alter show];
        return;
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex ==0)
    {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:nuri]];
    }
}

-(void)toggleSelection
{
    if (alreadySelected == false)
    {
        [self enableSelection];
    }
    else
    {
        [self disableSelection];
    }
}

-(void)enableSelection
{
    [_selButton setTintColor:[UIColor lightGrayColor]];
    
    [m_view vSelEnd];
    [m_view vSelStart];
    alreadySelected = true;
}

-(void)disableSelection
{
    [_selButton setTintColor:_toolBar.tintColor];
    
    [m_view vSelEnd];
    alreadySelected = false;
}

-(void)Copy :(id)sender
{
    
    NSString* s = [m_view vSelGetText];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = s;
    NSLog(@"%@",s);
    
    if(m_bSel)
    {
        m_bSel = false;
        [m_view vSelEnd];
    }
    
    [self toggleSelection];
}
-(void)StrikeOut :(id)sender
{
    //2strikethrough
    if(![m_view vSelMarkup:annotStrikeoutColor :2])
    {
        NSString *str1=NSLocalizedString(@"Alert", @"Localizable");
        NSString *str2=NSLocalizedString(@"This Document is readonly", @"Localizable");
        NSString *str3=NSLocalizedString(@"OK", @"Localizable");
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:str1 message:str2 delegate:self cancelButtonTitle:str3 otherButtonTitles:nil,nil];
        [alter show];
        return;
    }
    
    if(m_bSel)
    {
        m_bSel = false;
        [m_view vSelEnd];
    }
    
    [self toggleSelection];
}

-(void)HighLight :(id)sender
{
    //0HighLight
    if(![m_view vSelMarkup:annotHighlightColor :0])
    {
        NSString *str1=NSLocalizedString(@"Alert", @"Localizable");
        NSString *str2=NSLocalizedString(@"This Document is readonly", @"Localizable");
        NSString *str3=NSLocalizedString(@"OK", @"Localizable");
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:str1 message:str2 delegate:self cancelButtonTitle:str3 otherButtonTitles:nil,nil];
        [alter show];
        return;
    }
    
    if(m_bSel)
    {
        m_bSel = false;
        [m_view vSelEnd];
    }
    
    [self toggleSelection];
}
-(void)UnderLine :(id)sender
{
    //1UnderLine
    if(![m_view vSelMarkup:annotUnderlineColor :1])
    {
        NSString *str1=NSLocalizedString(@"Alert", @"Localizable");
        NSString *str2=NSLocalizedString(@"This Document is readonly", @"Localizable");
        NSString *str3=NSLocalizedString(@"OK", @"Localizable");
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:str1 message:str2 delegate:self cancelButtonTitle:str3 otherButtonTitles:nil,nil];
        [alter show];
        return;
    }
    
    if(m_bSel)
    {
        m_bSel = false;
        [m_view vSelEnd];
    }
    
    [self toggleSelection];
}

-(void)TextAnnot :(id)sender
{
    if (![m_view canSaveDocument]) {
        NSString *str1=NSLocalizedString(@"Alert", @"Localizable");
        NSString *str2=NSLocalizedString(@"This Document is readonly", @"Localizable");
        NSString *str3=NSLocalizedString(@"OK", @"Localizable");
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:str1 message:str2 delegate:self cancelButtonTitle:str3 otherButtonTitles:nil,nil];
        [alter show];
        return;
    }
    
    // b_noteAnnot = NO;
    m_bSel = false;
    b_outline = true;
    [m_view vSelEnd];
    //  [m_view vNoteStart];
    
    PDFannot = [m_view vGetTextAnnot :posx :posy];
    textAnnotVC = [[TextAnnotViewController alloc]init];
    [textAnnotVC setPos_x:posx];
    [textAnnotVC setDelegate:self];
    [textAnnotVC setPos_y:posy];
    
    //  [textAnnotVC setText:text];
    textAnnotVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    textAnnotVC.modalPresentationStyle = UIModalPresentationFormSheet;
    
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:textAnnotVC];
    [m_view vNoteStart];
    
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentViewController:navController animated:YES completion:nil];
    
}

-(void)OnSaveTextAnnot:(NSString *)textAnnot subject:(NSString *)subject
{
    if([textAnnot isEqualToString:@""])
    {
        [m_view vNoteEnd];
    }
    else{
        [m_view vNoteEnd];
        if(PDFannot){
            [PDFannot setPopupSubject:subject];
            [PDFannot setPopupText:textAnnot];
        }else{
            [m_view vAddTextAnnot:posx :posy:textAnnot :subject];
        }
    }
}
//This is a delegate function ,when tap the media annot in pdf file
//will generate a temp file,fileName is temp media path
- (void)OnMovie:(NSString *)fileName
{
    [tempfiles addObject:fileName];
    //GEAR
    NSURL *urlPath = [NSURL fileURLWithPath:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        mpvc = [[MPMoviePlayerViewController alloc] initWithContentURL:urlPath];
        mpvc.view.frame = self.view.bounds;
        mpvc.modalPresentationStyle = UIModalPresentationFormSheet;
        
        [self presentMoviePlayerViewControllerAnimated:mpvc];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Couldn't find media file" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    //END
}



- (void)OnSound:(NSString *)fileName
{
    [tempfiles addObject:fileName];
    
    //
    //open media file
    //
}

//End PopupView action
- (void)OnAnnotCommboBox:(NSArray *)dataArray selected:(int)index
{
    NSLog(@"");
    pickViewArr = dataArray;
    pickerView.hidden = NO;
    confirmPickerBtn.hidden = NO;
    [self.view bringSubviewToFront:confirmPickerBtn];
    [self.view bringSubviewToFront:pickerView];
    [pickerView reloadAllComponents];
    [pickerView selectRow:index inComponent:0 animated:NO];
}

#pragma mark - Immersive

- (void)showBars
{
    if(self.navigationController.navigationBar.hidden)
    {
        m_Thumbview.hidden = NO;
        m_slider.hidden = NO;
        [_pageNumLabel setHidden:false];
        // [self.navigationController setNavigationBarHidden:NO animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [_m_searchBar setHidden:NO];
        statusBarHidden = NO;
        isImmersive = NO;
    }
}

- (void)hideBars
{
    if(!self.navigationController.navigationBar.hidden)
    {
        m_Thumbview.hidden =YES;
        [_pageNumLabel setHidden:true];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [_m_searchBar resignFirstResponder];
        [_m_searchBar setHidden:YES];
        m_slider.hidden = YES;
        statusBarHidden = YES;
        isImmersive = YES;
    }
}

#pragma mark - Set view

- (void)showViewModeTableView
{
    ViewModeTableViewController *vm = [[ViewModeTableViewController alloc] init];
    vm.delegate = self;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        vm.modalPresentationStyle = UIModalPresentationPopover;
        vm.delegate = self;
        vm.preferredContentSize = CGSizeMake(320, (44 * 4) + 10);
        vm.tableView.scrollEnabled = NO;
        
        UIPopoverPresentationController *pop = vm.popoverPresentationController;
        pop.permittedArrowDirections = UIPopoverArrowDirectionUp;
        pop.barButtonItem = _viewModeButton;
        
        [self presentViewController:vm animated:YES completion:nil];
    }
    else
    {
        UIAlertController *action = [UIAlertController alertControllerWithTitle:@"Select View Mode" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        UIAlertAction *vert = [UIAlertAction actionWithTitle:@"Vertical" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self setReaderViewMode:0];
        }];
        [vert setValue:[[UIImage imageNamed:@"btn_view_vert"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        
        UIAlertAction *horz = [UIAlertAction actionWithTitle:@"Horizontal" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self setReaderViewMode:1];
        }];
        [horz setValue:[[UIImage imageNamed:@"btn_view_horz"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        
        UIAlertAction *singleP = [UIAlertAction actionWithTitle:@"Single Page" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self setReaderViewMode:3];
        }];
        [singleP setValue:[[UIImage imageNamed:@"btn_view_single"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        
        UIAlertAction *doubleP = [UIAlertAction actionWithTitle:@"Double Page" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self setReaderViewMode:4];
        }];
        [doubleP setValue:[[UIImage imageNamed:@"btn_view_dual"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        
        
        [action addAction:vert];
        [action addAction:horz];
        [action addAction:singleP];
        [action addAction:doubleP];
        
        [action addAction:cancel];
        
        [self presentViewController:action animated:YES completion:nil];
    }
}

- (void)setReaderViewMode:(int)mode
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    int currentPage = [m_view vGetCurrentPage];
    if( m_view != nil )
    {
        [m_view vClose];
        [m_view removeFromSuperview];
        m_view = NULL;
    }
    
    switch (mode) {
        case 2:
        {
            g_def_view = 3;
            break;
        }
        case 3:
        {
            g_def_view = 4;
            break;
        }
        default:
            g_def_view = mode;
            break;
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:mode forKey:@"DefView"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    CGRect rect = [self.view bounds];
    
    //GEAR
    if (![self isPortrait] && rect.size.width < rect.size.height) {
        float height = rect.size.height;
        rect.size.height = rect.size.width;
        rect.size.width = height;
    }
    //END
    
    m_view = [[PDFView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    
    [m_view setFirstPageCover:firstPageCover];
    [m_view setDoubleTapZoomMode:doubleTapZoomMode];
    [m_view vOpen :m_doc :(id<PDFViewDelegate>)self];
    _pagecount =[m_doc pageCount];
    
    if (m_Thumbview) {
        [self.view insertSubview:m_view belowSubview:m_Thumbview];
    }
    
    if (m_slider) {
        [self.view insertSubview:m_view belowSubview:m_slider];
    }
    
    m_bSel = false;
    
    [self PDFGoto:currentPage];
}

#pragma mark - Grid View

- (void)toggleGridView
{
    if (!m_Gridview) {
        [self showGridView];
        
    } else {
        [self hideGridView];
    }
}

- (void)showGridView
{
    if (!m_Gridview) {
        CGRect frame = self.view.frame;
        CGFloat x = 0.0;
        CGFloat y =  [[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.frame.size.height;
        y = 0.0;
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height - y;
        m_Gridview = [[PDFThumbView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        [m_Gridview vOpen:m_doc :(id<PDFThumbViewDelegate>)self mode:2 elementGap:(gridGap > 0) ? gridGap : 10 elementHeight:(gridElementHeight > 0) ? gridElementHeight : 200 gridMode:gridMode];
        
        if (gridBackgroundColor != 0) {
            [m_Gridview setThumbBackgroundColor:gridBackgroundColor];
        }
        
        [self.view addSubview:m_Gridview];
    }
}

- (void)hideGridView
{
    if(m_Gridview) {
        [m_Gridview removeFromSuperview];
        [m_Gridview vClose];
        m_Gridview = nil;
    }
}


#pragma mark - Signature

- (void)presentSignatureViewController
{
    SignatureViewController *sv = [[SignatureViewController alloc] init];
    sv.delegate = self;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        sv.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:sv animated:YES completion:nil];
}

- (void)didSign
{
    [self dismissViewControllerAnimated:YES completion:^{
        [m_view setSignatureImageAtIndex:PDFannot.getIndex atPage:[m_view vGetCurrentPage]];
        [m_view vAnnotEnd];
    }];
}

#pragma mark - Print

- (void)printPdf
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:pdfPath]) {
        UIAlertView *alter = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"PDF file not available"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alter show];
        return;
    }
    
    NSData *myData = [NSData dataWithContentsOfFile:pdfPath];
    
    UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    
    if ( pic && [UIPrintInteractionController canPrintData: myData] ) {
        pic.delegate = self;
        
        UIPrintInfo *printInfo = [UIPrintInfo printInfo];
        printInfo.outputType = UIPrintInfoOutputGeneral;
        printInfo.jobName = [pdfPath lastPathComponent];
        printInfo.duplex = UIPrintInfoDuplexLongEdge;
        pic.printInfo = printInfo;
        pic.showsPageRange = YES;
        pic.printingItem = myData;
        
        void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) = ^(UIPrintInteractionController *pic, BOOL completed, NSError *error) {
            if (!completed && error) {
                NSLog(@"FAILED! due to error in domain %@ with error code %ld", error.domain, (long)error.code);
            }
        };
        
        [pic presentAnimated:YES completionHandler:completionHandler];
    }
}

- (void)sharePdf
{

    if (![[NSFileManager defaultManager] fileExistsAtPath:pdfPath]) {
        UIAlertView *alter = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"PDF file not available"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alter show];
        return;
    }
    
    NSData *myData = [NSData dataWithContentsOfFile:pdfPath];
    UIActivityItemProvider *source = [[PDFItemProvider alloc] initWithPlaceholderItem:myData];
    
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:[NSArray arrayWithObject:source] applicationActivities:nil];
    
    avc.popoverPresentationController.sourceView = self.view;
    CGRect rect = self.view.frame;
    avc.popoverPresentationController.sourceRect = CGRectMake(rect.origin.x, rect.origin.y, 0, 0);
    avc.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    
    [self presentViewController:avc animated:YES completion:nil];

}

#pragma mark - Save

- (void)savePdf
{
    if([m_view forceSave])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Notice"
                                                                       message:@"Document saved"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - Attachments

- (BOOL)saveImageFromAnnotAtIndex:(int)index atPage:(int)pageno savePath:(NSString *)path size:(CGSize )size
{
    return [m_view saveImageFromAnnotAtIndex:index atPage:pageno savePath:path size:size];
}

#pragma mark - Annot render

- (BOOL)addAttachmentFromPath:(NSString *)path
{
    return [m_view addAttachmentFromPath:path];
}

#pragma mark - PickerView DataSource and Delegate
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [pickViewArr count];
}
-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [pickViewArr objectAtIndex:(int)row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectItem = (int)row;
}
- (void)setComboselect
{
    [m_view setCommboItem:selectItem];
    pickerView.hidden = YES;
    confirmPickerBtn.hidden = YES;
}
#pragma mark -EditBox delegate
- (void)OnAnnotEditBox :(CGRect)annotRect :(NSString *)editText :(float)textSize
{
    NSLog(@"annotRect = %@",NSStringFromCGRect(annotRect));
    textFd.hidden = NO;
    textFd.frame = annotRect;
    textFd.text = editText;
    textFd.backgroundColor = [UIColor whiteColor];
    textFd.font = [UIFont systemFontOfSize:textSize]; // To use a custom font you should add it as external font in Xcode project
    [self.view bringSubviewToFront:textFd];
    [textFd becomeFirstResponder];
}

#pragma mark - annotList Delegate
- (void)listCheckedAt:(NSArray *)indexes
{
    [annotListTV dismissViewControllerAnimated:YES completion:nil];
    [m_view selectListBoxItems:indexes];
    [m_view vSelEnd];
}

#pragma mark - textField Delegate
- (void)textFieldDidEndEditing:(UITextField *)textField;
{
    NSLog(@"textView.text = %@",textField.text);
    [m_view setEditBoxWithText:textField.text];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

//add begin and end editing delegate to add keyboard notifications
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    [self.view endEditing:YES];
    return YES;
}

//add keyboard notification
#pragma mark - Keyboard Notifications

- (void)keyboardDidShow:(NSNotification *)notification
{
    //move the view to avoid the keyboard overlay
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    // push the frame up the gap adding 1 pixel so the text field is not exactly on top of the keyboard
    float gap = (keyboardFrameBeginRect.origin.y - 1) - (textFd.frame.origin.y + textFd.frame.size.height);
    
    if (gap < 0) {
        [self.view setFrame:CGRectMake(0, gap, self.view.frame.size.width, self.view.frame.size.height)];
    }
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    //restore the correct view position
    [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
}

- (void)moviePlayedDidFinish:(NSNotification *)notification
{
}
@end


@implementation PDFItemProvider

- (id)item
{
    return self.placeholderItem;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController dataTypeIdentifierForActivityType:(UIActivityType)activityType
{
    return kUTTypePDF;
}

@end
