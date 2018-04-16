#import <Cordova/CDV.h>

@class RDPDFViewController;

// define the protocol for the delegate
@protocol RadaeePDFPluginDelegate
// define protocol functions that can be used in any class using this delegate
- (void)willShowReader;
- (void)didShowReader;
- (void)willCloseReader;
- (void)didCloseReader;
- (void)didChangePage:(int)page;
- (void)didSearchTerm:(NSString *)term found:(BOOL)found;
- (void)didTapOnPage:(int)page atPoint:(CGPoint)point;
- (void)didTapOnAnnotationOfType:(int)type atPage:(int)page atPoint:(CGPoint)point;
- (void)onAnnotExported:(NSString *)path;
@end;

@interface RadaeePDFPlugin : CDVPlugin{
    CDVInvokedUrlCommand* cdv_command;
    RDPDFViewController *m_pdf;
    UIViewController *m_childvc;

    NSURLConnection *pdfConn;
    NSString *url;
    NSMutableData *receivedData;
    void *buffer;
    
    //colors
    int inkColor;
    int rectColor;
    int underlineColor;
    int strikeoutColor;
    int highlightColor;
    int ovalColor;
    int selColor;
    
    int thumbBackgroundColor;
    int gridBackgroundColor;
    int readerBackgroundColor;
    int titleBackgroundColor;
    int iconsBackgroundColor;
    
    float thumbHeight;
    int gridElementHeight;
    int gridGap;
    int gridMode;
    
    int doubleTapZoomMode;
    
    BOOL firstPageCover;
    BOOL isImmersive;
    BOOL disableToolbar;
    
    int bottomBar;
}

@property (nonatomic, retain) CDVInvokedUrlCommand *cdv_command;

@property (nonatomic, retain) CDVInvokedUrlCommand *cdv_willShowReader;
@property (nonatomic, retain) CDVInvokedUrlCommand *cdv_didShowReader;
@property (nonatomic, retain) CDVInvokedUrlCommand *cdv_willCloseReader;
@property (nonatomic, retain) CDVInvokedUrlCommand *cdv_didCloseReader;
@property (nonatomic, retain) CDVInvokedUrlCommand *cdv_didChangePage;
@property (nonatomic, retain) CDVInvokedUrlCommand *cdv_didSearchTerm;
@property (nonatomic, retain) CDVInvokedUrlCommand *cdv_didTapOnPage;
@property (nonatomic, retain) CDVInvokedUrlCommand *cdv_didDoubleTapOnPage;
@property (nonatomic, retain) CDVInvokedUrlCommand *cdv_didLongPressOnPage;
@property (nonatomic, retain) CDVInvokedUrlCommand *cdv_didTapOnAnnotationOfType;
@property (nonatomic, retain) CDVInvokedUrlCommand *cdv_didUnselectAnnotation;
@property (nonatomic, retain) CDVInvokedUrlCommand *cdv_onAnnotExported;

@property (nonatomic) int viewMode;
@property (strong, nonatomic) NSString *lastOpenedPath;
@property (strong, nonatomic) UIImage *viewModeImage;
@property (strong, nonatomic) UIImage *searchImage;
@property (strong, nonatomic) UIImage *bookmarkImage;
@property (strong, nonatomic) UIImage *outlineImage;
@property (strong, nonatomic) UIImage *lineImage;
@property (strong, nonatomic) UIImage *rectImage;
@property (strong, nonatomic) UIImage *ellipseImage;
@property (strong, nonatomic) UIImage *printImage;
@property (strong, nonatomic) UIImage *gridImage;
@property (strong, nonatomic) UIImage *deleteImage;
@property (strong, nonatomic) UIImage *doneImage;
@property (strong, nonatomic) UIImage *removeImage;
@property (strong, nonatomic) UIImage *exportImage;
@property (strong, nonatomic) UIImage *prevImage;
@property (strong, nonatomic) UIImage *nextImage;

@property (nonatomic, assign) id <RadaeePDFPluginDelegate> delegate;

