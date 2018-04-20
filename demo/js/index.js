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
            // app.showToolbar(null);
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
            if (info.type == 1) {
                RadaeePDFPlugin.SelectedAnnotationDoAction();
            } else {
                app.showEditToolbar('img/edit-annotation.png',
                    RadaeePDFPlugin.SelectedAnnotationDelete, null, null, RadaeePDFPlugin.SelectedAnnotationDoAction);
            }
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

    showEditToolbar: function showEditToolbar(img, editCancelFunc,
        widthChangeFunc, colorChangeFunc, annotationTextFunc) {
        app.showToolbar('edit-toolbar');

        if (img) {
            app.show('edit-img');
            document.getElementById('edit-img').src = img;
        } else {
            app.hide('edit-img');
        }

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
            app.showToolbar(null);
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
        RadaeePDFPlugin.share({}).then(function (message) {
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
        app.showEditToolbar(img, RadaeePDFPlugin.drawFreeformCancel,
            RadaeePDFPlugin.drawFreeformSetWidth, RadaeePDFPlugin.drawFreeformSetColor);
    },

    thickMarker: function thickMarker(event) {
    },

    annotateBox: function annotateBox(event) {
        RadaeePDFPlugin.drawNoteStart();
        var img = event.target && event.target.src;
        app.showEditToolbar(img, null, null, null);
    },

    textHighlighter: function textHighlighter(event) {
        RadaeePDFPlugin.modifyTextHighlightStart();
        var img = event.target && event.target.src;
        app.showEditToolbar(img, null, null, RadaeePDFPlugin.modifyTextHighlightSetColor);
    },

    underline: function underline(event) {
        RadaeePDFPlugin.modifyTextUnderlineStart();
        var img = event.target && event.target.src;
        app.showEditToolbar(img, null, null, RadaeePDFPlugin.modifyTextUnderlineSetColor);
    },

    strikeout: function strikeout(event) {
        RadaeePDFPlugin.modifyTextStriketrhoughStart();
        var img = event.target && event.target.src;
        app.showEditToolbar(img, null, null, RadaeePDFPlugin.modifyTextStriketrhoughSetColor);
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
        app.showEditToolbar(img, RadaeePDFPlugin.drawLinesCancel,
            RadaeePDFPlugin.drawLinesSetWidth, RadaeePDFPlugin.drawLinesSetColor);
    },

    stamp: function stamp(event) {
        RadaeePDFPlugin.drawStampStart();
        var img = event.target && event.target.src;
        app.showEditToolbar(img, RadaeePDFPlugin.drawStampCancel, null, null);
    },

    signature: function signature(event) {
        RadaeePDFPlugin.drawStampStart({
            // https://github.com/szimek/signature_pad
            image: "iVBORw0KGgoAAAANSUhEUgAAAPoAAACWCAYAAAD32pUcAAAAAXNSR0IArs4c6QAAAAlwSFlzAAAL" +
                "EwAACxMBAJqcGAAAAVlpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADx4OnhtcG1ldGEgeG1sbnM6" +
                "eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDUuNC4wIj4KICAgPHJkZjpSREYg" +
                "eG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4K" +
                "ICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6dGlm" +
                "Zj0iaHR0cDovL25zLmFkb2JlLmNvbS90aWZmLzEuMC8iPgogICAgICAgICA8dGlmZjpPcmllbnRh" +
                "dGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9y" +
                "ZGY6UkRGPgo8L3g6eG1wbWV0YT4KTMInWQAAHdpJREFUeAHtnQmYZUV1x5MY2Rl2UQRmGIbFBQQF" +
                "QZYww0hUREAdjYTAsIoCDorAJyag7DsKsu8MyOaCUREUlAFRcVzyhS2sCjghww5Cgqzm/+t7/kzN" +
                "m9fdr5f3+t3uc77vf6vqVN2qU/9b51bduvd1v+FvUkaCgb9Vo383Eg1nm8lAMtAZBhodHKdPSQba" +
                "ysAb2lp7Vt7IAHy/JqwkfFt4TrhbQP9XISUZSAZqzoBn8nHqx/eFZ4Qzok9vjDCDZKAtDPx9W2rN" +
                "Spsx4Bn7QmVeJTwsPB8FnRfJDJKBZKCODPiGerCMPzU6cJfC7SOej1BBRAbJQF0ZsJNPUQeujU6s" +
                "p3CusFykc0MuiMggGagjA34uX0bG3ySsGZ04UeENEXeZSGaQDCQDdWKgnKV5Jp8WxuPY7LTvGWnP" +
                "+JHMIBlIBurEgB34FBl9UmH41oo/JrD7jpQ3hEqTx2QgGagFA35dtpOsPTcs9oYbS/azG3SRzCAZ" +
                "SAbqwoBn8s1k8OUNRq+jNB/MrB/6fD5vICiTyUAdGPCsvYqMvUhYKoxeKEK+hrs+4unkQUQGyUCd" +
                "GPCzNjP6OYJ32O3k75COD2O2EBDfFKpUHpOBZKAWDHiGPlzW2plxeuuvU3x29MQ3hUhmkAwkA3Vg" +
                "wM/lO8vYPcJgdJ61JyvObD5VQKyvUnlMBpKBrmfATssG27+FtczY5ax9v9L+Ks4zfBTNIBlIBrqd" +
                "ATvzEjL0BGGxMBi9Z/n9FWc25xkdSUeveMhjMlAbBjybHyCL3xtWo7Mzj1ccJz898uz8kcwgGUgG" +
                "up0BO/lWMvTTYax1nulvkZ6foi4d+b4BRDKDZCAZ6GYG7Mj8WOUYwWls9qy9r+LM5nujlFhfpfKY" +
                "DCQDXc+AZ+4vylJ+coowW1s/QXGc/EYBKW8ElSaPyUAy0NUM2Jk3lpX7hKXocGY79CzFcfQJApJL" +
                "9oqHPCYDtWIAh+ZV2pJhNWkvzQ9SHCefHnnWRzKDZCAZ6HYGPJv/swzdOoxFZ2feQHGc/MrIy5k8" +
                "iMggGagLA16WryiDvxxGo7Mz8y79kYBneudF8QySgWSg2xnwbP45GbpRGIvOzswv05jNmdURz/JV" +
                "Ko/JQDLQ9Qx4Np8oS/cLa3FwO/MMxXFyQsT6KpXHZCAZqAUDnrXZZV8tLPZfkWH3PZ/La3EZ08hk" +
                "oHcG7OT8aMWv0/wb8+Wle1bgRyvWubxUKclAMlAXBrxsP0AGv7XB6FlKM5uvGXo/x0cyg2QgGagD" +
                "A56d2XzbIwz2zP11pXHyj4Q+n8uDiAySgbox4Nn8UBn+lsL46Yrj5IeELp28ICejyUCdGPBsPkVG" +
                "f7Yw/F2K4+TfDR03A98QQpVBMpAM1IUBO++RMnjlMJqfmz4m8A8S/TzuG0IUySAZ6D4GcsnZ/Jrg" +
                "vPz99anC48IcAbla4D+svFt4VcDZCVOSgWSghgx4Nj9ato8P+09TyJLdX8XlTTKIySAZqCMDXopP" +
                "lvH8Qg3ZU8DJdyIh8ccyVSqPyUAyUDsG7Ogny/I3Ce8UcPKjBCRn8oqHPCYDtWXATj5ZPeCvx/DO" +
                "/GWBH6wgucNe8ZDHZKDWDNjReTZfQ7hVuFPwM7vzpUpJBurDQC5D510rnJiddv5sMzvtXxDeIawq" +
                "sHTPHXaRkJIM1J0Bz9b8DPUK4S/C26NTeUMMIjJIBurMgJfm49WJXwo8l28THcod9iAig2Sg7gzY" +
                "mQ9WR1im7xYdsr7u/Uv7k4Exz4CX7MuJiZeEo4IRf+I65glKApKB0cCAHfpH6swPo0P5Gm00XNns" +
                "QzIQDHhpzn88faBgxbN8ocpoMpAM1JEB76S/T8bzXO7NN+vr2Ke0ORlIBgoGvFzn56f/JVxX5GU0" +
                "GRh1DIzF2Yvnb/+09FjFcXR/4pofxYy6IZ4dggHPbGOJDfrMUp3PXO8VXhEuE54XUrqTgdwcHeJ1" +
                "GWszOv3FsT8tPC3wl2IWFuYKzlM0pYsYKFdZODw36ZRkoFcGfFPbXCVmRqlTFE6IOIOo3UIb2AE6" +
                "0V67+9PO+nHwkqNF29lY1j06GPDrMn5f/j2B9KbCVwSk3Y8wDNhmbZQDuceQPPRcm5KrHcQJvyB8" +
                "VDgu+EnegogM5jFQDopLpeZ1GnKisE5PbN4/SozksAZeSVApX9/tLPDosIiAlPZVmrF7LLnaQDT8" +
                "SmCpzjcOhGyiLiUgyVvFQx6DAc8ObL5NDx3OflJDfiSHLWAguu2FFD9SeEFgwIITBMRlqtTYPLLC" +
                "suPiyOcLcPQ7YT1hz0g/qJA9FcTlq1QexzQDniGYRXF0C0tAlu6Il/VVaniOpfNuqyrZ7GM2+oow" +
                "SbhduE/wYHUo1ZgTXyM6vovAz4P5ewCfEpAVhCcFHP+fBKTkt9Lkccwy4MHAEnBmwQJ/TOKsSLfD" +
                "wcqBe67aYYBeLiwfbRKwTzBH8E2mHXbQTjcLffc1mqg4szdccRNmBWT5iSLozw6FOXN+hmOYAQ8G" +
                "/uECTvaWggv+siuzLOKBVqWGdqRNt7uG4vcI/LOH7QSLv62/SYqHBJcfa45e3gx3FQ8vCrcKawmI" +
                "eeGv/ODk3ARyT0MkpMzPgB2HWWBKkcWuu2fzQj2kKG3ZgalohsC7+gsFP09yQylvKncrPVuw2F6n" +
                "R2sIB+4rN99rhYeFjwkWc8azOU7OTWCdyCw5DFUGY5UBzxZfEgGfCxI8eJghdgjdcAyaso5VVO9N" +
                "As/jH4w2CGyPBzgz08vCZWRKPHtVqdF5pI8lV9wM/yjw5sM3ScqYK5buXsp/SnHEeVUqj2OaAQ+G" +
                "D4mFM4IJO9I4pctZdqhEuS3qOVB4VrhIWFRAyLdzk7Yd71KcmYpHCMQDvUqNriP9L3li5v698COB" +
                "vRKLyzg8SRlw9I0oYL3LZziGGfCMsbo4+JaweHBhR9pF6f1C57KRHFBQnssfj7xD+IOwRVFLs4Fp" +
                "3e4qxyDeI8pbX5w+KqJlv3BqVjC3CJ6h6SRlfDN0+a2kg59fR76C18sQTxnDDHiwQMElwrrBhQcP" +
                "S8ELBDbnkLJ8pWnt6PoofYjA7DSDREg5cK1z6HOPlIKB7L8w65ne5eoeljdCXo0dLVwtTCs6Rp/L" +
                "fjvOm4lHBR5tJglIWV+lyeOYZcCD4RgxMD1YwLGs/6TiXirb4aJYS0E5MFl6f184QViyONttFar5" +
                "or65/FBalvncfBDrq1R9j/TDHBDfR7hc8LtvRXv66jKkLXZ0fi7MTXDHyPBqzOUyHMMM2HFZEh4b" +
                "PHgw2YnOlN4zhHWtUua6KL+3gKNuQCKE9vur0/kM3CeF6+Nc6yNZ28DXgA5MFWYKrHR8M1P09ZsA" +
                "8VJ87melxMkvikw7fyQzGMsM2AnXEAmXFETgQM5jB/yIyPOgKor2GfWMwk75OQKzuAdgKw7uyn3O" +
                "alIwmI+PjIHa4/q6JaRfvlmtpDibaCcLqwoWXweny9B575QSXv4oLBYFzFkk2xrQFtei7tejrSSN" +
                "VOUeYAyWS4W1wxAPHg8UZvN1I8+6SPYZ+KK/W6V+LPi1HCe5DeKtiOuapsIM6I/HSQOtp5W2OlXG" +
                "faK9XYULhakkQsp868qwvH6/Uwa8bBgF+ju3rGewcdqnHdsx2HryvDYzYCc5Tu3YcTxA7NAbKc+v" +
                "aFy+P7O48D6f10HXCV6qD3Zg2C5mPAb0WwWkjoOs5HEd9eFs4YtFX8g3f4r2KuaExy044RsHxPoq" +
                "NfxHO3hZ8+pK7C/wm4iULmLAg4ELc2jYVQ5Ax09X3iaR38rg83mcwrvxS4XFSUi8jK9SgzveotPu" +
                "K06tk6M3OsgB6sdMwaslulXyR7o38fWbogI4OZubCG20i5NG+xdVW3sJswRsMLyqaGW86LSUdjHg" +
                "wcTrKQaaxQPEF4gLdnFkWueyzUIPPvJOFXgtZCnzrGs1tF08e74k8KyPuB9VqruPpa2bytTvCGye" +
                "WQbCj6/FOJ08V3hUWCYqcl4khy0o7eN67CL8ScC5nxRYtb0Q6W0VImWfK00eO8aAnYYLN1OYGC2X" +
                "A8QX6DzlbR351kVygcADgcF3qbBLUaKsu1C3HPX579MZDKyd4ky32XJFI1AQvm0nK5qjhCuFtQSE" +
                "fPevR9HCwdeCV2/wsVmc43ZaqKLlIthW2rer0n8SaPdWwTcr3tige16YJCDleZUmjx1jwOQfoxa3" +
                "j1bLAeJ8ZvMfRr5vDpFcIPCSnBUCS8jJUYIB2d+5UbTPwPax1GUwjY/StrXPk0cw0w6JCZMFuJkh" +
                "WNwvp1sJfY4di8cjxPoqNfQj183XldqmCfcI8H+NsLlQyrlKkPeDUA7HdS/rz/gAGPBg2FHnfDnO" +
                "s87VeHDOlGJ6KK1zmTL0+VOl/J6wZmRaX5YdbNwO/e+qoA7P5wxy9x9n4YcnLNXXEBDy3aceRYsH" +
                "n7OSyuNU18Z51DecjlVeb9piWU57vxLYnLVgD+Bd/50CZfyJtPsvVctiXjgX3ko7Wq5krBc0aW8T" +
                "EWcWZJQDxANpfeVfX5RpFvVFIY8bwmXCkiQkg7nI1ZkLHm0ftj0unBRFhrONBVsdvMY8U8OWAjx+" +
                "nkTIUOw2F7NU12PCElGnr1skBx1QT2k/u/gvCXcJ2wgWygC3O1Hxl4VXBd/MnCdVv0K/ynb7PSEL" +
                "NGfAA4S7JK9yVolijRfDZF+i/L2jjHWR7AnK83gtVN44hjKQyzYcd1u842fG+GBkNLPL54xECMfu" +
                "OyE3JL5P58aKkO++9CgGeHDdzJjwwGfEiPVVanDH0nZqmCzcLTwpcBO3UK7k3XGW9dj0n4L7SNlW" +
                "pLR/EZ3wHmEH4TCBz65TBsCAL8hROufDcV5JMCpfoPUUny1wU0AaL5jrIu94wd+/ky7zSA+H2M7d" +
                "VdkTwmJRaaNdw9HWYOso+72lKvmJwA3Q4j44PdDQ9a+mE3Go3aKCodYLh2UdE5Xm+ftFgS8YFxYQ" +
                "ytmGHkUcPEb+VWnsujj0HkuRbBpQxnXSDjewOQL1lFhUaQQbUvpgwBeSuyQXBLGuSlVH676p5EGR" +
                "YZ3L+cIQXijsFRlchFYubhQfUOA2r9BZzJCIdVVq5I702xwRcuNjM2pdARkOXqgDILcJp/fEhs6B" +
                "7aa6pYVThBcEHB2Ht5TlrHPoa36+FDjnBZFhvcuVYckZ+k8Idwh27jmKXyWcIzBmU1pgwA7B8vGM" +
                "orwHjlW+MAzQewR/4FKW8wVfSvlciI8KCG2U5XqUw3RwvcwcDwvsNCPuV5UamWNpw2SZwCx+SGGK" +
                "+SpUg4q6nmN09uyiBnNTqFqKYrevNyew8nhKoO5NBAvt9teGbTtWZXFUnBPhetGGQZuULdtdVumz" +
                "BDv4lYpvLHgVoWhKKwz4IkE6s8DKcVJJtuvxBfuWFIeF0jqS1IGsJrCz3s73trRjsTNtJQWDcZnI" +
                "cN9crpMhbZsb7DtOYMPNz8zk225FhyRuZzvV8rDg/g+mfq57ed7HlL5feEBgVrVQptkYcX4Zelwc" +
                "KCUO+/Uys5f4CtLvK8wVOIeJ5eNCKeawtLfMz3jBgEliGb516D1wimKvX1QG6n3CuMi0M/kc8i8X" +
                "1o586yPZlsBtsNl3Q7TQ6iBsh0HmlLo3FW4UDicR4oHv9FBCtzVelTwibB6VmZNW6y5vTJzDrPkr" +
                "4THhC4Kl8UZgfV+hx8h3VAinZVXASm8DYaKwlsCeD+MP5/6u8L8CZQErgSUEhP4C14kupR8GPEi2" +
                "UTkIRqyrUvOO1l8tFcQjHkwOp0h3hbA8mRLrq1R7jr7gLOXmCDtGM7a3Pa02rxVb3Gfixws/Fd4r" +
                "WIbTLt/MqPNewRt7A7mRlDZj46oCDvln4WRhMcHivjndSlhen8d0gp2X8DXhJeHVBj15ODpLfB4n" +
                "LYNp3+eO2dCDhDsqO6cWXxinCV12fcUfEt6EUoLe5LPE+6awpIBYX6Xad7TjbK8mnhWWiqaa9aN9" +
                "Vsx/g+SR5SbhiKJB+BhOm8q6rlPd3GAR81Gl+j6W14iPWXi8eFrA0ccLlqHa7vHzCVXII8ATAht6" +
                "r0T4nEJuAr8QThf+RfAYUzRncEgYjJSD5CRV4IvqC9JYpwcPSyru8gizhsvvofiFgut1eanaLm7r" +
                "J2qJjRrEuirV3iN9tsPAh2fxDYtm22GPuT9F7eA8FuudbhZij68V+XsJLPt/I2wiWIbq4K6nDGmb" +
                "m/HawjuFtwps6oJGoWwr/Wk8L9PBgAfeF5T+x9B5sDaSZKLfowwGw4pRwPr9lGawWVy30+0MbcMk" +
                "NcLsMDUa65QNZTsbqe0bBRzd0g5HoW63u5XifxUIkd6uYZVbOY05Q/dRgZsEs/jugoX6y3LWDzVs" +
                "pU7abhdvQ7W/Vud7MHxAVuPoiAdOlZr/6Dx20b8WWa7jMKWPKoq3ciGL4kOO2rYzVNNTgtPlbDXk" +
                "RppUUM7iZB8pzBLYwLLYFqeHM3T/ZqvSG6LivtrjupT5k5X+rcBN4nJhnIA0lqu0w3vEdkBbwGmH" +
                "UqUMlQGIRVguHd0Tqw6Q3Ew8ONhMelR4c1GIDbkjirTrLlRtjdpmbMTJebZDbHOVGv6jb3LUjGP/" +
                "TIAL20O+44oOu7h9ZmMclZ1rpFm/scPlKcNy+WqB8/5b8GpO0fnKkU6pKQPl4DtSfVg5+tGXg3rw" +
                "XKuypxX9PlvxQyNNvWXdRbG2Rm3bFLXCwPUzsfXD3Tg8uW6ch9XNL4Tymdb5UrdFSp7vVwtcF6RZ" +
                "u6WDs7F1qgBPgJv8QgLCuX2NgZ5CeagPA77wn5fJ24TZ1jXrhQcP74F5hlsmCl2hcL+Ij5ST07zt" +
                "O1PxOWEPQekMhXpI0ZKnbVXT7cLJgh2E/Ha0q2rnkzdGaoZCHLbZbF46LnZxrZ6N8j9XuK5gKftl" +
                "XYY1ZsAXlKXaAdEPO0pv3XL+zSrA7IVcI3ymJ1Y5WicGdzQ3X1C2yyPFWYVN8xUcYgIO3Nayin9X" +
                "eFDYUrCYJ6fbFbqdd6gBnJw9E8R6bjqOo/+IcIdA2WeE3QRLp25Mbi/DDjDAAED4EOIEwQPXIXmN" +
                "4gHzD8rgWW6SwOurzwqIbxxVqvNH28feAQN52zDB+qFaBDdlH/dVmlXNTGFRAemks5TXiscF+rwO" +
                "Rkiwo+w3b0d+IFAGsFG5ooBQT1m2R5mH+jNQDpAj1Z3Vo0t2/t566PwfqcB5ArMHgx0pHaDSdP5o" +
                "G9gEYzAvFyaU/R2sVa6b898l3CYwI7L5ZSnLWNfO0O0dokbo7z7R2CJFoxMUZ0PSDj5L8Y0Ei+tw" +
                "OsNRxIDv3jzTfTD61d8F9zkMkheFe4WdWjw3irU1sDMT8kOHPwi+MTlvMAbQb9ezhOLMhDjNlcI4" +
                "AYG7obTRU8kAD74eU3We7SmrYKX2DeHlyH9Y4c6CpeyXdRmOIgbs0DyXHxj98qDpq5s+j1mcgeVl" +
                "sfV9nduJPDsazod9fhswWPuorzx3R6WZwV8QpgmWsox17Q7d1xXU0J+ER4SVhOWFrQX2Jp4X4IGb" +
                "8hHCkgLCua1c757CeagnA56ZJsj88kstD5zeeuVdXZ7NGTxerlrf23md1HvwbhY2To/GB+qIjQ7O" +
                "M++sqPNShZ7Fac98KtpRcZ9mqFWux1yBPZNXIo3uVYHVx3jB4vOcznAUMlA68zHqH0s7pL/B6sHB" +
                "bPGkcA4nSbrJybHHdh6gOAN9TZSS/vpXlaqOvlmQWkpgk5K6Hhc+LFjcltOdDn0t36SGrxCeEJi5" +
                "nxNuF44V3i5YsNfnWJfhKGXAg/gg9W+r6GN/A9b5fPl2l/CasHKcOxAHilPaGngg/1itzBGcdthX" +
                "442z864qzG46Tv41wTvqjeWUNWJS9msxWcHSHPiaYVg32Ys9KW1mwBefWYkZD7HjV6kFjz6Hmf9m" +
                "gdmCQY84r0qN/NGDnoH+knBxmNRfH8kvy0xR+vcCDn6rsIFg6bY+Yxf9dt9tJyF96rYbcWlfxtvA" +
                "gAfyJNV9clF/swHibA/qVaS4RThUeEh4m4B02yByH9lgxEl3xkiJ+1GlqiP9bnSEd0v3fYFz2XCb" +
                "Lliooy+uXG4kQ+wrMZK2ZNsjwIAHKOGpArMz0pej2jneonJ3C1sIZwvXCoidqkp1x9H9+YHMwVn5" +
                "cQ6C3g6A3e4bech7hKsEzgFsUC4tIJzXjX3tMS4PyUDJgAcqr9GY7ZDGwV5pq6PzcPL7he0FZnWc" +
                "gG/bEddZpUb+6JsZzo2d1/Rj0kLKhwvP4JxzvrC6YDEPTmeYDHQtAx6s02Th3mFlX07q8my83Sfs" +
                "FefcEOlIdl3gPnnZzg2K13+LC7wZAOxObykwYz8i4NzgAmFtwQIHvnFYl2Ey0LUMePC/XRaeWFjZ" +
                "2yC2kzOT4+SfiXM2VohDfDHSLhfJrgjcJ5bcdwp2Yl45kX5QeE2wfq7ihwl+jFF0gWd2dCnJQFcz" +
                "4IHPEvV0gRka8XNslZp3tPMy690j7Dkv6/U/RsCyGOmtjip35I7uM85+qHC78BcB5/4/4TfCaQKv" +
                "FeHFwg2xW/tkGzNMBpoy4IH7VeVOiRJ25sYTPPMvoozbhM8VBXi1hKNcHTrXWxTpqqidHaOwdQVh" +
                "LYFXbo0CH93en0abM50MvM6AHXoHafYNrXWvF4qInXxhpX8rMBMipJGLBBx9OwHprZ4qtzuOOLv7" +
                "1WgRelDeEBrLZDoZ6HoGPMDXlaUn9WOty+K8s4XDozwbV8iaAs+1c4RxAlInB8FWwKztuKIpyUC9" +
                "GfAyFKc8Q1guumN92btS9zNl+CManN+zNrvTzOb+Es43BqlSkoFkYKQY8GzLDjs75Ugz5yyd/BqV" +
                "4f0xgt55bMo9KuDo7xOQZnVVOXlMBpKBjjDgWXg/tdbXc7kdGaOuF75DJIQbhevZW3GcnJ3qlGQg" +
                "GegCBuycm8uW48Ke0qFtYqm7SsobnaGwzEP9awFH7+Z359iZkgyMCQbsoMurt/xGnC/BEOurVJX2" +
                "0p6lOh+ROO0lucP3Kw8nf16YJCCN9VXaPCYDyUBHGeDHKutFi3ZYG4BD26nPVPwpwRt1ZVnHuWHg" +
                "6HwHjvjcKpXHZCAZ6CgDXrIfoFZ3j5atsyE4qWfjbyiOA/MBCVKWtTPzgcn/CJTz13FlOalTkoFk" +
                "oFMM2PmmqkG/GrND24bSyY+WEufdLDL9rtxlXd9OUe5JhStFpm8CLpthMpAMdIABOzTP5d8W+LYb" +
                "sb5KzXsdtr8UOPknIqPRyVH73CsVp+zlKCXWV6k8JgPJQMcY8Ax7qVrcOlr1jGwjnPZrss/3Ug61" +
                "nXl1xZ8TcPTdBMT1VKk8JgPJQEcYsOPhuBdEi9bZAKenSYHTslGHsNnmm0SPIg4u/yWlKY+zrxZ5" +
                "vglEMoNkIBloNwN2uolqiK/Wmv1s1MvyDygfp2Vpb2nm5KXuFhXkHF69cVNAyvxKk8dkIBloKwN2" +
                "Pr5mOz5a8mxM0k7OJ6s47C8FO6pvElLNJ87n+/inBc7j9+j8ZBVxfpXKYzKQDLSVATs5u+Z3C42O" +
                "aIfnF2f8qeM/Ct6k87lSLSB2ZBydfzOEo/OhDGnE+VUqj8lAMtBWBjwj36xW+J4dsXM7nCDdMwLP" +
                "2OMFxHlVqvnRzuz37Hwwg1hfpfKYDCQDbWXAM/J2aoU/eug0jTq+bOQxI29IhsRL+SrV+9E3ET6f" +
                "zY243nnKnGSgIwzcpVb8yzQc3E6OQ88WcPL3C0irTk5Zz9ws9X8ueMlvPWVSkoFkoI0MeOnN+/CH" +
                "BM++dnKa/qmAk+9IQuJzqlTrRxx7YSEdvHXOsmQyMGQG7HBLqiaW1AdFjTijhS/YcPIZoShvAC6T" +
                "YTKQDHQxA56ZD5aNOPpSDbbayQ8PPbO9bw4NRVtODvX8lhvKgslAMjDPYXmNxk76YQ2kXKE0Mzk7" +
                "5QgOmk7aQ0UekoH6MODZ/ECZzHvxN4fpCyn0D0+uCh2Bn90LVUaTgWSgmxnwzEw4VzgvjF1OoTfe" +
                "CP08nk4eBGWQDNSJATvwXjKa5TnftE8Q+Aad9H8IbNAhLlul8pgMJAO1YMCzObP0g8IDwieFpwWc" +
                "/DZhRQFJJ694yGMyUDsG7Oh8a/5n4QkBBwc3CysISDp5xUMek4FaMmBHZ7f9ccFOfpbibMQh3qir" +
                "UnlMBpKBWjJgZ/+QrL9I2KboRc7kBRkZTQbqzoCd3f3gmb1R57wMk4FkoCYMNHNiZm/0LN9frUk/" +
                "0sxkIBlIBpKBZCAZSAaSgWQgGUgGkoFkIBlIBpKBZCAZSAaSgWQgGUgGkoFkIBlIBpKBZCAZSAaS" +
                "gWQgGUgGkoFkIBlIBpKBZCAZSAaSgWQgGUgGkoEaMfD/TkViyf+BZ10AAAAASUVORK5CYII=",
        });
        var img = event.target && event.target.src;
        app.showEditToolbar(img, RadaeePDFPlugin.drawStampCancel, null, null);
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
        RadaeePDFPlugin.allModesDone();
    },
};

app.initialize();
