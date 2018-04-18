//  RadaeePDFPlugin
//  GEAR.it s.r.l., http://www.gear.it, http://www.radaeepdf.com
//  Created by Nermeen Solaiman on 06/06/16.

// modified by Nermeen Solaiman on 09/11/16
//      added getFileState prototype
//  v1.1.0

// modified by Nermeen Solaiman/Emanuele on 31/01/17
//      added config prototypes
//  v1.2.0

// modified by Nermeen Solaiman on 26/04/17
//      added getPageCount, extractTextFromPage and encryptDocAs prototypes
//  v1.3.0

// modified by Nermeen Solaiman/Emanuele on 05/07/17
//      added addToBookmarks, removeBookmark and getBookmarks
//  v1.4.0

// modified by Nermeen Solaiman/Emanuele on 30/08/17
//      added js callbacks
//  v1.5.0

// modified by Nermeen Solaiman/Emanuele on 31/01/17
//      added addAnnotAttachment, renderAnnotToFile
//  v1.6.0

const exec = require('cordova/exec');

function RadaeePDFPlugin() { };

function addFunctionToPrototype(funcName, paramsList, renameTo) {
        var paramsSet = {};
        paramsList.forEach(function (paramName) {
                paramsSet[paramName] = true;
        });

        var jsFuncName = renameTo ? renameTo : funcName;

        RadaeePDFPlugin.prototype[jsFuncName] = function (params, successCallback, errorCallback) {
                params = params || {};
                Object.keys(params).forEach(function (key) {
                        if (!paramsSet[key]) {
                                throw new Error('Invalid parameter: ' + key);
                        }
                });

                if (typeof window.Promise === 'undefined') {
                        exec(successCallback, errorCallback, 'RadaeePDFPlugin', funcName, [params]);

                } else {
                        return new Promise(function (resolve, reject) {
                                exec(resolve, reject, 'RadaeePDFPlugin', funcName, [params]);
                        }).then(function (result) {
                                successCallback && successCallback(result);
                                return result;
                        }).catch(function (err) {
                                errorCallback && errorCallback(err);
                                return Promise.reject(err);
                        });
                }
        };
}

function addCallbackToPrototype(funcName) {
        RadaeePDFPlugin.prototype[funcName] = function (successCallback, errorCallback) {
                if (!errorCallback) {
                        errorCallback = function (err) { console.log(err); };
                }
                exec(successCallback, errorCallback, 'RadaeePDFPlugin', funcName, []);
        };
}

addFunctionToPrototype('activateLicense', ['licenseType', 'company', 'email', 'key']);
addFunctionToPrototype('show', ['url', 'author', 'password', 'gotoPage', 'readOnlyMode', 'automaticSave'], 'open');
addFunctionToPrototype('openFromAssets', ['url', 'author', 'password', 'gotoPage', 'readOnlyMode', 'automaticSave']);