- (void)pluginInitialize;
- (void)show:(CDVInvokedUrlCommand*)command;
- (void)activateLicense:(CDVInvokedUrlCommand*)command;
- (void)openFromAssets:(CDVInvokedUrlCommand*)command;
- (void)openFromPath:(CDVInvokedUrlCommand*)command;
- (void)fileState:(CDVInvokedUrlCommand*)command;
- (void)getPageNumber:(CDVInvokedUrlCommand*)command;
- (void)getPageCount:(CDVInvokedUrlCommand*)command;
- (void)setThumbnailBGColor:(CDVInvokedUrlCommand*)command;
- (void)setThumbGridBGColor:(CDVInvokedUrlCommand*)command;
- (void)setReaderBGColor:(CDVInvokedUrlCommand*)command;
- (void)setThumbGridElementHeight:(CDVInvokedUrlCommand*)command;
- (void)setThumbGridGap:(CDVInvokedUrlCommand*)command;
- (void)setThumbGridViewMode:(CDVInvokedUrlCommand*)command;
- (void)setTitleBGColor:(CDVInvokedUrlCommand*)command;
- (void)setIconsBGColor:(CDVInvokedUrlCommand*)command;
- (void)setThumbHeight:(CDVInvokedUrlCommand*)command;
- (void)setFirstPageCover:(CDVInvokedUrlCommand*)command;
- (void)setDoubleTapZoomMode:(CDVInvokedUrlCommand*)command;
- (void)setImmersive:(CDVInvokedUrlCommand*)command;
- (void)setReaderViewMode:(CDVInvokedUrlCommand*)command;
- (void)setToolbarEnabled:(CDVInvokedUrlCommand*)command;
- (void)extractTextFromPage:(CDVInvokedUrlCommand*)command;
- (void)encryptDocAs:(CDVInvokedUrlCommand *)command;
- (void)addAnnotAttachment:(CDVInvokedUrlCommand *)command;
- (void)renderAnnotToFile:(CDVInvokedUrlCommand *)command;

// Actions
- (void)setTopSpace:(CDVInvokedUrlCommand*)command;
- (void)close:(CDVInvokedUrlCommand*)command;
- (void)hide:(CDVInvokedUrlCommand*)command;
- (void)unhide:(CDVInvokedUrlCommand*)command;
- (void)showDrawMenu:(CDVInvokedUrlCommand*)command;
- (void)searchStart:(CDVInvokedUrlCommand*)command;
- (void)searchNext:(CDVInvokedUrlCommand*)command;
- (void)searchPrev:(CDVInvokedUrlCommand*)command;
- (void)searchEnd:(CDVInvokedUrlCommand*)command;
- (void)showOutlineMenu:(CDVInvokedUrlCommand*)command;
- (void)showBookmarksMenu:(CDVInvokedUrlCommand*)command;
- (void)showGridView:(CDVInvokedUrlCommand*)command;
- (void)undo:(CDVInvokedUrlCommand*)command;
- (void)redo:(CDVInvokedUrlCommand*)command;
- (void)bookmarkCurrentPage:(CDVInvokedUrlCommand*)command;
- (void)print:(CDVInvokedUrlCommand*)command;
- (void)share:(CDVInvokedUrlCommand*)command;
- (void)save:(CDVInvokedUrlCommand*)command;
- (void)showViewModeMenu:(CDVInvokedUrlCommand*)command;

