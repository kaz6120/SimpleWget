#import "SimpleWget.h"

@implementation SimpleWget

//********** INDEX *************
//(1)PREFERENCES
//(2)PREPARATIONS FOR DOWNLOAD
//(3)DOWNLOAD
//(4)JUST IN CASE
//(5)AFTER DOWNLOADING
//(6)QUITTING & CLOSING
//(7)CONTACT BUTTONS
//******************************
//==================================================================
// (1)PREFERENCES
//==================================================================
//INITIALIZE
- (id)init {

    self = [super init];
    
    //Notify when finished downloading or app is force quitted.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishedDownload:)
                                                 name:NSTaskDidTerminateNotification
                                               object:nil];
    //Prepare the dictionary to save prefs
    defs = [NSMutableDictionary dictionary];
    
    //define the default values.
    [defs setObject:@"~/Desktop" forKey:@"DOWNLOAD_DIR"];
    [defs setObject:@"Glass"     forKey:@"FINISH_SOUND"];
    
    [defs setObject:@"NO"  forKey:@"CONTINUE"];
    [defs setObject:@"NO"  forKey:@"NO_DIR"];
    [defs setObject:@"NO"  forKey:@"SPAN_HOSTS"];

    [defs setObject:@"20"  forKey:@"TRY"];
    [defs setObject:@"100" forKey:@"TIMEOUT"];
    [defs setObject:@"0"   forKey:@"WAIT_SECONDS"];
    [defs setObject:@"YES" forKey:@"NO_CLOBBER"];
    [defs setObject:@"YES" forKey:@"CACHE"];
    [defs setObject:@"NO"  forKey:@"WGET_LOG"];
    [defs setObject:@"NO"  forKey:@"NO_HOST_DIR"];

    prefs = [[NSUserDefaults standardUserDefaults] retain];
    [prefs registerDefaults:defs];
    
    wget = nil;//Initialize the wget pointer
    return self;

}
//DEALLOCATION
- (void)dealloc {
    [prefs release];
    [super dealloc];

}

//WAKE UP THE APP!
- (void)awakeFromNib {
    
    //Set the download destination folder
    [downloadDir setStringValue:[prefs stringForKey:@"DOWNLOAD_DIR"]];
    NSLog(@"--downloadDir has been set");

    //Set the sound
    soundname = [prefs stringForKey:@"FINISH_SOUND"];
    if (soundname == nil) {
        soundname = finishSound;

    }
    [finishSound selectItemWithTitle:soundname];
    NSLog(@"--finishSound has been set");

    //Set the options
    [_continue     setState:[prefs boolForKey:@"CONTINUE"]];
    [_no_directory setState:[prefs boolForKey:@"NO_DIR"]];
    [_spanhosts    setState:[prefs boolForKey:@"SPAN_HOSTS"]];

    [_try          setStringValue:[prefs stringForKey:@"TRY"]];
    [_timeout      setStringValue:[prefs stringForKey:@"TIMEOUT"]];
    [_wait_sec     setStringValue:[prefs stringForKey:@"WAIT_SECONDS"]];
    [_no_clobber   setState:[prefs boolForKey:@"NO_CLOBBER"]];
    [_cache        setState:[prefs boolForKey:@"CACHE"]];
    [_wgetlog      setState:[prefs boolForKey:@"WGET_LOG"]];
    [_no_host_dir  setState:[prefs boolForKey:@"NO_HOST_DIR"]];

    //Remember the window place
    [window setFrameAutosaveName:@"WINDOW"];
    [statusField setStringValue:NSLocalizedString(@"Status:Idle",nil)];

}

//IF THE PREFS ARE CHANGED, SAVE IT.
- (IBAction)prefsChanged:(id)sender {

    if (sender == downloadDir) {
        [prefs setObject:[downloadDir stringValue] forKey:@"DOWNLOAD_DIR"];

    } else if (sender == _continue) {
        [prefs setObject:[_continue stringValue] forKey:@"CONTINUE"];

    } else if (sender == _no_directory) {
        [prefs setObject:[_no_directory stringValue] forKey:@"NO_DIR"];

    } else if (sender == _spanhosts) {
        [prefs setObject:[_spanhosts stringValue] forKey:@"SPAN_HOSTS"];

    } else if (sender == _try) {
        [prefs setObject:[_try stringValue] forKey:@"TRY"];

    } else if (sender == _timeout) {
        [prefs setObject:[_timeout stringValue] forKey:@"TIMEOUT"];

    } else if (sender == _wait_sec) {
        [prefs setObject:[_wait_sec stringValue] forKey:@"WAIT_SECONDS"];

    } else if (sender == _no_clobber) {
        [prefs setObject:[_no_clobber stringValue] forKey:@"NO_CLOBBER"];

    } else if (sender == _cache) {
        [prefs setObject:[_cache stringValue] forKey:@"CACHE"];

    } else if (sender == _wgetlog) {
        [prefs setObject:[_wgetlog stringValue] forKey:@"WGET_LOG"];

    } else if (sender == _no_host_dir) {
        [prefs setObject:[_no_host_dir stringValue] forKey:@"NO_HOST_DIR"];

    }

}


