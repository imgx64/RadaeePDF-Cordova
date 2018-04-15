var app = {
    // Application Constructor
    initialize: function () {
        document.addEventListener('deviceready', this.onDeviceReady.bind(this), false);
    },

    onDeviceReady: function () {
        var parentElement = document.getElementById('deviceready');
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');

        console.log('Received Event: deviceready');

        registerCallbacks();

        onClick("activateLicense", app.activateLicense);
        onClick("open", app.open);
        onClick("openFromAssets", app.openAssets);

        onClick("close", app.close);
        onClick("edit-annotation", app.editAnnotation);
        onClick("search", app.search);
        onClick("annotations-bookmarks", app.annotationsBookmarks);
        onClick("outline-bookmarks", app.outlineBookmarks);
        onClick("rotate-left", app.rotateLeft);
        onClick("rotate-right", app.rotateRight);
        onClick("undo-main", app.undoMain);
        onClick("redo-main", app.redoMain);
        onClick("pages-bookmarks", app.pagesBookmarks);
        onClick("share", app.share);
        onClick("settings", app.settings);
        onClick("search-prev", app.searchPrev);
        onClick("search-next", app.searchNext);
        onClick("search-done", app.searchDone);
        onClick("thin-marker", app.thinMarker);
        onClick("thick-marker", app.thickMarker);
        onClick("annotate-box", app.annotateBox);
        onClick("text-highlighter", app.textHighlighter);
        onClick("underline", app.underline);
        onClick("strikeout", app.strikeout);
        onClick("flat-text", app.flatText);
        onClick("annotate-box-2", app.annotateBox2);
        onClick("straight-line", app.straightLine);
        onClick("stamp", app.stamp);
        onClick("signature", app.signature);
        onClick("voice-note", app.voiceNote);
        onClick("camera", app.camera);
        onClick("erase", app.erase);
        onClick("line-thickness", app.lineThickness);
        onClick("apply-thickness", app.applyThickness);
        onClick("color-palette", app.colorPalette);
        onClick("annotation-text", app.annotationText);
        onClick("apply", app.apply);

        var colorSelects = document.getElementsByClassName("color-select");
        for (var i = 0; i < colorSelects.length; i++) {
            var colorSelect = colorSelects[i];
            colorSelect.style.backgroundColor = "#" + colorSelect.dataset.color;
            colorSelect.addEventListener("click", app.colorSelect, false);
        }

        function onClick(elementId, func) {
            document.getElementById(elementId).addEventListener("click", func, false);
        }

        function registerCallbacks() {
            RadaeePDFPlugin.willShowReaderCallback(willShowReader);
            RadaeePDFPlugin.didShowReaderCallback(didShowReader);
            RadaeePDFPlugin.willCloseReaderCallback(willCloseReader);
            RadaeePDFPlugin.didCloseReaderCallback(didCloseReader);
            RadaeePDFPlugin.didChangePageCallback(didChangePage);
            RadaeePDFPlugin.didSearchTermCallback(didSearchTerm);
            RadaeePDFPlugin.didTapOnPageCallback(didTapOnPage);
            RadaeePDFPlugin.didTapOnAnnotationOfTypeCallback(didTapOnAnnotationOfType);
            RadaeePDFPlugin.didUnselectAnnotationCallback(didUnselectAnnotation);
            RadaeePDFPlugin.didDoubleTapOnPageCallback(didDoubleTapOnPage);
            RadaeePDFPlugin.didLongPressOnPageCallback(didLongPressOnPage);
        }

        function willShowReader() {
            console.log("--- Callback: willShowReader");
        }
        function didShowReader() {
            console.log("--- Callback: didShowReader");
        }
        function willCloseReader() {
            console.log("--- Callback: willCloseReader");
        }
        function didCloseReader() {
            console.log("--- Callback: didCloseReader");
            app.showToolbar(null);
        }
        function didChangePage(page) {
            console.log("--- Callback: didChangePage: " + page);
        }
        function didSearchTerm(term) {
            console.log("--- Callback: didSearchTerm: " + term);
        }
        function didTapOnPage(page) {
            console.log("--- Callback: didTapOnPage: " + page);
            /*RadaeePDFPlugin.renderAnnotToFile(
                        {
                            page: 4,
                            annotIndex: 3,
                            renderPath: "/mnt/sdcard/signature.png"
                        },
                        function(message) {
                             console.log("Success: " + message);
                        },
                        function(err){
                            console.log("Failure: " + err);}
                    );*/
        }
        function didTapOnAnnotationOfType(info) {
            console.log("--- Callback: didTapOnAnnotationOfType: " + info['type'] + " and index: " + info['index']);
            app.showEditToolbar('img/edit-annotation.png', RadaeePDFPlugin.SelectedAnnotationUnselect,
                RadaeePDFPlugin.SelectedAnnotationDelete, null, null, RadaeePDFPlugin.SelectedAnnotationDoAction);
        }
        function didUnselectAnnotation() {
            console.log("--- Callback: didUnselectAnnotation");
            app.showToolbar('main-toolbar');
        };
        function didDoubleTapOnPage(page) {
            console.log("--- Callback: didDoubleTapOnPage: " + page);
        }
        function didLongPressOnPage(page) {
            console.log("--- Callback: didLongPressOnPage: " + page);
        }
		/*RadaeePDFPlugin.addToBookmarks(
            {
                pdfPath: "file:///mnt/sdcard/Download/pdf/License.pdf",
                page: 1,
                label: ""
            },
            function(message) {
                 console.log("Success: " + message);
            },
            function(err){
                console.log("Failure: " + err);}
        );*/

        /*RadaeePDFPlugin.removeBookmark(
            {
            page: 1,
                pdfPath: "file:///mnt/sdcard/Download/pdf/License.pdf"
            },
            function(message) {
                 console.log("Success: " + message);
            },
            function(err){
                console.log("Failure: " + err);}
        );*/

        /*RadaeePDFPlugin.getBookmarks(
            {
                pdfPath: "file:///mnt/sdcard/Download/pdf/License.pdf"
            },
            function(message) {
                 console.log("Success: " + message);
            },
            function(err){
                console.log("Failure: " + err);}
        );*/

        /*RadaeePDFPlugin.addAnnotAttachment(
            {
                path: "/mnt/sdcard/untitled.png"
            },
            function(message) {
                 console.log("Success: " + message);
            },
            function(err){
                console.log("Failure: " + err);}
        );*/
    },

    show: function (elementId) {
        document.getElementById(elementId).classList.remove('hide');
    },

    hide: function (elementId) {
        document.getElementById(elementId).classList.add('hide');
    },

    showToolbar: function showToolbar(elementId) {
        var toolbars = [
            'main-toolbar',
            'search-toolbar',
            'annotation-toolbar',
            'edit-toolbar',
            'thickness-toolbar',
            'color-toolbar',
        ];

        toolbars.forEach(function (toolbar) {
            if (toolbar === elementId) {
                app.show(toolbar);
            } else {
                app.hide(toolbar);
            }
        });
    },

    showEditToolbar: function showEditToolbar(img, editDoneFunc, editCancelFunc,
        widthChangeFunc, colorChangeFunc, annotationTextFunc) {
        app.showToolbar('edit-toolbar');

        if (img) {
            app.show('edit-img');
            document.getElementById('edit-img').src = img;
        } else {
            app.hide('edit-img');
        }

        app.editDoneFunc = editDoneFunc;
        app.editCancelFunc = editCancelFunc;
        app.widthChangeFunc = widthChangeFunc;
        app.colorChangeFunc = colorChangeFunc;
        app.annotationTextFunc = annotationTextFunc;

        if (editCancelFunc) {
            app.show('erase');
        } else {
            app.hide('erase');
        }

        if (widthChangeFunc) {
            app.show('line-thickness');
        } else {
            app.hide('line-thickness');
        }

        if (colorChangeFunc) {
            app.show('color-palette');
        } else {
            app.hide('color-palette');
        }

        if (annotationTextFunc) {
            app.show('annotation-text');
        } else {
            app.hide('annotation-text');
        }
    },

    //activate license
    activateLicense: function () {
        console.log("Activating license");

        RadaeePDFPlugin.activateLicense({   //iOS's demo premium license for other license check:
            //http://www.radaeepdf.com/support/knowledge-base?view=kb&kbartid=4
            //http://www.radaeepdf.com/support/knowledge-base?view=kb&kbartid=8
            licenseType: 2, //0: for standard license, 1: for professional license, 2: for premium license
            company: "Radaee", //the company name you entered during license activation
            email: "radaee_com@yahoo.cn", //the email you entered during license activation
            key: "89WG9I-HCL62K-H3CRUZ-WAJQ9H-FADG6Z-XEBCAO" //your license activation key
        }).then(function (message) {
            console.log("Success: " + message);
        }).catch(function (err) {
            console.log("Failure: " + err);
        });
    },

    //open pdf from path
    open: function () {
        console.log("Opening PDF...");

        RadaeePDFPlugin.open({
            url: "file:///mnt/sdcard/Download/pdf/Sign.pdf",
            password: "" //password if needed
        }).then(function (message) {
            console.log("Success: " + message);
        }).catch(function (err) {
            console.log("Failure: " + err);
        });
    },

    //open pdf from assets
    openAssets: function () {
        console.log("Opening PDF from assets...");
        RadaeePDFPlugin.setTopSpace({
            topSpace: 50,
        }).then(function (message) {
            console.log("Success: " + message);

            return RadaeePDFPlugin.openFromAssets({
                url: "www/test.PDF",
                password: "" //password if needed
            });
        }).then(function (message) {
            console.log("Success: " + message);
            app.showToolbar('main-toolbar');
        }).catch(function (err) {
            console.log("Failure: " + err);
        });
    },

    close: function close(event) {
        RadaeePDFPlugin.close({}).then(function (message) {
            console.log("Success: " + message);
        }).catch(function (err) {
            console.log("Failure: " + err);
        });
    },

    editAnnotation: function editAnnotation(event) {
        app.showToolbar('annotation-toolbar');
    },

    search: function search(event) {
        RadaeePDFPlugin.searchStart({}).then(function (message) {
            console.log("Success: " + message);
            app.showToolbar('search-toolbar');
        }).catch(function (err) {
            console.log("Failure: " + err);
        });
    },

    annotationsBookmarks: function annotationsBookmarks(event) {
        RadaeePDFPlugin.showBookmarksMenu({}).then(function (message) {
            console.log("Success: " + message);
        }).catch(function (err) {
            console.log("Failure: " + err);
        }); ß
    },

    outlineBookmarks: function outlineBookmarks(event) {
        RadaeePDFPlugin.showOutlineMenu({}).then(function (message) {
            console.log("Success: " + message);
        }).catch(function (err) {
            console.log("Failure: " + err);
        });
    },

    rotateLeft: function rotateLeft(event) {
    },

    rotateRight: function rotateRight(event) {
    },

    undoMain: function undoMain(event) {
        RadaeePDFPlugin.undo({}).then(function (message) {
            console.log("Success: " + message);
        }).catch(function (err) {
            console.log("Failure: " + err);
        });
    },

    redoMain: function redoMain(event) {
        RadaeePDFPlugin.redo({}).then(function (message) {
            console.log("Success: " + message);
        }).catch(function (err) {
            console.log("Failure: " + err);
        });
    },

    pagesBookmarks: function pagesBookmarks(event) {
        RadaeePDFPlugin.showGridView({}).then(function (message) {
            console.log("Success: " + message);
        }).catch(function (err) {
            console.log("Failure: " + err);
        });
    },

    share: function share(event) {
        RadaeePDFPlugin.print({}).then(function (message) {
            console.log("Success: " + message);
        }).catch(function (err) {
            console.log("Failure: " + err);
        });
    },

    settings: function settings(event) {
        RadaeePDFPlugin.showViewModeMenu({}).then(function (message) {
            console.log("Success: " + message);
        }).catch(function (err) {
            console.log("Failure: " + err);
        });
    },

    searchPrev: function searchPrev(event) {
        var searchTerm = document.getElementById('search-box').value;
        RadaeePDFPlugin.searchPrev({
            searchTerm: searchTerm,
        }).then(function (message) {
            console.log("Success: " + message);
        }).catch(function (err) {
            console.log("Failure: " + err);
        });
    },

    searchNext: function searchNext(event) {
        var searchTerm = document.getElementById('search-box').value;
        RadaeePDFPlugin.searchNext({
            searchTerm: searchTerm,
        }).then(function (message) {
            console.log("Success: " + message);
        }).catch(function (err) {
            console.log("Failure: " + err);
        });
    },

    searchDone: function searchDone(event) {
        RadaeePDFPlugin.searchEnd({}).then(function (message) {
            console.log("Success: " + message);
            app.showToolbar('main-toolbar');
        }).catch(function (err) {
            console.log("Failure: " + err);
        });
    },

    thinMarker: function thinMarker(event) {
        RadaeePDFPlugin.drawFreeformStart();
        var img = event.target && event.target.src;
        app.showEditToolbar(img, RadaeePDFPlugin.drawFreeformEnd, RadaeePDFPlugin.drawFreeformCancel,
            RadaeePDFPlugin.drawFreeformSetWidth, RadaeePDFPlugin.drawFreeformSetColor);
    },

    thickMarker: function thickMarker(event) {
    },

    annotateBox: function annotateBox(event) {
        RadaeePDFPlugin.drawNoteStart();
        var img = event.target && event.target.src;
        app.showEditToolbar(img, RadaeePDFPlugin.drawNoteEnd, null, null, null);
    },

    textHighlighter: function textHighlighter(event) {
        RadaeePDFPlugin.modifyTextHighlightStart();
        var img = event.target && event.target.src;
        app.showEditToolbar(img, RadaeePDFPlugin.modifyTextEnd, null, null, RadaeePDFPlugin.modifyTextHighlightSetColor);
    },

    underline: function underline(event) {
        RadaeePDFPlugin.modifyTextUnderlineStart();
        var img = event.target && event.target.src;
        app.showEditToolbar(img, RadaeePDFPlugin.modifyTextEnd, null, null, RadaeePDFPlugin.modifyTextUnderlineSetColor);
    },

    strikeout: function strikeout(event) {
        RadaeePDFPlugin.modifyTextStriketrhoughStart();
        var img = event.target && event.target.src;
        app.showEditToolbar(img, RadaeePDFPlugin.modifyTextEnd, null, null, RadaeePDFPlugin.modifyTextStriketrhoughSetColor);
    },

    flatText: function flatText(event) {
    },

    annotateBox2: function annotateBox2(event) {
        RadaeePDFPlugin.bookmarkCurrentPage({}).then(function (message) {
            console.log("Success: " + message);
            app.showToolbar('main-toolbar');
        }).catch(function (err) {
            console.log("Failure: " + err);
        });
    },

    straightLine: function straightLine(event) {
        RadaeePDFPlugin.drawLinesStart();
        var img = event.target && event.target.src;
        app.showEditToolbar(img, RadaeePDFPlugin.drawLinesEnd, RadaeePDFPlugin.drawLinesCancel,
            RadaeePDFPlugin.drawLinesSetWidth, RadaeePDFPlugin.drawLinesSetColor);
    },

    stamp: function stamp(event) {
        RadaeePDFPlugin.drawStampStart();
        var img = event.target && event.target.src;
        app.showEditToolbar(img, RadaeePDFPlugin.drawStampEnd, RadaeePDFPlugin.drawStampCancel, null, null);
    },

    signature: function signature(event) {
    },

    voiceNote: function voiceNote(event) {
    },

    camera: function camera(event) {
    },

    erase: function erase(event) {
        app.showToolbar('main-toolbar');
        app.editCancelFunc && app.editCancelFunc();
    },

    lineThickness: function lineThickness(event) {
        app.showToolbar('thickness-toolbar');
    },

    applyThickness: function applyThickness(event) {
        var width = document.getElementById('input-thickness').value;
        app.widthChangeFunc && app.widthChangeFunc({
            width: width,
        }).then(function (message) {
            console.log("Success: " + message);
            app.showToolbar('edit-toolbar');
        }).catch(function (err) {
            console.log("Failure: " + err);
        });
    },

    colorPalette: function colorPalette(event) {
        app.showToolbar('color-toolbar');
    },

    colorSelect: function colorSelect(event) {
        var color = parseInt(event.target.dataset.color, 16);
        app.colorChangeFunc && app.colorChangeFunc({
            color: color,
        }).then(function (message) {
            console.log("Success: " + message);
            app.showToolbar('edit-toolbar');
        }).catch(function (err) {
            console.log("Failure: " + err);
        });
    },

    annotationText: function annotationText(event) {
        app.annotationTextFunc && app.annotationTextFunc({}).then(function (message) {
            console.log("Success: " + message);
            app.showToolbar('edit-toolbar');
        }).catch(function (err) {
            console.log("Failure: " + err);
        });
    },

    apply: function apply(event) {
        app.showToolbar('main-toolbar');
        app.editDoneFunc && app.editDoneFunc();
    },
};

app.initialize();