- (void)drawFreeformStart:(CDVInvokedUrlCommand*)command;
- (void)drawFreeformEnd:(CDVInvokedUrlCommand*)command;
- (void)drawFreeformCancel:(CDVInvokedUrlCommand*)command;
- (void)drawFreeformSetColor:(CDVInvokedUrlCommand*)command;
- (void)drawFreeformSetWidth:(CDVInvokedUrlCommand*)command;
- (void)drawNoteStart:(CDVInvokedUrlCommand*)command;
- (void)drawNoteEnd:(CDVInvokedUrlCommand*)command;
- (void)modifyTextHighlightStart:(CDVInvokedUrlCommand*)command;
- (void)modifyTextHighlightSetColor:(CDVInvokedUrlCommand*)command;
- (void)modifyTextUnderlineStart:(CDVInvokedUrlCommand*)command;
- (void)modifyTextUnderlineSetColor:(CDVInvokedUrlCommand*)command;
- (void)modifyTextStriketrhoughStart:(CDVInvokedUrlCommand*)command;
- (void)modifyTextStriketrhoughSetColor:(CDVInvokedUrlCommand*)command;
- (void)modifyTextEnd:(CDVInvokedUrlCommand*)command;
- (void)drawLinesStart:(CDVInvokedUrlCommand*)command;
- (void)drawLinesEnd:(CDVInvokedUrlCommand*)command;
- (void)drawLinesCancel:(CDVInvokedUrlCommand*)command;
- (void)drawLinesSetColor:(CDVInvokedUrlCommand*)command;
- (void)drawLinesSetWidth:(CDVInvokedUrlCommand*)command;
- (void)drawStampStart:(CDVInvokedUrlCommand*)command;
- (void)drawStampEnd:(CDVInvokedUrlCommand*)command;
- (void)drawStampCancel:(CDVInvokedUrlCommand*)command;
- (void)getAllAnnotations:(CDVInvokedUrlCommand*)command;
- (void)deleteAnnotation:(CDVInvokedUrlCommand*)command;
- (void)getOutline:(CDVInvokedUrlCommand*)command;
- (void)SelectedAnnotationDoAction:(CDVInvokedUrlCommand*)command;
- (void)SelectedAnnotationDelete:(CDVInvokedUrlCommand*)command;
- (void)SelectedAnnotationUnselect:(CDVInvokedUrlCommand*)command;
- (void)gotoPage:(CDVInvokedUrlCommand*)command;
- (void)getThumbnail:(CDVInvokedUrlCommand *)command;

// Form Manager

- (void)JSONFormFields:(CDVInvokedUrlCommand*)command;
- (void)JSONFormFieldsAtPage:(CDVInvokedUrlCommand*)command;

- (void)setFormFieldWithJSON:(CDVInvokedUrlCommand *)command;

// FTS Methods
#ifdef FTS_ENABLED
- (void)FTS_SetIndexDB:(CDVInvokedUrlCommand*)command;
- (void)FTS_AddIndex:(CDVInvokedUrlCommand*)command;
- (void)FTS_RemoveFromIndex:(CDVInvokedUrlCommand*)command;
- (void)FTS_Search:(CDVInvokedUrlCommand*)command;
- (void)SetSearchType:(CDVInvokedUrlCommand*)command;
- (void)GetSearchType:(CDVInvokedUrlCommand*)command;
#endif

// Bookmarks
- (void)addToBookmarks:(CDVInvokedUrlCommand *)command;//(NSString *)pdfPath page:(int)page label:(NSString *)label;
- (void)removeBookmark:(CDVInvokedUrlCommand *)command;//(int)page pdfPath:(NSString *)pdfPath;
- (void)getBookmarks:(CDVInvokedUrlCommand *)command;//(NSString *)pdfPath;

+ (NSString *)addToBookmarks:(NSString *)pdfPath page:(int)page label:(NSString *)label;
+ (void)removeBookmark:(int)page pdfPath:(NSString *)pdfPath;
+ (NSMutableArray *)loadBookmarkForPdf:(NSString *)pdfName withPath:(BOOL)withPath;

//Settings

- (void)setPagingEnabled:(BOOL)enabled;
- (void)setDoublePageEnabled:(BOOL)enabled;
- (void)toggleThumbSeekBar:(int)mode;
- (void)setColor:(int)color forFeature:(int)feature;

// Callbacks
- (void)willShowReaderCallback:(CDVInvokedUrlCommand *)command;
- (void)didShowReaderCallback:(CDVInvokedUrlCommand *)command;
- (void)willCloseReaderCallback:(CDVInvokedUrlCommand *)command;
- (void)didCloseReaderCallback:(CDVInvokedUrlCommand *)command;
- (void)didChangePageCallback:(CDVInvokedUrlCommand *)command;
- (void)didSearchTermCallback:(CDVInvokedUrlCommand *)command;
- (void)didTapOnPageCallback:(CDVInvokedUrlCommand *)command;
- (void)didDoubleTapOnPageCallback:(CDVInvokedUrlCommand *)command;
- (void)didLongPressOnPageCallback:(CDVInvokedUrlCommand *)command;
- (void)didTapOnAnnotationOfTypeCallback:(CDVInvokedUrlCommand *)command;
- (void)didUnselectAnnotationCallback:(CDVInvokedUrlCommand *)command;
- (void)onAnnotExportedCallback:(CDVInvokedUrlCommand *)command;

- (UIViewController *)getCordovaViewController;
- (void)setChildVcTopSpace;
- (void)rotated;

@end