//SLIDE OUT THE PREFS WINDOW
- (IBAction)raisePrefsWindow : (id)sender {

    [NSApp beginSheet:prefsWindow
       modalForWindow:window
        modalDelegate:self
       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
          contextInfo:nil];  

}
- (void)sheetDidEnd:(NSWindow *)sheet
         returnCode:(int)returnCode
        contextInfo:(void *)contextInfo {

}
//SOUND CHECK
- (IBAction)testSound:(id)sender {

    //If the sound is checked, ring the bell!
    soundname = [finishSound titleOfSelectedItem];
    sound = [NSSound soundNamed:soundname ];
    [sound play];
    [sound release];
    NSLog(@"--Sound Tested");

    //Save the soundname to prefs.
    [prefs setObject:[finishSound titleOfSelectedItem] forKey : @"FINISH_SOUND"];
    if (soundname != nil) {
        [finishSound setStringValue:soundname];

    }
    [prefs synchronize];
    NSLog(@"--finishSound Synchronized");
    
}

//Bring the defaults back!
- (IBAction)revert:(id)sender {

    //Remove all user settings from prefs
    prefs = [[NSUserDefaults standardUserDefaults] retain];
    
    [prefs removeObjectForKey:@"CONTINUE"];
    [prefs removeObjectForKey:@"NO_DIR"];
    [prefs removeObjectForKey:@"SPAN_HOSTS"];
    [prefs removeObjectForKey:@"DOWNLOAD_DIR"];
    [prefs removeObjectForKey:@"FINISH_SOUND"];
    [prefs removeObjectForKey:@"TRY"];
    [prefs removeObjectForKey:@"TIMEOUT"];
    [prefs removeObjectForKey:@"WAIT_SECONDS"];
    [prefs removeObjectForKey:@"NO_CLOBBER"];
    [prefs removeObjectForKey:@"CACHE"];
    [prefs removeObjectForKey:@"WGET_LOG"];
    [prefs removeObjectForKey:@"NO_HOST_DIR"];

    //Update user interface
    [self awakeFromNib];

}

//Close the sheet
- (IBAction)endPrefsWindow:(id)sender {

    [prefsWindow orderOut:sender];
    [NSApp endSheet:prefsWindow returnCode:1];

}


//==================================================================
// (2)PREPARATIONS FOR DOWNLOAD
//==================================================================
//Choose the destination folder

// This is using NSOpenPanel, and works. but no "New Folder" button...
- (IBAction)chooseDir:(id)sender {

    //open the panel
    setdir_panel = [NSOpenPanel openPanel];
    SEL sel = @selector(openPanelDidEnd:returnCode:contextInfo:);
    //slide sheet panel setting
    [setdir_panel beginSheetForDirectory:@"~/Desktop" //NSHomeDirectory()
                                    file:nil
                                   types:nil
                          modalForWindow:window // Connect to the window
                           modalDelegate:self
                          didEndSelector:sel
                             contextInfo:nil];
	[setdir_panel setCanCreateDirectories:YES];//Create a new directory
    [setdir_panel setCanChooseDirectories:YES];//Choose the directories
    [setdir_panel setCanChooseFiles:NO];// Not the files
    [setdir_panel setPrompt:NSLocalizedString(@"Choose Folder", nil)];
    NSLog(@"--Choose Folder");

}
//↓o.k, silde back!
- (void) openPanelDidEnd:(NSOpenPanel *)sheet
              returnCode:(int)returnCode
             contextInfo:(void *)contextInfo {
    
    // if the target is set, set the string value to the textfield,
    // and save it to the UserDefaults.
    // ok, first, prepare the UserDefaluts.
    if(returnCode == NSOKButton){
        NSLog(@"--Set OKButton");
        
        dirname = [[sheet filename] stringByExpandingTildeInPath];

        //if dirname is not nil, set "dirname" to the "downloadDir"
        //save it to "prefs".
        if (dirname != nil) {
            [downloadDir setStringValue:dirname];
            [prefs setObject:[downloadDir stringValue] forKey:@"DOWNLOAD_DIR"];
            [prefs synchronize];
            NSLog(@"--downloadDir synchronized");

        }
        
    }
}