addFunctionToPrototype('setTopSpace', ['topSpace']);
addFunctionToPrototype('close', []);
addFunctionToPrototype('hide', []);
addFunctionToPrototype('unhide', []);
addFunctionToPrototype('showDrawMenu', []);
addFunctionToPrototype('searchStart', []);
addFunctionToPrototype('searchNext', ['searchTerm']);
addFunctionToPrototype('searchPrev', ['searchTerm']);
addFunctionToPrototype('searchEnd', []);
addFunctionToPrototype('showOutlineMenu', []);
addFunctionToPrototype('showBookmarksMenu', []);
addFunctionToPrototype('showGridView', []);
addFunctionToPrototype('undo', []);
addFunctionToPrototype('redo', []);
addFunctionToPrototype('bookmarkCurrentPage', []);
addFunctionToPrototype('print', []);
addFunctionToPrototype('share', []);
addFunctionToPrototype('save', []);
addFunctionToPrototype('showViewModeMenu', []);
addFunctionToPrototype('drawFreeformStart', []);
addFunctionToPrototype('drawFreeformEnd', []);
addFunctionToPrototype('drawFreeformCancel', []);
addFunctionToPrototype('drawFreeformSetColor', ['color']);
addFunctionToPrototype('drawFreeformSetWidth', ['width']);
addFunctionToPrototype('drawNoteStart', []);
addFunctionToPrototype('drawNoteEnd', []);
addFunctionToPrototype('modifyTextHighlightStart', []);
addFunctionToPrototype('modifyTextHighlightSetColor', ['color']);
addFunctionToPrototype('modifyTextUnderlineStart', []);
addFunctionToPrototype('modifyTextUnderlineSetColor', ['color']);
addFunctionToPrototype('modifyTextStriketrhoughStart', []);
addFunctionToPrototype('modifyTextStriketrhoughSetColor', ['color']);
addFunctionToPrototype('modifyTextEnd', []);
addFunctionToPrototype('drawLinesStart', []);
addFunctionToPrototype('drawLinesEnd', []);
addFunctionToPrototype('drawLinesCancel', []);
addFunctionToPrototype('drawLinesSetColor', ['color']);
addFunctionToPrototype('drawLinesSetWidth', ['width']);
addFunctionToPrototype('drawStampStart', ['image']);
addFunctionToPrototype('drawStampEnd', []);
addFunctionToPrototype('drawStampCancel', []);
addFunctionToPrototype('getAllAnnotations', []);
addFunctionToPrototype('deleteAnnotation', ['page', 'index']);
addFunctionToPrototype('getOutline', []);
addFunctionToPrototype('SelectedAnnotationDoAction', []);
addFunctionToPrototype('SelectedAnnotationDelete', []);
addFunctionToPrototype('SelectedAnnotationUnselect', []);
addFunctionToPrototype('gotoPage', ['page']);
addFunctionToPrototype('getThumbnail', ['page']);

addFunctionToPrototype('fileState', [], 'getFileState');
addFunctionToPrototype('getPageNumber', []);
addFunctionToPrototype('JSONFormFields', [], 'getJSONFormFields');
addFunctionToPrototype('JSONFormFieldsAtPage', ['page'], 'getJSONFormFieldsAtPage');
addFunctionToPrototype('setFormFieldWithJSON', ['json']);
addFunctionToPrototype('setThumbnailBGColor', ['color']);
addFunctionToPrototype('setReaderBGColor', ['color']);
addFunctionToPrototype('setThumbHeight', ['height']);
addFunctionToPrototype('setDebugMode', []);
addFunctionToPrototype('setFirstPageCover', ['cover']);
addFunctionToPrototype('setReaderViewMode', ['mode']);
addFunctionToPrototype('setIconsBGColor', ['color']);
addFunctionToPrototype('setTitleBGColor', ['color']);
addFunctionToPrototype('setToolbarEnabled', ['enabled']);
addFunctionToPrototype('getPageCount', []);
addFunctionToPrototype('extractTextFromPage', ['page']);
addFunctionToPrototype('encryptDocAs', ['dst', 'user_pwd', 'owner_pwd', 'permission', 'method', 'id']);
addFunctionToPrototype('addToBookmarks', ['page', 'label']);
addFunctionToPrototype('removeBookmark', ['page']);
addFunctionToPrototype('getBookmarks', []);
addFunctionToPrototype('addAnnotAttachment', ['path']);
addFunctionToPrototype('renderAnnotToFile', ['page', 'annotIndex', 'renderPath', 'width', 'height']);

// Callbacks
addCallbackToPrototype('willShowReaderCallback');
addCallbackToPrototype('didShowReaderCallback');
addCallbackToPrototype('willCloseReaderCallback');
addCallbackToPrototype('didCloseReaderCallback');
addCallbackToPrototype('didChangePageCallback');
addCallbackToPrototype('didSearchTermCallback');
addCallbackToPrototype('didTapOnPageCallback');
addCallbackToPrototype('didDoubleTapOnPageCallback');
addCallbackToPrototype('didLongPressOnPageCallback');
addCallbackToPrototype('didTapOnAnnotationOfTypeCallback');
addCallbackToPrototype('didUnselectAnnotationCallback');

module.exports = new RadaeePDFPlugin();
