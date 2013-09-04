DAContextMenuTableViewController
================================

A UITableViewController subclass with "more" accessory view, that looks and behaves similarly to the one in the native mail app.

![Alt text](DAContextMenuTableViewController.gif)

I know there is a willTransitionToState: method where I could create a custom accessoryView with "More" button. 
But theres is no width for Delete button (which may vary for different languages) and no animation duration, so custom editing view seemed a better sollution for me.


Installation
==============

CocoaPods
--------------
Install CocoaPods if necessary:

    $ [sudo] gem install cocoapods
    $ pod setup

Change to the directory of your Xcode project:

    $ cd /path/to/MyProject
    $ touch Podfile
    $ edit Podfile

Edit your Podfile and add DAContextMenuTableViewController:

    platform :ios, '6.0'
    pod 'DAContextMenuTableViewController'

Install into your Xcode project:

    $ pod install

From now on open your project in Xcode from the .xcworkspace file (instead of the usual project file)

Manual Install
--------------

Just drag and drop DAContextMenuTableViewController folder into your project.

TODO
==============

- <del>bounce animation</del>
- better handling of rotation animation
- iOS7-like look for iOS 6 context menu action sheet