//Read URIs form text file
- (IBAction)readList:(id)sender {
    //open the panel
    readlist_panel = [NSOpenPanel openPanel];
    SEL sel = @selector(chooseFilePanelDidEnd:returnCode:contextInfo:);
    //slide sheet panel setting
    [readlist_panel beginSheetForDirectory:@"~/Desktop" //NSHomeDirectory()
                                      file:nil
                                     types:nil
                            modalForWindow:window
                             modalDelegate:self
                            didEndSelector:sel
                               contextInfo:nil];
    [readlist_panel setCanChooseDirectories:NO];
    [readlist_panel setCanChooseFiles:YES];
    [readlist_panel setPrompt:NSLocalizedString(@"Choose File", nil)];
    NSLog(@"--Choose File");
}
//↓o.k, slide back!
- (void) chooseFilePanelDidEnd:(NSOpenPanel *)sheet
                    returnCode:(int)returnCode
                   contextInfo:(void *)contextInfo {
    
    if (returnCode == NSOKButton) {
        listname = [sheet filename];
        if (listname != nil) {
            [downloadList setStringValue:listname];
            NSLog(@"--File selected");
        }
    }
}

//==================================================================
// (3)DOWNLOAD
//==================================================================
//If "Get" button is pushed...
- (IBAction)download:(id)sender {

    [downloadButton setTitle:NSLocalizedString(@"Loading", nil)];
    [downloadButton setEnabled:NO]; //can't press button when running

    //start NSTask *wget
    wget = [[NSTask alloc] init];

    //use this if wget is not bundled. 
    //[wget setLaunchPath:@"/usr/local/bin/wget"];

    //set the bundle path
    wget_path = [[NSMutableString alloc] init];
    [wget_path    setString:[[NSBundle mainBundle]bundlePath]];
    [wget_path appendString:@"/Contents/Resources/wget"];

    //set the path to wget
    [wget setLaunchPath:wget_path];
    //move to the directory where Wget launches
    [wget setCurrentDirectoryPath:
        [[downloadDir stringValue] stringByExpandingTildeInPath]];

    //O.K, now make up the Wget command.
    args = [[NSMutableArray alloc] initWithCapacity:64];
    
    if ([_recursive state]) {
        [args addObject:@"-r"];

    }
    
    if ([_continue state]) {
        [args addObject:@"-c"];

    }

    if ([_page state]) {
        [args addObject:@"-r"];
        [args addObject:@"-E"];
        [args addObject:@"-k"];
        [args addObject:@"-K"];
        [args addObject:@"-p"];
        
        if ([_spanhosts state]) {
            [args addObject:@"-H"];
        }

    }
    
    if ([_only state]) {
        [args addObject:@"-r"];

        if ([_spanhosts state]) {
            [args addObject:@"-H"];
        }
        
        [args addObject:@"-A"];
        [args addObject:[filetype stringValue]];
        
    }

    if ([_cache state]) {
        [args addObject:@"--cache=on"];
        
    } else {
        [args addObject:@"--cache=off"];

    }

    if ([_no_clobber state]) {
        [args addObject:@"-nc"];
    }

    if ([_no_directory state]) {
        [args addObject:@"-nd"];
        
    }
    
    if ([_no_host_dir state]) {
        [args addObject:@"-nH"];
        
    }

    [args addObject:@"-t"];
    [args addObject:[_try stringValue]];
    [args addObject:@"-T"];
    [args addObject:[_timeout stringValue]];
    [args addObject:@"-w"];
    [args addObject:[_wait_sec stringValue]];
    
    // set the recusive level and add url to the args
    [args addObject:@"-l"];
    [args addObject:[level stringValue]];
    [args addObject:[url stringValue]];

    // if text file exists, read it.
    [args addObject:@"-i"];
    [args addObject:[downloadList stringValue]];

    // generate wget.log if "wget log" option button is checked
    if ([_wgetlog state]) {
        [args addObject:@"-o"];
        [args addObject:@"wget.log"];
    }
    
    // set args into variable "wget"
    [wget setArguments:args];
    
    [wget launch];//BLAST OFF!

    // start the progressbar animation
    [progressbar setIndeterminate:YES];
    [progressbar setUsesThreadedAnimation:YES];
    [progressbar startAnimation:nil];

    [statusField setStringValue:NSLocalizedString(@"Status:Retrieving...",nil)];

}

