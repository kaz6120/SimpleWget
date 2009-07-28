/* SimpleWget */

#import <Cocoa/Cocoa.h>

@interface SimpleWget : NSObject
{
    //================================
    //ENVIROMENT SETTING PARTS
    //================================
    IBOutlet id downloadButton;
    IBOutlet id stopButton;
    IBOutlet id downloadDir;
    IBOutlet id downloadList;
    IBOutlet id url;
    IBOutlet id level;
    IBOutlet id window;
    IBOutlet id prefsWindow;
    IBOutlet id progressbar;
    IBOutlet id filetype;
    IBOutlet id finishSound;
    IBOutlet id statusField;

    //================================
    //WGET OPTION PARTS
    //================================
    IBOutlet id _recursive;
    IBOutlet id _page;
    IBOutlet id _only;

    IBOutlet id _continue;
    IBOutlet id _no_directory;
    IBOutlet id _spanhosts;
    
    IBOutlet id _no_clobber;
    IBOutlet id _cache;
    IBOutlet id _wgetlog;
    IBOutlet id _no_host_dir;

    IBOutlet id _try;
    IBOutlet id _timeout;
    IBOutlet id _wait_sec;

    //================================
    //VARIABLES
    //================================
    NSOpenPanel *setdir_panel;
    NSOpenPanel *readlist_panel;
    
    NSTask   *wget;
    NSSound  *sound;
    NSString *soundname;
    NSString *dirname;
    NSString *listname;
    NSString *wait;
    NSString *cache;

    NSUserDefaults *prefs;
    NSMutableDictionary *defs;
    NSMutableString *wget_path;
    NSMutableArray *args;
    
    //for contact buttons in About menu
    NSDictionary *goweb_error;
    NSDictionary *mailto_error;
    NSAppleScript *visit_web;
    NSAppleScript *contact;
}
//================================
//SOME KIND OF ACTIONS
//================================
- (IBAction)prefsChanged:(id)sender;
- (IBAction)revert:(id)sender;
- (IBAction)download:(id)sender;
- (IBAction)stopWget:(id)sender;
- (IBAction)testSound:(id)sender;//check the sound
- (IBAction)chooseDir:(id)sender;
- (IBAction)readList:(id)sender;//read-file action
- (IBAction)goweb:(id)sender;
- (IBAction)mailto:(id)sender;

//sliding out prefs panel
- (IBAction)raisePrefsWindow:(id)sender;
- (IBAction)endPrefsWindow:(id)sender;
- (void)sheetDidEnd:(NSWindow *)sheet
         returnCode:(int)returnCode
        contextInfo:(void *)contextInfo;

//siding out alert panel when closing main window
- (void)didEndShouldCloseSheet:(NSWindow *)sheet
                    returnCode:(int)returnCode
                   contextInfo:(void *)contextInfo;


@end

//==================================================================
// INFORMATION
//==================================================================
//
//===========================================================
// Coded by      : Kazufumi Tomori
// License       : GPL
// Last Modified : 2002-12-14
// Copyright (c) 2002-2009 JAM LOG. All Rights Reserved.
//===========================================================