//==================================================================
// (4)JUST IN CASE
//==================================================================

//if stop button is pushed...
- (IBAction)stopWget:(id)sender {

    //if wget task is running, terminate it.
    if ([wget isRunning]) {
        [wget terminate];
        [wget release];
        wget = nil;

        [statusField setStringValue:NSLocalizedString(@"Status:Idle",nil)];

    }
}

//==================================================================
// (5)AFTER DOWNLOADING
//==================================================================

//get the pushed button back to normal and ... ring!
- (void)finishedDownload:(NSNotification *)aNotification {

    //Stop the progressbar animation
    [progressbar stopAnimation:nil];
    [progressbar setIndeterminate:YES];

    //Download button
    [downloadButton setTitle:@"Get"];
    [downloadButton setEnabled:YES];

    //Ring the bell and finish
    soundname = [finishSound titleOfSelectedItem];
    sound = [NSSound soundNamed:soundname];// instanciate the sound class
    [sound play];//ring!
    [sound release];//clean up the instance
    [wget release]; //release the memory
    wget = nil;//clean up the pointer

    [statusField setStringValue:NSLocalizedString(@"Status:Idle",nil)];

    //Dock notification
    //Let SimpleWget jump in the doc.
    int j;
    j = [NSApp requestUserAttention:NSCriticalRequest];
    
}


//==================================================================
// (6)QUITTING & CLOSING
//==================================================================
//==================================================================
// What do I wanna do?:
// 1) slide out the alert sheet to choose "OK" or "Cancel"
//    when user attempt to close the window.
// 2) If user choose "OK", then close the window and quit the app.
// 3) There are 2 ways to quit the app.
//      A.cmd+Q   B.cmd+W
// 4) Interface Builder:
//    Don't forget to delegate. In the mainmenu.nib,
//    ctl+drug from "Window" to "SimpleWget instance"
//==================================================================
//Sliding out the alert sheet
- (BOOL)windowShouldClose:(NSWindow *)sender {

    NSBeginAlertSheet(NSLocalizedString(@"No Window, No SimpleWget",nil), //message
                      NSLocalizedString(@"OK", nil),                  //default button
                      NSLocalizedString(@"Cancel", nil),              //cancel button
                      nil,                         //other buttons
                      sender,                      //document window
                      self,                        //modal delegate
                      @selector(didEndShouldCloseSheet:returnCode:contextInfo:),
                      NULL,                        //didDismiss selector
                      sender,                      //context Info
                      NSLocalizedString(@"Click OK button to quit.",nil),
                      nil);                        //palameter to the message strings.
    return NO;}
//↓sliding into the window
- (void)didEndShouldCloseSheet:(NSWindow *)sheet
                    returnCode:(int)returnCode
                   contextInfo:(void *)contextInfo {
    
    if (returnCode == NSAlertDefaultReturn) //if default button(OK) is pushed
    //[(NSWindow *)contextInfo close];//only window close    
    [NSApp terminate:nil];//make application nil, and quit.
    //return YES;
}

//==================================================================
// (7)CONTACT BUTTONS
//==================================================================

- (IBAction)goweb:(id)sender {

    goweb_error = nil;
    visit_web = [[NSAppleScript alloc]
           initWithSource:@"open location \"http://jamlog.podzone.org\""];

    [visit_web executeAndReturnError:&goweb_error];
}

- (IBAction)mailto:(id)sender {
    
    mailto_error = nil;
    contact = [[NSAppleScript alloc]
          initWithSource:@"open location \"mailto:kaz6120@gmail.com?subject=SimpleWget:Feedback\""];

    [contact executeAndReturnError:&mailto_error];
}


@end

//==================================================================
// INFORMATION
//==================================================================
//
//======================================================
// Coded by      : Kazufumi Tomori
// License       : GPL
// Last Modified : 2009-04-29
// Copyright (c) 2002-2009 JAM LOG. All Rights Reserved.
//======================================================